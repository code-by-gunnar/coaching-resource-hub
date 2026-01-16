<template>
  <div class="admin-container">
    <!-- Loading state during auth check -->
    <div v-if="!isAuthLoaded" class="admin-content">
      <div class="admin-header">
        <h1>🔄 Loading...</h1>
        <p class="admin-subtitle">Checking administrator access...</p>
      </div>
    </div>

    <!-- Admin Access Check -->
    <div v-else-if="!hasAdminAccess" class="admin-content">
      <div class="admin-header">
        <h1>⛔ Admin Access Required</h1>
        <p class="admin-subtitle">You need administrator privileges to import questions.</p>
      </div>
      <ActionButton href="/docs/admin/" variant="secondary" icon="←">Back to Admin Hub</ActionButton>
    </div>

    <!-- CSV Import Interface -->
    <div v-else class="admin-content">
      <div class="admin-header">
        <div class="header-main">
          <h1>📥 Bulk Question Import</h1>
          <p class="admin-subtitle">Import multiple assessment questions from CSV file</p>
        </div>
      </div>

      <nav class="breadcrumb">
        <ActionButton href="/docs/admin/" variant="gray">Admin Hub</ActionButton>
        <span class="breadcrumb-separator">→</span>
        <ActionButton href="/docs/admin/assessments/" variant="gray">Assessments</ActionButton>
        <span class="breadcrumb-separator">→</span>
        <span>Import Questions</span>
      </nav>

      <!-- CSV Template Download -->
      <div class="import-section">
        <div class="section-header">
          <h2>📋 1. Download CSV Template</h2>
          <p>Use this template to format your questions correctly</p>
        </div>
        
        <div class="template-card">
          <div class="template-info">
            <h3>📄 CSV Template Format</h3>
            <p>Required columns (in this exact order):</p>
            <ul class="column-list">
              <li><code>assessment_id</code> - UUID of the assessment</li>
              <li><code>question_order</code> - Question number (1, 2, 3...)</li>
              <li><code>scenario</code> - Optional context/scenario</li>
              <li><code>question</code> - The question text</li>
              <li><code>option_a</code> - First answer option</li>
              <li><code>option_b</code> - Second answer option</li>
              <li><code>option_c</code> - Third answer option</li>
              <li><code>option_d</code> - Fourth answer option</li>
              <li><code>correct_answer</code> - Correct option (1, 2, 3, or 4)</li>
              <li><code>explanation</code> - Explanation of why this answer is correct (optional)</li>
              <li><code>competency_id</code> - UUID of competency area</li>
              <li><code>assessment_level_id</code> - UUID of assessment level (optional)</li>
              <li><code>difficulty_weight</code> - Difficulty (0.1-5.0, default: 1.0)</li>
              <li><code>is_active</code> - Active status (true/false, default: true)</li>
            </ul>
          </div>
          
          <div class="template-actions">
            <ActionButton @click="downloadTemplate" variant="primary" icon="💾">
              Download Template
            </ActionButton>
            <ActionButton @click="downloadSampleData" variant="secondary" icon="📊">
              Download Sample Data
            </ActionButton>
          </div>
        </div>
      </div>

      <!-- Reference Data Display -->
      <div class="import-section">
        <div class="section-header">
          <h2>🔍 2. Reference IDs</h2>
          <p>Use these IDs in your CSV file</p>
        </div>
        
        <div class="reference-grid">
          <!-- Assessments -->
          <div class="reference-card">
            <h3>📝 Assessments</h3>
            <div v-if="loadingReference" class="loading-text">Loading...</div>
            <div v-else class="reference-list">
              <div v-for="assessment in assessments" :key="assessment.id" class="reference-item">
                <code class="reference-id">{{ assessment.id }}</code>
                <span class="reference-name">{{ assessment.title }}</span>
              </div>
            </div>
          </div>

          <!-- Competencies -->
          <div class="reference-card">
            <h3>🎯 Competencies</h3>
            <div v-if="loadingReference" class="loading-text">Loading...</div>
            <div v-else class="reference-list">
              <div v-for="competency in competencies" :key="competency.id" class="reference-item">
                <code class="reference-id">{{ competency.id }}</code>
                <span class="reference-name">{{ competency.display_name }}</span>
              </div>
            </div>
          </div>

          <!-- Assessment Levels -->
          <div class="reference-card">
            <h3>📊 Assessment Levels</h3>
            <div v-if="loadingReference" class="loading-text">Loading...</div>
            <div v-else class="reference-list">
              <div v-for="level in assessmentLevels" :key="level.id" class="reference-item">
                <code class="reference-id">{{ level.id }}</code>
                <span class="reference-name">{{ level.level_name }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- File Upload -->
      <div class="import-section">
        <div class="section-header">
          <h2>📤 3. Upload CSV File</h2>
          <p>Select your formatted CSV file to import</p>
        </div>

        <div class="upload-area" :class="{ 'drag-over': isDragOver }" 
             @drop="handleDrop" @dragover="handleDragOver" @dragleave="handleDragLeave">
          <input ref="fileInput" type="file" accept=".csv" @change="handleFileSelect" class="file-input" />
          
          <div v-if="!selectedFile" class="upload-prompt">
            <div class="upload-icon">📁</div>
            <p><strong>Drag & drop your CSV file here</strong></p>
            <p>or <ActionButton @click="$refs.fileInput.click()" variant="text">browse files</ActionButton></p>
            <p class="upload-note">Maximum file size: 5MB</p>
          </div>

          <div v-else class="file-selected">
            <div class="file-icon">📄</div>
            <div class="file-info">
              <h3>{{ selectedFile.name }}</h3>
              <p>{{ formatFileSize(selectedFile.size) }} • {{ previewData.length }} rows</p>
            </div>
            <ActionButton @click="clearFile" variant="danger" icon="✖" />
          </div>
        </div>

        <div v-if="parseError" class="error-message">
          <strong>CSV Parse Error:</strong> {{ parseError }}
        </div>
      </div>

      <!-- Preview Data -->
      <div v-if="previewData.length > 0" class="import-section">
        <div class="section-header">
          <h2>👀 4. Preview Data</h2>
          <p>Review the first 5 rows before importing</p>
        </div>

        <div class="preview-container">
          <div class="preview-table-container">
            <table class="preview-table">
              <thead>
                <tr>
                  <th>Order</th>
                  <th>Question</th>
                  <th>Scenario</th>
                  <th>Options</th>
                  <th>Correct</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, index) in previewData.slice(0, 5)" :key="index" 
                    :class="{ 'error-row': row.validationErrors.length > 0 }">
                  <td>{{ row.question_order }}</td>
                  <td class="question-cell">{{ truncateText(row.question, 60) }}</td>
                  <td class="scenario-cell">{{ truncateText(row.scenario, 40) }}</td>
                  <td class="options-cell">
                    <div class="option-list">
                      <span class="option">A: {{ truncateText(row.option_a, 20) }}</span>
                      <span class="option">B: {{ truncateText(row.option_b, 20) }}</span>
                      <span class="option">C: {{ truncateText(row.option_c, 20) }}</span>
                      <span class="option">D: {{ truncateText(row.option_d, 20) }}</span>
                    </div>
                  </td>
                  <td class="correct-cell">{{ row.correct_answer }}</td>
                  <td class="status-cell">
                    <span v-if="row.validationErrors.length === 0" class="status-ok">✅ Valid</span>
                    <span v-else class="status-error">❌ {{ row.validationErrors.length }} errors</span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <div v-if="validationSummary.errors > 0" class="validation-summary error">
            <h3>⚠️ Validation Issues</h3>
            <p><strong>{{ validationSummary.errors }}</strong> rows have errors, <strong>{{ validationSummary.valid }}</strong> are valid</p>
            <ActionButton @click="showValidationDetails = !showValidationDetails" variant="secondary">
              {{ showValidationDetails ? 'Hide' : 'Show' }} Error Details
            </ActionButton>
          </div>

          <div v-else class="validation-summary success">
            <h3>✅ All Data Valid</h3>
            <p><strong>{{ validationSummary.valid }}</strong> questions ready to import</p>
          </div>
        </div>

        <!-- Validation Details -->
        <div v-if="showValidationDetails && validationSummary.errors > 0" class="validation-details">
          <h3>📋 Validation Error Details</h3>
          <div v-for="(row, index) in previewData.filter(r => r.validationErrors.length > 0)" :key="index" class="error-detail">
            <h4>Row {{ index + 2 }} (Question {{ row.question_order }}):</h4>
            <ul>
              <li v-for="error in row.validationErrors" :key="error" class="error-item">{{ error }}</li>
            </ul>
          </div>
        </div>
      </div>

      <!-- Import Action -->
      <div v-if="previewData.length > 0 && validationSummary.errors === 0" class="import-section">
        <div class="section-header">
          <h2>🚀 5. Import Questions</h2>
          <p>Import {{ validationSummary.valid }} valid questions to the database</p>
        </div>

        <div class="import-actions">
          <ActionButton @click="importQuestions" :disabled="importing" variant="success" icon="🚀">
            {{ importing ? 'Importing...' : 'Import Questions' }}
          </ActionButton>
          
          <div v-if="importProgress.total > 0" class="import-progress">
            <div class="progress-bar">
              <div class="progress-fill" :style="{ width: (importProgress.completed / importProgress.total * 100) + '%' }"></div>
            </div>
            <p>{{ importProgress.completed }} / {{ importProgress.total }} questions imported</p>
          </div>
        </div>

        <div v-if="importResults.success.length > 0 || importResults.errors.length > 0" class="import-results">
          <div v-if="importResults.success.length > 0" class="result-section success">
            <h3>✅ Successfully Imported</h3>
            <p>{{ importResults.success.length }} questions imported successfully</p>
          </div>

          <div v-if="importResults.errors.length > 0" class="result-section error">
            <h3>❌ Import Errors</h3>
            <div v-for="error in importResults.errors" :key="error.row" class="import-error">
              <strong>Row {{ error.row }}:</strong> {{ error.message }}
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAdminSession } from '../composables/useAdminSession'
import { useAdminSupabase } from '../composables/useAdminSupabase'
import ActionButton from './shared/ActionButton.vue'

