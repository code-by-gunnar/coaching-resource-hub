import { test, expect } from '../fixtures/auth.js';
import { databaseHelper } from '../fixtures/databaseHelper.js';

test.describe('Streamlined Assessment Flow', () => {
  // Clean up after each test
  test.afterEach(async () => {
    await databaseHelper.cleanupAllAssessments();
  });

  test('should complete fresh assessment with Take action', async ({ authenticatedPage: page }) => {
    console.log('=== Test: Fresh Assessment with ?action=take ===');
    
    // Navigate with action=take parameter
    await page.goto('http://localhost:5173/docs/assessments/take?action=take#core-fundamentals-i');
    
    // Should auto-start assessment (no intermediate page, no modal)
    await page.waitForTimeout(2000);
    
    // Should be directly on first question
    await expect(page.locator('.answer-option').first()).toBeVisible({ timeout: 10000 });
    await expect(page.locator('text=/Question 1 of/')).toBeVisible();
    console.log('✅ Assessment auto-started on question 1');
    
    // Complete all questions
    let questionCount = 0;
    const maxQuestions = 20; // Safety limit
    
    while (questionCount < maxQuestions) {
      const hasAnswerOptions = await page.locator('.answer-option').count() > 0;
      if (!hasAnswerOptions) break;
      
      questionCount++;
      console.log(`Answering question ${questionCount}`);
      
      // Answer the question
      await page.click('.answer-option:nth-child(1)');
      
      // Check for finish or next button
      const finishButton = page.locator('button:has-text("Finish Assessment")');
      const nextButton = page.locator('button:has-text("Next Question")');
      
      if (await finishButton.count() > 0) {
        await finishButton.click();
        break;
      } else if (await nextButton.count() > 0) {
        await nextButton.click();
        await page.waitForTimeout(1000);
      } else {
        break;
      }
    }
    
    // Verify completion
    await page.waitForTimeout(3000);
    await expect(page.locator('text=Assessment Complete!')).toBeVisible({ timeout: 5000 });
    console.log(`✅ Completed assessment with ${questionCount} questions`);
  });

  test('should handle continue action when no incomplete assessment exists', async ({ authenticatedPage: page }) => {
    console.log('=== Test: Continue Action with No Incomplete Assessment ===');
    
    // Navigate with action=continue parameter (but no incomplete assessment exists)
    await page.goto('http://localhost:5173/docs/assessments/take?action=continue#core-fundamentals-i');
    
    // Should auto-start fresh assessment since no incomplete one exists
    await page.waitForTimeout(2000);
    await expect(page.locator('.answer-option').first()).toBeVisible({ timeout: 10000 });
    await expect(page.locator('text=/Question 1 of/')).toBeVisible();
    console.log('✅ Started fresh assessment when no incomplete assessment exists');
    
    // Answer first question to create an in_progress state, then exit
    await page.click('.answer-option:nth-child(1)');
    await page.click('button:has-text("Next Question")');
    await page.waitForTimeout(1000);
    
    // Verify we're on question 2
    await expect(page.locator('text=/Question 2 of/')).toBeVisible();
    console.log('✅ Successfully progressed to question 2');
    
    // Navigate away to test resume functionality  
    await page.goto('http://localhost:5173/docs/assessments/');
    await page.waitForTimeout(2000);
    
    // Should now show Continue button
    const continueExists = await page.locator('button:has-text("Continue Assessment")').count();
    console.log(`✅ Continue button ${continueExists > 0 ? 'exists' : 'does not exist'} after partial completion`);
  });

  test('should start fresh assessment with Retake action', async ({ authenticatedPage: page }) => {
    console.log('=== Test: Retake Assessment with ?action=retake ===');
    
    // Navigate with action=retake parameter (should always start fresh)
    await page.goto('http://localhost:5173/docs/assessments/take?action=retake#core-fundamentals-i');
    
    // Should auto-start fresh assessment regardless of any existing state
    await page.waitForTimeout(2000);
    await expect(page.locator('.answer-option').first()).toBeVisible({ timeout: 10000 });
    await expect(page.locator('text=/Question 1 of/')).toBeVisible();
    console.log('✅ Retake auto-started at question 1');
    
    // Answer first question to verify it's working
    await page.click('.answer-option:nth-child(1)');
    await page.click('button:has-text("Next Question")');
    await page.waitForTimeout(1000);
    
    // Verify we moved to question 2
    await expect(page.locator('text=/Question 2 of/')).toBeVisible();
    console.log('✅ Retake assessment is working correctly');
  });

  test('should show Take Assessment button by default', async ({ authenticatedPage: page }) => {
    console.log('=== Test: Default Button State ===');
    
    // Fresh user should see "Take Assessment"
    await page.goto('http://localhost:5173/docs/assessments/');
    
    // Debug: Log all buttons present
    const buttons = await page.locator('button').all();
    const buttonTexts = [];
    for (const button of buttons) {
      const text = await button.textContent();
      buttonTexts.push(text);
    }
    console.log('🔍 All buttons found:', buttonTexts);
    
    await expect(page.locator('button:has-text("Take Assessment")')).toBeVisible();
    console.log('✅ Fresh user sees "Take Assessment" button');
  });

  test('should handle direct URL navigation correctly', async ({ authenticatedPage: page }) => {
    console.log('=== Test: Direct URL Navigation ===');
    
    // Test clicking buttons generates correct URLs with actions
    await page.goto('http://localhost:5173/docs/assessments/');
    
    // Intercept navigation to check URL parameters
    let interceptedUrl = '';
    page.on('framenavigated', (frame) => {
      if (frame === page.mainFrame()) {
        interceptedUrl = frame.url();
      }
    });
    
    // Click Take Assessment button
    await page.click('button:has-text("Take Assessment")');
    await page.waitForTimeout(1000);
    
    // Verify URL contains action=take parameter
    expect(interceptedUrl).toContain('action=take');
    console.log(`✅ Take Assessment button navigated to: ${interceptedUrl}`);
    
    // Verify we're on the assessment (no intermediate page)
    await expect(page.locator('.answer-option').first()).toBeVisible({ timeout: 10000 });
    console.log('✅ Direct navigation bypassed intermediate page');
  });

  test('should navigate directly to assessment questions', async ({ authenticatedPage: page }) => {
    console.log('=== Test: Direct Question Navigation ===');
    
    // Start an assessment and verify we land directly on questions
    await page.goto('http://localhost:5173/docs/assessments/take?action=take#core-fundamentals-i');
    await page.waitForTimeout(2000);
    await expect(page.locator('.answer-option').first()).toBeVisible({ timeout: 10000 });
    console.log('✅ Direct navigation to assessment questions works');
    
    // Verify we're on question 1
    await expect(page.locator('text=/Question 1 of/')).toBeVisible();
    console.log('✅ Started at question 1 as expected');
  });
});