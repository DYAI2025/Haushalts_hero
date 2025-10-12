
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

    // Get best scores for each category
    const scores = await prisma.score.groupBy({
      by: ['category'],
      where: { userId },
      _max: {
        scoreValue: true
      }
    })

    const categoryScores = scores.map(score => ({
      category: score.category,
      bestScore: score._max.scoreValue || 0
    }))

    return NextResponse.json(categoryScores)
  } catch (error) {
    console.error('Error fetching category scores:', error)
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}
