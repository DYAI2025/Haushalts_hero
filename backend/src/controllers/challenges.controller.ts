// ============================================
// Challenges Controller
// ============================================

import { Response, NextFunction } from 'express';
import challengeService from '../services/challenge.service';
import { AuthRequest } from '../types';
import { AppError } from '../middleware/errorHandler';

export class ChallengesController {
  /**
   * GET /challenges
   * Get challenge history
   */
  async getChallenges(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      if (!req.user) {
        throw new AppError(401, 'UNAUTHORIZED', 'Not authenticated');
      }

      const limit = req.query.limit ? parseInt(req.query.limit as string, 10) : 100;
      const offset = req.query.offset ? parseInt(req.query.offset as string, 10) : 0;
      const category = req.query.category as string | undefined;

      const challenges = await challengeService.getChallenges(req.user.userId, {
        limit,
        offset,
        category,
      });

      const total = await challengeService.getChallengesCount(req.user.userId, category);

      res.status(200).json({
        data: challenges,
        pagination: {
          total,
          limit,
          offset,
          hasMore: offset + challenges.length < total,
        },
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /challenges
   * Create new challenge
   */
  async createChallenge(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      if (!req.user) {
        throw new AppError(401, 'UNAUTHORIZED', 'Not authenticated');
      }

      const challenge = await challengeService.createChallenge(req.user.userId, req.body);

      res.status(201).json(challenge);
    } catch (error) {
      next(error);
    }
  }

  /**
   * GET /challenges/:id
   * Get challenge by ID
   */
  async getChallengeById(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      if (!req.user) {
        throw new AppError(401, 'UNAUTHORIZED', 'Not authenticated');
      }

      const challenge = await challengeService.getChallengeById(
        req.user.userId,
        req.params.id
      );

      res.status(200).json(challenge);
    } catch (error) {
      next(error);
    }
  }

  /**
   * DELETE /challenges/:id
   * Delete challenge
   */
  async deleteChallenge(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      if (!req.user) {
        throw new AppError(401, 'UNAUTHORIZED', 'Not authenticated');
      }

      await challengeService.deleteChallenge(req.user.userId, req.params.id);

      res.status(200).json({
        message: 'Challenge deleted successfully',
      });
    } catch (error) {
      next(error);
    }
  }
}

export default new ChallengesController();
