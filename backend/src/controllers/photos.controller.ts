// ============================================
// Photos Controller
// ============================================

import { Response, NextFunction } from 'express';
import storageService from '../services/storage.service';
import { AuthRequest } from '../types';
import { AppError } from '../middleware/errorHandler';

export class PhotosController {
  /**
   * POST /photos/upload
   * Upload photo
   */
  async uploadPhoto(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      if (!req.user) {
        throw new AppError(401, 'UNAUTHORIZED', 'Not authenticated');
      }

      if (!req.file) {
        throw new AppError(400, 'VALIDATION_ERROR', 'No file provided');
      }

      const photo = await storageService.uploadPhoto(req.user.userId, req.file);

      res.status(201).json(photo);
    } catch (error) {
      next(error);
    }
  }

  /**
   * GET /photos/:id
   * Get photo by ID (returns photo metadata OR file)
   */
  async getPhoto(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      if (!req.user) {
        throw new AppError(401, 'UNAUTHORIZED', 'Not authenticated');
      }

      const photoId = req.params.id;
      const download = req.query.download === 'true';

      if (download) {
        // Return photo file
        const { buffer, mimeType } = await storageService.getPhotoFile(
          req.user.userId,
          photoId
        );

        res.setHeader('Content-Type', mimeType);
        res.setHeader('Content-Length', buffer.length);
        res.send(buffer);
      } else {
        // Return photo metadata
        const photo = await storageService.getPhoto(req.user.userId, photoId);
        res.status(200).json(photo);
      }
    } catch (error) {
      next(error);
    }
  }

  /**
   * DELETE /photos/:id
   * Delete photo
   */
  async deletePhoto(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      if (!req.user) {
        throw new AppError(401, 'UNAUTHORIZED', 'Not authenticated');
      }

      const photoId = req.params.id;

      await storageService.deletePhoto(req.user.userId, photoId);

      res.status(200).json({
        message: 'Photo deleted successfully',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * GET /photos/stats
   * Get storage statistics
   */
  async getStats(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      if (!req.user) {
        throw new AppError(401, 'UNAUTHORIZED', 'Not authenticated');
      }

      const photoCount = await storageService.getPhotoCount(req.user.userId);
      const storageUsed = await storageService.getStorageUsed(req.user.userId);

      res.status(200).json({
        photoCount,
        storageUsed,
        storageUsedMB: Math.round((storageUsed / 1024 / 1024) * 100) / 100,
      });
    } catch (error) {
      next(error);
    }
  }
}

export default new PhotosController();
