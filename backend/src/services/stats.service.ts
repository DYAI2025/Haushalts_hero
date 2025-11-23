// ============================================
// Stats Service
// ============================================

import { v4 as uuidv4 } from 'uuid';
import prisma from '../config/database';
import { AppError } from '../middleware/errorHandler';
import { WeeklyStatsResponse, WeeklyStatsUpdate, CategoryCounts } from '../types';

export class StatsService {
  /**
   * Get weekly stats
   */
  async getWeeklyStats(userId: string, weekStart?: Date): Promise<WeeklyStatsResponse | null> {
    const targetWeek = weekStart || this.getWeekStart();

    const stats = await prisma.weeklyStats.findFirst({
      where: {
        userId,
        weekStart: targetWeek,
      },
    });

    return stats;
  }

  /**
   * Get monthly stats (aggregate of all weeks in month)
   */
  async getMonthlyStats(userId: string, month?: string): Promise<any> {
    const { startDate, endDate } = this.getMonthRange(month);

    const weeklyStats = await prisma.weeklyStats.findMany({
      where: {
        userId,
        weekStart: {
          gte: startDate,
          lt: endDate,
        },
      },
      orderBy: {
        weekStart: 'asc',
      },
    });

    // Aggregate monthly data
    const totalChallenges = weeklyStats.reduce((sum, s) => sum + s.challengesCompleted, 0);
    const avgScore =
      weeklyStats.length > 0
        ? weeklyStats.reduce((sum, s) => sum + s.averageScore, 0) / weeklyStats.length
        : 0;

    const categoryCounts: CategoryCounts = { mirror: 0, toilet: 0, room: 0 };
    weeklyStats.forEach((s) => {
      const counts = JSON.parse(s.categoryCounts) as CategoryCounts;
      categoryCounts.mirror += counts.mirror || 0;
      categoryCounts.toilet += counts.toilet || 0;
      categoryCounts.room += counts.room || 0;
    });

    const totalPoints = weeklyStats.reduce((sum, s) => sum + s.totalPoints, 0);

    return {
      month: startDate.toISOString().substring(0, 7), // YYYY-MM
      challengesCompleted: totalChallenges,
      averageScore: Math.round(avgScore * 10) / 10,
      categoryCounts,
      totalPoints,
      weeklyBreakdown: weeklyStats.map((s) => ({
        weekStart: s.weekStart,
        challengesCompleted: s.challengesCompleted,
        averageScore: s.averageScore,
        totalPoints: s.totalPoints,
      })),
    };
  }

  /**
   * Update weekly stats
   */
  async updateWeeklyStats(
    userId: string,
    data: WeeklyStatsUpdate
  ): Promise<WeeklyStatsResponse> {
    const weekStart = this.getWeekStart();

    // Check if stats already exist
    const existingStats = await prisma.weeklyStats.findFirst({
      where: {
        userId,
        weekStart,
      },
    });

    if (existingStats) {
      // Update existing stats
      const updated = await prisma.weeklyStats.update({
        where: { id: existingStats.id },
        data: {
          challengesCompleted: data.challengesCompleted,
          averageScore: data.averageScore,
          categoryCounts: JSON.stringify(data.categoryCounts),
          totalPoints: data.totalPoints,
        },
      });

      return {
        ...updated,
        categoryCounts: JSON.parse(updated.categoryCounts) as CategoryCounts,
      };
    } else {
      // Create new stats
      const stats = await prisma.weeklyStats.create({
        data: {
          id: uuidv4(),
          userId,
          weekStart,
          challengesCompleted: data.challengesCompleted,
          averageScore: data.averageScore,
          categoryCounts: JSON.stringify(data.categoryCounts),
          totalPoints: data.totalPoints,
        },
      });

      return {
        ...stats,
        categoryCounts: JSON.parse(stats.categoryCounts) as CategoryCounts,
      };
    }
  }

  /**
   * Calculate stats from challenges
   */
  async calculateStatsFromChallenges(userId: string): Promise<WeeklyStatsResponse> {
    const weekStart = this.getWeekStart();
    const weekEnd = new Date(weekStart);
    weekEnd.setDate(weekEnd.getDate() + 7);

    // Get all challenges for this week
    const challenges = await prisma.challenge.findMany({
      where: {
        userId,
        timestamp: {
          gte: weekStart,
          lt: weekEnd,
        },
      },
    });

    const challengesCompleted = challenges.length;
    const averageScore =
      challengesCompleted > 0
        ? challenges.reduce((sum, c) => sum + c.overallScore, 0) / challengesCompleted
        : 0;

    const categoryCounts: CategoryCounts = { mirror: 0, toilet: 0, room: 0 };
    challenges.forEach((c) => {
      if (c.category in categoryCounts) {
        categoryCounts[c.category as keyof CategoryCounts]++;
      }
    });

    const totalPoints = challenges.reduce((sum, c) => sum + c.overallScore, 0);

    return this.updateWeeklyStats(userId, {
      challengesCompleted,
      averageScore: Math.round(averageScore * 10) / 10,
      categoryCounts,
      totalPoints,
    });
  }

  /**
   * Get start of current week (Monday 00:00)
   */
  private getWeekStart(): Date {
    const now = new Date();
    const dayOfWeek = now.getDay();
    const diff = dayOfWeek === 0 ? 6 : dayOfWeek - 1; // Monday = 0

    const weekStart = new Date(now);
    weekStart.setDate(now.getDate() - diff);
    weekStart.setHours(0, 0, 0, 0);

    return weekStart;
  }

  /**
   * Get month range (first day to first day of next month)
   */
  private getMonthRange(month?: string): { startDate: Date; endDate: Date } {
    if (month) {
      const [year, monthNum] = month.split('-').map(Number);
      const startDate = new Date(year, monthNum - 1, 1);
      const endDate = new Date(year, monthNum, 1);
      return { startDate, endDate };
    } else {
      const now = new Date();
      const startDate = new Date(now.getFullYear(), now.getMonth(), 1);
      const endDate = new Date(now.getFullYear(), now.getMonth() + 1, 1);
      return { startDate, endDate };
    }
  }
}

export default new StatsService();
