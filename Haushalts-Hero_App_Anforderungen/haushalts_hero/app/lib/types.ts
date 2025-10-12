
// NextAuth type augmentation
declare module "next-auth" {
  interface Session {
    user: {
      id: string;
      email: string;
      name?: string | null;
      image?: string | null;
      displayName?: string;
      avatar?: string;
    };
  }

  interface User {
    id: string;
    email: string;
    name?: string | null;
    displayName?: string;
    avatar?: string;
  }
}

declare module "next-auth/jwt" {
  interface JWT {
    displayName?: string;
    avatar?: string;
  }
}

export interface CameraConfig {
  width: number;
  height: number;
  facingMode: 'user' | 'environment';
}

export interface ROIConfig {
  x: number;
  y: number;
  width: number;
  height: number;
}

export interface ScoringResult {
  score: number;
  category: ChallengeCategory;
  breakdown: {
    edgeDetection?: number;
    brightnessAnalysis?: number;
    stainReduction?: number;
    reflectionQuality?: number;
    cleanlinessScore?: number;
    tidiness?: number;
    freeSpace?: number;
  };
  feedback: string;
}

export enum ChallengeCategory {
  MIRROR_CLEANING = 'MIRROR_CLEANING',
  TOILET_CLEANING = 'TOILET_CLEANING', 
  ROOM_TIDYING = 'ROOM_TIDYING'
}

export enum ChallengeStatus {
  IN_PROGRESS = 'IN_PROGRESS',
  COMPLETED = 'COMPLETED',
  FAILED = 'FAILED'
}

export interface User {
  id: string;
  email: string;
  name?: string;
  displayName?: string;
  avatar?: string;
}

export interface Challenge {
  id: string;
  userId: string;
  category: ChallengeCategory;
  status: ChallengeStatus;
  beforePhoto?: string;
  afterPhoto?: string;
  roiData?: ROIConfig;
  createdAt: Date;
  completedAt?: Date;
  scores?: Score[];
}

export interface Score {
  id: string;
  userId: string;
  challengeId: string;
  category: ChallengeCategory;
  scoreValue: number;
  breakdown: ScoringResult['breakdown'];
  combo: number;
  createdAt: Date;
}

export interface Household {
  id: string;
  name: string;
  code: string;
  ownerId: string;
  members: HouseholdMember[];
}

export interface HouseholdMember {
  id: string;
  userId: string;
  householdId: string;
  role: 'member' | 'admin';
  user: User;
}

export interface LeaderboardEntry {
  userId: string;
  displayName: string;
  avatar?: string;
  totalScore: number;
  challengesCompleted: number;
  averageScore: number;
  currentStreak: number;
  level: number;
}

export interface ComboInfo {
  count: number;
  multiplier: number;
  title: string;
}
