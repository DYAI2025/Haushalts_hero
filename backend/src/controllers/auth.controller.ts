// ============================================
// Authentication Controller
// ============================================

import { Request, Response, NextFunction } from 'express';
import authService from '../services/auth.service';
import { AuthRequest } from '../types';

export class AuthController {
  /**
   * POST /auth/register
   * Register new user
   */
  async register(req: Request, res: Response, next: NextFunction) {
    try {
      const { email, password } = req.body;

      const result = await authService.register(email, password);

      res.status(201).json({
        user: result.user,
        accessToken: result.tokens.accessToken,
        refreshToken: result.tokens.refreshToken,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /auth/login
   * Login user
   */
  async login(req: Request, res: Response, next: NextFunction) {
    try {
      const { email, password } = req.body;

      const result = await authService.login(email, password);

      res.status(200).json({
        user: result.user,
        accessToken: result.tokens.accessToken,
        refreshToken: result.tokens.refreshToken,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /auth/refresh
   * Refresh access token
   */
  async refresh(req: Request, res: Response, next: NextFunction) {
    try {
      const { refreshToken } = req.body;

      const tokens = await authService.refresh(refreshToken);

      res.status(200).json({
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * POST /auth/logout
   * Logout user (revoke refresh token)
   */
  async logout(req: Request, res: Response, next: NextFunction) {
    try {
      const { refreshToken } = req.body;

      await authService.logout(refreshToken);

      res.status(200).json({
        message: 'Logged out successfully',
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * GET /auth/me
   * Get current user
   */
  async me(req: AuthRequest, res: Response, next: NextFunction) {
    try {
      if (!req.user) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

      const user = await authService.getCurrentUser(req.user.userId);

      res.status(200).json(user);
    } catch (error) {
      next(error);
    }
  }
}

export default new AuthController();
