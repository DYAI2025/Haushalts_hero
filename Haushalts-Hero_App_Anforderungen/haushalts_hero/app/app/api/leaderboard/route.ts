
import { NextRequest, NextResponse } from 'next/server'
import { getServerSession } from 'next-auth/next'
import { authOptions } from '@/lib/auth'
import { prisma } from '@/lib/db'

export const dynamic = 'force-dynamic'

export async function GET(request: NextRequest) {
  try {
    const session = await getServerSession(authOptions)
    
    if (!session?.user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
    }

    // Get top users by total points
    const topUsers = await prisma.userStats.findMany({
      orderBy: [
        { totalPoints: 'desc' },
        { bestScore: 'desc' },
        { currentStreak: 'desc' }
      ],
      take: 50
    })

    // Get user details separately
    const userIds = topUsers.map(stat => stat.userId)
    const users = await prisma.user.findMany({
      where: { id: { in: userIds } },
      select: {
        id: true,
        displayName: true,
        name: true,
        avatar: true
      }
    })

    const userMap = new Map(users.map(user => [user.id, user]))

    const leaderboard = topUsers.map(stat => {
      const user = userMap.get(stat.userId)
      return {
        userId: stat.userId,
        displayName: user?.displayName || user?.name || 'Anonymer Held',
        avatar: user?.avatar,
        totalScore: stat.totalPoints,
        challengesCompleted: stat.completedChallenges,
        averageScore: Math.round(stat.averageScore),
        currentStreak: stat.currentStreak,
        level: stat.level,
        bestScore: stat.bestScore
      }
    })

    // Find current user's position
    const currentUserPosition = leaderboard.findIndex(entry => entry.userId === session.user?.id) + 1

    return NextResponse.json({
      leaderboard,
      currentUserPosition
    })
  } catch (error) {
    console.error('Error fetching leaderboard:', error)
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}
