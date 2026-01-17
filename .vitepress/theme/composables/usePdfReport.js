/**
 * Composable for generating PDF reports from AI assessment results
 * Uses pdfmake for reliable client-side PDF generation
 */

import { ref } from 'vue'

// Cache for pdfMake instance
let pdfMakeInstance = null

/**
 * Load image as base64 for pdfmake
 */
async function loadImageAsBase64(url) {
  try {
    const response = await fetch(url)
    const blob = await response.blob()
    return new Promise((resolve, reject) => {
      const reader = new FileReader()
      reader.onloadend = () => resolve(reader.result)
      reader.onerror = reject
      reader.readAsDataURL(blob)
    })
  } catch (err) {
    console.error('Failed to load image:', err)
    return null
  }
}

// CDN sources for pdfmake with fallbacks
const PDFMAKE_CDNS = [
  {
    main: 'https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.2.10/pdfmake.min.js',
    fonts: 'https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.2.10/vfs_fonts.min.js'
  },
  {
    main: 'https://cdn.jsdelivr.net/npm/pdfmake@0.2.10/build/pdfmake.min.js',
    fonts: 'https://cdn.jsdelivr.net/npm/pdfmake@0.2.10/build/vfs_fonts.min.js'
  },
  {
    main: 'https://unpkg.com/pdfmake@0.2.10/build/pdfmake.min.js',
    fonts: 'https://unpkg.com/pdfmake@0.2.10/build/vfs_fonts.min.js'
  }
]

/**
 * Load a script from URL with timeout
 */
function loadScript(src, timeout = 10000) {
  return new Promise((resolve, reject) => {
    const script = document.createElement('script')
    script.src = src

    const timer = setTimeout(() => {
      reject(new Error(`Script load timeout: ${src}`))
    }, timeout)

    script.onload = () => {
      clearTimeout(timer)
      resolve()
    }
    script.onerror = () => {
      clearTimeout(timer)
      reject(new Error(`Failed to load: ${src}`))
    }
    document.head.appendChild(script)
  })
}

/**
 * Load pdfmake from CDN with fallbacks (avoids Vite bundling issues)
 */
async function loadPdfMake() {
  if (pdfMakeInstance) return pdfMakeInstance

  // Check if already loaded globally
  if (window.pdfMake) {
    pdfMakeInstance = window.pdfMake
    return pdfMakeInstance
  }

  // Try each CDN until one works
  let lastError = null
  for (const cdn of PDFMAKE_CDNS) {
    try {
      await loadScript(cdn.main)
      await loadScript(cdn.fonts)

      if (window.pdfMake) {
        pdfMakeInstance = window.pdfMake
        return pdfMakeInstance
      }
    } catch (err) {
      lastError = err
      console.warn(`pdfmake CDN failed, trying next:`, err.message)
      continue
    }
  }

  throw lastError || new Error('All pdfmake CDN sources failed')
}

export function usePdfReport() {
  const generating = ref(false)
  const error = ref(null)

  /**
   * Generate PDF from assessment data and AI report
   */
  const generatePdf = async ({
    assessmentTitle,
    framework,
    difficulty,
    score,
    correctAnswers,
    totalQuestions,
    timeSpent,
    completedAt,
    competencyStats,
    aiReport,
    parsedReport
  }) => {
    generating.value = true
    error.value = null

    try {
      // Load pdfmake from CDN to avoid Vite bundling issues
      const pdfMake = await loadPdfMake()

      // Load logo
      const logoUrl = 'https://hfmpacbmbyvnupzgorek.supabase.co/storage/v1/object/public/coaching-downloads/assets/logo.png'
      const logoBase64 = await loadImageAsBase64(logoUrl)

      // Build document definition
      const docDefinition = buildDocDefinition({
        assessmentTitle,
        framework,
        difficulty,
        score,
        correctAnswers,
        totalQuestions,
        timeSpent,
        completedAt,
        competencyStats,
        parsedReport,
        logoBase64
      })

      // Generate and download PDF
      pdfMake.createPdf(docDefinition).download(`coaching-assessment-report-${Date.now()}.pdf`)

      return true
    } catch (err) {
      console.error('PDF generation error:', err)
      error.value = err.message || 'Failed to generate PDF'
      return false
    } finally {
      generating.value = false
    }
  }

  return {
    generating,
    error,
    generatePdf
  }
}

/**
 * Build pdfmake document definition
 */
