
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

    // Get recent scores to calculate combo
    const recentScores = await prisma.score.findMany({
      where: { 
        userId,
        scoreValue: { gte: 75 } // Only successful challenges count for combo
      },
      orderBy: { createdAt: 'desc' },
      take: 10
    })

    // Calculate consecutive successful challenges
    let combo = 1
    const now = new Date()
    
    for (let i = 0; i < recentScores.length; i++) {
      const score = recentScores[i]
      const scoreDate = new Date(score.createdAt)
      const daysDiff = Math.floor((now.getTime() - scoreDate.getTime()) / (1000 * 60 * 60 * 24))
      
      if (daysDiff <= i + 1) { // Allow one day per combo level
        combo = i + 2
      } else {
        break
      }
    }

    return NextResponse.json({ combo: Math.min(combo, 10) })
  } catch (error) {
    console.error('Error fetching combo:', error)
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}
