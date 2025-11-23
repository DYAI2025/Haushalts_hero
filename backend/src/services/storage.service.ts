// ============================================
// Storage Service
// ============================================

import fs from 'fs/promises';
import path from 'path';
import { v4 as uuidv4 } from 'uuid';
import prisma from '../config/database';
import config from '../config';
import { AppError } from '../middleware/errorHandler';
import { PhotoResponse } from '../types';

export class StorageService {
  private uploadDir: string;

  constructor() {
    this.uploadDir = config.upload.dir;
    this.ensureUploadDir();
  }

  /**
   * Ensure upload directory exists
   */
  private async ensureUploadDir(): Promise<void> {
    try {
      await fs.access(this.uploadDir);
    } catch {
      await fs.mkdir(this.uploadDir, { recursive: true });
    }
  }

  /**
   * Upload photo
   */
  async uploadPhoto(
    userId: string,
    file: Express.Multer.File
  ): Promise<PhotoResponse> {
    // Validate file type
    if (!config.upload.allowedTypes.includes(file.mimetype)) {
      throw new AppError(400, 'VALIDATION_ERROR', 'Invalid file type');
    }

    // Validate file size
    if (file.size > config.upload.maxSize) {
      throw new AppError(400, 'VALIDATION_ERROR', 'File too large');
    }

    // Generate unique filename
    const ext = path.extname(file.originalname);
    const filename = `${uuidv4()}${ext}`;
    const filePath = path.join(this.uploadDir, filename);

    // Save file
    await fs.writeFile(filePath, file.buffer);

    // Create photo record in database
    const photo = await prisma.photo.create({
      data: {
        id: uuidv4(),
        userId,
        url: `/photos/${filename}`,
        path: filePath,
        size: file.size,
        mimeType: file.mimetype,
      },
    });

    return photo;
  }

  /**
   * Get photo by ID
   */
  async getPhoto(userId: string, photoId: string): Promise<PhotoResponse> {
    const photo = await prisma.photo.findFirst({
      where: {
        id: photoId,
        userId,
      },
    });

    if (!photo) {
      throw new AppError(404, 'NOT_FOUND', 'Photo not found');
    }

    return photo;
  }

  /**
   * Get photo file
   */
  async getPhotoFile(
    userId: string,
    photoId: string
  ): Promise<{ buffer: Buffer; mimeType: string }> {
    const photo = await this.getPhoto(userId, photoId);

    try {
      const buffer = await fs.readFile(photo.path);
      return { buffer, mimeType: photo.mimeType };
    } catch (error) {
      throw new AppError(404, 'NOT_FOUND', 'Photo file not found');
    }
  }

  /**
   * Delete photo
   */
  async deletePhoto(userId: string, photoId: string): Promise<void> {
    const photo = await prisma.photo.findFirst({
      where: {
        id: photoId,
        userId,
      },
    });

    if (!photo) {
      throw new AppError(404, 'NOT_FOUND', 'Photo not found');
    }

    // Delete file
    try {
      await fs.unlink(photo.path);
    } catch (error) {
      console.error('Failed to delete file:', error);
      // Continue to delete database record even if file deletion fails
    }

    // Delete database record
    await prisma.photo.delete({
      where: { id: photoId },
    });
  }

  /**
   * Get user's photo count
   */
  async getPhotoCount(userId: string): Promise<number> {
    return await prisma.photo.count({
      where: { userId },
    });
  }

  /**
   * Get total storage used by user (in bytes)
   */
  async getStorageUsed(userId: string): Promise<number> {
    const result = await prisma.photo.aggregate({
      where: { userId },
      _sum: {
        size: true,
      },
    });

    return result._sum.size || 0;
  }

  /**
   * Clean up old photos (older than 90 days)
   */
  async cleanupOldPhotos(userId?: string): Promise<number> {
    const ninetyDaysAgo = new Date();
    ninetyDaysAgo.setDate(ninetyDaysAgo.getDate() - 90);

    const oldPhotos = await prisma.photo.findMany({
      where: {
        ...(userId && { userId }),
        createdAt: {
          lt: ninetyDaysAgo,
        },
      },
    });

    // Delete files
    await Promise.all(
      oldPhotos.map(async (photo) => {
        try {
          await fs.unlink(photo.path);
        } catch (error) {
          console.error(`Failed to delete file ${photo.path}:`, error);
        }
      })
    );

    // Delete database records
    const result = await prisma.photo.deleteMany({
      where: {
        id: {
          in: oldPhotos.map((p) => p.id),
        },
      },
    });

    return result.count;
  }
}

export default new StorageService();
