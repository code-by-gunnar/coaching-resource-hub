/**
 * Base Strength Leverage Patterns
 * Common strength leveraging concepts that can be adapted across frameworks and difficulty levels
 */

export function useStrengthLeverageBase() {
  
  /**
   * Core strength leverage patterns that can be customized per framework/difficulty
   */
  const strengthLeveragePatterns = {
    'Active Listening': {
      beginner: {
        personal: 'Practice with friends/family - become known as a great listener',
        social: 'Use your listening skills to help others feel heard',
        professional: 'Volunteer to be the note-taker in meetings',
        impact: 'When people feel heard by you, they open up faster'
      },
      intermediate: {
        personal: 'Model deep listening for colleagues - become the team\'s listening champion',
        social: 'Teach listening techniques to other coaches',
        professional: 'Offer to mentor junior coaches on advanced listening',
        impact: 'Your listening creates safe space for deeper client exploration'
      },
      advanced: {
        personal: 'Master organizational listening - understand systemic dynamics',
        social: 'Lead listening skills workshops for coaching organizations',
        professional: 'Become the go-to coach for complex emotional situations',
        impact: 'Your listening unlocks breakthrough insights others miss'
      }
    },
    
    'Powerful Questions': {
      beginner: {
        personal: 'Ask one powerful question per day in conversations',
        social: 'Help others solve problems by asking better questions',
        professional: 'Become the person who asks questions others don\'t think of',
        impact: 'Your questions help people think differently'
      },
      intermediate: {
        personal: 'Create signature questions that become your trademark',
        social: 'Teach questioning frameworks to other coaches',
        professional: 'Use advanced questioning in complex client situations',
        impact: 'Your questions unlock awareness and breakthrough insights'
      },
      advanced: {
        personal: 'Master systemic questioning for organizational change',
        social: 'Lead workshops on advanced questioning techniques',
        professional: 'Specialize in coaching leaders through complex decisions',
        impact: 'Your questions transform how people see entire systems'
      }
    },
    
    'Creating Awareness': {
      beginner: {
        personal: 'Help someone see a blind spot they didn\'t know they had',
        social: 'Point out positive patterns people don\'t notice',
        professional: 'Use awareness skills to help teammates connect dots',
        impact: 'You help people see themselves clearly - builds deep trust'
      },
      intermediate: {
        personal: 'Position yourself as the coach who reveals blind spots',
        social: 'Help clients connect patterns across different life areas',
        professional: 'Guide teams to see systemic patterns they\'re missing',
        impact: 'Your awareness creation makes you the coach others recommend'
      },
      advanced: {
        personal: 'Master organizational pattern recognition',
        social: 'Train other coaches in advanced awareness techniques',
        professional: 'Specialize in helping leaders see complex dynamics',
        impact: 'Your insights transform how people understand entire systems'
      }
    }
  }
  
  /**
   * Generate strength leverage actions based on competency, difficulty, and framework
   */
  const generateStrengthActions = (competency, difficulty, customizations = {}) => {
    const pattern = strengthLeveragePatterns[competency]
    if (!pattern || !pattern[difficulty]) {
      return generateGenericStrengthActions(competency, difficulty)
    }
    
    const actions = []
    const levelPattern = pattern[difficulty]
    
    // Apply customizations or use default pattern
    actions.push(`This week: ${customizations.personal || levelPattern.personal}`)
    actions.push(`Next opportunity: ${customizations.social || levelPattern.social}`)
    actions.push(`Try this: ${customizations.professional || levelPattern.professional}`)
    actions.push(`Leverage it: ${customizations.impact || levelPattern.impact}`)
    
    return actions
  }
  
  /**
   * Generate generic strength actions when no specific pattern exists
   */
  const generateGenericStrengthActions = (competency, difficulty) => {
    const difficultyLevel = {
      beginner: {
        scope: 'personal practice',
        timeline: 'this week',
        impact: 'builds confidence'
      },
      intermediate: {
        scope: 'professional development',
        timeline: 'this month',
        impact: 'establishes expertise'
      },
      advanced: {
        scope: 'thought leadership',
        timeline: 'this quarter',
        impact: 'transforms industry practices'
      }
    }
    
    const level = difficultyLevel[difficulty] || difficultyLevel.beginner
    
    return [
      `${level.timeline}: Use your ${competency} strength in ${level.scope}`,
      `Next opportunity: Share your ${competency} expertise with others`,
      `Try this: Become known for your ${competency} skills`,
      `Leverage it: Your ${competency} strength ${level.impact} - lean into it`
    ]
  }
  
  /**
   * Get strength development trajectory for a competency
   */
  const getStrengthTrajectory = (competency) => {
    const pattern = strengthLeveragePatterns[competency]
    if (!pattern) return null
    
    return {
      beginner: pattern.beginner?.impact || 'Build foundation',
      intermediate: pattern.intermediate?.impact || 'Develop expertise',
      advanced: pattern.advanced?.impact || 'Lead transformation'
    }
  }

  return {
    generateStrengthActions,
    getStrengthTrajectory,
    strengthLeveragePatterns
  }
}