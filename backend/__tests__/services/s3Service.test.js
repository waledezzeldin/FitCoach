const s3Service = require('../../src/services/s3Service');
const AWS = require('aws-sdk');

// Mock AWS SDK
jest.mock('aws-sdk', () => {
  const mockUpload = jest.fn();
  const mockDeleteObject = jest.fn();
  const mockHeadObject = jest.fn();
  const mockGetSignedUrl = jest.fn();

  return {
    S3: jest.fn(() => ({
      upload: (params) => ({
        promise: mockUpload
      }),
      deleteObject: (params) => ({
        promise: mockDeleteObject
      }),
      headObject: (params) => ({
        promise: mockHeadObject
      }),
      getSignedUrl: mockGetSignedUrl
    })),
    mockUpload,
    mockDeleteObject,
    mockHeadObject,
    mockGetSignedUrl
  };
});

describe('S3Service', () => {
  let mockFile;

  beforeEach(() => {
    jest.clearAllMocks();

    mockFile = {
      originalname: 'test.jpg',
      mimetype: 'image/jpeg',
      buffer: Buffer.from('test file content')
    };
  });

  describe('uploadFile', () => {
    it('should upload file to S3', async () => {
      AWS.mockUpload.mockResolvedValue({
        Location: 'https://bucket.s3.amazonaws.com/general/test.jpg',
        Key: 'general/test.jpg',
        Bucket: 'test-bucket'
      });

      const result = await s3Service.uploadFile(mockFile, 'general');

      expect(result).toEqual({
        url: 'https://bucket.s3.amazonaws.com/general/test.jpg',
        key: 'general/test.jpg',
        bucket: 'test-bucket'
      });
    });

    it('should use default folder if not specified', async () => {
      AWS.mockUpload.mockResolvedValue({
        Location: 'https://bucket.s3.amazonaws.com/general/test.jpg',
        Key: 'general/test.jpg',
        Bucket: 'test-bucket'
      });

      await s3Service.uploadFile(mockFile);

      expect(AWS.mockUpload).toHaveBeenCalled();
    });

    it('should handle upload errors', async () => {
      AWS.mockUpload.mockRejectedValue(new Error('S3 error'));

      await expect(
        s3Service.uploadFile(mockFile)
      ).rejects.toThrow('Failed to upload file');
    });
  });

  describe('uploadFiles', () => {
    it('should upload multiple files', async () => {
      const files = [mockFile, { ...mockFile, originalname: 'test2.jpg' }];

      AWS.mockUpload.mockResolvedValue({
        Location: 'https://bucket.s3.amazonaws.com/test.jpg',
        Key: 'general/test.jpg',
        Bucket: 'test-bucket'
      });

      const results = await s3Service.uploadFiles(files, 'general');

      expect(results).toHaveLength(2);
      expect(AWS.mockUpload).toHaveBeenCalledTimes(2);
    });

    it('should handle upload errors', async () => {
      const files = [mockFile];

      AWS.mockUpload.mockRejectedValue(new Error('S3 error'));

      await expect(
        s3Service.uploadFiles(files)
      ).rejects.toThrow('Failed to upload files');
    });
  });

  describe('deleteFile', () => {
    it('should delete file from S3', async () => {
      AWS.mockDeleteObject.mockResolvedValue({});

      await s3Service.deleteFile('general/test.jpg');

      expect(AWS.mockDeleteObject).toHaveBeenCalled();
    });

    it('should handle delete errors', async () => {
      AWS.mockDeleteObject.mockRejectedValue(new Error('S3 error'));

      await expect(
        s3Service.deleteFile('general/test.jpg')
      ).rejects.toThrow('Failed to delete file');
    });
  });

  describe('getPresignedUrl', () => {
    it('should generate presigned URL', () => {
      const mockUrl = 'https://bucket.s3.amazonaws.com/test.jpg?signature=xyz';
      AWS.mockGetSignedUrl.mockReturnValue(mockUrl);

      const url = s3Service.getPresignedUrl('general/test.jpg');

      expect(url).toBe(mockUrl);
    });

    it('should use default expiry', () => {
      AWS.mockGetSignedUrl.mockReturnValue('https://example.com');

      s3Service.getPresignedUrl('general/test.jpg');

      expect(AWS.mockGetSignedUrl).toHaveBeenCalledWith(
        'getObject',
        expect.objectContaining({
          Expires: 3600
        })
      );
    });

    it('should use custom expiry', () => {
      AWS.mockGetSignedUrl.mockReturnValue('https://example.com');

      s3Service.getPresignedUrl('general/test.jpg', 7200);

      expect(AWS.mockGetSignedUrl).toHaveBeenCalledWith(
        'getObject',
        expect.objectContaining({
          Expires: 7200
        })
      );
    });

    it('should handle errors', () => {
      AWS.mockGetSignedUrl.mockImplementation(() => {
        throw new Error('S3 error');
      });

      expect(() => {
        s3Service.getPresignedUrl('general/test.jpg');
      }).toThrow('Failed to generate presigned URL');
    });
  });

  describe('getFileMetadata', () => {
    it('should get file metadata', async () => {
      const mockMetadata = {
        ContentLength: 1024,
        ContentType: 'image/jpeg',
        LastModified: new Date(),
        ETag: 'abc123'
      };

      AWS.mockHeadObject.mockResolvedValue(mockMetadata);

      const result = await s3Service.getFileMetadata('general/test.jpg');

      expect(result).toEqual({
        size: 1024,
        contentType: 'image/jpeg',
        lastModified: mockMetadata.LastModified,
        etag: 'abc123'
      });
    });

    it('should handle errors', async () => {
      AWS.mockHeadObject.mockRejectedValue(new Error('S3 error'));

      await expect(
        s3Service.getFileMetadata('general/test.jpg')
      ).rejects.toThrow('Failed to get file metadata');
    });
  });
});
