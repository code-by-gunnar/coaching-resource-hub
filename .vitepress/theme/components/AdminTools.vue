<script setup>
import { ref, onMounted, computed } from 'vue'
import { createClient } from '@supabase/supabase-js'

// ============================================================================
// Supabase Client
// ============================================================================
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseKey = import.meta.env.VITE_SUPABASE_SERVICE_ROLE_KEY || import.meta.env.VITE_SUPABASE_ANON_KEY
const supabase = createClient(supabaseUrl, supabaseKey)

// ============================================================================
// State
// ============================================================================
const activeTab = ref('overview')
const loading = ref(false)
const error = ref(null)
const success = ref(null)

// Overview data
const frameworks = ref([])
const assessmentData = ref([])

// Create assessment form
const newAssessment = ref({
  framework_code: 'core',
  level_code: 'intermediate',
  name: '',
  description: '',
  question_count: 15,
  passing_score: 70
})

// Import state
const csvFile = ref(null)
const importResults = ref(null)
const importing = ref(false)

// ============================================================================
// Load Data
// ============================================================================
async function loadOverview() {
  loading.value = true
  error.value = null

  try {
    // Get frameworks
    const { data: fw, error: fwErr } = await supabase
      .from('ai_frameworks')
      .select('*')
      .order('code')

    if (fwErr) throw fwErr
    frameworks.value = fw

    // Get levels with question counts
    const assessments = []
    for (const framework of fw) {
      const { data: levels, error: lvlErr } = await supabase
        .from('ai_assessment_levels')
        .select('*')
        .eq('framework_id', framework.id)
        .order('level_code')

      if (lvlErr) throw lvlErr

      for (const level of levels || []) {
        // Count questions
        const { count } = await supabase
          .from('ai_questions')
          .select('*', { count: 'exact', head: true })
          .eq('level_id', level.id)
          .eq('is_active', true)

        // Get competencies
        const { data: comps } = await supabase
          .from('ai_competencies')
          .select('code, name')
          .eq('framework_id', framework.id)
          .eq('is_active', true)
          .order('sort_order')

        assessments.push({
          framework_code: framework.code,
          framework_name: framework.name,
          level_code: level.level_code,
          level_name: level.name,
          level_id: level.id,
          question_count: count || 0,
          required_questions: level.question_count,
          passing_score: level.passing_score,
          is_active: level.is_active,
          competencies: comps || []
        })
      }
    }
    assessmentData.value = assessments

  } catch (err) {
    error.value = err.message
  } finally {
    loading.value = false
  }
}

// ============================================================================
// Create Assessment
// ============================================================================
async function createAssessment() {
  loading.value = true
  error.value = null
  success.value = null

  try {
    // Get framework
    const { data: framework, error: fwErr } = await supabase
      .from('ai_frameworks')
      .select('id')
      .eq('code', newAssessment.value.framework_code)
      .single()

    if (fwErr) throw new Error(`Framework not found: ${newAssessment.value.framework_code}`)

    // Check if level exists
    const { data: existing } = await supabase
      .from('ai_assessment_levels')
      .select('id')
      .eq('framework_id', framework.id)
      .eq('level_code', newAssessment.value.level_code)
      .single()

    if (existing) {
      throw new Error(`Level ${newAssessment.value.level_code} already exists for ${newAssessment.value.framework_code}`)
    }

    // Create level
    const { error: createErr } = await supabase
      .from('ai_assessment_levels')
      .insert({
        framework_id: framework.id,
        level_code: newAssessment.value.level_code,
        name: newAssessment.value.name || `${newAssessment.value.framework_code} - ${newAssessment.value.level_code}`,
        description: newAssessment.value.description || null,
        question_count: newAssessment.value.question_count,
        passing_score: newAssessment.value.passing_score,
        is_active: true
      })

    if (createErr) throw createErr

    success.value = `Created assessment: ${newAssessment.value.name}`
    await loadOverview()

    // Reset form
    newAssessment.value = {
      framework_code: 'core',
      level_code: 'intermediate',
      name: '',
      description: '',
      question_count: 15,
      passing_score: 70
    }

  } catch (err) {
    error.value = err.message
  } finally {
    loading.value = false
  }
}