function buildDocDefinition({
  assessmentTitle,
  framework,
  difficulty,
  score,
  correctAnswers,
  totalQuestions,
  timeSpent,
  completedAt,
  competencyStats,
  parsedReport,
  logoBase64
}) {
  const scoreLabel = getScoreLabel(score)
  const scoreColor = getScoreColor(score)
  const formattedDate = formatDate(completedAt)
  const formattedTime = formatTime(timeSpent)
  const generatedDate = new Date().toLocaleDateString('en-GB', {
    day: 'numeric',
    month: 'long',
    year: 'numeric'
  })

  // Build content array
  const content = []

  // Header with logo
  const headerColumns = []

  if (logoBase64) {
    headerColumns.push({
      image: logoBase64,
      width: 35
    })
  }

  headerColumns.push({
    stack: [
      { text: 'Your Coaching Hub', style: 'siteTitle' },
      { text: 'Professional Development Assessment Report', style: 'tagline' }
    ],
    width: '*',
    margin: [15, 0, 0, 0]
  })

  headerColumns.push({
    text: `Generated: ${generatedDate}`,
    style: 'reportDate',
    alignment: 'right',
    width: 'auto'
  })

  content.push({
    columns: headerColumns,
    margin: [0, 0, 0, 15]
  })

  // Divider line
  content.push({
    table: {
      widths: ['*'],
      body: [[{ text: '', fillColor: '#2d5a27' }]]
    },
    layout: { hLineWidth: () => 0, vLineWidth: () => 0, paddingTop: () => 1, paddingBottom: () => 1 },
    margin: [0, 0, 0, 20]
  })

  // Assessment Title and badges
  content.push({
    text: assessmentTitle || 'Coaching Assessment',
    style: 'assessmentTitle',
    alignment: 'center'
  })

  content.push({
    columns: [
      { text: '', width: '*' },
      {
        text: framework || 'Core',
        style: 'badgeFramework',
        width: 'auto',
        margin: [0, 0, 10, 0]
      },
      {
        text: difficulty || 'Beginner',
        style: 'badgeDifficulty',
        width: 'auto'
      },
      { text: '', width: '*' }
    ],
    margin: [0, 10, 0, 5]
  })

  content.push({
    text: `Completed on ${formattedDate}`,
    style: 'completionInfo',
    alignment: 'center',
    margin: [0, 0, 0, 20]
  })

  // Score Section - simplified layout
  content.push({
    table: {
      widths: [70, '*'],
      body: [[
        {
          text: `${score}%`,
          fontSize: 22,
          bold: true,
          color: 'white',
          fillColor: scoreColor,
          alignment: 'center',
          margin: [0, 12, 0, 12]
        },
        {
          stack: [
            { text: scoreLabel, style: 'scoreLabel', fontSize: 14 },
            { text: `${correctAnswers} of ${totalQuestions} questions correct`, style: 'scoreStats', margin: [0, 3, 0, 0] }
          ],
          margin: [12, 10, 0, 10]
        }
      ]]
    },
    layout: {
      hLineWidth: () => 0,
      vLineWidth: () => 0,
      fillColor: (rowIndex, node, columnIndex) => columnIndex === 1 ? '#f5f5f5' : null,
      paddingLeft: () => 0,
      paddingRight: () => 0,
      paddingTop: () => 0,
      paddingBottom: () => 0
    },
    margin: [0, 0, 0, 20]
  })

  // Competency Breakdown
  if (competencyStats && competencyStats.length > 0) {
    content.push({ text: 'Competency Breakdown', style: 'sectionTitle' })

    const competencyTableBody = competencyStats.map(stat => {
      const statColor = getScoreColor(stat.percentage)
      return [
        { text: stat.area, style: 'competencyName' },
        { text: `${stat.correct}/${stat.total}`, style: 'competencyDetail', alignment: 'center' },
        {
          text: `${stat.percentage}%`,
          bold: true,
          color: 'white',
          fillColor: statColor,
          alignment: 'center',
          margin: [0, 2, 0, 2]
        }
      ]
    })

    content.push({
      table: {
        headerRows: 1,
        widths: ['*', 60, 50],
        body: [
          [
            { text: 'Competency', bold: true, color: '#666' },
            { text: 'Score', bold: true, color: '#666', alignment: 'center' },
            { text: '%', bold: true, color: '#666', alignment: 'center' }
          ],
          ...competencyTableBody
        ]
      },
      layout: {
        hLineWidth: (i, node) => (i === 0 || i === 1 || i === node.table.body.length) ? 1 : 0,
        vLineWidth: () => 0,
        hLineColor: () => '#ddd',
        paddingTop: () => 6,
        paddingBottom: () => 6
      },
      margin: [0, 0, 0, 20]
    })
  }

  // AI Report Sections
  if (parsedReport) {
    if (parsedReport.overall) {
      content.push(buildAiSection('Overall Assessment', parsedReport.overall, '#2d5a27'))
    }
    if (parsedReport.strengths) {
      content.push(buildAiSection('Strength Areas', parsedReport.strengths, '#4caf50'))
    }
    if (parsedReport.development) {
      content.push(buildAiSection('Development Areas', parsedReport.development, '#ff9800'))
    }
    if (parsedReport.crossCompetency) {
      content.push(buildAiSection('Cross-Competency Insights', parsedReport.crossCompetency, '#2196f3'))
    }
    if (parsedReport.progress) {
      content.push(buildAiSection('Progress Notes', parsedReport.progress, '#9c27b0'))
    }
    if (parsedReport.priority) {
      content.push(buildAiSection('Priority Focus', parsedReport.priority, '#f44336'))
    }
  }

  // Footer
  content.push({
    stack: [
      {
        table: {
          widths: ['*'],
          body: [[{ text: '', fillColor: '#ddd' }]]
        },
        layout: { hLineWidth: () => 0, vLineWidth: () => 0, paddingTop: () => 0, paddingBottom: () => 0 }
      },
      { text: 'This report was generated by Your Coaching Hub assessment system.', style: 'footer', margin: [0, 10, 0, 0] },
      { text: 'Confidential - For personal development purposes only', style: 'footerItalic' },
      { text: 'www.yourcoachinghub.co.uk', style: 'footerWebsite' }
    ],
    margin: [0, 30, 0, 0]
  })

  return {
    content,
    styles: getStyles(),
    defaultStyle: {
      font: 'Roboto',
      fontSize: 10
    },
    pageMargins: [40, 40, 40, 40]
  }
}

