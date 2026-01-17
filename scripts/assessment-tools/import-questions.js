#!/usr/bin/env node
/**
 * Import Assessment Questions from CSV
 *
 * Usage: node import-questions.js <csv-file>
 *
 * Required env vars (or .env file):
 *   SUPABASE_URL
 *   SUPABASE_SERVICE_ROLE_KEY
 */

import 'dotenv/config'
import { createClient } from '@supabase/supabase-js'
import { readFileSync } from 'fs'
import { parse } from 'csv-parse/sync'

// ============================================================================
// Configuration
// ============================================================================

const SUPABASE_URL = process.env.SUPABASE_URL
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY

if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  console.error('Error: Missing environment variables')
  console.error('Required: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY')
  process.exit(1)
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

// ============================================================================
// Helper Functions
// ============================================================================

async function getFrameworkId(code) {
  const { data, error } = await supabase
    .from('ai_frameworks')
    .select('id')
    .eq('code', code)
    .single()

  if (error) throw new Error(`Framework '${code}' not found: ${error.message}`)
  return data.id
}

async function getLevelId(frameworkId, levelCode) {
  const { data, error } = await supabase
    .from('ai_assessment_levels')
    .select('id')
    .eq('framework_id', frameworkId)
    .eq('level_code', levelCode)
    .single()

  if (error) throw new Error(`Level '${levelCode}' not found for framework: ${error.message}`)
  return data.id
}

async function getCompetencyId(frameworkId, competencyCode) {
  const { data, error } = await supabase
    .from('ai_competencies')
    .select('id')
    .eq('framework_id', frameworkId)
    .eq('code', competencyCode)
    .single()

  if (error) throw new Error(`Competency '${competencyCode}' not found: ${error.message}`)
  return data.id
}

function buildOptions(row) {
  return [
    { key: 'a', text: row.option_a },
    { key: 'b', text: row.option_b },
    { key: 'c', text: row.option_c },
    { key: 'd', text: row.option_d }
  ]
}

// ============================================================================
// Main Import Function
// ============================================================================

async function importQuestions(csvPath) {
  console.log(`\nReading CSV file: ${csvPath}\n`)

  // Read and parse CSV
  const csvContent = readFileSync(csvPath, 'utf-8')
  const records = parse(csvContent, {
    columns: true,
    skip_empty_lines: true,
    trim: true
  })

  console.log(`Found ${records.length} questions to import\n`)

  // Cache for lookups
  const frameworkCache = new Map()
  const levelCache = new Map()
  const competencyCache = new Map()

  let imported = 0
  let skipped = 0
  let errors = []

  for (let i = 0; i < records.length; i++) {
    const row = records[i]
    const rowNum = i + 2 // +2 for header row and 0-index

    try {
      // Validate required fields
      const required = ['framework_code', 'level_code', 'competency_code',
                       'scenario_text', 'question_text', 'option_a', 'option_b',
                       'option_c', 'option_d', 'correct_option', 'concept_tag', 'explanation']

      for (const field of required) {
        if (!row[field]) {
          throw new Error(`Missing required field: ${field}`)
        }
      }

      // Validate correct_option
      if (!['a', 'b', 'c', 'd'].includes(row.correct_option.toLowerCase())) {
        throw new Error(`Invalid correct_option: ${row.correct_option} (must be a, b, c, or d)`)
      }

      // Get framework ID (with caching)
      let frameworkId = frameworkCache.get(row.framework_code)
      if (!frameworkId) {
        frameworkId = await getFrameworkId(row.framework_code)
        frameworkCache.set(row.framework_code, frameworkId)
      }

      // Get level ID (with caching)
      const levelKey = `${row.framework_code}:${row.level_code}`
      let levelId = levelCache.get(levelKey)
      if (!levelId) {
        levelId = await getLevelId(frameworkId, row.level_code)
        levelCache.set(levelKey, levelId)
      }

      // Get competency ID (with caching)
      const competencyKey = `${row.framework_code}:${row.competency_code}`
      let competencyId = competencyCache.get(competencyKey)
      if (!competencyId) {
        competencyId = await getCompetencyId(frameworkId, row.competency_code)
        competencyCache.set(competencyKey, competencyId)
      }

      // Build question object
      const question = {
        framework_id: frameworkId,
        level_id: levelId,
        competency_id: competencyId,
        scenario_text: row.scenario_text,
        question_text: row.question_text,
        options: buildOptions(row),
        correct_option: row.correct_option.toLowerCase(),
        concept_tag: row.concept_tag,
        explanation: row.explanation,
        ai_hint: row.ai_hint || null,
        difficulty_weight: parseInt(row.difficulty_weight) || 1,
        is_active: true
      }

      // Insert question
      const { error } = await supabase
        .from('ai_questions')
        .insert(question)

      if (error) throw error

      imported++
      process.stdout.write(`\rImported: ${imported} | Skipped: ${skipped} | Errors: ${errors.length}`)

    } catch (err) {
      errors.push({ row: rowNum, message: err.message })
      skipped++
      process.stdout.write(`\rImported: ${imported} | Skipped: ${skipped} | Errors: ${errors.length}`)
    }
  }

  // Summary
  console.log('\n\n' + '='.repeat(50))
  console.log('IMPORT SUMMARY')
  console.log('='.repeat(50))
  console.log(`Total rows:    ${records.length}`)
  console.log(`Imported:      ${imported}`)
  console.log(`Skipped:       ${skipped}`)
  console.log(`Errors:        ${errors.length}`)

  if (errors.length > 0) {
    console.log('\nErrors:')
    for (const err of errors) {
      console.log(`  Row ${err.row}: ${err.message}`)
    }
  }

  console.log('\nDone!')
}

// ============================================================================
// CLI Entry Point
// ============================================================================

const args = process.argv.slice(2)

if (args.length === 0) {
  console.log('Usage: node import-questions.js <csv-file>')
  console.log('\nExample: node import-questions.js core-intermediate-questions.csv')
  process.exit(1)
}

importQuestions(args[0]).catch(err => {
  console.error('\nFatal error:', err.message)
  process.exit(1)
})