// Admin authentication
const { hasAdminAccess } = useAdminSession()
const { adminSupabase } = useAdminSupabase()
const isAuthLoaded = ref(false)

// Component state
const selectedFile = ref(null)
const previewData = ref([])
const parseError = ref('')
const isDragOver = ref(false)
const showValidationDetails = ref(false)
const importing = ref(false)
const loadingReference = ref(true)

// Reference data
const assessments = ref([])
const competencies = ref([])
const assessmentLevels = ref([])

// Import tracking
const importProgress = ref({ completed: 0, total: 0 })
const importResults = ref({ success: [], errors: [] })

// CSV column headers - updated order: scenario before question
const requiredColumns = [
  'assessment_id', 'question_order', 'scenario', 'question', 'option_a', 
  'option_b', 'option_c', 'option_d', 'correct_answer', 'explanation', 'competency_id',
  'assessment_level_id', 'difficulty_weight', 'is_active'
]

// Computed properties
const validationSummary = computed(() => {
  const valid = previewData.value.filter(row => row.validationErrors.length === 0).length
  const errors = previewData.value.length - valid
  return { valid, errors }
})

// Methods
const loadReferenceData = async () => {
  if (!adminSupabase) return
  
  try {
    loadingReference.value = true
    
    // Load assessments
    const { data: assessmentData } = await adminSupabase
      .from('assessments')
      .select('id, title')
      .order('title')
    assessments.value = assessmentData || []

    // Load competencies
    const { data: competencyData } = await adminSupabase
      .from('competency_display_names')
      .select('id, display_name')
      .order('display_name')
    competencies.value = competencyData || []

    // Load assessment levels
    const { data: levelData } = await adminSupabase
      .from('assessment_levels')
      .select('id, level_name')
      .order('level_name')
    assessmentLevels.value = levelData || []

  } catch (error) {
    console.error('Error loading reference data:', error)
  } finally {
    loadingReference.value = false
  }
}

