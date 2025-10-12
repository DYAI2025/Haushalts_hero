
export const CATEGORIES = {
  MIRROR_CLEANING: {
    name: 'Spiegel putzen',
    icon: '🪞',
    description: 'Streifenfreie Reflexion erreichen',
    color: 'blue',
    criteria: ['Streifenreduktion', 'Reflexionsqualität', 'Sauberkeit']
  },
  TOILET_CLEANING: {
    name: 'Toilette putzen', 
    icon: '🚽',
    description: 'Flecken und Verschmutzung entfernen',
    color: 'green',
    criteria: ['Fleckenentfernung', 'Hygiene', 'Glanz']
  },
  ROOM_TIDYING: {
    name: 'Zimmer aufräumen',
    icon: '🏠',
    description: 'Ordnung und freie Flächen schaffen',
    color: 'purple',
    criteria: ['Unordnungsreduktion', 'Freie Flächen', 'Organisation']
  }
} as const;

export const SCORE_THRESHOLDS = {
  VICTORY: 75,
  GOOD: 60,
  AVERAGE: 40,
  POOR: 20
} as const;

export const COMBO_MULTIPLIERS = {
  1: { multiplier: 1.0, title: 'Erster Versuch' },
  2: { multiplier: 1.1, title: 'Doppelschlag!' },
  3: { multiplier: 1.2, title: 'Triple Kill!' },
  4: { multiplier: 1.3, title: 'Quadruple!' },
  5: { multiplier: 1.5, title: 'Pentakill!' },
  10: { multiplier: 2.0, title: 'LEGENDÄR!' }
} as const;

export const LEVEL_REQUIREMENTS = [
  0, 100, 300, 600, 1000, 1500, 2100, 2800, 3600, 4500, 5500
] as const;

export const CAMERA_CONSTRAINTS = {
  video: {
    width: { ideal: 1280 },
    height: { ideal: 720 },
    facingMode: 'environment'
  }
} as const;

export const ROI_PRESETS = {
  MIRROR_CLEANING: { x: 0.1, y: 0.1, width: 0.8, height: 0.8 },
  TOILET_CLEANING: { x: 0.15, y: 0.2, width: 0.7, height: 0.6 },
  ROOM_TIDYING: { x: 0.05, y: 0.1, width: 0.9, height: 0.8 }
} as const;