// ============================================================================
// CSV Import
// ============================================================================
function handleFileSelect(event) {
  csvFile.value = event.target.files[0]
  importResults.value = null
}

async function importQuestions() {
  if (!csvFile.value) {
    error.value = 'Please select a CSV file'
    return
  }

  importing.value = true
  error.value = null
  success.value = null
  importResults.value = null

  try {
    const text = await csvFile.value.text()
    const lines = text.split('\n').filter(line => line.trim())

    if (lines.length < 2) {
      throw new Error('CSV file must have a header row and at least one data row')
    }

    // Parse header
    const headers = lines[0].split(',').map(h => h.trim().toLowerCase().replace(/"/g, ''))

    // Validate required columns
    const required = ['framework_code', 'level_code', 'competency_code', 'scenario_text',
                     'question_text', 'option_a', 'option_b', 'option_c', 'option_d',
                     'correct_option', 'concept_tag', 'explanation']

    for (const col of required) {
      if (!headers.includes(col)) {
        throw new Error(`Missing required column: ${col}`)
      }
    }

    // Cache for lookups
    const frameworkCache = new Map()
    const levelCache = new Map()
    const competencyCache = new Map()

    let imported = 0
    let skipped = 0
    const errors = []

    // Process rows
    for (let i = 1; i < lines.length; i++) {
      const values = parseCSVRow(lines[i])
      if (values.length !== headers.length) {
        errors.push({ row: i + 1, message: 'Column count mismatch' })
        skipped++
        continue
      }

      const row = {}
      headers.forEach((h, idx) => row[h] = values[idx])

      try {
        // Get framework ID
        let frameworkId = frameworkCache.get(row.framework_code)
        if (!frameworkId) {
          const { data, error } = await supabase
            .from('ai_frameworks')
            .select('id')
            .eq('code', row.framework_code)
            .single()
          if (error) throw new Error(`Framework '${row.framework_code}' not found`)
          frameworkId = data.id
          frameworkCache.set(row.framework_code, frameworkId)
        }

        // Get level ID
        const levelKey = `${row.framework_code}:${row.level_code}`
        let levelId = levelCache.get(levelKey)
        if (!levelId) {
          const { data, error } = await supabase
            .from('ai_assessment_levels')
            .select('id')
            .eq('framework_id', frameworkId)
            .eq('level_code', row.level_code)
            .single()
          if (error) throw new Error(`Level '${row.level_code}' not found`)
          levelId = data.id
          levelCache.set(levelKey, levelId)
        }

        // Get competency ID
        const compKey = `${row.framework_code}:${row.competency_code}`
        let competencyId = competencyCache.get(compKey)
        if (!competencyId) {
          const { data, error } = await supabase
            .from('ai_competencies')
            .select('id')
            .eq('framework_id', frameworkId)
            .eq('code', row.competency_code)
            .single()
          if (error) throw new Error(`Competency '${row.competency_code}' not found`)
          competencyId = data.id
          competencyCache.set(compKey, competencyId)
        }

        // Insert question
        const { error: insertErr } = await supabase
          .from('ai_questions')
          .insert({
            framework_id: frameworkId,
            level_id: levelId,
            competency_id: competencyId,
            scenario_text: row.scenario_text,
            question_text: row.question_text,
            options: [
              { key: 'a', text: row.option_a },
              { key: 'b', text: row.option_b },
              { key: 'c', text: row.option_c },
              { key: 'd', text: row.option_d }
            ],
            correct_option: row.correct_option.toLowerCase(),
            concept_tag: row.concept_tag,
            explanation: row.explanation,
            ai_hint: row.ai_hint || null,
            difficulty_weight: parseInt(row.difficulty_weight) || 1,
            is_active: true
          })

        if (insertErr) throw insertErr
        imported++

      } catch (err) {
        errors.push({ row: i + 1, message: err.message })
        skipped++
      }
    }

    importResults.value = { imported, skipped, errors }

    if (imported > 0) {
      success.value = `Successfully imported ${imported} questions`
      await loadOverview()
    }

  } catch (err) {
    error.value = err.message
  } finally {
    importing.value = false
  }
}

// Simple CSV row parser (handles quoted values)
function parseCSVRow(row) {
  const values = []
  let current = ''
  let inQuotes = false

  for (let i = 0; i < row.length; i++) {
    const char = row[i]

    if (char === '"') {
      inQuotes = !inQuotes
    } else if (char === ',' && !inQuotes) {
      values.push(current.trim())
      current = ''
    } else {
      current += char
    }
  }
  values.push(current.trim())

  return values
}

// ============================================================================
// Computed
// ============================================================================
const availableLevels = computed(() => {
  const framework = frameworks.value.find(f => f.code === newAssessment.value.framework_code)
  if (!framework) return ['beginner', 'intermediate', 'advanced']

  const existingLevels = assessmentData.value
    .filter(a => a.framework_code === newAssessment.value.framework_code)
    .map(a => a.level_code)

  return ['beginner', 'intermediate', 'advanced'].filter(l => !existingLevels.includes(l))
})

// ============================================================================
// Lifecycle
// ============================================================================
onMounted(() => {
  loadOverview()
})
</script>

<template>
  <div class="admin-tools">
    <h1>Assessment Admin Tools</h1>

    <!-- Tabs -->
    <div class="tabs">
      <button
        :class="{ active: activeTab === 'overview' }"
        @click="activeTab = 'overview'"
      >
        Overview
      </button>
      <button
        :class="{ active: activeTab === 'create' }"
        @click="activeTab = 'create'"
      >
        Create Assessment
      </button>
      <button
        :class="{ active: activeTab === 'import' }"
        @click="activeTab = 'import'"
      >
        Import Questions
      </button>
    </div>

    <!-- Messages -->
    <div v-if="error" class="message error">{{ error }}</div>
    <div v-if="success" class="message success">{{ success }}</div>

    <!-- Overview Tab -->
    <div v-if="activeTab === 'overview'" class="tab-content">
      <div v-if="loading" class="loading">Loading...</div>

      <div v-else-if="assessmentData.length === 0" class="empty">
        No assessments configured yet.
      </div>

      <div v-else class="assessment-grid">
        <div v-for="assessment in assessmentData" :key="`${assessment.framework_code}-${assessment.level_code}`" class="assessment-card">
          <div class="card-header">
            <span class="framework-badge" :class="assessment.framework_code">
              {{ assessment.framework_code.toUpperCase() }}
            </span>
            <span class="level-badge">{{ assessment.level_code }}</span>
          </div>
          <h3>{{ assessment.level_name }}</h3>
          <div class="stats">
            <div class="stat">
              <span class="stat-value" :class="{ warning: assessment.question_count < assessment.required_questions }">
                {{ assessment.question_count }}
              </span>
              <span class="stat-label">/ {{ assessment.required_questions }} questions</span>
            </div>
            <div class="stat">
              <span class="stat-value">{{ assessment.passing_score }}%</span>
              <span class="stat-label">to pass</span>
            </div>
          </div>
          <div class="competencies">
            <strong>Competencies:</strong>
            <div class="comp-list">
              <span v-for="comp in assessment.competencies" :key="comp.code" class="comp-tag">
                {{ comp.name }}
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Create Assessment Tab -->
    <div v-if="activeTab === 'create'" class="tab-content">
      <form @submit.prevent="createAssessment" class="create-form">
        <div class="form-group">
          <label>Framework</label>
          <select v-model="newAssessment.framework_code">
            <option value="core">Core Coaching Fundamentals</option>
            <option value="icf">ICF Core Competencies</option>
            <option value="ac">AC Competencies</option>
          </select>
        </div>

        <div class="form-group">
          <label>Level</label>
          <select v-model="newAssessment.level_code">
            <option v-for="level in availableLevels" :key="level" :value="level">
              {{ level }}
            </option>
          </select>
          <small v-if="availableLevels.length === 0" class="warning">
            All levels exist for this framework
          </small>
        </div>

        <div class="form-group">
          <label>Assessment Name</label>
          <input
            v-model="newAssessment.name"
            type="text"
            placeholder="e.g., Core II - Intermediate Skills"
          />
        </div>

        <div class="form-group">
          <label>Description</label>
          <textarea
            v-model="newAssessment.description"
            placeholder="Brief description of this assessment level"
            rows="3"
          ></textarea>
        </div>

        <div class="form-row">
          <div class="form-group">
            <label>Questions per Assessment</label>
            <input v-model.number="newAssessment.question_count" type="number" min="5" max="50" />
          </div>
          <div class="form-group">
            <label>Passing Score (%)</label>
            <input v-model.number="newAssessment.passing_score" type="number" min="50" max="100" />
          </div>
        </div>

        <button type="submit" :disabled="loading || availableLevels.length === 0" class="btn-primary">
          {{ loading ? 'Creating...' : 'Create Assessment' }}
        </button>
      </form>
    </div>

    <!-- Import Questions Tab -->
    <div v-if="activeTab === 'import'" class="tab-content">
      <div class="import-section">
        <h3>CSV Format</h3>
        <p>Your CSV must have these columns:</p>
        <code class="csv-columns">
          framework_code, level_code, competency_code, scenario_text, question_text,
          option_a, option_b, option_c, option_d, correct_option, concept_tag, explanation,
          ai_hint (optional), difficulty_weight (optional)
        </code>

        <div class="form-group">
          <label>Select CSV File</label>
          <input type="file" accept=".csv" @change="handleFileSelect" />
        </div>

        <button
          @click="importQuestions"
          :disabled="!csvFile || importing"
          class="btn-primary"
        >
          {{ importing ? 'Importing...' : 'Import Questions' }}
        </button>

        <div v-if="importResults" class="import-results">
          <h4>Import Results</h4>
          <div class="results-summary">
            <span class="result-stat success">{{ importResults.imported }} imported</span>
            <span class="result-stat warning">{{ importResults.skipped }} skipped</span>
          </div>
          <div v-if="importResults.errors.length > 0" class="errors-list">
            <strong>Errors:</strong>
            <ul>
              <li v-for="err in importResults.errors" :key="err.row">
                Row {{ err.row }}: {{ err.message }}
              </li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.admin-tools {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}

h1 {
  margin-bottom: 1.5rem;
  color: var(--vp-c-text-1);
}

/* Tabs */
.tabs {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 1.5rem;
  border-bottom: 1px solid var(--vp-c-divider);
  padding-bottom: 0.5rem;
}

.tabs button {
  padding: 0.5rem 1rem;
  border: none;
  background: none;
  cursor: pointer;
  font-size: 1rem;
  color: var(--vp-c-text-2);
  border-radius: 6px;
  transition: all 0.2s;
}

.tabs button:hover {
  background: var(--vp-c-bg-soft);
}

.tabs button.active {
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand-1);
  font-weight: 500;
}

/* Messages */
.message {
  padding: 1rem;
  border-radius: 8px;
  margin-bottom: 1rem;
}

.message.error {
  background: #fef2f2;
  color: #dc2626;
  border: 1px solid #fecaca;
}

.message.success {
  background: #f0fdf4;
  color: #16a34a;
  border: 1px solid #bbf7d0;
}

/* Overview Grid */
.assessment-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 1.5rem;
}

