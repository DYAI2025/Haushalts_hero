// ============================================
// Content Controller
// ============================================

import { Request, Response, NextFunction } from 'express';
import contentService from '../services/content.service';

export class ContentController {
  /**
   * GET /content/coaching-tips
   * Get coaching tips
   */
  async getCoachingTips(req: Request, res: Response, next: NextFunction) {
    try {
      const context = req.query.context as string | undefined;

      const tips = await contentService.getCoachingTips(context);

      res.status(200).json(tips);
    } catch (error) {
      next(error);
    }
  }

  /**
   * GET /content/micro-learning
   * Get micro-learning modules
   */
  async getMicroLearning(req: Request, res: Response, next: NextFunction) {
    try {
      const modules = await contentService.getMicroLearning();

      res.status(200).json(modules);
    } catch (error) {
      next(error);
    }
  }

  /**
   * GET /content/seasons/active
   * Get active season
   */
  async getActiveSeason(req: Request, res: Response, next: NextFunction) {
    try {
      const season = await contentService.getActiveSeason();

      if (!season) {
        return res.status(404).json({
          error: {
            code: 'NOT_FOUND',
            message: 'No active season found',
          },
        });
      }

      res.status(200).json(season);
    } catch (error) {
      next(error);
    }
  }

  /**
   * GET /content/seasons
   * Get all seasons
   */
  async getSeasons(req: Request, res: Response, next: NextFunction) {
    try {
      const seasons = await contentService.getSeasons();

      res.status(200).json(seasons);
    } catch (error) {
      next(error);
    }
  }
}

export default new ContentController();
