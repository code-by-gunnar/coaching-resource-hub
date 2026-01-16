import { test, expect } from '../fixtures/auth.js';
import { databaseHelper } from '../fixtures/databaseHelper.js';

// Helper function to extract granular enriched_data structure
async function extractDetailedResultsData(page) {
  // Wait for all content to load
  await page.waitForTimeout(3000);
  
  const data = {
    // Basic score and performance info
    score: null,
    performanceLevel: null,
    totalQuestions: null,
    correctAnswers: null,
    
    // Key section presence
    hasAssessmentInsights: false,
    hasLearningRecommendations: false,
    
    // Granular weakness/strength structure
    weaknesses: [],
    strengths: [],
    
    // Learning path recommendations
    recommendations: [],
    
    // Metadata
    assessmentTitle: null
  };
  
  try {
    // Extract basic info
    const scoreElement = await page.locator('.score-value').first();
    if (await scoreElement.count() > 0) {
      data.score = await scoreElement.textContent();
    }
    
    const performanceElement = await page.locator('.performance-summary h3, .performance-message');
    if (await performanceElement.count() > 0) {
      data.performanceLevel = await performanceElement.first().textContent();
    }
    
    const statsText = await page.locator('.summary-stats').textContent();
    if (statsText) {
      const correctMatch = statsText.match(/(\d+) out of (\d+)/);
      if (correctMatch) {
        data.correctAnswers = correctMatch[1];
        data.totalQuestions = correctMatch[2];
      }
    }
    
    const titleElement = await page.locator('.results-header h1');
    if (await titleElement.count() > 0) {
      data.assessmentTitle = await titleElement.textContent();
    }
    
    // Check for key sections
    data.hasAssessmentInsights = await page.locator('.insights-container').count() > 0;
    data.hasLearningRecommendations = await page.locator('.learning-path-section').count() > 0;
    
    // Extract WEAKNESSES (Development Areas)
    const weaknessCards = await page.locator('.insights-section .insight-card.development').all();
    for (const card of weaknessCards) {
      const weakness = {
        area: null,
        displayName: null,
        percentage: null,
        tags: [],
        performanceAnalysis: [],
        strategicActions: [],
        specificSkills: []
      };
      
      // Extract area name and percentage
      const competencyInfo = await card.locator('.competency-info h4');
      if (await competencyInfo.count() > 0) {
        weakness.displayName = await competencyInfo.textContent();
      }
      
      const scoreValue = await card.locator('.score-value');
      if (await scoreValue.count() > 0) {
        weakness.percentage = await scoreValue.textContent();
      }
      
      // Click to expand if not expanded
      const isExpanded = await card.locator('.is-expanded').count() > 0;
      if (!isExpanded) {
        await card.locator('.card-header').click();
        await page.waitForTimeout(500);
      }
      
      // Extract skill tags
      const tagElements = await card.locator('.skill-tag.development').all();
      for (const tag of tagElements) {
        const tagText = await tag.textContent();
        if (tagText) weakness.tags.push(tagText.trim());
      }
      
      // Extract Performance Analysis
      const analysisElements = await card.locator('.insight-section .insight-text.personalized').all();
      for (const analysis of analysisElements) {
        const analysisText = await analysis.textContent();
        if (analysisText) weakness.performanceAnalysis.push(analysisText.trim());
      }
      
      // Extract Strategic Actions
      const actionElements = await card.locator('.action-section .action-text.personalized').all();
      for (const action of actionElements) {
        const actionText = await action.textContent();
        if (actionText) weakness.strategicActions.push(actionText.trim());
      }
      
      // Extract Specific Skills
      const skillElements = await card.locator('.tag-analysis-item').all();
      for (const skill of skillElements) {
        const tagName = await skill.locator('.tag-name').textContent();
        const tagInsight = await skill.locator('.tag-insight').textContent();
        const tagAction = await skill.locator('.tag-action').textContent();
        
        weakness.specificSkills.push({
          name: tagName?.trim(),
          insight: tagInsight?.trim(),
          action: tagAction?.trim()
        });
      }
      
      data.weaknesses.push(weakness);
    }
    
    // Extract STRENGTHS (similar structure)
    const strengthCards = await page.locator('.insights-section .insight-card.strength').all();
    for (const card of strengthCards) {
      const strength = {
        area: null,
        displayName: null,
        percentage: null,
        tags: [],
        leverageStrengths: [],
        actions: []
      };
      
      const competencyInfo = await card.locator('.competency-info h4');
      if (await competencyInfo.count() > 0) {
        strength.displayName = await competencyInfo.textContent();
      }
      
      const scoreValue = await card.locator('.score-value');
      if (await scoreValue.count() > 0) {
        strength.percentage = await scoreValue.textContent();
      }
      
      // Click to expand
      const isExpanded = await card.locator('.is-expanded').count() > 0;
      if (!isExpanded) {
        await card.locator('.card-header').click();
        await page.waitForTimeout(500);
      }
      
      // Extract skill tags
      const tagElements = await card.locator('.skill-tag.strength').all();
      for (const tag of tagElements) {
        const tagText = await tag.textContent();
        if (tagText) strength.tags.push(tagText.trim());
      }
      
      // Extract leverage insights
      const leverageElements = await card.locator('.insight-section .insight-text.personalized').all();
      for (const leverage of leverageElements) {
        const leverageText = await leverage.textContent();
        if (leverageText) strength.leverageStrengths.push(leverageText.trim());
      }
      
      data.strengths.push(strength);
    }
    
    // Extract Learning Path recommendations
    const recommendationElements = await page.locator('.learning-recommendation, .recommendation-item, .resource-item').all();
    for (const element of recommendationElements) {
      const text = await element.textContent();
      if (text && text.trim()) {
        data.recommendations.push(text.trim());
      }
    }
    
  } catch (error) {
    console.error('Error extracting detailed results data:', error);
  }
  
  return data;
}

