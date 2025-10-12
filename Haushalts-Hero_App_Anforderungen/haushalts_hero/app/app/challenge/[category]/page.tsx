
'use client'

import { useState, useEffect } from 'react'
import { useRouter, useParams } from 'next/navigation'
import { useSession } from 'next-auth/react'
import { Button } from '@/components/ui/button'
import CameraCapture from '@/components/camera-capture'
import VictoryScreen from '@/components/victory-screen'
import ReferencePhotoManager from '@/components/reference-photo-manager'
import { ArrowLeft, Camera, Zap, RotateCcw, Image } from 'lucide-react'
import { ChallengeCategory, ScoringResult, ComboInfo } from '@/lib/types'
import { ScoringEngine } from '@/lib/scoring'
import { CATEGORIES, SCORE_THRESHOLDS, COMBO_MULTIPLIERS } from '@/lib/constants'
import { motion, AnimatePresence } from 'framer-motion'
import { toast } from 'sonner'

export const dynamic = 'force-dynamic'

type ChallengeStep = 'intro' | 'reference-photos' | 'before-photo' | 'instructions' | 'after-photo' | 'processing' | 'results'

export default function ChallengePage() {
  const { data: session } = useSession()
  const router = useRouter()
  const params = useParams()
  const category = params?.category as ChallengeCategory

  const [step, setStep] = useState<ChallengeStep>('intro')
  const [beforePhoto, setBeforePhoto] = useState<string>('')
  const [afterPhoto, setAfterPhoto] = useState<string>('')
  const [score, setScore] = useState<ScoringResult | null>(null)
  const [combo, setCombo] = useState<ComboInfo>({ count: 1, multiplier: 1, title: 'Erster Versuch' })
  const [isProcessing, setIsProcessing] = useState(false)
  const [hasReferencePhotos, setHasReferencePhotos] = useState<boolean>(false)

  const categoryInfo = CATEGORIES[category]

  useEffect(() => {
    if (!session) {
      router.push('/auth/signin')
    }
    if (!categoryInfo) {
      router.push('/')
    }
    
    // Prüfe ob Referenzfotos existieren
    checkReferencePhotos()
  }, [session, categoryInfo, router])

  const checkReferencePhotos = () => {
    try {
      const saved = localStorage.getItem(`reference-photos-${category}`)
      if (saved) {
        const photos = JSON.parse(saved)
        const hasPhotos = photos.clean && photos.dirty
        setHasReferencePhotos(hasPhotos)
      }
    } catch {
      setHasReferencePhotos(false)
    }
  }

  const handleReferencePhotosReady = (cleanRef: string, dirtyRef: string) => {
    setHasReferencePhotos(true)
    setStep('before-photo')
  }

  const handleBeforePhoto = (photo: string) => {
    setBeforePhoto(photo)
    setStep('instructions')
  }

  const handleAfterPhoto = async (photo: string) => {
    setAfterPhoto(photo)
    setStep('processing')
    setIsProcessing(true)

    try {
      // Simulate processing delay for better UX
      await new Promise(resolve => setTimeout(resolve, 1500))

      // Get user's recent combo count
      const comboResponse = await fetch('/api/user/combo')
      let comboCount = 1
      if (comboResponse.ok) {
        const comboData = await comboResponse.json()
        comboCount = comboData.combo || 1
      }

      // Calculate score
      const result = await ScoringEngine.analyzeImages(
        beforePhoto,
        photo,
        category
      )

      // Apply combo multiplier
      const comboMultiplier = COMBO_MULTIPLIERS[Math.min(comboCount, 10) as keyof typeof COMBO_MULTIPLIERS] || 
                             COMBO_MULTIPLIERS[10]
      
      const finalScore = {
        ...result,
        score: Math.min(100, Math.round(result.score * comboMultiplier.multiplier))
      }

      setScore(finalScore)
      setCombo({
        count: comboCount,
        multiplier: comboMultiplier.multiplier,
        title: comboMultiplier.title
      })

      // Save challenge to database
      await fetch('/api/challenges', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          category,
          beforePhoto,
          afterPhoto: photo,
          score: finalScore.score,
          breakdown: finalScore.breakdown
        })
      })

      setStep('results')
    } catch (error) {
      console.error('Error processing challenge:', error)
      toast.error('Fehler beim Verarbeiten der Fotos')
      setStep('after-photo')
    } finally {
      setIsProcessing(false)
    }
  }

  const handleShare = async () => {
    if (!score) return

    if (navigator.share) {
      try {
        await navigator.share({
          title: 'Haushalts-Hero Erfolg!',
          text: `Ich habe gerade ${score.score}/100 Punkte beim ${categoryInfo.name} erreicht! 🏆`,
          url: window.location.origin
        })
      } catch (error) {
        console.error('Error sharing:', error)
      }
    } else {
      // Fallback: copy to clipboard
      const text = `Ich habe gerade ${score.score}/100 Punkte beim ${categoryInfo.name} erreicht! 🏆`
      navigator.clipboard.writeText(text)
      toast.success('In die Zwischenablage kopiert!')
    }
  }

  const handleContinue = () => {
    router.push('/')
  }

  const handleRetry = () => {
    setStep('before-photo')
    setBeforePhoto('')
    setAfterPhoto('')
    setScore(null)
  }

  if (!session || !categoryInfo) {
    return null
  }

  return (
    <div className="mobile-container">
      {/* Reference Photo Manager */}
      {step === 'reference-photos' && (
        <ReferencePhotoManager
          category={category}
          onPhotosReady={handleReferencePhotosReady}
          onCancel={() => setStep('intro')}
        />
      )}

      {/* Camera Capture */}
      {(step === 'before-photo' || step === 'after-photo') && (
        <CameraCapture
          category={category}
          onCapture={step === 'before-photo' ? handleBeforePhoto : handleAfterPhoto}
          onCancel={() => step === 'before-photo' ? router.push('/') : setStep('instructions')}
          isAfterPhoto={step === 'after-photo'}
        />
      )}

      {/* Victory Screen */}
      {step === 'results' && score && (
        <VictoryScreen
          score={score}
          combo={combo}
          isVictory={score.score >= SCORE_THRESHOLDS.VICTORY}
          onContinue={handleContinue}
          onShare={handleShare}
        />
      )}

      {/* Processing Screen */}
      {step === 'processing' && (
        <div className="fixed inset-0 bg-gradient-to-br from-purple-600 to-blue-600 flex items-center justify-center z-50">
          <div className="text-center text-white">
            <motion.div
              animate={{ rotate: 360 }}
              transition={{ duration: 2, repeat: Infinity, ease: "linear" }}
              className="w-16 h-16 border-4 border-white/30 border-t-white rounded-full mx-auto mb-6"
            />
            <h2 className="text-2xl font-bold mb-2">Analysiere Fotos...</h2>
            <p className="text-white/80">KI-Bewertung läuft</p>
            
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 1 }}
              className="mt-6"
            >
              <div className="flex justify-center space-x-2">
                {[...Array(3)].map((_, i) => (
                  <motion.div
                    key={i}
                    className="w-2 h-2 bg-white rounded-full"
                    animate={{
                      scale: [1, 1.5, 1],
                      opacity: [0.5, 1, 0.5],
                    }}
                    transition={{
                      duration: 1,
                      repeat: Infinity,
                      delay: i * 0.2,
                    }}
                  />
                ))}
              </div>
            </motion.div>
          </div>
        </div>
      )}

      {/* Main Content */}
      <AnimatePresence mode="wait">
        {step === 'intro' && (
          <motion.div
            key="intro"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="p-6"
          >
            {/* Header */}
            <div className="flex items-center mb-6">
              <Button
                onClick={() => router.push('/')}
                size="sm"
                variant="ghost"
                className="mr-3"
              >
                <ArrowLeft className="h-4 w-4" />
              </Button>
              <h1 className="text-2xl font-bold text-gray-900">
                {categoryInfo.name}
              </h1>
            </div>

            {/* Challenge Info */}
            <div className="bg-gradient-to-br from-blue-50 to-purple-50 rounded-2xl p-6 mb-6">
              <div className="text-center">
                <div className="text-6xl mb-4">{categoryInfo.icon}</div>
                <h2 className="text-xl font-bold mb-2 text-gray-800">
                  {categoryInfo.description}
                </h2>
                <p className="text-gray-600 mb-6">
                  Mache ein Vorher- und Nachher-Foto für eine automatische Bewertung
                </p>

                {/* Criteria */}
                <div className="bg-white/50 rounded-lg p-4 mb-6">
                  <h3 className="font-medium text-gray-800 mb-2">
                    Bewertungskriterien:
                  </h3>
                  <div className="flex flex-wrap gap-2 justify-center">
                    {categoryInfo.criteria.map((criterion, index) => (
                      <span
                        key={index}
                        className="bg-blue-100 text-blue-800 px-3 py-1 rounded-full text-sm font-medium"
                      >
                        {criterion}
                      </span>
                    ))}
                  </div>
                </div>
              </div>
            </div>

            {/* Instructions */}
            <div className="space-y-4 mb-8">
              <div className="flex items-start space-x-3">
                <div className="bg-blue-500 text-white rounded-full w-8 h-8 flex items-center justify-center font-bold text-sm">
                  1
                </div>
                <div>
                  <h3 className="font-medium text-gray-800">Vorher-Foto</h3>
                  <p className="text-gray-600 text-sm">
                    Zeige den aktuellen Zustand vor der Reinigung
                  </p>
                </div>
              </div>
              <div className="flex items-start space-x-3">
                <div className="bg-blue-500 text-white rounded-full w-8 h-8 flex items-center justify-center font-bold text-sm">
                  2
                </div>
                <div>
                  <h3 className="font-medium text-gray-800">Putzen</h3>
                  <p className="text-gray-600 text-sm">
                    Reinige gründlich nach den Bewertungskriterien
                  </p>
                </div>
              </div>
              <div className="flex items-start space-x-3">
                <div className="bg-blue-500 text-white rounded-full w-8 h-8 flex items-center justify-center font-bold text-sm">
                  3
                </div>
                <div>
                  <h3 className="font-medium text-gray-800">Nachher-Foto</h3>
                  <p className="text-gray-600 text-sm">
                    Zeige das saubere Ergebnis für die Bewertung
                  </p>
                </div>
              </div>
            </div>

            {/* Reference Photos Info */}
            {!hasReferencePhotos && (
              <div className="bg-orange-50 border border-orange-200 rounded-lg p-4 mb-4">
                <div className="flex items-center space-x-2 mb-2">
                  <Image className="h-5 w-5 text-orange-600" />
                  <h3 className="font-medium text-orange-900">
                    Referenzfotos für bessere Bewertung
                  </h3>
                </div>
                <p className="text-sm text-orange-800 mb-3">
                  Hinterlege einmalig Referenzfotos von "sauber" und "schmutzig" 
                  für präzisere KI-Bewertungen und mehr Punkte!
                </p>
                <Button
                  onClick={() => setStep('reference-photos')}
                  size="sm"
                  className="w-full mb-3 bg-orange-600 hover:bg-orange-700"
                >
                  <Image className="h-4 w-4 mr-2" />
                  Referenzfotos einrichten
                </Button>
              </div>
            )}

            {/* Start Button */}
            <Button
              onClick={() => hasReferencePhotos ? setStep('before-photo') : setStep('reference-photos')}
              size="lg"
              className="w-full bg-blue-600 hover:bg-blue-700"
            >
              <Camera className="h-5 w-5 mr-2" />
              {hasReferencePhotos ? 'Challenge starten' : 'Einrichten & Starten'}
            </Button>
            
            {hasReferencePhotos && (
              <Button
                onClick={() => setStep('reference-photos')}
                size="sm"
                variant="outline"
                className="w-full mt-2"
              >
                <Image className="h-4 w-4 mr-2" />
                Referenzfotos bearbeiten
              </Button>
            )}
          </motion.div>
        )}

        {step === 'instructions' && (
          <motion.div
            key="instructions"
            initial={{ opacity: 0, x: 50 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -50 }}
            className="p-6"
          >
            {/* Header */}
            <div className="flex items-center mb-6">
              <Button
                onClick={() => setStep('before-photo')}
                size="sm"
                variant="ghost"
                className="mr-3"
              >
                <ArrowLeft className="h-4 w-4" />
              </Button>
              <h1 className="text-2xl font-bold text-gray-900">
                Jetzt putzen!
              </h1>
            </div>

            {/* Photo Preview */}
            <div className="mb-6">
              <div className="bg-gray-100 rounded-xl p-4 mb-4">
                <img 
                  src={beforePhoto} 
                  alt="Vorher-Foto" 
                  className="w-full h-48 object-cover rounded-lg"
                />
                <p className="text-center text-sm text-gray-600 mt-2">
                  Vorher-Foto aufgenommen ✓
                </p>
              </div>
            </div>

            {/* Instructions */}
            <div className="bg-gradient-to-br from-green-50 to-blue-50 rounded-2xl p-6 mb-6">
              <h2 className="text-xl font-bold mb-4 text-gray-800 flex items-center">
                <Zap className="h-6 w-6 mr-2 text-yellow-500" />
                Zeit zum Putzen!
              </h2>
              
              <div className="space-y-3 mb-6">
                <div className="flex items-center space-x-3">
                  <div className="w-2 h-2 bg-green-500 rounded-full"></div>
                  <p className="text-gray-700">
                    Konzentriere dich auf die Bewertungskriterien
                  </p>
                </div>
                <div className="flex items-center space-x-3">
                  <div className="w-2 h-2 bg-green-500 rounded-full"></div>
                  <p className="text-gray-700">
                    Arbeite gründlich und systematisch
                  </p>
                </div>
                <div className="flex items-center space-x-3">
                  <div className="w-2 h-2 bg-green-500 rounded-full"></div>
                  <p className="text-gray-700">
                    Mache danach ein Foto aus dem gleichen Blickwinkel
                  </p>
                </div>
              </div>

              {/* Criteria reminder */}
              <div className="bg-white/50 rounded-lg p-3">
                <h3 className="font-medium text-gray-800 mb-2 text-sm">
                  Fokus auf:
                </h3>
                <div className="flex flex-wrap gap-2">
                  {categoryInfo.criteria.map((criterion, index) => (
                    <span
                      key={index}
                      className="bg-green-100 text-green-800 px-2 py-1 rounded-full text-xs font-medium"
                    >
                      {criterion}
                    </span>
                  ))}
                </div>
              </div>
            </div>

            {/* Action Buttons */}
            <div className="space-y-3">
              <Button
                onClick={() => setStep('after-photo')}
                size="lg"
                className="w-full bg-green-600 hover:bg-green-700"
              >
                <Camera className="h-5 w-5 mr-2" />
                Nachher-Foto aufnehmen
              </Button>
              
              <Button
                onClick={handleRetry}
                size="lg"
                variant="outline"
                className="w-full"
              >
                <RotateCcw className="h-5 w-5 mr-2" />
                Vorher-Foto wiederholen
              </Button>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}
