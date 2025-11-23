// ============================================
// Goals Controller
// ============================================

import { Response, NextFunction } from 'express';
import goalService from '../services/goal.service';
import { AuthRequest } from '../types';
import { AppError } from '../middleware/errorHandler';

export class GoalsController {
  /**
   * GET /goals/active
   * Get active goals for current week
   */
  async getActiveGoals(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      if (!req.user) {
        throw new AppError(401, 'UNAUTHORIZED', 'Not authenticated');
      }

      const goals = await goalService.getActiveGoals(req.user.userId);

      res.status(200).json(goals);
    } catch (error) {
      next(error);
    }
  }

  /**
   * PATCH /goals/progress
   * Update goal progress
   */
  async updateProgress(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      if (!req.user) {
        throw new AppError(401, 'UNAUTHORIZED', 'Not authenticated');
      }

      const { points } = req.body;

      const goal = await goalService.updateGoalProgress(req.user.userId, points);

      res.status(200).json(goal);
    } catch (error) {
      next(error);
    }
  }
}

export default new GoalsController();
