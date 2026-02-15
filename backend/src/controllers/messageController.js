const db = require('../database');
const logger = require('../utils/logger');
const s3Service = require('../services/s3Service');
const quotaService = require('../services/quotaService');

const resolveCoachRecordByUserId = async (userId) => {
  const result = await db.query('SELECT id FROM coaches WHERE user_id = $1', [userId]);
  return result.rows[0] || null;
};

/**
 * Message Controller
 * Handles all messaging operations including conversations, messages, and attachments
 */

/**
 * Get all conversations for a user
 */
exports.getConversations = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { limit = 20, offset = 0 } = req.query;

    const result = await db.query(
      `SELECT 
        c.id,
        c.user_id as "userId",
        cu.id as "coachId",
        c.created_at as "createdAt",
        c.updated_at as "updatedAt",
        c.last_message_at as "lastMessageAt",
        c.last_message_preview as "lastMessageContent",
        CASE
          WHEN u.id = $1 THEN c.unread_count_user
          ELSE c.unread_count_coach
        END as "unreadCount",
        CASE
          WHEN u.id = $1 THEN cu.id
          ELSE u.id
        END as "otherUserId",
        CASE
          WHEN u.id = $1 THEN cu.full_name
          ELSE u.full_name
        END as "otherUserName",
        CASE
          WHEN u.id = $1 THEN cu.profile_picture_url
          ELSE u.profile_picture_url
        END as "otherUserAvatar",
        CASE
          WHEN u.id = $1 THEN cu.role
          ELSE u.role
        END as "otherUserRole"
       FROM conversations c
       JOIN users u ON c.user_id = u.id
       JOIN coaches ch ON c.coach_id = ch.id
       JOIN users cu ON ch.user_id = cu.id
      WHERE u.id = $1 OR cu.id = $1
       ORDER BY c.last_message_at DESC NULLS LAST, c.created_at DESC
       LIMIT $2 OFFSET $3`,
      [userId, limit, offset]
    );

    res.json({
      success: true,
      conversations: result.rows,
      total: result.rows.length
    });

  } catch (error) {
    logger.error('Get conversations error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get conversations'
    });
  }
};

/**
 * Get a single conversation (metadata)
 */
exports.getConversation = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id: conversationId } = req.params;

    const result = await db.query(
      `SELECT 
        c.id,
        c.user_id as "userId",
        cu.id as "coachId",
        c.created_at as "createdAt",
        c.updated_at as "updatedAt",
        c.last_message_at as "lastMessageAt",
        c.last_message_preview as "lastMessageContent",
        CASE
          WHEN u.id = $2 THEN c.unread_count_user
          ELSE c.unread_count_coach
        END as "unreadCount"
       FROM conversations c
       JOIN users u ON c.user_id = u.id
       JOIN coaches ch ON c.coach_id = ch.id
       JOIN users cu ON ch.user_id = cu.id
       WHERE c.id = $1 AND (u.id = $2 OR cu.id = $2)
       LIMIT 1`,
      [conversationId, userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Conversation not found'
      });
    }

    res.json({
      success: true,
      conversation: result.rows[0]
    });
  } catch (error) {
    logger.error('Get conversation error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get conversation'
    });
  }
};

/**
 * Get messages for a specific conversation
 */
