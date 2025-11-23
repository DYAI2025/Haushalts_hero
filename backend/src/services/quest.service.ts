// ============================================
// Quest Service
// ============================================

import { v4 as uuidv4 } from 'uuid';
import prisma from '../config/database';
import { AppError } from '../middleware/errorHandler';
import { QuestResponse } from '../types';

export class QuestService {
  /**
   * Get active quests for current week
   */
  async getActiveQuests(userId: string): Promise<QuestResponse[]> {
    const weekStart = this.getWeekStart();

    const quests = await prisma.quest.findMany({
      where: {
        userId,
        weekStart,
      },
      orderBy: {
        createdAt: 'asc',
      },
    });

    // If no quests exist for this week, generate default quests
    if (quests.length === 0) {
      return await this.generateWeeklyQuests(userId);
    }

    return quests;
  }

  /**
   * Update quest progress
   */
  async updateQuestProgress(
    userId: string,
    questId: string,
    increment: number
  ): Promise<QuestResponse> {
    const quest = await prisma.quest.findFirst({
      where: {
        id: questId,
        userId,
      },
    });

    if (!quest) {
      throw new AppError(404, 'NOT_FOUND', 'Quest not found');
    }

    const newProgress = Math.min(quest.currentProgress + increment, quest.targetCount);

    const updatedQuest = await prisma.quest.update({
      where: { id: questId },
      data: {
        currentProgress: newProgress,
      },
    });

    return updatedQuest;
  }

  /**
   * Reset quests for new week
   */
  async resetQuests(userId: string): Promise<QuestResponse[]> {
    const weekStart = this.getWeekStart();

    // Delete old quests
    await prisma.quest.deleteMany({
      where: {
        userId,
        weekStart: {
          lt: weekStart,
        },
      },
    });

    // Generate new quests
    return await this.generateWeeklyQuests(userId);
  }

  /**
   * Generate default weekly quests
   */
  private async generateWeeklyQuests(userId: string): Promise<QuestResponse[]> {
    const weekStart = this.getWeekStart();

    const defaultQuests = [
      {
        title: 'Spiegel-Meister',
        description: 'Putze 3 Spiegel diese Woche',
        category: 'mirror',
        targetCount: 3,
        rewardPoints: 150,
      },
      {
        title: 'Toiletten-Champion',
        description: 'Reinige 5 Toiletten diese Woche',
        category: 'toilet',
        targetCount: 5,
        rewardPoints: 250,
      },
      {
        title: 'Raum-Organisator',
        description: 'Räume 4 Zimmer auf diese Woche',
        category: 'room',
        targetCount: 4,
        rewardPoints: 200,
      },
      {
        title: 'Perfektionist',
        description: 'Erreiche 3x einen Score von 85+',
        category: null,
        targetCount: 3,
        rewardPoints: 300,
      },
    ];

    const quests = await Promise.all(
      defaultQuests.map((questData) =>
        prisma.quest.create({
          data: {
            id: uuidv4(),
            userId,
            weekStart,
            ...questData,
          },
        })
      )
    );

    return quests;
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

export default new QuestService();
