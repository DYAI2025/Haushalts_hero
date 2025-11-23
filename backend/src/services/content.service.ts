// ============================================
// Content Service
// ============================================

import { CoachingTip, MicroLearning, Season } from '../types';

export class ContentService {
  /**
   * Get coaching tips
   */
  async getCoachingTips(context?: string): Promise<CoachingTip[]> {
    // Static coaching tips for MVP
    // In production, these would come from a CMS or database
    const tips: CoachingTip[] = [
      {
        id: '1',
        title: 'Spiegel-Streifenfrei',
        message: 'Für streifenfreie Spiegel: Erst mit Glasreiniger putzen, dann mit Zeitungspapier nachpolieren!',
        category: 'mirror',
        context: 'after_challenge',
      },
      {
        id: '2',
        title: 'Toiletten-Trick',
        message: 'Lass den Reiniger 10 Minuten einwirken, bevor du putzt. Das spart Kraft!',
        category: 'toilet',
        context: 'before_challenge',
      },
      {
        id: '3',
        title: 'Aufräum-Methode',
        message: 'Die 5-Minuten-Regel: Setze dir einen Timer und räume schnell auf. Du wirst überrascht sein!',
        category: 'room',
        context: 'motivation',
      },
      {
        id: '4',
        title: 'Motivation',
        message: 'Jeder Anfang ist schwer, aber du machst das großartig! Weiter so!',
        context: 'encouragement',
      },
      {
        id: '5',
        title: 'Streak-Power',
        message: 'Du bist auf einem guten Weg! Behalte deinen Streak bei und sammle Bonuspunkte!',
        context: 'streak',
      },
      {
        id: '6',
        title: 'Perfektionist',
        message: 'Ein Score über 85 ist fantastisch! Du hast ein Auge fürs Detail!',
        context: 'high_score',
      },
      {
        id: '7',
        title: 'Learning Moment',
        message: 'Jede Challenge ist eine Chance zu lernen. Schau dir die Heatmap an!',
        context: 'low_score',
      },
    ];

    if (context) {
      return tips.filter((t) => t.context === context);
    }

    return tips;
  }

  /**
   * Get micro-learning modules
   */
  async getMicroLearning(): Promise<MicroLearning[]> {
    // Static micro-learning content for MVP
    const modules: MicroLearning[] = [
      {
        id: '1',
        title: 'Die Psychologie des Aufräumens',
        content: 'Studien zeigen, dass eine aufgeräumte Umgebung Stress reduziert und die Produktivität um bis zu 25% steigert.',
        duration: 60, // seconds
        category: 'psychology',
      },
      {
        id: '2',
        title: 'Nachhaltig Putzen',
        content: 'Essig und Natron sind umweltfreundliche Alternativen zu chemischen Reinigern und genauso effektiv!',
        duration: 45,
        category: 'sustainability',
      },
      {
        id: '3',
        title: 'Die 2-Minuten-Regel',
        content: 'Wenn etwas weniger als 2 Minuten dauert, mach es sofort! Diese Regel verhindert, dass sich Aufgaben stapeln.',
        duration: 30,
        category: 'productivity',
      },
      {
        id: '4',
        title: 'Hygiene-Mythen',
        content: 'Wusstest du? Die Küchenspüle enthält oft mehr Bakterien als die Toilette! Regelmäßiges Desinfizieren ist wichtig.',
        duration: 50,
        category: 'health',
      },
      {
        id: '5',
        title: 'Minimalismus-Prinzip',
        content: 'Weniger ist mehr: Reduziere Besitz und gewinne Lebensqualität. Frage dich: Brauche ich das wirklich?',
        duration: 40,
        category: 'lifestyle',
      },
    ];

    return modules;
  }

  /**
   * Get active season
   */
  async getActiveSeason(): Promise<Season | null> {
    const seasons = await this.getSeasons();
    const now = new Date();

    return seasons.find((s) => s.startDate <= now && s.endDate >= now) || null;
  }

  /**
   * Get all seasons
   */
  async getSeasons(): Promise<Season[]> {
    // Static seasons for MVP
    const currentYear = new Date().getFullYear();

    const seasons: Season[] = [
      {
        id: '1',
        name: 'Frühjahrsputz 2025',
        description: 'Der große Frühjahrsputz ist da! Sammle Bonuspunkte für jeden Raum, den du aufräumst.',
        startDate: new Date(currentYear, 2, 1), // March 1
        endDate: new Date(currentYear, 4, 31), // May 31
        isActive: this.isDateInRange(new Date(), new Date(currentYear, 2, 1), new Date(currentYear, 4, 31)),
        rewards: ['3x Punkte für Zimmer-Challenges', 'Exklusives Frühjahrs-Badge'],
      },
      {
        id: '2',
        name: 'Sommer-Glow 2025',
        description: 'Lass alles glänzen! Fokus auf Spiegel und Fenster.',
        startDate: new Date(currentYear, 5, 1), // June 1
        endDate: new Date(currentYear, 7, 31), // August 31
        isActive: this.isDateInRange(new Date(), new Date(currentYear, 5, 1), new Date(currentYear, 7, 31)),
        rewards: ['2x Punkte für Spiegel-Challenges', 'Sommer-Glow Badge'],
      },
      {
        id: '3',
        name: 'Herbst-Ordnung 2025',
        description: 'Bereite dein Zuhause auf die gemütliche Jahreszeit vor.',
        startDate: new Date(currentYear, 8, 1), // September 1
        endDate: new Date(currentYear, 10, 30), // November 30
        isActive: this.isDateInRange(new Date(), new Date(currentYear, 8, 1), new Date(currentYear, 10, 30)),
        rewards: ['2x Punkte für Raum-Organisation', 'Herbst-Ordnung Badge'],
      },
      {
        id: '4',
        name: 'Winter-Hygiene 2025',
        description: 'Bleib gesund! Extra Punkte für Hygiene-Challenges.',
        startDate: new Date(currentYear, 11, 1), // December 1
        endDate: new Date(currentYear + 1, 1, 28), // February 28
        isActive: this.isDateInRange(new Date(), new Date(currentYear, 11, 1), new Date(currentYear + 1, 1, 28)),
        rewards: ['2x Punkte für Toiletten-Challenges', 'Winter-Hygiene Badge'],
      },
    ];

    return seasons;
  }

  /**
   * Check if date is in range
   */
  private isDateInRange(date: Date, start: Date, end: Date): boolean {
    return date >= start && date <= end;
  }
}

export default new ContentService();
