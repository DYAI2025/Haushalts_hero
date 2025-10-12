
'use client'

import { useState, useEffect } from 'react'
import { Button } from '@/components/ui/button'
import { Trophy, Star, Zap, Home, Share } from 'lucide-react'
import { motion, AnimatePresence } from 'framer-motion'
import { ScoringResult, ComboInfo } from '@/lib/types'
import { SCORE_THRESHOLDS, COMBO_MULTIPLIERS } from '@/lib/constants'

interface VictoryScreenProps {
  score: ScoringResult
  combo: ComboInfo
  isVictory: boolean
  onContinue: () => void
  onShare?: () => void
}

export default function VictoryScreen({ 
  score, 
  combo, 
  isVictory, 
  onContinue,
  onShare 
}: VictoryScreenProps) {
  const [animationPhase, setAnimationPhase] = useState(0)
  const [displayScore, setDisplayScore] = useState(0)
  
  // Berechne Performance-Prozentage
  const performancePercent = (score.score / 100) * 100
  const isGreatPerformance = performancePercent >= 80
  const isGoodPerformance = performancePercent >= 60
  
  // Wähle passende Emoji und Animation basierend auf Performance
  const getPerformanceEmoji = () => {
    if (isGreatPerformance) return '🏆'
    if (isGoodPerformance) return '💪'
    return '👍'
  }
  
  const getPerformanceMessage = () => {
    if (isGreatPerformance) return 'FANTASTISCH!'
    if (isGoodPerformance) return 'GUT GEMACHT!'
    return 'NICHT SCHLECHT!'
  }
  
  const getPerformanceSubtext = () => {
    if (isGreatPerformance) return 'Du bist ein wahrer Haushalts-Hero! 🌟'
    if (isGoodPerformance) return 'Solide Leistung! 💫'
    return 'Weiter so! 👌'
  }

  useEffect(() => {
    // Animation sequence
    const sequence = async () => {
      await new Promise(resolve => setTimeout(resolve, 500))
      setAnimationPhase(1) // Show avatar
      
      await new Promise(resolve => setTimeout(resolve, 800))
      setAnimationPhase(2) // Show score animation
      
      // Animate score counting up
      let current = 0
      const increment = score.score / 30
      const timer = setInterval(() => {
        current += increment
        if (current >= score.score) {
          setDisplayScore(score.score)
          clearInterval(timer)
          setTimeout(() => setAnimationPhase(3), 500) // Show combo and buttons
        } else {
          setDisplayScore(Math.floor(current))
        }
      }, 30)
    }

    sequence()
  }, [score.score])

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      className="fixed inset-0 bg-gradient-to-br from-purple-600 via-blue-600 to-teal-500 z-50 flex flex-col items-center justify-center p-6"
    >
      {/* Background particles effect */}
      <div className="absolute inset-0 overflow-hidden">
        {[...Array(20)].map((_, i) => (
          <motion.div
            key={i}
            className="absolute bg-white/20 rounded-full"
            style={{
              left: `${Math.random() * 100}%`,
              top: `${Math.random() * 100}%`,
              width: `${Math.random() * 8 + 4}px`,
              height: `${Math.random() * 8 + 4}px`,
            }}
            animate={{
              y: [-20, -100],
              opacity: [0.7, 0],
            }}
            transition={{
              duration: Math.random() * 3 + 2,
              repeat: Infinity,
              delay: Math.random() * 2,
            }}
          />
        ))}
      </div>

      <div className="relative z-10 text-center max-w-sm mx-auto">
        {/* Avatar Animation */}
        <AnimatePresence>
          {animationPhase >= 1 && (
            <motion.div
              initial={{ scale: 0, rotate: -180 }}
              animate={{ 
                scale: 1, 
                rotate: 0,
                // Extra Jubel-Animation für 80%+
                ...(isGreatPerformance ? {
                  y: [0, -20, 0],
                  transition: { 
                    duration: 0.8, 
                    repeat: 2,
                    repeatType: "reverse" as const
                  }
                } : {})
              }}
              className={`mb-6 ${isGreatPerformance ? 'street-fighter-victory-epic' : isVictory ? 'street-fighter-victory' : ''}`}
            >
              <div className={`w-32 h-32 mx-auto ${
                isGreatPerformance 
                  ? 'bg-gradient-to-br from-gold-400 to-yellow-600 animate-pulse' 
                  : isGoodPerformance
                  ? 'bg-gradient-to-br from-yellow-400 to-orange-500'
                  : 'bg-gradient-to-br from-blue-400 to-purple-500'
              } rounded-full flex items-center justify-center text-6xl shadow-2xl`}>
                {getPerformanceEmoji()}
              </div>
              
              {/* Zusätzliche Effekte für große Erfolge */}
              {isGreatPerformance && (
                <>
                  <motion.div
                    initial={{ scale: 0, opacity: 0 }}
                    animate={{ scale: [1, 1.5, 1], opacity: [0, 1, 0] }}
                    transition={{ duration: 1, repeat: Infinity, delay: 0.5 }}
                    className="absolute inset-0 w-32 h-32 mx-auto bg-yellow-400 rounded-full opacity-20"
                  />
                  <motion.div
                    initial={{ scale: 0 }}
                    animate={{ scale: 1, rotate: 360 }}
                    transition={{ duration: 1, delay: 0.3 }}
                    className="absolute -top-2 -right-2 text-2xl"
                  >
                    ⭐
                  </motion.div>
                </>
              )}
            </motion.div>
          )}
        </AnimatePresence>

        {/* Challenge Status */}
        <motion.h1
          initial={{ y: 50, opacity: 0 }}
          animate={animationPhase >= 1 ? { y: 0, opacity: 1 } : {}}
          className="text-4xl font-bold text-white mb-2"
        >
          {getPerformanceMessage()}
        </motion.h1>

        <motion.p
          initial={{ y: 20, opacity: 0 }}
          animate={animationPhase >= 1 ? { y: 0, opacity: 1 } : {}}
          transition={{ delay: 0.2 }}
          className="text-white/90 mb-2"
        >
          {getPerformanceSubtext()}
        </motion.p>
        
        <motion.p
          initial={{ y: 20, opacity: 0 }}
          animate={animationPhase >= 1 ? { y: 0, opacity: 1 } : {}}
          transition={{ delay: 0.3 }}
          className="text-white/80 text-sm mb-8"
        >
          {score.feedback}
        </motion.p>

        {/* Score Display */}
        <AnimatePresence>
          {animationPhase >= 2 && (
            <motion.div
              initial={{ scale: 0 }}
              animate={{ scale: 1 }}
              className="mb-8"
            >
              <div className="bg-white/20 backdrop-blur-sm rounded-2xl p-6 mb-4">
                <div className="text-6xl font-bold text-white mb-2">
                  {displayScore}
                  <span className="text-2xl ml-1">/100</span>
                </div>
                <div className="flex justify-center space-x-1 mb-4">
                  {[...Array(5)].map((_, i) => (
                    <Star 
                      key={i} 
                      className={`h-6 w-6 ${
                        i < Math.floor(score.score / 20) 
                          ? 'text-yellow-400 fill-current' 
                          : 'text-white/30'
                      }`} 
                    />
                  ))}
                </div>

                {/* Score Breakdown */}
                <div className="space-y-2 text-sm">
                  {Object.entries(score.breakdown).map(([key, value]) => (
                    <div key={key} className="flex justify-between text-white/80">
                      <span className="capitalize">
                        {key.replace(/([A-Z])/g, ' $1').toLowerCase()}
                      </span>
                      <span>{value}</span>
                    </div>
                  ))}
                </div>
              </div>

              {/* Combo Display */}
              {combo.count > 1 && (
                <motion.div
                  initial={{ scale: 0, rotate: -10 }}
                  animate={{ scale: 1, rotate: 0 }}
                  className="bg-gradient-to-r from-orange-400 to-red-500 rounded-xl p-4 mb-4"
                >
                  <div className="flex items-center justify-center space-x-2">
                    <Zap className="h-6 w-6 text-white" />
                    <div className="text-white">
                      <div className="font-bold text-lg">{combo.title}</div>
                      <div className="text-sm opacity-90">
                        {combo.count}x Kombo • {combo.multiplier}x Punkte
                      </div>
                    </div>
                  </div>
                </motion.div>
              )}
            </motion.div>
          )}
        </AnimatePresence>

        {/* Action Buttons */}
        <AnimatePresence>
          {animationPhase >= 3 && (
            <motion.div
              initial={{ y: 50, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              className="space-y-3"
            >
              <Button
                onClick={onContinue}
                size="lg"
                className="w-full bg-white text-purple-600 hover:bg-gray-100 font-semibold"
              >
                <Home className="h-5 w-5 mr-2" />
                Weiter
              </Button>
              
              {onShare && (
                <Button
                  onClick={onShare}
                  size="lg"
                  variant="outline"
                  className="w-full border-white text-white hover:bg-white hover:text-purple-600"
                >
                  <Share className="h-5 w-5 mr-2" />
                  Erfolg teilen
                </Button>
              )}
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </motion.div>
  )
}
