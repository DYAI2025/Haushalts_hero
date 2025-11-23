// ============================================
// Authentication Middleware
// ============================================

import { Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import config from '../config';
import { AuthRequest, AuthPayload } from '../types';
import { AppError } from './errorHandler';

export const authenticate = (
  req: AuthRequest,
  res: Response,
  next: NextFunction
) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new AppError(401, 'UNAUTHORIZED', 'No token provided');
    }

    const token = authHeader.substring(7); // Remove 'Bearer ' prefix

    const decoded = jwt.verify(token, config.jwt.accessSecret) as AuthPayload;

    req.user = decoded;
    next();
  } catch (error) {
    if (error instanceof jwt.TokenExpiredError) {
      return next(new AppError(401, 'UNAUTHORIZED', 'Token expired'));
    }
    if (error instanceof jwt.JsonWebTokenError) {
      return next(new AppError(401, 'UNAUTHORIZED', 'Invalid token'));
    }
    next(error);
  }
};
