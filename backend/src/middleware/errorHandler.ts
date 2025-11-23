// ============================================
// Global Error Handler Middleware
// ============================================

import { Request, Response, NextFunction } from 'express';
import { ZodError } from 'zod';
import { ApiError, ErrorCode } from '../types';

export class AppError extends Error {
  constructor(
    public statusCode: number,
    public code: ErrorCode,
    message: string,
    public details?: Record<string, unknown>
  ) {
    super(message);
    this.name = 'AppError';
    Error.captureStackTrace(this, this.constructor);
  }
}

export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  // Zod validation errors
  if (err instanceof ZodError) {
    const apiError: ApiError = {
      code: 'VALIDATION_ERROR',
      message: 'Validation failed',
      details: {
        issues: err.errors.map((e) => ({
          path: e.path.join('.'),
          message: e.message,
        })),
      },
    };
    return res.status(400).json({ error: apiError });
  }

  // Custom application errors
  if (err instanceof AppError) {
    const apiError: ApiError = {
      code: err.code,
      message: err.message,
      details: err.details,
    };
    return res.status(err.statusCode).json({ error: apiError });
  }

  // JWT errors
  if (err.name === 'JsonWebTokenError') {
    const apiError: ApiError = {
      code: 'UNAUTHORIZED',
      message: 'Invalid token',
    };
    return res.status(401).json({ error: apiError });
  }

  if (err.name === 'TokenExpiredError') {
    const apiError: ApiError = {
      code: 'UNAUTHORIZED',
      message: 'Token expired',
    };
    return res.status(401).json({ error: apiError });
  }

  // Prisma errors
  if (err.constructor.name === 'PrismaClientKnownRequestError') {
    const prismaError = err as any;
    if (prismaError.code === 'P2002') {
      const apiError: ApiError = {
        code: 'CONFLICT',
        message: 'Resource already exists',
        details: { field: prismaError.meta?.target },
      };
      return res.status(409).json({ error: apiError });
    }
    if (prismaError.code === 'P2025') {
      const apiError: ApiError = {
        code: 'NOT_FOUND',
        message: 'Resource not found',
      };
      return res.status(404).json({ error: apiError });
    }
  }

  // Log unexpected errors
  console.error('Unexpected error:', err);

  // Generic server error
  const apiError: ApiError = {
    code: 'INTERNAL_ERROR',
    message: 'An unexpected error occurred',
    details: process.env.NODE_ENV === 'development' ? { error: err.message } : undefined,
  };
  res.status(500).json({ error: apiError });
};

// Not found handler
export const notFoundHandler = (req: Request, res: Response) => {
  const apiError: ApiError = {
    code: 'NOT_FOUND',
    message: `Route ${req.method} ${req.path} not found`,
  };
  res.status(404).json({ error: apiError });
};
