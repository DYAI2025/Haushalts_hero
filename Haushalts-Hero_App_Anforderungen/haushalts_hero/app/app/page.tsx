
'use client'

import { useState, useEffect } from 'react'
import { useSession } from 'next-auth/react'
import { useRouter } from 'next/navigation'
import { motion } from 'framer-motion'
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import ChallengeCard from '@/components/challenge-card'
import { Trophy, Users, Settings, LogOut, Zap } from 'lucide-react'
import { signOut } from 'next-auth/react'
import { ChallengeCategory } from '@/lib/types'

interface UserStats {
  totalChallenges: number
  completedChallenges: number
  averageScore: number
  bestScore: number
  currentStreak: number
  level: number
  totalPoints: number
}

interface CategoryScore {
  category: ChallengeCategory
  bestScore: number
}

export default function HomePage() {
  const { data: session, status } = useSession()
  const router = useRouter()
  const [stats, setStats] = useState<UserStats | null>(null)
  const [categoryScores, setCategoryScores] = useState<CategoryScore[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (status === 'loading') return
    
    if (!session) {
      router.push('/auth/signin')
      return
    }

    loadUserData()
  }, [session, status, router])

  const loadUserData = async () => {
    try {
      const [statsResponse, scoresResponse] = await Promise.all([
        fetch('/api/user/stats'),
        fetch('/api/user/category-scores')
      ])
      
      if (statsResponse.ok) {
        const statsData = await statsResponse.json()
        setStats(statsData)
      }
      
      if (scoresResponse.ok) {
        const scoresData = await scoresResponse.json()
        setCategoryScores(scoresData)
      }
    } catch (error) {
      console.error('Error loading user data:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleStartChallenge = (category: ChallengeCategory) => {
    router.push(`/challenge/${category}`)
  }

  const getBestScore = (category: ChallengeCategory) => {
    const categoryScore = categoryScores.find(s => s.category === category)
    return categoryScore?.bestScore
  }

  const handleSignOut = () => {
    signOut({ callbackUrl: '/auth/signin' })
  }

  if (status === 'loading' || loading) {
    return (
      <div className="mobile-container flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mx-auto mb-4"></div>
          <p className="text-gray-600">Lade deine Daten...</p>
        </div>
      </div>
    )
  }

  if (!session) {
    return null
  }

  return (
    <div className="mobile-container">
      {/* Header */}
      <div className="hero-gradient p-6 text-white relative overflow-hidden">
        {/* Background decoration */}
        <div className="absolute top-0 right-0 w-32 h-32 bg-white/10 rounded-full -translate-y-16 translate-x-16"></div>
        <div className="absolute bottom-0 left-0 w-24 h-24 bg-white/10 rounded-full translate-y-12 -translate-x-12"></div>
        
        <div className="relative z-10">
          <div className="flex justify-between items-start mb-6">
            <div>
              <h1 className="text-2xl font-bold mb-1">
                Haushalts-Hero
              </h1>
              <p className="text-white/80">
                Willkommen zurück, {session.user?.name?.split(' ')[0] || 'Held'}!
              </p>
            </div>
            <div className="flex space-x-2">
              <Button
                size="sm"
                variant="ghost"
                className="text-white hover:bg-white/20"
                onClick={() => router.push('/leaderboard')}
              >
                <Users className="h-4 w-4" />
              </Button>
              <Button
                size="sm"
                variant="ghost"
                className="text-white hover:bg-white/20"
                onClick={handleSignOut}
              >
                <LogOut className="h-4 w-4" />
              </Button>
            </div>
          </div>

          {/* User Stats */}
          {stats && (
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              className="grid grid-cols-2 gap-4"
            >
              <div className="bg-white/20 backdrop-blur-sm rounded-lg p-3">
                <div className="text-2xl font-bold mb-1">
                  {stats.level}
                </div>
                <div className="text-sm text-white/80">Level</div>
              </div>
              <div className="bg-white/20 backdrop-blur-sm rounded-lg p-3">
                <div className="text-2xl font-bold mb-1">
                  {stats.bestScore}
                </div>
                <div className="text-sm text-white/80">Bester Score</div>
              </div>
              <div className="bg-white/20 backdrop-blur-sm rounded-lg p-3">
                <div className="text-2xl font-bold mb-1 flex items-center">
                  {stats.currentStreak}
                  {stats.currentStreak > 0 && <Zap className="h-4 w-4 ml-1 text-yellow-300" />}
                </div>
                <div className="text-sm text-white/80">Streak</div>
              </div>
              <div className="bg-white/20 backdrop-blur-sm rounded-lg p-3">
                <div className="text-2xl font-bold mb-1">
                  {stats.totalPoints}
                </div>
                <div className="text-sm text-white/80">Punkte</div>
              </div>
            </motion.div>
          )}
        </div>
      </div>

      {/* Main Content */}
      <div className="p-6 space-y-6">
        {/* Quick Actions */}
        <div>
          <h2 className="text-xl font-bold mb-4 text-gray-800">
            Wähle deine Challenge
          </h2>
          <div className="space-y-4">
            <ChallengeCard
              category={ChallengeCategory.MIRROR_CLEANING}
              onStart={handleStartChallenge}
              bestScore={getBestScore(ChallengeCategory.MIRROR_CLEANING)}
              isPopular
              delay={0}
            />
            <ChallengeCard
              category={ChallengeCategory.TOILET_CLEANING}
              onStart={handleStartChallenge}
              bestScore={getBestScore(ChallengeCategory.TOILET_CLEANING)}
              delay={0.1}
            />
            <ChallengeCard
              category={ChallengeCategory.ROOM_TIDYING}
              onStart={handleStartChallenge}
              bestScore={getBestScore(ChallengeCategory.ROOM_TIDYING)}
              delay={0.2}
            />
          </div>
        </div>

        {/* Recent Activity */}
        {stats && stats.completedChallenges > 0 && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3 }}
          >
            <h2 className="text-xl font-bold mb-4 text-gray-800">
              Deine Fortschritte
            </h2>
            <Card className="p-4">
              <div className="flex items-center justify-between">
                <div>
                  <p className="font-medium text-gray-900">
                    Challenges abgeschlossen
                  </p>
                  <p className="text-sm text-gray-500">
                    {stats.completedChallenges} von {stats.totalChallenges}
                  </p>
                </div>
                <div className="bg-blue-100 p-3 rounded-full">
                  <Trophy className="h-6 w-6 text-blue-600" />
                </div>
              </div>
              <div className="mt-3">
                <div className="bg-gray-200 rounded-full h-2">
                  <div 
                    className="bg-blue-500 h-2 rounded-full transition-all duration-500"
                    style={{
                      width: `${stats.totalChallenges > 0 
                        ? (stats.completedChallenges / stats.totalChallenges) * 100
                        : 0
                      }%`
                    }}
                  ></div>
                </div>
              </div>
            </Card>
          </motion.div>
        )}
      </div>
    </div>
  )
}
