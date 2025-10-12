
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

    const userId = session.user.id

    // Get or create user stats
    let userStats = await prisma.userStats.findUnique({
      where: { userId }
    })

    if (!userStats) {
      userStats = await prisma.userStats.create({
        data: { userId }
      })
    }

    // Get recent challenges for streak calculation
    const recentChallenges = await prisma.challenge.findMany({
      where: {
        userId,
        status: 'COMPLETED',
        completedAt: {
          gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) // Last 30 days
        }
      },
      include: {
        scores: true
      },
      orderBy: { completedAt: 'desc' }
    })

    // Calculate stats
    const totalChallenges = await prisma.challenge.count({
      where: { userId }
    })

    const completedChallenges = await prisma.challenge.count({
      where: { userId, status: 'COMPLETED' }
    })

    const scores = await prisma.score.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' }
    })

    const bestScore = scores.length > 0 ? Math.max(...scores.map(s => s.scoreValue)) : 0
    const averageScore = scores.length > 0 
      ? scores.reduce((sum, s) => sum + s.scoreValue, 0) / scores.length 
      : 0

    // Calculate current streak
    let currentStreak = 0
    const now = new Date()
    let checkDate = new Date(now.getFullYear(), now.getMonth(), now.getDate())
    
    for (let i = 0; i < 30; i++) {
      const dayStart = new Date(checkDate)
      const dayEnd = new Date(checkDate.getTime() + 24 * 60 * 60 * 1000)
      
      const dayChallenge = recentChallenges.find(c => 
        c.completedAt && 
        c.completedAt >= dayStart && 
        c.completedAt < dayEnd
      )
      
      if (dayChallenge) {
        currentStreak++
        checkDate.setDate(checkDate.getDate() - 1)
      } else {
        break
      }
    }

    // Calculate level and total points
    const totalPoints = scores.reduce((sum, s) => sum + s.scoreValue * s.combo, 0)
    const level = Math.floor(totalPoints / 500) + 1

    // Update user stats
    await prisma.userStats.update({
      where: { userId },
      data: {
        totalChallenges,
        completedChallenges,
        averageScore,
        bestScore,
        currentStreak,
        totalPoints,
        level
      }
    })

    return NextResponse.json({
      totalChallenges,
      completedChallenges,
      averageScore: Math.round(averageScore),
      bestScore,
      currentStreak,
      longestStreak: userStats.longestStreak,
      totalPoints,
      level
    })
  } catch (error) {
    console.error('Error fetching user stats:', error)
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}