.assessment-card {
  background: var(--vp-c-bg-soft);
  border-radius: 12px;
  padding: 1.25rem;
  border: 1px solid var(--vp-c-divider);
}

.card-header {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 0.75rem;
}

.framework-badge {
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.7rem;
  font-weight: 600;
  text-transform: uppercase;
}

.framework-badge.core { background: #dbeafe; color: #1d4ed8; }
.framework-badge.icf { background: #fef3c7; color: #b45309; }
.framework-badge.ac { background: #d1fae5; color: #047857; }

.level-badge {
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.7rem;
  font-weight: 500;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-2);
  text-transform: capitalize;
}

.assessment-card h3 {
  margin: 0 0 1rem 0;
  font-size: 1.1rem;
  color: var(--vp-c-text-1);
}

.stats {
  display: flex;
  gap: 1.5rem;
  margin-bottom: 1rem;
}

.stat {
  display: flex;
  align-items: baseline;
  gap: 0.25rem;
}

.stat-value {
  font-size: 1.25rem;
  font-weight: 600;
  color: var(--vp-c-text-1);
}

.stat-value.warning {
  color: #f59e0b;
}

.stat-label {
  font-size: 0.8rem;
  color: var(--vp-c-text-3);
}

.competencies strong {
  font-size: 0.8rem;
  color: var(--vp-c-text-2);
}

.comp-list {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  margin-top: 0.5rem;
}

.comp-tag {
  padding: 0.2rem 0.5rem;
  background: var(--vp-c-bg);
  border-radius: 4px;
  font-size: 0.75rem;
  color: var(--vp-c-text-2);
}

/* Forms */
.create-form, .import-section {
  max-width: 600px;
}

.form-group {
  margin-bottom: 1.25rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: var(--vp-c-text-1);
}

.form-group input,
.form-group select,
.form-group textarea {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-1);
  font-size: 1rem;
}

.form-group input:focus,
.form-group select:focus,
.form-group textarea:focus {
  outline: none;
  border-color: var(--vp-c-brand-1);
}

.form-group small.warning {
  color: #f59e0b;
  font-size: 0.8rem;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
}

.btn-primary {
  padding: 0.75rem 1.5rem;
  background: var(--vp-c-brand-1);
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 500;
  cursor: pointer;
  transition: background 0.2s;
}

.btn-primary:hover:not(:disabled) {
  background: var(--vp-c-brand-2);
}

.btn-primary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Import Section */
.csv-columns {
  display: block;
  padding: 1rem;
  background: var(--vp-c-bg-soft);
  border-radius: 8px;
  font-size: 0.85rem;
  margin: 1rem 0;
  word-break: break-word;
}

.import-results {
  margin-top: 1.5rem;
  padding: 1rem;
  background: var(--vp-c-bg-soft);
  border-radius: 8px;
}

.results-summary {
  display: flex;
  gap: 1rem;
  margin-bottom: 1rem;
}

.result-stat {
  padding: 0.5rem 1rem;
  border-radius: 6px;
  font-weight: 500;
}

.result-stat.success {
  background: #d1fae5;
  color: #047857;
}

.result-stat.warning {
  background: #fef3c7;
  color: #b45309;
}

.errors-list {
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 1px solid var(--vp-c-divider);
}

.errors-list ul {
  margin: 0.5rem 0 0 1.5rem;
  font-size: 0.85rem;
  color: #dc2626;
}

.loading {
  text-align: center;
  padding: 2rem;
  color: var(--vp-c-text-2);
}

.empty {
  text-align: center;
  padding: 3rem;
  color: var(--vp-c-text-3);
}

@media (max-width: 640px) {
  .admin-tools {
    padding: 1rem;
  }

  .form-row {
    grid-template-columns: 1fr;
  }

  .assessment-grid {
    grid-template-columns: 1fr;
  }
}
</style>