const downloadTemplate = () => {
  const csvContent = requiredColumns.join(',') + '\n'
  downloadCSV(csvContent, 'question_import_template.csv')
}

const downloadSampleData = () => {
  const sampleData = [
    requiredColumns.join(','),
    `"${assessments.value[0]?.id || 'ASSESSMENT_ID'}",1,"A client comes to you feeling nervous about their first coaching session.","What is the most effective way to build rapport with a client?","Listen actively and mirror their body language","Jump straight into goal setting","Give them advice immediately","Share your own experiences",1,"Active listening and mirroring builds trust and rapport with nervous clients.","${competencies.value[0]?.id || 'COMPETENCY_ID'}","${assessmentLevels.value[0]?.id || ''}",1.0,true`,
    `"${assessments.value[0]?.id || 'ASSESSMENT_ID'}",2,"","How do you handle client resistance?","Acknowledge and explore the resistance","Push through it","Ignore it and continue","End the session",1,"Acknowledging resistance without judgment allows clients to feel heard and explore barriers.","${competencies.value[0]?.id || 'COMPETENCY_ID'}","${assessmentLevels.value[0]?.id || ''}",1.0,true`
  ].join('\n')
  
  downloadCSV(sampleData, 'question_import_sample.csv')
}

const downloadCSV = (content, filename) => {
  const blob = new Blob([content], { type: 'text/csv' })
  const url = window.URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = filename
  link.click()
  window.URL.revokeObjectURL(url)
}

