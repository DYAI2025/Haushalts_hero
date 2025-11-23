// ============================================
// Zod Validation Schemas
// ============================================

import { z } from 'zod';

// ============================================
// Auth Schemas
// ============================================

export const registerSchema = z.object({
  body: z.object({
    email: z.string().email('Invalid email format'),
    password: z
      .string()
      .min(8, 'Password must be at least 8 characters')
      .max(100, 'Password too long'),
  }),
});

export const loginSchema = z.object({
  body: z.object({
    email: z.string().email('Invalid email format'),
    password: z.string().min(1, 'Password required'),
  }),
});

export const refreshTokenSchema = z.object({
  body: z.object({
    refreshToken: z.string().min(1, 'Refresh token required'),
  }),
});

// ============================================
// Challenge Schemas
// ============================================

const subscoreSchema = z.object({
  name: z.string(),
  value: z.number().int().min(0).max(100),
  weight: z.number().min(0).max(1),
});

const heatmapPointSchema = z.object({
  x: z.number().min(0).max(1),
  y: z.number().min(0).max(1),
  intensity: z.number().min(0).max(1),
});

const heatmapDataSchema = z.object({
  width: z.number().int().positive(),
  height: z.number().int().positive(),
  points: z.array(heatmapPointSchema),
});

const challengeScoreSchema = z.object({
  overallScore: z.number().int().min(0).max(100),
  subscores: z.array(subscoreSchema).min(1),
  confidence: z.number().min(0).max(1),
  explanation: z.string().min(1).max(500),
  heatmapData: heatmapDataSchema.optional(),
});

export const createChallengeSchema = z.object({
  body: z.object({
    category: z.enum(['mirror', 'toilet', 'room']),
    beforePhotoUrl: z.string().url(),
    afterPhotoUrl: z.string().url(),
    score: challengeScoreSchema,
  }),
});

export const getChallengesSchema = z.object({
  query: z.object({
    limit: z.string().regex(/^\d+$/).transform(Number).optional(),
    offset: z.string().regex(/^\d+$/).transform(Number).optional(),
    category: z.enum(['mirror', 'toilet', 'room']).optional(),
  }),
});

export const getChallengeByIdSchema = z.object({
  params: z.object({
    id: z.string().uuid('Invalid challenge ID'),
  }),
});

export const deleteChallengeSchema = z.object({
  params: z.object({
    id: z.string().uuid('Invalid challenge ID'),
  }),
});

// ============================================
// Quest Schemas
// ============================================

export const updateQuestProgressSchema = z.object({
  params: z.object({
    id: z.string().uuid('Invalid quest ID'),
  }),
  body: z.object({
    increment: z.number().int().min(1),
  }),
});

// ============================================
// Goal Schemas
// ============================================

export const updateGoalProgressSchema = z.object({
  body: z.object({
    points: z.number().int().min(0),
  }),
});

// ============================================
// Stats Schemas
// ============================================

const categoryCounts = z.object({
  mirror: z.number().int().min(0),
  toilet: z.number().int().min(0),
  room: z.number().int().min(0),
});

export const updateWeeklyStatsSchema = z.object({
  body: z.object({
    challengesCompleted: z.number().int().min(0),
    averageScore: z.number().min(0).max(100),
    categoryCounts: categoryCounts,
    totalPoints: z.number().int().min(0),
  }),
});

export const getWeeklyStatsSchema = z.object({
  query: z.object({
    weekStart: z.string().datetime().optional(),
  }),
});

export const getMonthlyStatsSchema = z.object({
  query: z.object({
    month: z.string().regex(/^\d{4}-\d{2}$/).optional(), // YYYY-MM format
  }),
});

// ============================================
// User Settings Schemas
// ============================================

export const updateUserSettingsSchema = z.object({
  body: z.object({
    enableHapticFeedback: z.boolean().optional(),
    enableSoundEffects: z.boolean().optional(),
    showHeatmapByDefault: z.boolean().optional(),
  }),
});

// ============================================
// Photo Schemas
// ============================================

export const getPhotoByIdSchema = z.object({
  params: z.object({
    id: z.string().uuid('Invalid photo ID'),
  }),
});

export const deletePhotoSchema = z.object({
  params: z.object({
    id: z.string().uuid('Invalid photo ID'),
  }),
});
