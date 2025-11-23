// ============================================
// Type Definitions for Haushalts-Hero Backend
// ============================================

import { Request } from 'express';

// ============================================
// Auth Types
// ============================================

export interface AuthPayload {
  userId: string;
  email: string;
}

export interface AuthRequest extends Request {
  user?: AuthPayload;
}

export interface TokenPair {
  accessToken: string;
  refreshToken: string;
}

// ============================================
// Challenge Types
// ============================================

export interface Subscore {
  name: string;
  value: number;
  weight: number;
}

export interface ChallengeScore {
  overallScore: number;
  subscores: Subscore[];
  confidence: number;
  explanation: string;
  heatmapData?: HeatmapData;
}

export interface HeatmapData {
  width: number;
  height: number;
  points: Array<{
    x: number;
    y: number;
    intensity: number;
  }>;
}

export interface ChallengeCreateRequest {
  category: 'mirror' | 'toilet' | 'room';
  beforePhotoUrl: string;
  afterPhotoUrl: string;
  score: ChallengeScore;
}

export interface ChallengeResponse {
  id: string;
  userId: string;
  category: string;
  beforePhotoUrl: string;
  afterPhotoUrl: string;
  timestamp: Date;
  overallScore: number;
  subscores: Subscore[];
  confidence: number;
  explanation: string;
  heatmapData?: HeatmapData;
  createdAt: Date;
}

// ============================================
// Quest Types
// ============================================

export interface QuestResponse {
  id: string;
  userId: string;
  title: string;
  description: string;
  category?: string;
  targetCount: number;
  currentProgress: number;
  rewardPoints: number;
  weekStart: Date;
  createdAt: Date;
  updatedAt: Date;
}

export interface QuestProgressUpdate {
  increment: number;
}

// ============================================
// Goal Types
// ============================================

export interface GoalResponse {
  id: string;
  userId: string;
  title: string;
  targetPoints: number;
  currentPoints: number;
  weekStart: Date;
  createdAt: Date;
  updatedAt: Date;
}

export interface GoalProgressUpdate {
  points: number;
}

// ============================================
// Stats Types
// ============================================

export interface CategoryCounts {
  mirror: number;
  toilet: number;
  room: number;
}

export interface WeeklyStatsResponse {
  id: string;
  userId: string;
  weekStart: Date;
  challengesCompleted: number;
  averageScore: number;
  categoryCounts: CategoryCounts;
  totalPoints: number;
  createdAt: Date;
}

export interface WeeklyStatsUpdate {
  challengesCompleted: number;
  averageScore: number;
  categoryCounts: CategoryCounts;
  totalPoints: number;
}

// ============================================
// Content Types
// ============================================

export interface CoachingTip {
  id: string;
  title: string;
  message: string;
  category?: string;
  context?: string;
}

export interface MicroLearning {
  id: string;
  title: string;
  content: string;
  duration: number;
  category: string;
}

export interface Season {
  id: string;
  name: string;
  description: string;
  startDate: Date;
  endDate: Date;
  isActive: boolean;
  rewards?: string[];
}

// ============================================
// Photo Types
// ============================================

export interface PhotoUploadRequest {
  file: Express.Multer.File;
}

export interface PhotoResponse {
  id: string;
  userId: string;
  url: string;
  path: string;
  size: number;
  mimeType: string;
  createdAt: Date;
}

// ============================================
// User Types
// ============================================

export interface UserResponse {
  id: string;
  email: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface UserSettingsResponse {
  id: string;
  userId: string;
  enableHapticFeedback: boolean;
  enableSoundEffects: boolean;
  showHeatmapByDefault: boolean;
  updatedAt: Date;
}

export interface UserSettingsUpdate {
  enableHapticFeedback?: boolean;
  enableSoundEffects?: boolean;
  showHeatmapByDefault?: boolean;
}

// ============================================
// Error Types
// ============================================

export interface ApiError {
  code: string;
  message: string;
  details?: Record<string, unknown>;
}

export type ErrorCode =
  | 'UNAUTHORIZED'
  | 'FORBIDDEN'
  | 'NOT_FOUND'
  | 'VALIDATION_ERROR'
  | 'INTERNAL_ERROR'
  | 'CONFLICT';

// ============================================
// Pagination Types
// ============================================

export interface PaginationParams {
  limit?: number;
  offset?: number;
}

export interface PaginatedResponse<T> {
  data: T[];
  pagination: {
    total: number;
    limit: number;
    offset: number;
    hasMore: boolean;
  };
}
