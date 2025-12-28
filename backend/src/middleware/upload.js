const multer = require('multer');
const path = require('path');
const logger = require('../utils/logger');

// File size limits
const MAX_FILE_SIZE = parseInt(process.env.MAX_FILE_SIZE) || 10 * 1024 * 1024; // 10MB

// Allowed file types
const ALLOWED_IMAGE_TYPES = (process.env.ALLOWED_IMAGE_TYPES || 'image/jpeg,image/png,image/jpg').split(',');
const ALLOWED_VIDEO_TYPES = (process.env.ALLOWED_VIDEO_TYPES || 'video/mp4,video/quicktime').split(',');

// Configure multer for memory storage (for S3 upload)
const storage = multer.memoryStorage();

/**
 * File filter function
 */
const fileFilter = (allowedTypes) => {
  return (req, file, cb) => {
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error(`Invalid file type. Allowed types: ${allowedTypes.join(', ')}`), false);
    }
  };
};

/**
 * Image upload middleware
 */
exports.uploadImage = multer({
  storage,
  limits: { fileSize: MAX_FILE_SIZE },
  fileFilter: fileFilter(ALLOWED_IMAGE_TYPES)
});

/**
 * Video upload middleware
 */
exports.uploadVideo = multer({
  storage,
  limits: { fileSize: MAX_FILE_SIZE * 5 }, // 50MB for videos
  fileFilter: fileFilter(ALLOWED_VIDEO_TYPES)
});

/**
 * Any file upload middleware
 */
exports.uploadAny = multer({
  storage,
  limits: { fileSize: MAX_FILE_SIZE }
});

/**
 * Multiple images upload
 */
exports.uploadMultipleImages = multer({
  storage,
  limits: { fileSize: MAX_FILE_SIZE },
  fileFilter: fileFilter(ALLOWED_IMAGE_TYPES)
}).array('images', 10); // Max 10 images

/**
 * Single image upload
 */
exports.uploadSingleImage = multer({
  storage,
  limits: { fileSize: MAX_FILE_SIZE },
  fileFilter: fileFilter(ALLOWED_IMAGE_TYPES)
}).single('image');

/**
 * Profile photo upload
 */
exports.uploadProfilePhoto = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB for profile photos
  fileFilter: fileFilter(ALLOWED_IMAGE_TYPES)
}).single('photo');

/**
 * Handle multer errors
 */
exports.handleUploadError = (err, req, res, next) => {
  if (err instanceof multer.MulterError) {
    if (err.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({
        success: false,
        message: 'File too large',
        maxSize: MAX_FILE_SIZE
      });
    }
    
    return res.status(400).json({
      success: false,
      message: err.message
    });
  }
  
  if (err) {
    logger.error('Upload error:', err);
    return res.status(400).json({
      success: false,
      message: err.message || 'Upload failed'
    });
  }
  
  next();
};