exports.getConversationMessages = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id: conversationId } = req.params;
    const { limit = 50, offset = 0, before } = req.query;

    // Verify user is part of conversation
    const conversationCheck = await db.query(
      `SELECT c.id
       FROM conversations c
       JOIN coaches ch ON c.coach_id = ch.id
       WHERE c.id = $1 AND (c.user_id = $2 OR ch.user_id = $2)`,
      [conversationId, userId]
    );

    if (conversationCheck.rows.length === 0) {
      return res.status(403).json({
        success: false,
        message: 'Access denied to this conversation'
      });
    }

    let query = `
      SELECT 
        m.id,
        m.conversation_id,
        m.sender_id,
        m.receiver_id,
        m.content,
        m.message_type,
        m.attachment_url,
        m.attachment_type,
        m.attachment_name,
        m.is_read,
        m.read_at,
        m.created_at,
        u.full_name as sender_name,
        u.profile_picture_url as sender_avatar
      FROM messages m
      JOIN users u ON m.sender_id = u.id
      WHERE m.conversation_id = $1
    `;

    const params = [conversationId];
    let paramCount = 2;

    // Pagination with before (cursor-based)
    if (before) {
      query += ` AND m.created_at < (SELECT created_at FROM messages WHERE id = $${paramCount})`;
      params.push(before);
      paramCount++;
    }

    query += ` ORDER BY m.created_at DESC LIMIT $${paramCount} OFFSET $${paramCount + 1}`;
    params.push(limit, offset);

    const result = await db.query(query, params);

    res.json({
      success: true,
      messages: result.rows.reverse(), // Return in chronological order
      total: result.rows.length
    });

  } catch (error) {
    logger.error('Get conversation messages error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get messages'
    });
  }
};

/**
 * Send a message
 */
exports.sendMessage = async (req, res) => {
  const client = await db.pool.connect();
  
  try {
    const userId = req.user.userId;
    const { 
      conversationId, 
      recipientId, 
      content, 
      messageType = 'text',
      attachmentUrl,
      attachmentType,
      attachmentName
    } = req.body;

    await client.query('BEGIN');

    let finalConversationId = conversationId;

    // Create conversation if it doesn't exist
    if (!conversationId && recipientId) {
      // Check if conversation already exists
      // Determine who is user and who is coach
      const userRoles = await client.query(
        `SELECT id, role FROM users WHERE id IN ($1, $2)`,
        [userId, recipientId]
      );

      const currentUser = userRoles.rows.find(u => u.id === userId);
      const recipient = userRoles.rows.find(u => u.id === recipientId);

      if (!currentUser || !recipient) {
        throw new Error('Invalid sender or recipient');
      }

      let coachUserId = null;
      let conversationUserId = null;
      if (currentUser.role === 'coach') {
        coachUserId = currentUser.id;
        conversationUserId = recipient.id;
      } else if (recipient.role === 'coach') {
        coachUserId = recipient.id;
        conversationUserId = currentUser.id;
      } else {
        throw new Error('Conversation requires a coach participant');
      }

      const coachRecord = await resolveCoachRecordByUserId(coachUserId);
      if (!coachRecord) {
        throw new Error('Coach record not found');
      }

      const existingConv = await client.query(
        `SELECT id FROM conversations 
         WHERE user_id = $1 AND coach_id = $2`,
        [conversationUserId, coachRecord.id]
      );

      if (existingConv.rows.length > 0) {
        finalConversationId = existingConv.rows[0].id;
      } else {
        const newConv = await client.query(
          `INSERT INTO conversations (user_id, coach_id)
           VALUES ($1, $2)
           RETURNING id`,
          [conversationUserId, coachRecord.id]
        );

        finalConversationId = newConv.rows[0].id;
      }
    }

    if (!finalConversationId) {
      throw new Error('Conversation ID is required');
    }

    const conversationResult = await client.query(
      `SELECT c.id, c.user_id, c.coach_id, ch.user_id as coach_user_id
       FROM conversations c
       JOIN coaches ch ON c.coach_id = ch.id
       WHERE c.id = $1`,
      [finalConversationId]
    );

    if (conversationResult.rows.length === 0) {
      throw new Error('Conversation not found');
    }

    const conversation = conversationResult.rows[0];
    const receiverId = conversation.user_id === userId
      ? conversation.coach_user_id
      : conversation.user_id;

    // Insert message
    const messageResult = await client.query(
      `INSERT INTO messages (
        conversation_id, 
        sender_id,
        receiver_id,
        content, 
        message_type,
        attachment_url,
        attachment_type,
        attachment_name
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
      RETURNING *`,
      [finalConversationId, userId, receiverId, content, messageType, attachmentUrl, attachmentType, attachmentName]
    );

    const message = messageResult.rows[0];

    // Update conversation last message
    const contentPreview = content 
      ? content.substring(0, 100) 
      : (messageType === 'image' ? '📷 Image' : '📎 Attachment');

    const unreadField = conversation.user_id === userId
      ? 'unread_count_coach'
      : 'unread_count_user';
    await client.query(
      `UPDATE conversations
       SET last_message_at = NOW(),
           last_message_preview = $1,
           ${unreadField} = ${unreadField} + 1
       WHERE id = $2`,
      [contentPreview, finalConversationId]
    );

    // Increment quota usage
    await quotaService.incrementQuota(userId, 'messages');

    await client.query('COMMIT');

    // Get sender info for socket emission
    const senderInfo = await db.query(
      `SELECT id, full_name, profile_picture_url FROM users WHERE id = $1`,
      [userId]
    );

    const messageWithSender = {
      ...message,
      sender_name: senderInfo.rows[0].full_name,
      sender_avatar: senderInfo.rows[0].profile_picture_url
    };

    res.json({
      success: true,
      message: messageWithSender,
      conversationId: finalConversationId
    });

  } catch (error) {
    await client.query('ROLLBACK');
    logger.error('Send message error:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to send message'
    });
  } finally {
    client.release();
  }
};