test.describe('Assessment Results Validation', () => {
  // Clean up after each test but preserve completed attempts for results validation
  test.afterEach(async () => {
    await databaseHelper.cleanupAllAssessments(true); // preserveCompleted = true
  });

  test('should display correct results for 0% score (A,A,A)', async ({ authenticatedPage: page }) => {
    console.log('=== Test: 0% Score Results (A,A,A) ===');
    
    // Start assessment
    await page.goto('http://localhost:5173/docs/assessments/take?action=take#core-fundamentals-i');
    await page.waitForTimeout(2000);
    
    // Answer all questions with A,A,A sequence
    const answers = ['A', 'A', 'A'];
    
    for (let i = 0; i < answers.length; i++) {
      console.log(`Answering question ${i + 1} with ${answers[i]}`);
      
      // Wait for answer options to be visible
      await expect(page.locator('.answer-option').first()).toBeVisible({ timeout: 10000 });
      
      // Click the correct answer option (A=1st, B=2nd, C=3rd, D=4th)
      const optionIndex = answers[i].charCodeAt(0) - 'A'.charCodeAt(0);
      await page.click(`.answer-option:nth-child(${optionIndex + 1})`);
      
      // Click Next or Finish button
      const finishButton = page.locator('button:has-text("Finish Assessment")');
      const nextButton = page.locator('button:has-text("Next Question")');
      
      if (await finishButton.count() > 0) {
        await finishButton.click();
        break;
      } else {
        await nextButton.click();
        await page.waitForTimeout(1000);
      }
    }
    
    // Wait for completion page
    await page.waitForTimeout(3000);
    await expect(page.locator('text=Assessment Complete!')).toBeVisible({ timeout: 5000 });
    
    // Verify 0% score is displayed
    await expect(page.locator('text=/0%|0 %/').first()).toBeVisible();
    console.log('✅ 0% score displayed correctly');
    
    // Click View Detailed Results
    await page.click('button:has-text("View Detailed Results")');
    await page.waitForTimeout(2000);
    
    // Verify detailed results page loads with enriched_data
    await expect(page.locator('.assessment-results-container')).toBeVisible({ timeout: 10000 });
    
    // Extract and validate granular results structure
    const resultsData = await extractDetailedResultsData(page);
    console.log('📊 0% Detailed Results:', JSON.stringify(resultsData, null, 2));
    
    // Validate 0% specific structure - should have 3 weaknesses, 0 strengths
    expect(resultsData.score).toBe('0%');
    expect(resultsData.performanceLevel).toMatch(/needs improvement/i);
    expect(resultsData.hasAssessmentInsights).toBe(true); // Should show insights structure now
    expect(resultsData.hasLearningRecommendations).toBe(true);
    
    // Validate weakness structure (0% should have 3 weaknesses)
    expect(resultsData.weaknesses.length).toBe(3);
    expect(resultsData.strengths.length).toBe(0);
    
    // Validate each weakness has required granular structure
    for (const weakness of resultsData.weaknesses) {
      expect(weakness.displayName).toBeTruthy();
      expect(weakness.percentage).toBeTruthy();
      expect(weakness.tags.length).toBeGreaterThan(0); // Should have skill tags
      expect(weakness.performanceAnalysis.length).toBeGreaterThan(0); // Performance Analysis items
      expect(weakness.strategicActions.length).toBeGreaterThan(0); // Strategic Actions items
      expect(weakness.specificSkills.length).toBeGreaterThan(0); // Specific Skills items
    }
    
    console.log('✅ Detailed results data validated for 0% score');
  });

  test('should display correct results for 67% score (B,B,D)', async ({ authenticatedPage: page }) => {
    console.log('=== Test: 67% Score Results (B,B,D) ===');
    
    // Start assessment
    await page.goto('http://localhost:5173/docs/assessments/take?action=take#core-fundamentals-i');
    await page.waitForTimeout(2000);
    
    // Answer all questions with B,B,D sequence
    const answers = ['B', 'B', 'D'];
    
    for (let i = 0; i < answers.length; i++) {
      console.log(`Answering question ${i + 1} with ${answers[i]}`);
      
      // Wait for answer options to be visible
      await expect(page.locator('.answer-option').first()).toBeVisible({ timeout: 10000 });
      
      // Click the correct answer option (A=1st, B=2nd, C=3rd, D=4th)
      const optionIndex = answers[i].charCodeAt(0) - 'A'.charCodeAt(0);
      await page.click(`.answer-option:nth-child(${optionIndex + 1})`);
      
      // Click Next or Finish button
      const finishButton = page.locator('button:has-text("Finish Assessment")');
      const nextButton = page.locator('button:has-text("Next Question")');
      
      if (await finishButton.count() > 0) {
        await finishButton.click();
        break;
      } else {
        await nextButton.click();
        await page.waitForTimeout(1000);
      }
    }
    
    // Wait for completion page
    await page.waitForTimeout(3000);
    await expect(page.locator('text=Assessment Complete!')).toBeVisible({ timeout: 5000 });
    
    // Verify 67% score is displayed
    await expect(page.locator('text=/67%|67 %/').first()).toBeVisible();
    console.log('✅ 67% score displayed correctly');
    
    // Click View Detailed Results
    await page.click('button:has-text("View Detailed Results")');
    await page.waitForTimeout(2000);
    
    // Verify detailed results page loads with enriched_data
    await expect(page.locator('.assessment-results-container')).toBeVisible({ timeout: 10000 });
    
    // Extract and validate granular results structure
    const resultsData = await extractDetailedResultsData(page);
    console.log('📊 67% Detailed Results:', JSON.stringify(resultsData, null, 2));
    
    // Validate 67% specific structure - should have 1 weakness, 2 strengths
    expect(resultsData.score).toBe('67%');
    expect(resultsData.performanceLevel).toMatch(/needs improvement/i);
    expect(resultsData.hasAssessmentInsights).toBe(true);
    expect(resultsData.hasLearningRecommendations).toBe(true);
    
    // Validate weakness/strength distribution (67% should have 1 weakness, 2 strengths)
    expect(resultsData.weaknesses.length).toBe(1);
    expect(resultsData.strengths.length).toBe(2);
    
    // Validate weakness structure
    for (const weakness of resultsData.weaknesses) {
      expect(weakness.displayName).toBeTruthy();
      expect(weakness.tags.length).toBeGreaterThan(0);
      expect(weakness.performanceAnalysis.length).toBeGreaterThan(0);
      expect(weakness.strategicActions.length).toBeGreaterThan(0);
      expect(weakness.specificSkills.length).toBeGreaterThan(0);
    }
    
    // Validate strength structure
    for (const strength of resultsData.strengths) {
      expect(strength.displayName).toBeTruthy();
      expect(strength.tags.length).toBeGreaterThan(0);
      expect(strength.leverageStrengths.length).toBeGreaterThan(0);
    }
    
    console.log('✅ Detailed results data validated for 67% score');
  });

  test('should display correct results for 100% score (B,B,C)', async ({ authenticatedPage: page }) => {
    console.log('=== Test: 100% Score Results (B,B,C) ===');
    
    // Start assessment
    await page.goto('http://localhost:5173/docs/assessments/take?action=take#core-fundamentals-i');
    await page.waitForTimeout(2000);
    
    // Answer all questions with B,B,C sequence
    const answers = ['B', 'B', 'C'];
    
    for (let i = 0; i < answers.length; i++) {
      console.log(`Answering question ${i + 1} with ${answers[i]}`);
      
      // Wait for answer options to be visible
      await expect(page.locator('.answer-option').first()).toBeVisible({ timeout: 10000 });
      
      // Click the correct answer option (A=1st, B=2nd, C=3rd, D=4th)
      const optionIndex = answers[i].charCodeAt(0) - 'A'.charCodeAt(0);
      await page.click(`.answer-option:nth-child(${optionIndex + 1})`);
      
      // Click Next or Finish button
      const finishButton = page.locator('button:has-text("Finish Assessment")');
      const nextButton = page.locator('button:has-text("Next Question")');
      
      if (await finishButton.count() > 0) {
        await finishButton.click();
        break;
      } else {
        await nextButton.click();
        await page.waitForTimeout(1000);
      }
    }
    
    // Wait for completion page
    await page.waitForTimeout(3000);
    await expect(page.locator('text=Assessment Complete!')).toBeVisible({ timeout: 5000 });
    
    // Verify 100% score is displayed
    await expect(page.locator('text=/100%|100 %/').first()).toBeVisible();
    console.log('✅ 100% score displayed correctly');
    
    // Click View Detailed Results
    await page.click('button:has-text("View Detailed Results")');
    await page.waitForTimeout(2000);
    
    // Verify detailed results page loads with enriched_data
    await expect(page.locator('.assessment-results-container')).toBeVisible({ timeout: 10000 });
    
    // Extract and validate granular results structure
    const resultsData = await extractDetailedResultsData(page);
    console.log('📊 100% Detailed Results:', JSON.stringify(resultsData, null, 2));
    
    // Validate 100% specific structure - should have 0 weaknesses, 3 strengths
    expect(resultsData.score).toBe('100%');
    expect(resultsData.performanceLevel).toMatch(/outstanding/i);
    expect(resultsData.hasAssessmentInsights).toBe(true);
    expect(resultsData.hasLearningRecommendations).toBe(true);
    
    // Validate weakness/strength distribution (100% should have 0 weaknesses, 3 strengths)
    expect(resultsData.weaknesses.length).toBe(0);
    expect(resultsData.strengths.length).toBe(3);
    
    // Validate strength structure
    for (const strength of resultsData.strengths) {
      expect(strength.displayName).toBeTruthy();
      expect(strength.percentage).toBeTruthy();
      expect(strength.tags.length).toBeGreaterThan(0); // Should have skill tags
      expect(strength.leverageStrengths.length).toBeGreaterThan(0); // Leverage insights
    }
    
    // Validate learning path is optimized for high performers
    expect(resultsData.recommendations.length).toBeGreaterThan(0);
    expect(resultsData.recommendations.length).toBeLessThan(10); // Fewer, advanced recommendations
    
    console.log('✅ Detailed results data validated for 100% score');
  });
});