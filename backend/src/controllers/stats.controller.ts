// ============================================
// Stats Controller
// ============================================

import { Response, NextFunction } from 'express';
import statsService from '../services/stats.service';
import { AuthRequest } from '../types';
import { AppError } from '../middleware/errorHandler';

export class StatsController {
  /**
   * GET /stats/weekly
   * Get weekly stats
   */
  async getWeeklyStats(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      if (!req.user) {
        throw new AppError(401, 'UNAUTHORIZED', 'Not authenticated');
      }

      const weekStart = req.query.weekStart
        ? new Date(req.query.weekStart as string)
        : undefined;

      const stats = await statsService.getWeeklyStats(req.user.userId, weekStart);

      if (!stats) {
        // Calculate stats from challenges if they don't exist
        const calculatedStats = await statsService.calculateStatsFromChallenges(
          req.user.userId
        );
        return res.status(200).json(calculatedStats);
      }

      res.status(200).json(stats);
    } catch (error) {
      next(error);
    }
  }

  /**
   * GET /stats/monthly
   * Get monthly stats
   */
  async getMonthlyStats(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      if (!req.user) {
        throw new AppError(401, 'UNAUTHORIZED', 'Not authenticated');
      }

      const month = req.query.month as string | undefined;

      const stats = await statsService.getMonthlyStats(req.user.userId, month);

      res.status(200).json(stats);
    } catch (error) {
      next(error);
    }
  }

  /**
   * PUT /stats/weekly
   * Update weekly stats
   */
  async updateWeeklyStats(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      if (!req.user) {
        throw new AppError(401, 'UNAUTHORIZED', 'Not authenticated');
      }

      const stats = await statsService.updateWeeklyStats(req.user.userId, req.body);

      res.status(200).json(stats);
    } catch (error) {
      next(error);
    }
  }
}

export default new StatsController();
