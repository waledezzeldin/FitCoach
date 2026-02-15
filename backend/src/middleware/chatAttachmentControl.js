const logger = require('../utils/logger');

/**
 * Middleware to check if user can send chat attachments
 * Only Premium+ users can send attachments
 * Freemium users: text-only messages
 */
async function checkAttachmentPermission(req, res, next) {
  try {
    const { hasAttachment, attachmentType, attachmentUrl } = req.body;

    // If no attachment, allow
    if (!hasAttachment && !attachmentUrl) {
      return next();
    }

    // Check user's subscription tier
    const userTier = req.user.subscriptionTier || req.user.subscription_tier;

    // Only Premium and Smart Premium can send attachments
    const canSendAttachments = ['premium', 'smart_premium'].includes(userTier);

    if (!canSendAttachments) {
      return res.status(403).json({
        success: false,
        message: 'Attachment feature is only available for Premium subscribers',
        error: 'ATTACHMENT_PREMIUM_REQUIRED',
        upgradeRequired: true,
        feature: 'chat_attachments',
        currentTier: userTier,
        requiredTier: 'premium'
      });
    }

    // Validate attachment type
    const allowedTypes = ['image', 'pdf', 'video'];
    if (hasAttachment && attachmentType && !allowedTypes.includes(attachmentType)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid attachment type',
        allowedTypes
      });
    }

    // User is premium and can send attachments
    next();

  } catch (error) {
    logger.error('Chat attachment permission check error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to check attachment permission'
    });
  }
}

/**
 * Check attachment size limits based on tier
 */
function checkAttachmentSize(req, res, next) {
  const userTier = req.user.subscriptionTier || req.user.subscription_tier;
  const fileSize = req.file ? req.file.size : 0;

  // Size limits in bytes
  const SIZE_LIMITS = {
    premium: 10 * 1024 * 1024, // 10MB
    smart_premium: 50 * 1024 * 1024 // 50MB
  };

  const maxSize = SIZE_LIMITS[userTier] || 0;

  if (fileSize > maxSize) {
    return res.status(413).json({
      success: false,
      message: `File size exceeds limit for ${userTier} tier`,
      maxSize: maxSize,
      fileSize: fileSize,
      maxSizeMB: maxSize / (1024 * 1024)
    });
  }

  next();
}

module.exports = {
  checkAttachmentPermission,
  checkAttachmentSize
};