/**
 * Mark messages as read
 */
exports.markAsRead = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id: conversationId } = req.params;

    // Verify user is part of conversation
    const conversation = await db.query(
      `SELECT c.user_id, ch.user_id as coach_user_id
       FROM conversations c
       JOIN coaches ch ON c.coach_id = ch.id
       WHERE c.id = $1`,
      [conversationId]
    );

    if (conversation.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Conversation not found'
      });
    }

    const isUser = conversation.rows[0].user_id === userId;
    const isCoach = conversation.rows[0].coach_user_id === userId;

    if (!isUser && !isCoach) {
      return res.status(403).json({
        success: false,
        message: 'Access denied'
      });
    }

    // Mark all unread messages as read
    await db.query(
      `UPDATE messages
       SET read_at = NOW(),
           is_read = TRUE
       WHERE conversation_id = $1 
       AND sender_id != $2 
       AND read_at IS NULL`,
      [conversationId, userId]
    );

    // Reset unread count
    await db.query(
      `UPDATE conversations
       SET ${isUser ? 'unread_count_user' : 'unread_count_coach'} = 0
       WHERE id = $1`,
      [conversationId]
    );

    res.json({
      success: true,
      message: 'Messages marked as read'
    });

  } catch (error) {
    logger.error('Mark as read error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to mark messages as read'
    });
  }
};

/**
 * Upload attachment (images, PDFs for Premium+)
 */
exports.uploadAttachment = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { file } = req;

    if (!file) {
      return res.status(400).json({
        success: false,
        message: 'No file provided'
      });
    }

    // Upload to S3
    const uploadResult = await s3Service.uploadFile(
      file.buffer,
      `messages/${userId}/${Date.now()}_${file.originalname}`,
      file.mimetype
    );

    res.json({
      success: true,
      attachment: {
        url: uploadResult.url,
        type: file.mimetype.startsWith('image/') ? 'image' : 'file',
        name: file.originalname,
        size: file.size
      }
    });

  } catch (error) {
    logger.error('Upload attachment error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to upload attachment'
    });
  }
};

/**
 * Delete a message (sender only, within 5 minutes)
 */