/**
 * Build AI section block
 */
function buildAiSection(title, content, accentColor) {
  // Parse content - handle markdown-style formatting
  const parsedContent = parseMarkdownContent(content)

  return {
    table: {
      widths: [4, '*'],
      body: [[
        { text: '', fillColor: accentColor, border: [false, false, false, false] },
        {
          stack: [
            { text: title, style: 'aiSectionTitle' },
            ...parsedContent
          ],
          border: [false, false, false, false],
          margin: [10, 10, 10, 10]
        }
      ]]
    },
    layout: {
      fillColor: '#fafafa',
      hLineWidth: () => 0,
      vLineWidth: () => 0
    },
    margin: [0, 0, 0, 15]
  }
}

/**
 * Parse markdown-style content to pdfmake format
 */
function parseMarkdownContent(text) {
  if (!text) return [{ text: '' }]

  const lines = text.split('\n')
  const result = []
  let currentList = []

  lines.forEach(line => {
    const trimmed = line.trim()
    if (!trimmed) return

    // Check if it's a bullet point
    if (trimmed.startsWith('- ') || trimmed.startsWith('• ')) {
      const bulletText = trimmed.substring(2)
      currentList.push({ text: bulletText, style: 'listItem' })
    } else if (trimmed.match(/^\d+\.\s/)) {
      // Numbered list
      const listText = trimmed.replace(/^\d+\.\s/, '')
      currentList.push({ text: listText, style: 'listItem' })
    } else {
      // Flush any pending list
      if (currentList.length > 0) {
        result.push({
          ul: currentList.map(item => item.text),
          style: 'list',
          margin: [0, 5, 0, 5]
        })
        currentList = []
      }

      // Parse inline formatting
      let formattedText = parseInlineFormatting(trimmed)
      result.push({ text: formattedText, style: 'paragraph', margin: [0, 0, 0, 8] })
    }
  })

  // Flush any remaining list
  if (currentList.length > 0) {
    result.push({
      ul: currentList.map(item => item.text),
      style: 'list',
      margin: [0, 5, 0, 5]
    })
  }

  return result.length > 0 ? result : [{ text: text, style: 'paragraph' }]
}

/**
 * Parse inline markdown formatting (bold, italic)
 */