const handleDragOver = (e) => {
  e.preventDefault()
  isDragOver.value = true
}

const handleDragLeave = () => {
  isDragOver.value = false
}

const handleDrop = (e) => {
  e.preventDefault()
  isDragOver.value = false
  const files = e.dataTransfer.files
  if (files.length > 0) {
    handleFileSelect({ target: { files } })
  }
}

const handleFileSelect = (e) => {
  const file = e.target.files[0]
  if (!file) return

  if (!file.name.toLowerCase().endsWith('.csv')) {
    parseError.value = 'Please select a CSV file'
    return
  }

  if (file.size > 5 * 1024 * 1024) { // 5MB limit
    parseError.value = 'File size must be less than 5MB'
    return
  }

  selectedFile.value = file
  parseCSV(file)
}

const parseCSV = async (file) => {
  try {
    parseError.value = ''
    const text = await file.text()
    const lines = text.split('\n').filter(line => line.trim())
    
    if (lines.length < 2) {
      parseError.value = 'CSV must have at least a header row and one data row'
      return
    }

    // Parse header
    const headers = lines[0].split(',').map(h => h.trim().replace(/['"]/g, ''))
    
    // Validate headers
    const missingColumns = requiredColumns.filter(col => !headers.includes(col))
    if (missingColumns.length > 0) {
      parseError.value = `Missing required columns: ${missingColumns.join(', ')}`
      return
    }

    // Parse data rows
    const rows = []
    for (let i = 1; i < lines.length; i++) {
      const values = parseCSVLine(lines[i])
      if (values.length !== headers.length) continue // Skip malformed rows
      
      const row = {}
      headers.forEach((header, index) => {
        row[header] = values[index]?.trim() || ''
      })
      
      // Validate row
      row.validationErrors = validateRow(row)
      rows.push(row)
    }

    previewData.value = rows
  } catch (error) {
    parseError.value = `Error parsing CSV: ${error.message}`
  }
}

const parseCSVLine = (line) => {
  const result = []
  let current = ''
  let inQuotes = false
  
  for (let i = 0; i < line.length; i++) {
    const char = line[i]
    
    if (char === '"') {
      inQuotes = !inQuotes
    } else if (char === ',' && !inQuotes) {
      result.push(current)
      current = ''
    } else {
      current += char
    }
  }
  
  result.push(current)
  return result
}

const validateRow = (row) => {
  const errors = []
  
  // Required fields
  if (!row.assessment_id) errors.push('assessment_id is required')
  if (!row.question_order || isNaN(row.question_order)) errors.push('question_order must be a number')
  if (!row.question) errors.push('question is required')
  if (!row.option_a) errors.push('option_a is required')
  if (!row.option_b) errors.push('option_b is required')
  if (!row.option_c) errors.push('option_c is required')
  if (!row.option_d) errors.push('option_d is required')
  const correctAnswer = parseInt(row.correct_answer)
  if (!row.correct_answer || isNaN(correctAnswer) || ![1, 2, 3, 4].includes(correctAnswer)) {
    errors.push('correct_answer must be 1, 2, 3, or 4')
  }
  if (!row.competency_id) errors.push('competency_id is required')
  
  // Validate UUIDs (relaxed to allow test UUIDs)
  const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i
  if (row.assessment_id && !uuidRegex.test(row.assessment_id)) {
    errors.push('assessment_id must be a valid UUID')
  }
  if (row.competency_id && !uuidRegex.test(row.competency_id)) {
    errors.push('competency_id must be a valid UUID')
  }
  if (row.assessment_level_id && row.assessment_level_id !== '' && !uuidRegex.test(row.assessment_level_id)) {
    errors.push('assessment_level_id must be a valid UUID or empty')
  }
  
  // Validate ranges
  if (row.difficulty_weight && (isNaN(row.difficulty_weight) || row.difficulty_weight < 0.1 || row.difficulty_weight > 5.0)) {
    errors.push('difficulty_weight must be between 0.1 and 5.0')
  }
  
  return errors
}

const clearFile = () => {
  selectedFile.value = null
  previewData.value = []
  parseError.value = ''
  importResults.value = { success: [], errors: [] }
  importProgress.value = { completed: 0, total: 0 }
}

const importQuestions = async () => {
  if (!adminSupabase) return
  
  importing.value = true
  importProgress.value = { completed: 0, total: previewData.value.length }
  importResults.value = { success: [], errors: [] }
  
  try {
    for (let i = 0; i < previewData.value.length; i++) {
      const row = previewData.value[i]
      
      if (row.validationErrors.length > 0) {
        importResults.value.errors.push({
          row: i + 2,
          message: `Validation errors: ${row.validationErrors.join(', ')}`
        })
        continue
      }
      
      try {
        const correctAnswer = parseInt(row.correct_answer)
        
        const dbData = {
          assessment_id: row.assessment_id,
          question_order: parseInt(row.question_order),
          scenario: row.scenario || null,
          question: row.question,
          option_a: row.option_a,
          option_b: row.option_b,
          option_c: row.option_c,
          option_d: row.option_d,
          correct_answer: correctAnswer,
          correct_answer_option_id: correctAnswer,
          explanation: row.explanation || null,
          competency_id: row.competency_id,
          assessment_level_id: row.assessment_level_id || null,
          difficulty_weight: parseFloat(row.difficulty_weight) || 1.0
        }
        
        const { error } = await adminSupabase
          .from('assessment_questions')
          .insert([dbData])
        
        if (error) throw error
        
        importResults.value.success.push(i + 2)
      } catch (error) {
        importResults.value.errors.push({
          row: i + 2,
          message: error.message
        })
      }
      
      importProgress.value.completed = i + 1
    }
  } catch (error) {
    console.error('Import error:', error)
  } finally {
    importing.value = false
  }
}

const formatFileSize = (bytes) => {
  if (bytes === 0) return '0 Bytes'
  const k = 1024
  const sizes = ['Bytes', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}

const truncateText = (text, maxLength) => {
  if (!text) return ''
  return text.length > maxLength ? text.substring(0, maxLength) + '...' : text
}

// Lifecycle
onMounted(async () => {
  isAuthLoaded.value = true
  await loadReferenceData()
})
</script>

<style scoped>
/* Admin container base styling to match other admin components */
.admin-container {
  max-width: 1000px;
  margin: 0 auto;
  padding: 20px;
}

.admin-content {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.admin-header {
  margin-bottom: 30px;
}

.header-main h1 {
  font-size: 28px;
  margin-bottom: 8px;
  color: var(--vp-c-text-1);
}

.admin-subtitle {
  color: var(--vp-c-text-2);
  font-size: 14px;
  margin: 0;
}

.breadcrumb {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 32px;
  padding: 12px;
  background: var(--vp-c-bg-soft);
  border-radius: 6px;
}

.breadcrumb-separator {
  color: var(--vp-c-text-3);
}

/* Import sections styling */
.import-section {
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-border);
  border-radius: 8px;
  overflow: hidden;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: start;
  margin-bottom: 24px;
  padding: 24px 24px 0;
}

.section-header h2 {
  font-size: 22px;
  margin: 0 0 4px 0;
  color: var(--vp-c-text-1);
}

.section-header p {
  color: var(--vp-c-text-2);
  font-size: 14px;
  margin: 0;
}

/* Template section */
.template-card {
  padding: 24px;
  display: flex;
  gap: 32px;
  align-items: flex-start;
}

.template-info {
  flex: 1;
}

.template-info h3 {
  margin: 0 0 16px 0;
  color: var(--vp-c-text-1);
  font-size: 18px;
}

.template-info p {
  color: var(--vp-c-text-2);
  margin: 0 0 12px 0;
}

.column-list {
  margin: 16px 0;
  padding-left: 20px;
}

.column-list li {
  margin: 8px 0;
  font-family: var(--vp-font-family-mono);
  font-size: 13px;
  color: var(--vp-c-text-2);
}

.column-list code {
  background: var(--vp-c-bg-mute);
  padding: 2px 6px;
  border-radius: 3px;
  color: var(--vp-c-text-1);
}

.template-actions {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

/* Reference data grid */
.reference-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 16px;
  padding: 24px;
}

.reference-card {
  border: 1px solid var(--vp-c-border);
  border-radius: 6px;
  padding: 16px;
  background: var(--vp-c-bg);
}

.reference-card h3 {
  margin: 0 0 12px 0;
  color: var(--vp-c-text-1);
  font-size: 16px;
}

.loading-text {
  color: var(--vp-c-text-3);
  font-style: italic;
}

.reference-list {
  max-height: 200px;
  overflow-y: auto;
}

.reference-item {
  margin: 8px 0;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.reference-id {
  font-family: var(--vp-font-family-mono);
  font-size: 11px;
  background: var(--vp-c-bg-mute);
  padding: 4px 6px;
  border-radius: 3px;
  word-break: break-all;
  color: var(--vp-c-text-2);
}

.reference-name {
  font-size: 13px;
  color: var(--vp-c-text-1);
}

/* Upload area */
.upload-area {
  margin: 24px;
  border: 2px dashed var(--vp-c-border);
  border-radius: 8px;
  padding: 32px;
  text-align: center;
  transition: all 0.2s;
  cursor: pointer;
  background: var(--vp-c-bg);
}

.upload-area.drag-over {
  border-color: var(--vp-c-brand);
  background: var(--vp-c-brand-soft);
}

.file-input {
  display: none;
}

.upload-icon {
  font-size: 48px;
  margin-bottom: 16px;
}

.upload-prompt p {
  margin: 8px 0;
  color: var(--vp-c-text-2);
}

.upload-prompt strong {
  color: var(--vp-c-text-1);
}


.upload-note {
  font-size: 12px !important;
  color: var(--vp-c-text-3) !important;
}

.file-selected {
  display: flex;
  align-items: center;
  gap: 16px;
  text-align: left;
  justify-content: space-between;
}

.file-icon {
  font-size: 32px;
}

.file-info h3 {
  margin: 0;
  color: var(--vp-c-text-1);
  font-size: 16px;
}

.file-info p {
  margin: 4px 0 0 0;
  color: var(--vp-c-text-2);
  font-size: 13px;
}


.error-message {
  color: var(--vp-c-danger);
  font-size: 14px;
  margin: 16px 24px;
  padding: 12px;
  background: var(--vp-c-danger-soft);
  border-radius: 6px;
}

/* Preview table */
.preview-container {
  padding: 24px;
}

.preview-table-container {
  overflow-x: auto;
  margin-bottom: 16px;
  border: 1px solid var(--vp-c-border);
  border-radius: 6px;
}

.preview-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
  background: var(--vp-c-bg);
}

.preview-table th,
.preview-table td {
  padding: 12px 8px;
  border-bottom: 1px solid var(--vp-c-border);
  text-align: left;
  vertical-align: top;
}

.preview-table th {
  background: var(--vp-c-bg-soft);
  font-weight: 600;
  color: var(--vp-c-text-1);
  font-size: 12px;
}

.preview-table td {
  color: var(--vp-c-text-2);
}

.error-row {
  background: var(--vp-c-danger-soft);
}

.question-cell {
  max-width: 200px;
}

.scenario-cell {
  max-width: 150px;
  font-style: italic;
}

.options-cell {
  max-width: 250px;
}

.option-list {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.option {
  font-size: 11px;
  color: var(--vp-c-text-3);
}

.correct-cell {
  font-weight: 600;
  color: var(--vp-c-brand);
}

.status-ok {
  color: var(--vp-c-success);
  font-weight: 500;
}

.status-error {
  color: var(--vp-c-danger);
  font-weight: 500;
}

/* Validation summary */
.validation-summary {
  padding: 16px;
  border-radius: 6px;
  margin-bottom: 16px;
}

.validation-summary.success {
  background: var(--vp-c-success-soft);
  border: 1px solid var(--vp-c-success);
  color: var(--vp-c-success-darker);
}

.validation-summary.error {
  background: var(--vp-c-danger-soft);
  border: 1px solid var(--vp-c-danger);
  color: var(--vp-c-danger-darker);
}

.validation-summary h3 {
  margin: 0 0 8px 0;
  font-size: 16px;
}

.validation-summary p {
  margin: 0;
  font-size: 14px;
}


/* Validation details */
.validation-details {
  padding: 24px;
  background: var(--vp-c-danger-soft);
  border-top: 1px solid var(--vp-c-border);
}

.error-detail {
  margin-bottom: 16px;
}

.error-detail h4 {
  margin: 0 0 8px 0;
  color: var(--vp-c-danger);
  font-size: 14px;
}

.error-detail ul {
  margin: 0;
  padding-left: 20px;
}

.error-item {
  color: var(--vp-c-danger-darker);
  margin: 4px 0;
  font-size: 13px;
}

/* Import actions */
.import-actions {
  padding: 24px;
  text-align: center;
}


.import-progress {
  margin-top: 16px;
}

.progress-bar {
  width: 100%;
  height: 8px;
  background: var(--vp-c-bg-mute);
  border-radius: 4px;
  overflow: hidden;
  margin-bottom: 8px;
}

.progress-fill {
  height: 100%;
  background: var(--vp-c-success);
  transition: width 0.3s ease;
}

.import-progress p {
  margin: 0;
  font-size: 14px;
  color: var(--vp-c-text-2);
}

/* Import results */
.import-results {
  padding: 24px;
  border-top: 1px solid var(--vp-c-border);
}

.result-section {
  margin-bottom: 16px;
  padding: 16px;
  border-radius: 6px;
}

.result-section.success {
  background: var(--vp-c-success-soft);
  border: 1px solid var(--vp-c-success);
}

.result-section.error {
  background: var(--vp-c-danger-soft);
  border: 1px solid var(--vp-c-danger);
}

.result-section h3 {
  margin: 0 0 8px 0;
  font-size: 16px;
}

.result-section p {
  margin: 0;
  font-size: 14px;
}

.import-error {
  margin: 8px 0;
  font-size: 13px;
  color: var(--vp-c-danger-darker);
}

/* Responsive design */
@media (max-width: 768px) {
  .admin-container {
    padding: 16px;
  }
  
  .template-card {
    flex-direction: column;
    gap: 16px;
  }
  
  .reference-grid {
    grid-template-columns: 1fr;
  }
  
  .file-selected {
    flex-direction: column;
    text-align: center;
  }
  
  .section-header {
    flex-direction: column;
    align-items: start;
    gap: 16px;
  }
}
</style>