exports.deleteMessage = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id: messageId } = req.params;

    // Check if message exists and user is sender
    const message = await db.query(
      `SELECT id, sender_id, created_at FROM messages 
       WHERE id = $1 AND sender_id = $2`,
      [messageId, userId]
    );

    if (message.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Message not found or access denied'
      });
    }

    // Check if message is less than 5 minutes old
    const messageAge = Date.now() - new Date(message.rows[0].created_at).getTime();
    const fiveMinutes = 5 * 60 * 1000;

    if (messageAge > fiveMinutes) {
      return res.status(400).json({
        success: false,
        message: 'Messages can only be deleted within 5 minutes of sending'
      });
    }

    // Soft delete (mark as deleted)
    await db.query(
      `UPDATE messages 
       SET content = '[Message deleted]',
           message_type = 'deleted',
           attachment_url = NULL
       WHERE id = $1`,
      [messageId]
    );

    res.json({
      success: true,
      message: 'Message deleted'
    });

  } catch (error) {
    logger.error('Delete message error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete message'
    });
  }
};

/**
 * Delete all messages in a conversation (participant only)
 */
exports.deleteConversationMessages = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { id: conversationId } = req.params;

    const conversation = await db.query(
      `SELECT c.id
       FROM conversations c
       JOIN coaches ch ON c.coach_id = ch.id
       WHERE c.id = $1 AND (c.user_id = $2 OR ch.user_id = $2)`,
      [conversationId, userId]
    );

    if (conversation.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Conversation not found or access denied'
      });
    }

    await db.query(
      'DELETE FROM messages WHERE conversation_id = $1',
      [conversationId]
    );

    await db.query(
      `UPDATE conversations
       SET last_message_preview = NULL,
           last_message_at = NULL,
           unread_count_user = 0,
           unread_count_coach = 0,
           updated_at = NOW()
       WHERE id = $1`,
      [conversationId]
    );

    res.json({
      success: true,
      message: 'Conversation cleared'
    });
  } catch (error) {
    logger.error('Delete conversation messages error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to clear conversation'
    });
  }
};

/**
 * Get unread message count
 */
exports.getUnreadCount = async (req, res) => {
  try {
    const userId = req.user.userId;

    const result = await db.query(
      `SELECT 
        SUM(
          CASE
            WHEN c.user_id = $1 THEN c.unread_count_user
            ELSE c.unread_count_coach
          END
        ) as total_unread
       FROM conversations c
       JOIN coaches ch ON c.coach_id = ch.id
       WHERE c.user_id = $1 OR ch.user_id = $1`,
      [userId]
    );

    res.json({
      success: true,
      unreadCount: parseInt(result.rows[0].total_unread) || 0
    });

  } catch (error) {
    logger.error('Get unread count error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get unread count'
    });
  }
};

/**
 * Search messages
 */
exports.searchMessages = async (req, res) => {
  try {
    const userId = req.user.userId;
    const { query, conversationId } = req.query;

    if (!query || query.length < 2) {
      return res.status(400).json({
        success: false,
        message: 'Search query must be at least 2 characters'
      });
    }

    let sqlQuery = `
      SELECT 
        m.id,
        m.conversation_id,
        m.content,
        m.created_at,
        u.full_name as sender_name,
        c.last_message_preview
      FROM messages m
      JOIN conversations c ON m.conversation_id = c.id
      JOIN coaches ch ON c.coach_id = ch.id
      JOIN users u ON m.sender_id = u.id
      WHERE (c.user_id = $1 OR ch.user_id = $1)
      AND m.content ILIKE $2
    `;

    const params = [userId, `%${query}%`];

    if (conversationId) {
      sqlQuery += ` AND m.conversation_id = $3`;
      params.push(conversationId);
    }

    sqlQuery += ` ORDER BY m.created_at DESC LIMIT 50`;

    const result = await db.query(sqlQuery, params);

    res.json({
      success: true,
      results: result.rows,
      total: result.rows.length
    });

  } catch (error) {
    logger.error('Search messages error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to search messages'
    });
  }
};

module.exports = exports;
