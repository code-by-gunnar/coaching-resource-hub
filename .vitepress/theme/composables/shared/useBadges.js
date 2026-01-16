// Shared badge styles and utilities
export const useBadges = () => {
  // CSS class definitions with custom CSS variables for dark/light mode compatibility
  const badgeStyles = `
/* Custom CSS Variables for Badge System - Light Mode */
:root {
  --badge-red-bg: #fee2e2;
  --badge-red-text: #b91c1c;
  --badge-green-bg: #dcfce7;
  --badge-green-text: #15803d;
  --badge-yellow-bg: #fef3c7;
  --badge-yellow-text: #d97706;
  --badge-blue-bg: #dbeafe;
  --badge-blue-text: #1d4ed8;
  --badge-purple-bg: #f3e8ff;
  --badge-purple-text: #7c3aed;
  --badge-indigo-bg: #e0e7ff;
  --badge-indigo-text: #4f46e5;
  --badge-gray-bg: #f3f4f6;
  --badge-gray-text: #4b5563;
  --badge-danger-bg: #fee2e2;
  --badge-danger-text: #b91c1c;
}

/* Custom CSS Variables - Dark Mode */
html.dark {
  --badge-red-bg: #451a1a;
  --badge-red-text: #f87171;
  --badge-green-bg: #1a2e1a;
  --badge-green-text: #4ade80;
  --badge-yellow-bg: #2d2a1a;
  --badge-yellow-text: #fbbf24;
  --badge-blue-bg: #1e3a5f;
  --badge-blue-text: #60a5fa;
  --badge-purple-bg: #2d1b3d;
  --badge-purple-text: #a855f7;
  --badge-indigo-bg: #1e1b4b;
  --badge-indigo-text: #818cf8;
  --badge-gray-bg: #374151;
  --badge-gray-text: #d1d5db;
  --badge-danger-bg: #451a1a;
  --badge-danger-text: #f87171;
}

[data-theme="dark"] {
  --badge-red-bg: #451a1a;
  --badge-red-text: #f87171;
  --badge-green-bg: #1a2e1a;
  --badge-green-text: #4ade80;
  --badge-yellow-bg: #2d2a1a;
  --badge-yellow-text: #fbbf24;
  --badge-blue-bg: #1e3a5f;
  --badge-blue-text: #60a5fa;
  --badge-purple-bg: #2d1b3d;
  --badge-purple-text: #a855f7;
  --badge-indigo-bg: #1e1b4b;
  --badge-indigo-text: #818cf8;
  --badge-gray-bg: #374151;
  --badge-gray-text: #d1d5db;
  --badge-danger-bg: #451a1a;
  --badge-danger-text: #f87171;
}
/* Analysis Type Badge - Strongest override with custom colors */
body .admin-content .analysis-type-badge,
body .table-section .analysis-type-badge,
.analysis-type-badge {
  display: inline-block !important;
  padding: 6px 12px !important;
  border-radius: 4px !important;
  font-size: 12px !important;
  font-weight: 500 !important;
  background: var(--badge-purple-bg) !important;
  color: var(--badge-purple-text) !important;
  white-space: nowrap !important;
  text-transform: none !important;
  border: none !important;
  line-height: 1.3 !important;
}

/* Traffic Light Colors for Analysis Types - Strongest override */
body .admin-content .analysis-type-badge.weakness,
body .table-section .analysis-type-badge.weakness,
.analysis-type-badge.weakness {
  background: var(--badge-red-bg) !important;
  color: var(--badge-red-text) !important;
}

body .admin-content .analysis-type-badge.strength,
body .table-section .analysis-type-badge.strength,
.analysis-type-badge.strength {
  background: var(--badge-green-bg) !important;
  color: var(--badge-green-text) !important;
}

body .admin-content .analysis-type-badge.developing,
body .table-section .analysis-type-badge.developing,
.analysis-type-badge.developing {
  background: var(--badge-yellow-bg) !important;
  color: var(--badge-yellow-text) !important;
}

/* Level Badge - Strongest override with custom colors */
body .admin-content .level-badge,
body .table-section .level-badge,
.level-badge {
  display: inline-block !important;
  padding: 6px 12px !important;
  border-radius: 4px !important;
  font-size: 12px !important;
  font-weight: 500 !important;
  background: var(--badge-gray-bg) !important;
  color: var(--badge-gray-text) !important;
  white-space: nowrap !important;
  text-transform: none !important;
  border: none !important;
  line-height: 1.3 !important;
}

body .admin-content .level-badge.foundational,
body .admin-content .level-badge.beginner,
body .table-section .level-badge.foundational,
body .table-section .level-badge.beginner,
.level-badge.foundational,
.level-badge.beginner {
  background: var(--badge-blue-bg) !important;
  color: var(--badge-blue-text) !important;
}

body .admin-content .level-badge.developing,
body .admin-content .level-badge.intermediate,
body .table-section .level-badge.developing,
body .table-section .level-badge.intermediate,
.level-badge.developing,
.level-badge.intermediate {
  background: var(--badge-yellow-bg) !important;
  color: var(--badge-yellow-text) !important;
}

body .admin-content .level-badge.advanced,
body .table-section .level-badge.advanced,
.level-badge.advanced {
  background: var(--badge-red-bg) !important;
  color: var(--badge-red-text) !important;
}

/* Framework Badge - Strongest override with custom colors */
body .admin-content .framework-badge,
body .table-section .framework-badge,
.framework-badge {
  display: inline-block !important;
  padding: 6px 12px !important;
  border-radius: 4px !important;
  font-size: 12px !important;
  font-weight: 600 !important;
  text-transform: uppercase !important;
  white-space: nowrap !important;
  background: var(--badge-gray-bg) !important;
  color: var(--badge-gray-text) !important;
  border: none !important;
  line-height: 1.3 !important;
}

body .admin-content .framework-badge.core,
body .table-section .framework-badge.core,
.framework-badge.core {
  background: var(--badge-purple-bg) !important;
  color: var(--badge-purple-text) !important;
}

body .admin-content .framework-badge.icf,
body .table-section .framework-badge.icf,
.framework-badge.icf {
  background: var(--badge-green-bg) !important;
  color: var(--badge-green-text) !important;
}

body .admin-content .framework-badge.ac,
body .table-section .framework-badge.ac,
.framework-badge.ac {
  background: var(--badge-blue-bg) !important;
  color: var(--badge-blue-text) !important;
}

/* Resource Type Badge - Strongest override with custom colors */
body .admin-content .type-badge,
body .table-section .type-badge,
.type-badge {
  display: inline-block !important;
  padding: 6px 12px !important;
  border-radius: 4px !important;
  font-size: 12px !important;
  font-weight: 500 !important;
  background: var(--badge-gray-bg) !important;
  color: var(--badge-gray-text) !important;
  white-space: nowrap !important;
  text-transform: none !important;
  border: none !important;
  line-height: 1.3 !important;
}

body .admin-content .type-badge.Articles,
body .table-section .type-badge.Articles,
.type-badge.Articles {
  background: var(--badge-blue-bg) !important;
  color: var(--badge-blue-text) !important;
}

body .admin-content .type-badge.Videos,
body .table-section .type-badge.Videos,
.type-badge.Videos {
  background: var(--badge-red-bg) !important;
  color: var(--badge-red-text) !important;
}

body .admin-content .type-badge.Guides,
body .table-section .type-badge.Guides,
.type-badge.Guides {
  background: var(--badge-green-bg) !important;
  color: var(--badge-green-text) !important;
}

body .admin-content .type-badge.Tools,
body .table-section .type-badge.Tools,
.type-badge.Tools {
  background: var(--badge-purple-bg) !important;
  color: var(--badge-purple-text) !important;
}

body .admin-content .type-badge.Books,
body .table-section .type-badge.Books,
.type-badge.Books {
  background: var(--badge-yellow-bg) !important;
  color: var(--badge-yellow-text) !important;
}

body .admin-content .type-badge.Courses,
body .table-section .type-badge.Courses,
.type-badge.Courses {
  background: var(--badge-indigo-bg) !important;
  color: var(--badge-indigo-text) !important;
}

/* Status Badge - Strongest override with custom colors */
body .admin-content .status-badge,
body .table-section .status-badge,
.status-badge {
  display: inline-flex !important;
  align-items: center !important;
  padding: 6px 12px !important;
  border-radius: 4px !important;
  font-size: 13px !important;
  font-weight: 500 !important;
  background: var(--badge-danger-bg) !important;
  color: var(--badge-danger-text) !important;
  white-space: nowrap !important;
  min-width: fit-content !important;
  text-transform: none !important;
  cursor: pointer !important;
  transition: all 0.2s ease !important;
  border: none !important;
  line-height: 1.3 !important;
}

body .admin-content .status-badge.active,
body .table-section .status-badge.active,
.status-badge.active {
  background: var(--badge-green-bg) !important;
  color: var(--badge-green-text) !important;
}

body .admin-content .status-badge:hover,
body .table-section .status-badge:hover,
.status-badge:hover {
  transform: translateY(-1px);
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

body .admin-content .status-badge.inactive,
body .table-section .status-badge.inactive,
.status-badge.inactive {
  background: var(--badge-gray-bg) !important;
  color: var(--badge-gray-text) !important;
}

/* Additional Admin-specific Badges - Strongest override */
body .admin-content .priority-badge,
body .table-section .priority-badge,
.priority-badge {
  display: inline-block !important;
  padding: 6px 12px !important;
  border-radius: 4px !important;
  font-size: 13px !important;
  font-weight: 500 !important;
  background: var(--badge-gray-bg) !important;
  color: var(--badge-gray-text) !important;
  text-align: center !important;
  min-width: 32px !important;
  text-transform: none !important;
  border: none !important;
  line-height: 1.3 !important;
}

body .admin-content .range-badge,
body .table-section .range-badge,
.range-badge {
  display: inline-block !important;
  padding: 6px 12px !important;
  border-radius: 4px !important;
  font-size: 13px !important;
  font-weight: 500 !important;
  background: var(--badge-indigo-bg) !important;
  color: var(--badge-indigo-text) !important;
  font-family: monospace !important;
  text-transform: none !important;
  border: none !important;
  line-height: 1.3 !important;
}

body .admin-content .answer-badge,
body .table-section .answer-badge,
.answer-badge {
  display: inline-block !important;
  padding: 6px 12px !important;
  border-radius: 4px !important;
  font-size: 13px !important;
  font-weight: 500 !important;
  background: var(--badge-indigo-bg) !important;
  color: var(--badge-indigo-text) !important;
  font-family: monospace !important;
  text-transform: none !important;
  border: none !important;
  line-height: 1.3 !important;
}

/* Scoring Tier Badge - Strongest override with traffic light colors */
body .admin-content .tier-badge,
body .table-section .tier-badge,
.tier-badge {
  display: inline-block !important;
  padding: 6px 12px !important;
  border-radius: 4px !important;
  font-size: 12px !important;
  font-weight: 500 !important;
  background: var(--badge-gray-bg) !important;
  color: var(--badge-gray-text) !important;
  white-space: nowrap !important;
  text-transform: none !important;
  border: none !important;
  line-height: 1.3 !important;
}

body .admin-content .tier-badge.tier-low,
body .table-section .tier-badge.tier-low,
.tier-badge.tier-low {
  background: var(--badge-red-bg) !important;
  color: var(--badge-red-text) !important;
}

body .admin-content .tier-badge.tier-medium,
body .table-section .tier-badge.tier-medium,
.tier-badge.tier-medium {
  background: var(--badge-orange-bg) !important;
  color: var(--badge-orange-text) !important;
}

body .admin-content .tier-badge.tier-high,
body .table-section .tier-badge.tier-high,
.tier-badge.tier-high {
  background: var(--badge-green-bg) !important;
  color: var(--badge-green-text) !important;
}

body .admin-content .tier-badge.tier-none,
body .table-section .tier-badge.tier-none,
.tier-badge.tier-none {
  background: var(--badge-gray-bg) !important;
  color: var(--badge-gray-text) !important;
  font-style: italic !important;
}

body .admin-content .tier-badge.weakness,
body .table-section .tier-badge.weakness,
.tier-badge.weakness {
  background: var(--badge-red-bg) !important;
  color: var(--badge-red-text) !important;
}

body .admin-content .tier-badge.developing,
body .table-section .tier-badge.developing,
.tier-badge.developing {
  background: var(--badge-yellow-bg) !important;
  color: var(--badge-yellow-text) !important;
}

body .admin-content .tier-badge.strength,
body .table-section .tier-badge.strength,
.tier-badge.strength {
  background: var(--badge-green-bg) !important;
  color: var(--badge-green-text) !important;
}

body .admin-content .field-count,
body .table-section .field-count,
.field-count {
  font-size: 14px !important;
  font-weight: 500 !important;
  color: var(--badge-gray-text) !important;
}

/* Action Buttons - Consistent with badge sizing */
body .admin-content .action-btn,
body .table-section .action-btn,
.action-btn {
  padding: 6px 12px !important;
  border: none !important;
  border-radius: 4px !important;
  font-size: 13px !important;
  font-weight: 500 !important;
  cursor: pointer !important;
  transition: all 0.2s !important;
  white-space: nowrap !important;
  line-height: 1.3 !important;
}

body .admin-content .action-btn.edit,
body .table-section .action-btn.edit,
.action-btn.edit {
  background: var(--badge-blue-bg) !important;
  color: var(--badge-blue-text) !important;
}

body .admin-content .action-btn.edit:hover,
body .table-section .action-btn.edit:hover,
.action-btn.edit:hover {
  background: var(--badge-blue-text) !important;
  color: white !important;
}

body .admin-content .action-btn.delete,
body .table-section .action-btn.delete,
.action-btn.delete {
  background: var(--badge-red-bg) !important;
  color: var(--badge-red-text) !important;
}

body .admin-content .action-btn.delete:hover,
body .table-section .action-btn.delete:hover,
.action-btn.delete:hover {
  background: var(--badge-red-text) !important;
  color: white !important;
}
  `

  // Utility function to get level class for dynamic styling
  const getLevelClass = (levelName) => {
    if (!levelName) return 'unknown'
    const name = levelName.toLowerCase()
    if (name.includes('beginner') || name.includes('foundational')) return 'beginner'
    if (name.includes('intermediate') || name.includes('developing')) return 'intermediate'
    if (name.includes('advanced')) return 'advanced'
    return 'unknown'
  }

  // Utility function to get framework class
  const getFrameworkClass = (frameworkCode) => {
    if (!frameworkCode) return ''
    return frameworkCode.toLowerCase()
  }

  // Utility function to get resource type class
  const getResourceTypeClass = (typeName) => {
    if (!typeName) return ''
    return typeName
  }

  // Utility function to get analysis type class for traffic light colors
  const getAnalysisTypeClass = (analysisTypeName) => {
    if (!analysisTypeName) return ''
    const name = analysisTypeName.toLowerCase()
    if (name.includes('weakness')) return 'weakness'
    if (name.includes('strength')) return 'strength'
    if (name.includes('developing')) return 'developing'
    return ''
  }

  // Utility function to get tier class for scoring tiers
  const getTierClass = (tierCode) => {
    if (!tierCode) return ''
    const code = tierCode.toLowerCase()
    if (code.includes('low') || code.includes('weak')) return 'tier-low'
    if (code.includes('high') || code.includes('strong')) return 'tier-high'
    if (code.includes('mid') || code.includes('med')) return 'tier-medium'
    return 'tier-default'
  }

  // Function to inject styles into the page
  const injectBadgeStyles = () => {
    if (typeof document !== 'undefined') {
      const existingStyle = document.getElementById('shared-badge-styles')
      if (!existingStyle) {
        const style = document.createElement('style')
        style.id = 'shared-badge-styles'
        style.textContent = badgeStyles
        document.head.appendChild(style)
      }
    }
  }

  return {
    badgeStyles,
    getLevelClass,
    getFrameworkClass, 
    getResourceTypeClass,
    getAnalysisTypeClass,
    getTierClass,
    injectBadgeStyles
  }
}