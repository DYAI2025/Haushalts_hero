// ============================================
// Quests Controller
// ============================================

import { Response, NextFunction } from 'express';
import questService from '../services/quest.service';
import { AuthRequest } from '../types';
import { AppError } from '../middleware/errorHandler';

export class QuestsController {
  /**
   * GET /quests/active
   * Get active quests for current week
   */
  async getActiveQuests(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      if (!req.user) {
        throw new AppError(401, 'UNAUTHORIZED', 'Not authenticated');
      }

      const quests = await questService.getActiveQuests(req.user.userId);

      res.status(200).json(quests);
    } catch (error) {
      next(error);
    }
  }

  /**
   * PATCH /quests/:id/progress
   * Update quest progress
   */
  async updateProgress(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      if (!req.user) {
        throw new AppError(401, 'UNAUTHORIZED', 'Not authenticated');
      }

      const { increment } = req.body;
      const questId = req.params.id;

      const quest = await questService.updateQuestProgress(
        req.user.userId,
        questId,
        increment
      );

      res.status(200).json(quest);
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /quests/reset
   * Reset quests for new week
   */
  async resetQuests(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      if (!req.user) {
        throw new AppError(401, 'UNAUTHORIZED', 'Not authenticated');
      }

      const quests = await questService.resetQuests(req.user.userId);

      res.status(200).json(quests);
    } catch (error) {
      next(error);
    }
  }
}

export default new QuestsController();
