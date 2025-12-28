const AWS = require('aws-sdk');
const { v4: uuidv4 } = require('uuid');
const logger = require('../utils/logger');

// Configure AWS
const s3 = new AWS.S3({
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  region: process.env.AWS_REGION || 'me-south-1'
});

const BUCKET_NAME = process.env.AWS_S3_BUCKET || 'fitcoach-uploads';

/**
 * Upload file to S3
 */
exports.uploadFile = async (file, folder = 'general') => {
  try {
    const fileExtension = file.originalname.split('.').pop();
    const fileName = `${folder}/${uuidv4()}.${fileExtension}`;
    
    const params = {
      Bucket: BUCKET_NAME,
      Key: fileName,
      Body: file.buffer,
      ContentType: file.mimetype,
      ACL: 'public-read'
    };
    
    const result = await s3.upload(params).promise();
    
    logger.info(`File uploaded to S3: ${result.Key}`);
    
    return {
      url: result.Location,
      key: result.Key,
      bucket: result.Bucket
    };
    
  } catch (error) {
    logger.error('S3 upload error:', error);
    throw new Error('Failed to upload file');
  }
};

/**
 * Upload multiple files
 */
exports.uploadFiles = async (files, folder = 'general') => {
  try {
    const uploadPromises = files.map(file => exports.uploadFile(file, folder));
    const results = await Promise.all(uploadPromises);
    return results;
  } catch (error) {
    logger.error('S3 multiple upload error:', error);
    throw new Error('Failed to upload files');
  }
};

/**
 * Delete file from S3
 */
exports.deleteFile = async (key) => {
  try {
    const params = {
      Bucket: BUCKET_NAME,
      Key: key
    };
    
    await s3.deleteObject(params).promise();
    
    logger.info(`File deleted from S3: ${key}`);
    
  } catch (error) {
    logger.error('S3 delete error:', error);
    throw new Error('Failed to delete file');
  }
};

/**
 * Generate presigned URL for temporary access
 */
exports.getPresignedUrl = (key, expiresIn = 3600) => {
  try {
    const params = {
      Bucket: BUCKET_NAME,
      Key: key,
      Expires: expiresIn
    };
    
    const url = s3.getSignedUrl('getObject', params);
    return url;
    
  } catch (error) {
    logger.error('S3 presigned URL error:', error);
    throw new Error('Failed to generate presigned URL');
  }
};

/**
 * Get file metadata
 */
exports.getFileMetadata = async (key) => {
  try {
    const params = {
      Bucket: BUCKET_NAME,
      Key: key
    };
    
    const result = await s3.headObject(params).promise();
    
    return {
      size: result.ContentLength,
      contentType: result.ContentType,
      lastModified: result.LastModified,
      etag: result.ETag
    };
    
  } catch (error) {
    logger.error('S3 get metadata error:', error);
    throw new Error('Failed to get file metadata');
  }
};
