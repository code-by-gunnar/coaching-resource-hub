#!/usr/bin/env node
/**
 * Create New Assessment Level
 *
 * Interactive script to create assessment skeleton:
 * - Assessment level (if not exists)
 * - Competencies for that level
 *
 * Usage: node create-assessment.js
 *
 * Required env vars (or .env file):
 *   SUPABASE_URL
 *   SUPABASE_SERVICE_ROLE_KEY
 */

import 'dotenv/config'
import { createClient } from '@supabase/supabase-js'
import * as readline from 'readline'

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

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
})

function ask(question) {
  return new Promise(resolve => {
    rl.question(question, resolve)
  })
}

function askChoice(question, options) {
  return new Promise(async resolve => {
    console.log(`\n${question}`)
    options.forEach((opt, i) => console.log(`  ${i + 1}. ${opt}`))

    while (true) {
      const answer = await ask(`Enter choice (1-${options.length}): `)
      const num = parseInt(answer)
      if (num >= 1 && num <= options.length) {
        resolve(options[num - 1])
        return
      }
      console.log('Invalid choice, try again.')
    }
  })
}

// ============================================================================
// Main Functions
// ============================================================================

async function getFrameworks() {
  const { data, error } = await supabase
    .from('ai_frameworks')
    .select('*')
    .eq('is_active', true)
    .order('code')

  if (error) throw error
  return data
}

async function getExistingLevels(frameworkId) {
  const { data, error } = await supabase
    .from('ai_assessment_levels')
    .select('*')
    .eq('framework_id', frameworkId)
    .order('level_code')

  if (error) throw error
  return data
}

async function getExistingCompetencies(frameworkId) {
  const { data, error } = await supabase
    .from('ai_competencies')
    .select('*')
    .eq('framework_id', frameworkId)
    .order('sort_order')

  if (error) throw error
  return data
}

async function createLevel(frameworkId, levelCode, name, description, questionCount, passingScore) {
  const { data, error } = await supabase
    .from('ai_assessment_levels')
    .insert({
      framework_id: frameworkId,
      level_code: levelCode,
      name: name,
      description: description,
      question_count: questionCount,
      passing_score: passingScore,
      is_active: true
    })
    .select()
    .single()

  if (error) throw error
  return data
}

async function createCompetency(frameworkId, code, name, description, aiContext, sortOrder) {
  const { data, error } = await supabase
    .from('ai_competencies')
    .insert({
      framework_id: frameworkId,
      code: code,
      name: name,
      description: description,
      ai_context: aiContext,
      sort_order: sortOrder,
      is_active: true
    })
    .select()
    .single()

  if (error) throw error
  return data
}

// ============================================================================
// Interactive Wizard
// ============================================================================

async function main() {
  console.log('\n' + '='.repeat(50))
  console.log('CREATE NEW ASSESSMENT')
  console.log('='.repeat(50))

  // Step 1: Select Framework
  const frameworks = await getFrameworks()
  console.log('\nAvailable frameworks:')
  frameworks.forEach((f, i) => console.log(`  ${i + 1}. ${f.name} (${f.code})`))

  const frameworkChoice = await ask(`\nSelect framework (1-${frameworks.length}): `)
  const framework = frameworks[parseInt(frameworkChoice) - 1]
  if (!framework) {
    console.log('Invalid selection')
    process.exit(1)
  }

  console.log(`\nSelected: ${framework.name}`)

  // Step 2: Check existing levels
  const existingLevels = await getExistingLevels(framework.id)
  console.log('\nExisting levels for this framework:')
  if (existingLevels.length === 0) {
    console.log('  (none)')
  } else {
    existingLevels.forEach(l => console.log(`  - ${l.name} (${l.level_code})`))
  }

  // Step 3: Select or create level
  const levelCodes = ['beginner', 'intermediate', 'advanced']
  const availableLevels = levelCodes.filter(
    code => !existingLevels.find(l => l.level_code === code)
  )

  if (availableLevels.length === 0) {
    console.log('\nAll levels already exist for this framework.')
    console.log('Use import-questions.js to add questions to existing levels.')
    rl.close()
    return
  }

  console.log('\nAvailable levels to create:')
  availableLevels.forEach((l, i) => console.log(`  ${i + 1}. ${l}`))

  const levelChoice = await ask(`\nSelect level to create (1-${availableLevels.length}): `)
  const levelCode = availableLevels[parseInt(levelChoice) - 1]
  if (!levelCode) {
    console.log('Invalid selection')
    process.exit(1)
  }

  // Step 4: Get level details
  console.log(`\nCreating: ${framework.code} - ${levelCode}`)

  const levelName = await ask('Assessment name (e.g., "Core I - Fundamentals"): ')
  const levelDesc = await ask('Description: ')
  const questionCount = await ask('Number of questions per assessment (default: 15): ')
  const passingScore = await ask('Passing score percentage (default: 70): ')

  const level = await createLevel(
    framework.id,
    levelCode,
    levelName || `${framework.name} - ${levelCode}`,
    levelDesc || null,
    parseInt(questionCount) || 15,
    parseInt(passingScore) || 70
  )

  console.log(`\nCreated level: ${level.name}`)

  // Step 5: Check existing competencies
  const existingCompetencies = await getExistingCompetencies(framework.id)

  if (existingCompetencies.length > 0) {
    console.log('\nExisting competencies for this framework:')
    existingCompetencies.forEach(c => console.log(`  - ${c.name} (${c.code})`))

    const useExisting = await ask('\nUse existing competencies? (y/n): ')
    if (useExisting.toLowerCase() === 'y') {
      console.log('\nSetup complete! You can now import questions using:')
      console.log(`  node import-questions.js your-questions.csv`)
      rl.close()
      return
    }
  }

  // Step 6: Create competencies
  console.log('\nLet\'s create competencies for this assessment.')
  console.log('Enter competencies one at a time. Type "done" when finished.\n')

  let sortOrder = existingCompetencies.length
  const newCompetencies = []

  while (true) {
    const code = await ask('Competency code (e.g., "active_listening") or "done": ')
    if (code.toLowerCase() === 'done') break

    const name = await ask('Display name (e.g., "Active Listening"): ')
    const desc = await ask('Description: ')
    const aiContext = await ask('AI context (helps AI generate better feedback): ')

    const comp = await createCompetency(
      framework.id,
      code,
      name,
      desc || null,
      aiContext || null,
      sortOrder++
    )

    newCompetencies.push(comp)
    console.log(`  Created: ${comp.name}\n`)
  }

  // Summary
  console.log('\n' + '='.repeat(50))
  console.log('SETUP COMPLETE')
  console.log('='.repeat(50))
  console.log(`Framework:    ${framework.name}`)
  console.log(`Level:        ${level.name}`)
  console.log(`Questions:    ${level.question_count} per assessment`)
  console.log(`Pass score:   ${level.passing_score}%`)
  console.log(`Competencies: ${existingCompetencies.length + newCompetencies.length}`)

  console.log('\nNext steps:')
  console.log('1. Create a CSV file with questions (see template-questions.csv)')
  console.log('2. Import questions:')
  console.log(`   node import-questions.js your-questions.csv`)

  rl.close()
}

main().catch(err => {
  console.error('\nError:', err.message)
  rl.close()
  process.exit(1)
})