function parseInlineFormatting(text) {
  // Handle **bold** and *italic*
  const parts = []
  let remaining = text

  // Simple regex-based parsing for bold
  const boldRegex = /\*\*([^*]+)\*\*/g
  let lastIndex = 0
  let match

  while ((match = boldRegex.exec(text)) !== null) {
    if (match.index > lastIndex) {
      parts.push({ text: text.substring(lastIndex, match.index) })
    }
    parts.push({ text: match[1], bold: true, color: '#2d5a27' })
    lastIndex = match.index + match[0].length
  }

  if (lastIndex < text.length) {
    parts.push({ text: text.substring(lastIndex) })
  }

  return parts.length > 0 ? parts : text
}

/**
 * Get pdfmake styles
 */
function getStyles() {
  return {
    siteTitle: {
      fontSize: 20,
      bold: true,
      color: '#2d5a27'
    },
    tagline: {
      fontSize: 10,
      color: '#666',
      margin: [0, 3, 0, 0]
    },
    reportDate: {
      fontSize: 9,
      color: '#888'
    },
    assessmentTitle: {
      fontSize: 16,
      bold: true,
      color: '#333'
    },
    badgeFramework: {
      fontSize: 9,
      bold: true,
      color: '#2d5a27',
      background: '#e8f5e9',
      padding: [8, 4]
    },
    badgeDifficulty: {
      fontSize: 9,
      bold: true,
      color: '#1565c0',
      background: '#e3f2fd',
      padding: [8, 4]
    },
    completionInfo: {
      fontSize: 10,
      color: '#666'
    },
    scoreValue: {
      fontSize: 22,
      bold: true,
      color: 'white'
    },
    scoreLabel: {
      fontSize: 16,
      bold: true,
      color: '#333'
    },
    scoreStats: {
      fontSize: 10,
      color: '#666',
      margin: [0, 2, 0, 0]
    },
    sectionTitle: {
      fontSize: 14,
      bold: true,
      color: '#2d5a27',
      margin: [0, 15, 0, 10]
    },
    competencyName: {
      fontSize: 11,
      bold: true
    },
    competencyScore: {
      fontSize: 10,
      bold: true
    },
    competencyDetail: {
      fontSize: 9,
      color: '#666'
    },
    aiSectionTitle: {
      fontSize: 12,
      bold: true,
      color: '#333',
      margin: [0, 0, 0, 8]
    },
    paragraph: {
      fontSize: 10,
      lineHeight: 1.4
    },
    list: {
      fontSize: 10
    },
    listItem: {
      fontSize: 10
    },
    footer: {
      fontSize: 9,
      color: '#888',
      alignment: 'center'
    },
    footerItalic: {
      fontSize: 9,
      color: '#888',
      italics: true,
      alignment: 'center',
      margin: [0, 3, 0, 0]
    },
    footerWebsite: {
      fontSize: 9,
      color: '#2d5a27',
      bold: true,
      alignment: 'center',
      margin: [0, 3, 0, 0]
    }
  }
}

/**
 * Get score color
 */
function getScoreColor(score) {
  if (score >= 90) return '#2d5a27'
  if (score >= 80) return '#388e3c'
  if (score >= 70) return '#689f38'
  if (score >= 60) return '#ffa000'
  if (score >= 40) return '#f57c00'
  return '#d32f2f'
}

/**
 * Get score label
 */
function getScoreLabel(score) {
  if (score >= 90) return 'Outstanding Performance'
  if (score >= 80) return 'Strong Performance'
  if (score >= 70) return 'Proficient'
  if (score >= 60) return 'Developing'
  if (score >= 40) return 'Emerging'
  if (score >= 20) return 'Building Foundations'
  return 'Getting Started'
}

/**
 * Format date
 */
function formatDate(dateStr) {
  if (!dateStr) return 'Unknown'
  try {
    return new Date(dateStr).toLocaleDateString('en-GB', {
      day: 'numeric',
      month: 'long',
      year: 'numeric'
    })
  } catch {
    return dateStr
  }
}

/**
 * Format time spent
 */
function formatTime(seconds) {
  // Handle null, undefined, NaN, or non-numeric values
  if (seconds === null || seconds === undefined || isNaN(seconds) || typeof seconds !== 'number') {
    return 'Not recorded'
  }
  const totalSeconds = Math.floor(seconds)
  if (totalSeconds <= 0) return 'Not recorded'

  const mins = Math.floor(totalSeconds / 60)
  const secs = totalSeconds % 60
  if (mins === 0) return `${secs} second${secs !== 1 ? 's' : ''}`
  if (secs === 0) return `${mins} minute${mins !== 1 ? 's' : ''}`
  return `${mins}m ${secs}s`
}
