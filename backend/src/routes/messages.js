const express = require('express');
const router = express.Router();
const { authMiddleware, checkMessageQuota } = require('../middleware/auth');
const { checkAttachmentPermission } = require('../middleware/chatAttachmentControl');
const messageController = require('../controllers/messageController');
const upload = require('../middleware/upload');

// Conversation routes
router.get('/conversations', authMiddleware, messageController.getConversations);
router.get('/conversations/:id', authMiddleware, messageController.getConversation);
router.get('/conversations/:id/messages', authMiddleware, messageController.getConversationMessages);
router.delete('/conversations/:id/messages', authMiddleware, messageController.deleteConversationMessages);

// Message routes
router.post('/', authMiddleware, checkMessageQuota, messageController.sendMessage);
router.post('/send', authMiddleware, checkMessageQuota, messageController.sendMessage);
router.put('/:id/read', authMiddleware, messageController.markAsRead);
router.patch('/:id/read', authMiddleware, messageController.markAsRead);
router.delete('/:id', authMiddleware, messageController.deleteMessage);

// Attachment upload (Premium+ only for PDFs/files)
router.post(
  '/upload', 
  authMiddleware, 
  checkAttachmentPermission, 
  upload.uploadAny.single('file'), 
  messageController.uploadAttachment
);

// Utility routes
router.get('/unread/count', authMiddleware, messageController.getUnreadCount);
router.get('/search', authMiddleware, messageController.searchMessages);

module.exports = router;
