/**
 * Shared Learning Resources Base Patterns
 * Common learning resource templates that can be adapted across frameworks and difficulty levels
 * Provides foundational books, courses, tools, and development paths
 */

export function useLearningResourcesBase() {
  
  /**
   * Core learning resource templates by competency and difficulty
   */
  const resourceTemplates = {
    'Active Listening': {
      beginner: {
        icon: '👂',
        title: 'Active Listening Fundamentals',
        description: 'Essential resources to build strong listening foundations.',
        resources: [
          'Book: "Co-Active Coaching" by Whitworth, Kimsey-House - Chapter 3: Listening',
          'Course: ICF Core Competency Workshop - Active Listening Basics',
          'Video: "The Lost Art of Listening" - Michael P. Nichols introduction',
          'Tool: Listening Self-Assessment - Track your listening habits'
        ]
      },
      intermediate: {
        icon: '👂',
        title: 'Advanced Listening Mastery',
        description: 'Sophisticated listening techniques for experienced coaches.',
        resources: [
          'Book: "Deep Listening" by Kay Lindahl - Spiritual aspects of listening',
          'Course: Somatic Listening Certification - Body-based awareness',
          'Training: Level III Listening Workshop - Energy and field awareness',
          'Tool: 360 Listening Feedback Assessment - Multi-perspective evaluation'
        ]
      },
      advanced: {
        icon: '👂',
        title: 'Mastery-Level Listening',
        description: 'Expert-level listening for organizational and systemic work.',
        resources: [
          'Book: "Presence" by Senge, Scharmer - Organizational listening',
          'Program: Organizational Listening Certification - Systems awareness',
          'Research: "Listening in Complex Systems" - Academic foundation',
          'Methodology: Develop your own listening assessment framework'
        ]
      }
    },

    'Powerful Questions': {
      beginner: {
        icon: '❓',
        title: 'Questioning Fundamentals',
        description: 'Learn to ask questions that create awareness and insight.',
        resources: [
          'Book: "The Coaching Habit" by Michael Bungay Stanier - 7 Essential Questions',
          'Guide: ICF Core Competencies - Powerful Questioning Examples',
          'Tool: Question Bank for Beginners - 50+ starter questions by situation',
          'Video: "Open vs Closed Questions" - Coaching Foundation Series'
        ]
      },
      intermediate: {
        icon: '❓',
        title: 'Advanced Questioning Techniques',
        description: 'Sophisticated inquiry methods for deeper client exploration.',
        resources: [
          'Book: "The Art of Powerful Questions" by Eric Vogt - Question frameworks',
          'Course: Solution-Focused Coaching - Advanced questioning methods',
          'Training: Clean Language Certification - Precise questioning techniques',
          'Tool: Advanced Question Bank - 200+ questions by coaching context'
        ]
      },
      advanced: {
        icon: '❓',
        title: 'Mastery-Level Inquiry',
        description: 'Expert questioning for organizational and systemic coaching.',
        resources: [
          'Book: "Theory U" by Otto Scharmer - Systemic questioning methods',
          'Program: Systemic Coaching Certification - Organizational inquiry',
          'Research: "Questions that Change Everything" - Advanced methodologies',
          'Development: Create proprietary questioning frameworks'
        ]
      }
    },

    'Creating Awareness': {
      beginner: {
        icon: '💡',
        title: 'Awareness Creation Basics',
        description: 'Foundational techniques for helping clients discover insights.',
        resources: [
          'Book: "Coaching for Performance" by John Whitmore - GROW Model Basics',
          'Course: Beginner Coach Training - Awareness and Insight Generation',
          'Tool: Reframing Techniques Cheat Sheet - 10 simple reframing methods',
          'Workshop: "Creating Aha Moments" - Local coaching meetup/online'
        ]
      },
      intermediate: {
        icon: '💡',
        title: 'Advanced Awareness Techniques',
        description: 'Sophisticated methods for generating client insights.',
        resources: [
          'Book: "Ontological Coaching" by Alan Sieler - Being-based awareness',
          'Course: Gestalt Coaching Certification - Here-and-now awareness',
          'Training: Perceptual Positions Workshop - Multiple perspective techniques',
          'Tool: Awareness Mapping Templates - Structured insight generation'
        ]
      },
      advanced: {
        icon: '💡',
        title: 'Mastery-Level Awareness',
        description: 'Expert awareness creation for complex organizational work.',
        resources: [
          'Book: "Integral Coaching" by Laura Divine - Multi-level awareness',
          'Program: Systems Constellation Training - Field awareness methods',
          'Research: "Consciousness in Coaching" - Academic perspectives',
          'Innovation: Develop new awareness methodologies'
        ]
      }
    },

    'Goal Setting': {
      beginner: {
        icon: '🎯',
        title: 'Goal Setting & Action Planning',
        description: 'Essential frameworks for creating achievable goals.',
        resources: [
          'Book: "The 4 Disciplines of Execution" - Goal achievement fundamentals',
          'Tool: SMART Goals Worksheet - Simple template for beginners',
          'Course: "Goal Setting That Works" - Basic accountability systems',
          'Guide: GROW Model Step-by-Step - Beginner implementation'
        ]
      },
      intermediate: {
        icon: '🎯',
        title: 'Advanced Goal Design',
        description: 'Sophisticated goal-setting and achievement methodologies.',
        resources: [
          'Book: "Atomic Habits" by James Clear - Systems thinking for goals',
          'Course: Advanced Goal Architecture - Multi-level goal design',
          'Training: Values-Based Goal Setting - Alignment methodologies',
          'Tool: Goal Ecosystem Mapping - Interconnected goal systems'
        ]
      },
      advanced: {
        icon: '🎯',
        title: 'Mastery-Level Goal Systems',
        description: 'Expert-level goal architecture for organizational change.',
        resources: [
          'Book: "Theory of Constraints" by Goldratt - Systems goal optimization',
          'Program: Organizational Goal Systems - Enterprise-level design',
          'Research: "Goal Science" - Academic foundation and latest findings',
          'Innovation: Develop breakthrough goal methodologies'
        ]
      }
    },

    'Direct Communication': {
      beginner: {
        icon: '💬',
        title: 'Direct Communication Skills',
        description: 'Learn to communicate with clarity and compassion.',
        resources: [
          'Book: "Crucial Conversations" by Kerry Patterson - Foundation skills',
          'Tool: "I" Statements Practice Sheet - Direct feedback templates',
          'Video: "How to Give Feedback" - Basic delivery techniques',
          'Course: Assertiveness Training for Coaches - Online fundamentals'
        ]
      },
      intermediate: {
        icon: '💬',
        title: 'Advanced Communication Mastery',
        description: 'Sophisticated direct communication for complex situations.',
        resources: [
          'Book: "Radical Candor" by Kim Scott - Caring direct communication',
          'Course: Difficult Conversations Mastery - Advanced techniques',
          'Training: Nonviolent Communication - Compassionate directness',
          'Tool: Communication Style Assessment - Adaptive approaches'
        ]
      },
      advanced: {
        icon: '💬',
        title: 'Mastery-Level Communication',
        description: 'Expert communication for organizational transformation.',
        resources: [
          'Book: "Conversational Intelligence" by Judith Glaser - Neuroscience approach',
          'Program: Organizational Communication - Systems-level impact',
          'Research: "Communication in Change" - Academic methodologies',
          'Development: Create communication transformation frameworks'
        ]
      }
    }
  }

  /**
   * Foundation and advancement resources based on overall performance
   */
  const performanceBasedResources = {
    foundation: {
      icon: '🏗️',
      title: 'Coaching Foundation Building',
      description: 'Core resources every new coach needs.',
      resources: [
        'Book: "Co-Active Coaching" by Whitworth, Kimsey-House - The coaching bible',
        'Course: ICF-Approved Coach Training Program - Get certified',
        'Community: Local ICF Chapter Membership - Find practice partners',
        'Mentor: Connect with an experienced coach for guidance'
      ]
    },
    advancement: {
      icon: '🚀',
      title: 'Ready for Next Level',
      description: 'You\'ve mastered the basics - time to level up.',
      resources: [
        'Assessment: Take next difficulty level assessment',
        'Certification: ICF Credential Preparation - Professional development',
        'Program: Specialized Coaching Niche Training - Choose focus area',
        'Book: Advanced methodology for your framework'
      ]
    },
    mastery: {
      icon: '👑',
      title: 'Mastery-Level Development',
      description: 'Advanced resources for coaching mastery.',
      resources: [
        'Certification: ICF MCC Credential Path - Master level',
        'Program: Advanced Specialization Training',
        'Research: Contribute to coaching methodology development',
        'Teaching: Train other coaches in your areas of expertise'
      ]
    }
  }

  /**
   * Generate learning resources based on competency performance
   */
  const generateLearningResources = (competencyStats, overallScore, difficulty = 'beginner', customizations = {}) => {
    if (!competencyStats?.length) return []
    
    const resources = []
    const lowPerformance = competencyStats.filter(comp => comp.percentage < 70)
    
    // Add competency-specific resources for weak areas
    lowPerformance.forEach(comp => {
      const template = resourceTemplates[comp.area]
      if (template && template[difficulty]) {
        const resource = { ...template[difficulty] }
        
        // Apply any framework-specific customizations
        if (customizations[comp.area]) {
          resource.title = customizations[comp.area].title || resource.title
          resource.description = customizations[comp.area].description || resource.description
          resource.resources = [...resource.resources, ...(customizations[comp.area].additionalResources || [])]
        }
        
        resources.push(resource)
      }
    })
    
    // Add performance-based resources
    if (overallScore < 60) {
      resources.push(performanceBasedResources.foundation)
    } else if (overallScore >= 80) {
      const advancement = { ...performanceBasedResources.advancement }
      advancement.resources[0] = `Assessment: Take ${difficulty === 'beginner' ? 'intermediate' : 'advanced'} level assessment`
      resources.push(advancement)
    } else if (overallScore >= 90) {
      resources.push(performanceBasedResources.mastery)
    }
    
    return resources
  }

  /**
   * Get resource recommendations for specific competency
   */
  const getCompetencyResources = (competencyArea, difficulty = 'beginner', customizations = {}) => {
    const template = resourceTemplates[competencyArea]
    if (!template || !template[difficulty]) {
      return generateGenericResources(competencyArea, difficulty)
    }
    
    const resource = { ...template[difficulty] }
    
    // Apply customizations
    if (customizations) {
      resource.title = customizations.title || resource.title
      resource.description = customizations.description || resource.description
      if (customizations.additionalResources) {
        resource.resources = [...resource.resources, ...customizations.additionalResources]
      }
    }
    
    return resource
  }

  /**
   * Generate generic resources for competencies not in templates
   */
  const generateGenericResources = (competencyArea, difficulty) => {
    const difficultyLabels = {
      beginner: 'Fundamentals',
      intermediate: 'Advanced',
      advanced: 'Mastery-Level'
    }
    
    return {
      icon: '📚',
      title: `${competencyArea} ${difficultyLabels[difficulty] || 'Resources'}`,
      description: `${difficulty} level resources for ${competencyArea} development.`,
      resources: [
        `Book: Research foundational ${competencyArea} literature`,
        `Course: Find ${difficulty} level ${competencyArea} training`,
        `Tool: Develop ${competencyArea} practice exercises`,
        `Community: Connect with ${competencyArea} specialists`
      ]
    }
  }

  return {
    generateLearningResources,
    getCompetencyResources,
    resourceTemplates,
    performanceBasedResources
  }
}