
'use client'

import { useState, useEffect } from 'react'
import { signIn, getSession } from 'next-auth/react'
import { useRouter } from 'next/navigation'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card'
import { Loader2, User, Lock, Home } from 'lucide-react'
import { toast } from 'sonner'
import { motion } from 'framer-motion'
import Link from 'next/link'

export default function SignInPage() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const [isCheckingSession, setIsCheckingSession] = useState(true)
  const router = useRouter()

  useEffect(() => {
    const checkSession = async () => {
      const session = await getSession()
      if (session) {
        router.push('/')
        return
      }
      setIsCheckingSession(false)
    }
    
    checkSession()
  }, [router])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsLoading(true)

    try {
      const result = await signIn('credentials', {
        email,
        password,
        redirect: false,
      })

      if (result?.error) {
        toast.error('Anmeldung fehlgeschlagen. Bitte überprüfe deine Eingaben.')
      } else {
        toast.success('Erfolgreich angemeldet!')
        router.push('/')
      }
    } catch (error) {
      toast.error('Ein Fehler ist aufgetreten')
    } finally {
      setIsLoading(false)
    }
  }

  if (isCheckingSession) {
    return (
      <div className="mobile-container flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mx-auto mb-4"></div>
          <p className="text-gray-600">Lade App...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="mobile-container">
      <div className="min-h-screen bg-gradient-to-br from-blue-50 via-purple-50 to-pink-50 flex flex-col justify-center p-6">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-center mb-8"
        >
          <div className="w-20 h-20 mx-auto mb-4 bg-gradient-to-br from-blue-500 to-purple-600 rounded-2xl flex items-center justify-center text-white text-3xl shadow-lg">
            🏠
          </div>
          <h1 className="text-4xl font-bold text-gray-900 mb-2">
            Haushalts-Hero
          </h1>
          <p className="text-gray-600">
            Die ultimative gamifizierte Putz-App
          </p>
        </motion.div>

        {/* Sign In Form */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
        >
          <Card className="shadow-xl border-0">
            <CardHeader className="text-center pb-6">
              <CardTitle className="text-2xl font-bold text-gray-900">
                Anmelden
              </CardTitle>
              <CardDescription>
                Melde dich an, um deine Fortschritte zu verfolgen
              </CardDescription>
            </CardHeader>
            
            <CardContent>
              <form onSubmit={handleSubmit} className="space-y-4">
                <div className="space-y-2">
                  <Label htmlFor="email" className="text-sm font-medium text-gray-700">
                    E-Mail
                  </Label>
                  <div className="relative">
                    <User className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
                    <Input
                      id="email"
                      type="email"
                      placeholder="deine@email.de"
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      className="pl-10"
                      required
                    />
                  </div>
                </div>
                
                <div className="space-y-2">
                  <Label htmlFor="password" className="text-sm font-medium text-gray-700">
                    Passwort
                  </Label>
                  <div className="relative">
                    <Lock className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
                    <Input
                      id="password"
                      type="password"
                      placeholder="••••••••"
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      className="pl-10"
                      required
                    />
                  </div>
                </div>

                <Button
                  type="submit"
                  className="w-full bg-gradient-to-r from-blue-500 to-purple-600 hover:from-blue-600 hover:to-purple-700 text-white font-semibold py-2.5"
                  disabled={isLoading}
                >
                  {isLoading ? (
                    <>
                      <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                      Anmelden...
                    </>
                  ) : (
                    <>
                      <Home className="h-4 w-4 mr-2" />
                      Anmelden
                    </>
                  )}
                </Button>
              </form>
            </CardContent>

            <CardFooter className="flex flex-col space-y-4 pt-6">
              <div className="text-center">
                <p className="text-sm text-gray-600">
                  Noch kein Account?{' '}
                  <Link 
                    href="/auth/signup" 
                    className="text-blue-600 hover:text-blue-500 font-medium"
                  >
                    Jetzt registrieren
                  </Link>
                </p>
              </div>
            </CardFooter>
          </Card>
        </motion.div>

        {/* Features */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="mt-8 grid grid-cols-2 gap-4 text-center"
        >
          <div className="bg-white/50 backdrop-blur-sm rounded-lg p-4">
            <div className="text-2xl mb-2">📸</div>
            <p className="text-sm font-medium text-gray-700">Foto-Bewertung</p>
          </div>
          <div className="bg-white/50 backdrop-blur-sm rounded-lg p-4">
            <div className="text-2xl mb-2">🏆</div>
            <p className="text-sm font-medium text-gray-700">Leaderboard</p>
          </div>
          <div className="bg-white/50 backdrop-blur-sm rounded-lg p-4">
            <div className="text-2xl mb-2">⚡</div>
            <p className="text-sm font-medium text-gray-700">Combo-System</p>
          </div>
          <div className="bg-white/50 backdrop-blur-sm rounded-lg p-4">
            <div className="text-2xl mb-2">🎯</div>
            <p className="text-sm font-medium text-gray-700">3 Kategorien</p>
          </div>
        </motion.div>
      </div>
    </div>
  )
}
