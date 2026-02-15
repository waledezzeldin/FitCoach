const jwt = require('jsonwebtoken');
const db = require('../database');
const logger = require('../utils/logger');
const { incrementMessageCount, canSendMessage } = require('../services/quotaService');

// Store active user connections
const userSockets = new Map();

/**
 * Setup Socket.IO event handlers
 */
exports.setupSocketHandlers = (io) => {
  
  // Socket.IO middleware for authentication
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth.token;
      
      if (!token) {
        return next(new Error('Authentication required'));
      }
      
      // Verify JWT
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      
      // Attach user info to socket
      socket.userId = decoded.userId;
      socket.userRole = decoded.role;
      socket.userTier = decoded.tier;
      
      next();
      
    } catch (error) {
      logger.error('Socket authentication error:', error);
      next(new Error('Authentication failed'));
    }
  });
  
  io.on('connection', (socket) => {
    logger.info(`User connected: ${socket.userId}`);
    
    // Store socket connection
    userSockets.set(socket.userId, socket.id);
    
    // Join user's personal room
    socket.join(`user_${socket.userId}`);
    
    // ============================================
    // MESSAGING EVENTS
    // ============================================
    
    /**
     * Join conversation
     */
    socket.on('join_conversation', async (data) => {
      try {
        const { conversationId } = data;
        
        // Verify user is part of conversation
        const result = await db.query(
          `SELECT * FROM conversations 
           WHERE id = $1 AND (user_id = $2 OR coach_id IN (
             SELECT id FROM coaches WHERE user_id = $2
           ))`,
          [conversationId, socket.userId]
        );
        
        if (result.rows.length === 0) {
          return socket.emit('error', { message: 'Conversation not found' });
        }
        
        socket.join(`conversation_${conversationId}`);
        logger.info(`User ${socket.userId} joined conversation ${conversationId}`);
        
      } catch (error) {
        logger.error('Join conversation error:', error);
        socket.emit('error', { message: 'Failed to join conversation' });
      }
    });
    
    /**
     * Send message
     */
    socket.on('send_message', async (data) => {
      const client = await db.getClient();
      
      try {
        const { conversationId, content, type = 'text', attachmentUrl, attachmentType } = data;
        
        await client.query('BEGIN');
        
        // Check message quota
        const canSend = await canSendMessage(socket.userId);
        
        if (!canSend) {
          socket.emit('quota_exceeded', {
            message: 'Message quota exceeded. Please upgrade your plan.',
            upgradeRequired: true
          });
          await client.query('ROLLBACK');
          return;
        }
        
        // Check if attachment is allowed (Premium+ only)
        if (type !== 'text' && socket.userTier === 'freemium') {
          socket.emit('error', {
            message: 'Attachments are only available for Premium and Smart Premium users',
            upgradeRequired: true
          });
          await client.query('ROLLBACK');
          return;
        }
        
        // Get conversation details
        const convResult = await client.query(
          `SELECT c.*, ch.user_id as coach_user_id
           FROM conversations c
           JOIN coaches ch ON c.coach_id = ch.id
           WHERE c.id = $1`,
          [conversationId]
        );
        
        if (convResult.rows.length === 0) {
          socket.emit('error', { message: 'Conversation not found' });
          await client.query('ROLLBACK');
          return;
        }
        
        const conversation = convResult.rows[0];
        
        // Determine sender and receiver
        const receiverId = conversation.user_id === socket.userId 
          ? conversation.coach_user_id 
          : conversation.user_id;
        
        // Insert message
        const messageResult = await client.query(
          `INSERT INTO messages (
            conversation_id, sender_id, receiver_id, content, message_type, 
            attachment_url, attachment_type
          ) VALUES ($1, $2, $3, $4, $5, $6, $7)
          RETURNING *`,
          [conversationId, socket.userId, receiverId, content, type, attachmentUrl, attachmentType]
        );
        
        const message = messageResult.rows[0];
        
        // Update conversation
        const unreadField = conversation.user_id === socket.userId
          ? 'unread_count_coach'
          : 'unread_count_user';
        await client.query(
          `UPDATE conversations
           SET last_message_preview = $1,
               last_message_at = NOW(),
               ${unreadField} = ${unreadField} + 1
           WHERE id = $2`,
          [content, conversationId]
        );
        
        // Increment message count
        await incrementMessageCount(socket.userId);
        
        await client.query('COMMIT');
        
        const payload = {
          id: message.id,
          conversationId: message.conversation_id,
          senderId: message.sender_id,
          receiverId: message.receiver_id,
          content: message.content,
          type: message.message_type,
          attachmentUrl: message.attachment_url,
          attachmentType: message.attachment_type,
          isRead: false,
          createdAt: new Date(message.created_at).toISOString(),
          readAt: null
        };

        // Emit message to conversation room
        io.to(`conversation_${conversationId}`).emit('new_message', {
          message: payload
        });

        // Flutter socket compatibility
        io.to(`conversation_${conversationId}`).emit('message:new', payload);
        
        // Notify receiver if they're online
        const receiverSocketId = userSockets.get(receiverId);
        if (receiverSocketId) {
          io.to(receiverSocketId).emit('notification', {
            type: 'new_message',
            conversationId,
            senderId: socket.userId,
            content: content.substring(0, 50) + (content.length > 50 ? '...' : '')
          });

          io.to(receiverSocketId).emit('message:new', payload);
        }
        
        logger.info(`Message sent: ${message.id} in conversation ${conversationId}`);
        
      } catch (error) {
        await client.query('ROLLBACK');
        logger.error('Send message error:', error);
        socket.emit('error', { message: 'Failed to send message' });
      } finally {
        client.release();
      }
    });
    
    /**
     * Mark message as read
     */
    socket.on('mark_read', async (data) => {
      try {
        const { messageId } = data;
        
        await db.query(
          `UPDATE messages 
           SET is_read = TRUE, read_at = NOW()
           WHERE id = $1 AND receiver_id = $2`,
          [messageId, socket.userId]
        );
        
        // Notify sender
        const msgResult = await db.query(
          'SELECT sender_id, conversation_id FROM messages WHERE id = $1',
          [messageId]
        );
        
        if (msgResult.rows.length > 0) {
          const { sender_id, conversation_id } = msgResult.rows[0];
          const senderSocketId = userSockets.get(sender_id);
          
          if (senderSocketId) {
            io.to(senderSocketId).emit('message_read', {
              messageId,
              conversationId: conversation_id,
              readAt: new Date()
            });
          }
        }
        
      } catch (error) {
        logger.error('Mark read error:', error);
      }
    });
    
    /**
     * Typing indicator
     */
    socket.on('typing_start', async (data) => {
      try {
        const { conversationId } = data;
        
        socket.to(`conversation_${conversationId}`).emit('user_typing', {
          userId: socket.userId,
          conversationId
        });
        
      } catch (error) {
        logger.error('Typing start error:', error);
      }
    });
    
    socket.on('typing_stop', async (data) => {
      try {
        const { conversationId } = data;
        
        socket.to(`conversation_${conversationId}`).emit('user_stopped_typing', {
          userId: socket.userId,
          conversationId
        });
        
      } catch (error) {
        logger.error('Typing stop error:', error);
      }
    });
    
    // ============================================
    // DISCONNECT
    // ============================================
    
    socket.on('disconnect', () => {
      logger.info(`User disconnected: ${socket.userId}`);
      userSockets.delete(socket.userId);
    });
  });
  
  logger.info('Socket.IO handlers setup complete');
};

// Export userSockets for use in other modules
exports.userSockets = userSockets;
