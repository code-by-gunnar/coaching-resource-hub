#!/usr/bin/env node
/**
 * List All Assessments
 *
 * Shows frameworks, levels, competencies, and question counts.
 *
 * Usage: node list-assessments.js
 *
 * Required env vars (or .env file):
 *   SUPABASE_URL
 *   SUPABASE_SERVICE_ROLE_KEY
 */

import 'dotenv/config'
import { createClient } from '@supabase/supabase-js'

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
// Main Function
// ============================================================================

async function listAssessments() {
  console.log('\n' + '='.repeat(60))
  console.log('ASSESSMENT OVERVIEW')
  console.log('='.repeat(60))

  // Get all frameworks
  const { data: frameworks, error: fwError } = await supabase
    .from('ai_frameworks')
    .select('*')
    .order('code')

  if (fwError) throw fwError

  for (const fw of frameworks) {
    console.log(`\n${fw.name} (${fw.code})`)
    console.log('-'.repeat(40))

    // Get levels for this framework
    const { data: levels, error: lvlError } = await supabase
      .from('ai_assessment_levels')
      .select('*')
      .eq('framework_id', fw.id)
      .order('level_code')

    if (lvlError) throw lvlError

    if (levels.length === 0) {
      console.log('  No levels configured')
      continue
    }

    for (const level of levels) {
      // Count questions for this level
      const { count: questionCount, error: qError } = await supabase
        .from('ai_questions')
        .select('*', { count: 'exact', head: true })
        .eq('level_id', level.id)
        .eq('is_active', true)

      if (qError) throw qError

      const status = level.is_active ? '' : ' [INACTIVE]'
      console.log(`\n  ${level.name} (${level.level_code})${status}`)
      console.log(`    Questions: ${questionCount || 0} (${level.question_count} per assessment)`)
      console.log(`    Pass score: ${level.passing_score}%`)

      // Get competencies
      const { data: competencies, error: cError } = await supabase
        .from('ai_competencies')
        .select('*')
        .eq('framework_id', fw.id)
        .eq('is_active', true)
        .order('sort_order')

      if (cError) throw cError

      if (competencies.length > 0) {
        console.log('    Competencies:')
        for (const comp of competencies) {
          // Count questions for this competency in this level
          const { count: compQuestionCount } = await supabase
            .from('ai_questions')
            .select('*', { count: 'exact', head: true })
            .eq('level_id', level.id)
            .eq('competency_id', comp.id)
            .eq('is_active', true)

          console.log(`      - ${comp.name} (${comp.code}): ${compQuestionCount || 0} questions`)
        }
      }
    }
  }

  // Summary stats
  const { count: totalQuestions } = await supabase
    .from('ai_questions')
    .select('*', { count: 'exact', head: true })
    .eq('is_active', true)

  const { count: totalAttempts } = await supabase
    .from('ai_assessment_attempts')
    .select('*', { count: 'exact', head: true })

  console.log('\n' + '='.repeat(60))
  console.log('SUMMARY')
  console.log('='.repeat(60))
  console.log(`Total frameworks: ${frameworks.length}`)
  console.log(`Total questions:  ${totalQuestions || 0}`)
  console.log(`Total attempts:   ${totalAttempts || 0}`)
  console.log('')
}

listAssessments().catch(err => {
  console.error('\nError:', err.message)
  process.exit(1)
})
