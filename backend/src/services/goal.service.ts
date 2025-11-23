// ============================================
// Goal Service
// ============================================

import { v4 as uuidv4 } from 'uuid';
import prisma from '../config/database';
import { AppError } from '../middleware/errorHandler';
import { GoalResponse } from '../types';

export class GoalService {
  /**
   * Get active goals for current week
   */
  async getActiveGoals(userId: string): Promise<GoalResponse[]> {
    const weekStart = this.getWeekStart();

    const goals = await prisma.goal.findMany({
      where: {
        userId,
        weekStart,
      },
      orderBy: {
        createdAt: 'asc',
      },
    });

    // If no goals exist for this week, generate default goal
    if (goals.length === 0) {
      return await this.generateWeeklyGoals(userId);
    }

    return goals;
  }

  /**
   * Update goal progress
   */
  async updateGoalProgress(userId: string, points: number): Promise<GoalResponse> {
    const weekStart = this.getWeekStart();

    // Get or create weekly goal
    let goal = await prisma.goal.findFirst({
      where: {
        userId,
        weekStart,
      },
    });

    if (!goal) {
      // Create default goal if it doesn't exist
      const goals = await this.generateWeeklyGoals(userId);
      goal = goals[0];
    }

    const newPoints = Math.min(goal.currentPoints + points, goal.targetPoints);

    const updatedGoal = await prisma.goal.update({
      where: { id: goal.id },
      data: {
        currentPoints: newPoints,
      },
    });

    return updatedGoal;
  }

  /**
   * Generate default weekly goals
   */
  private async generateWeeklyGoals(userId: string): Promise<GoalResponse[]> {
    const weekStart = this.getWeekStart();

    const goal = await prisma.goal.create({
      data: {
        id: uuidv4(),
        userId,
        weekStart,
        title: 'Wochenziel',
        targetPoints: 1000,
        currentPoints: 0,
      },
    });

    return [goal];
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
}

export default new GoalService();
