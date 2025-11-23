// ============================================
// Challenge Service
// ============================================

import { v4 as uuidv4 } from 'uuid';
import prisma from '../config/database';
import { AppError } from '../middleware/errorHandler';
import {
  ChallengeCreateRequest,
  ChallengeResponse,
  Subscore,
  HeatmapData,
  PaginationParams,
} from '../types';

export class ChallengeService {
  /**
   * Create new challenge
   */
  async createChallenge(
    userId: string,
    data: ChallengeCreateRequest
  ): Promise<ChallengeResponse> {
    const { category, beforePhotoUrl, afterPhotoUrl, score } = data;

    const challenge = await prisma.challenge.create({
      data: {
        id: uuidv4(),
        userId,
        category,
        beforePhotoUrl,
        afterPhotoUrl,
        overallScore: score.overallScore,
        subscores: JSON.stringify(score.subscores),
        confidence: score.confidence,
        explanation: score.explanation,
        heatmapData: score.heatmapData ? JSON.stringify(score.heatmapData) : null,
      },
    });

    return this.toChallengeResponse(challenge);
  }

  /**
   * Get challenge by ID
   */
  async getChallengeById(userId: string, challengeId: string): Promise<ChallengeResponse> {
    const challenge = await prisma.challenge.findFirst({
      where: {
        id: challengeId,
        userId,
      },
    });

    if (!challenge) {
      throw new AppError(404, 'NOT_FOUND', 'Challenge not found');
    }

    return this.toChallengeResponse(challenge);
  }

  /**
   * Get challenge history for user
   */
  async getChallenges(
    userId: string,
    params?: PaginationParams & { category?: string }
  ): Promise<ChallengeResponse[]> {
    const { limit = 100, offset = 0, category } = params || {};

    const challenges = await prisma.challenge.findMany({
      where: {
        userId,
        ...(category && { category }),
      },
      orderBy: {
        timestamp: 'desc',
      },
      take: limit,
      skip: offset,
    });

    return challenges.map((c) => this.toChallengeResponse(c));
  }

  /**
   * Delete challenge
   */
  async deleteChallenge(userId: string, challengeId: string): Promise<void> {
    const challenge = await prisma.challenge.findFirst({
      where: {
        id: challengeId,
        userId,
      },
    });

    if (!challenge) {
      throw new AppError(404, 'NOT_FOUND', 'Challenge not found');
    }

    await prisma.challenge.delete({
      where: { id: challengeId },
    });
  }

  /**
   * Get challenges count for user
   */
  async getChallengesCount(userId: string, category?: string): Promise<number> {
    return await prisma.challenge.count({
      where: {
        userId,
        ...(category && { category }),
      },
    });
  }

  /**
   * Get average score for user
   */
  async getAverageScore(userId: string): Promise<number> {
    const result = await prisma.challenge.aggregate({
      where: { userId },
      _avg: {
        overallScore: true,
      },
    });

    return result._avg.overallScore || 0;
  }

  /**
   * Convert Prisma challenge to response format
   */
  private toChallengeResponse(challenge: any): ChallengeResponse {
    return {
      id: challenge.id,
      userId: challenge.userId,
      category: challenge.category,
      beforePhotoUrl: challenge.beforePhotoUrl,
      afterPhotoUrl: challenge.afterPhotoUrl,
      timestamp: challenge.timestamp,
      overallScore: challenge.overallScore,
      subscores: JSON.parse(challenge.subscores) as Subscore[],
      confidence: challenge.confidence,
      explanation: challenge.explanation,
      heatmapData: challenge.heatmapData
        ? (JSON.parse(challenge.heatmapData) as HeatmapData)
        : undefined,
      createdAt: challenge.createdAt,
    };
  }
}

export default new ChallengeService();
