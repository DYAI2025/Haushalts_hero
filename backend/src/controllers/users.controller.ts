// ============================================
// Users Controller
// ============================================

import { Response, NextFunction } from 'express';
import prisma from '../config/database';
import { AuthRequest } from '../types';
import { AppError } from '../middleware/errorHandler';

export class UsersController {
  /**
   * GET /users/me
   * Get current user with settings
   */
  async getMe(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      if (!req.user) {
        throw new AppError(401, 'UNAUTHORIZED', 'Not authenticated');
      }

      const user = await prisma.user.findUnique({
        where: { id: req.user.userId },
        include: {
          settings: true,
        },
      });

      if (!user) {
        throw new AppError(404, 'NOT_FOUND', 'User not found');
      }

      res.status(200).json({
        id: user.id,
        email: user.email,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
        settings: user.settings,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * PUT /users/me/settings
   * Update user settings
   */
  async updateSettings(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      if (!req.user) {
        throw new AppError(401, 'UNAUTHORIZED', 'Not authenticated');
      }

      const { enableHapticFeedback, enableSoundEffects, showHeatmapByDefault } = req.body;

      // Find or create settings
      let settings = await prisma.userSettings.findUnique({
        where: { userId: req.user.userId },
      });

      if (!settings) {
        // Create default settings if they don't exist
        settings = await prisma.userSettings.create({
          data: {
            userId: req.user.userId,
            enableHapticFeedback: enableHapticFeedback ?? true,
            enableSoundEffects: enableSoundEffects ?? true,
            showHeatmapByDefault: showHeatmapByDefault ?? false,
          },
        });
      } else {
        // Update existing settings
        settings = await prisma.userSettings.update({
          where: { userId: req.user.userId },
          data: {
            ...(enableHapticFeedback !== undefined && { enableHapticFeedback }),
            ...(enableSoundEffects !== undefined && { enableSoundEffects }),
            ...(showHeatmapByDefault !== undefined && { showHeatmapByDefault }),
          },
        });
      }

      res.status(200).json(settings);
    } catch (error) {
      next(error);
    }
  }
}

export default new UsersController();
