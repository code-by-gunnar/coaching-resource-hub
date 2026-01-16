import { test, expect } from '../fixtures/auth.js';
import { databaseHelper } from '../fixtures/databaseHelper.js';

test.describe('Basic Assessment Test', () => {
  // Don't clean up - keep test data for inspection
  // test.afterEach(async () => {
  //   await databaseHelper.cleanupAllAssessments();
  // });

  test('should complete assessment end-to-end', async ({ authenticatedPage: page }) => {
    console.log('=== Basic Assessment End-to-End Test ===');
    
    // Use streamlined flow - direct navigation with action parameter
    await page.goto('/docs/assessments/take?action=take#core-fundamentals-i');
    
    // Should auto-start assessment (no intermediate page, no modal)
    await page.waitForTimeout(2000);
    
    // Verify we're directly on the first question (streamlined flow)
    await expect(page.locator('.answer-option').first()).toBeVisible({ timeout: 10000 });
    await expect(page.locator('text=/Question 1 of/')).toBeVisible();
    console.log('✅ Assessment auto-started at question 1 (streamlined flow)');
    
    // Dynamic question answering loop
    let questionCount = 0;
    const maxQuestions = 20; // Safety limit
    
    while (questionCount < maxQuestions) {
      // Check if we have answer options (meaning we're still in questions)
      const hasAnswerOptions = await page.locator('.answer-option').count() > 0;
      if (!hasAnswerOptions) {
        console.log('No more answer options found, assessment completed');
        break;
      }
      
      questionCount++;
      console.log(`Answering question ${questionCount}`);
      
      // Wait for answer options to be visible
      await expect(page.locator('.answer-option').first()).toBeVisible({ timeout: 10000 });
      
      // Click the first answer option
      await page.click('.answer-option:nth-child(1)');
      
      // Check if this is the last question by looking for "Finish Assessment" button
      const finishButton = page.locator('button:has-text("Finish Assessment")');
      const nextButton = page.locator('button:has-text("Next Question")');
      
      if (await finishButton.count() > 0) {
        console.log('Found Finish Assessment button, completing assessment');
        await finishButton.click();
        break;
      } else if (await nextButton.count() > 0) {
        console.log('Found Next Question button, continuing');
        await nextButton.click();
        await page.waitForTimeout(1000); // Wait for next question to load
      } else {
        console.error('Neither Finish nor Next button found!');
        break;
      }
    }
    
    console.log(`✅ Completed assessment with ${questionCount} questions using streamlined flow`);
    
    // Verify completion
    await page.waitForTimeout(3000);
    await expect(page.locator('text=Assessment Complete!')).toBeVisible({ timeout: 5000 });
    
    // Verify score is displayed
    const scoreText = await page.locator('text=/%/').count();
    expect(scoreText).toBeGreaterThan(0);
    
    console.log('✅ Assessment completion verified with score display');
    expect(questionCount).toBeGreaterThan(0); // Ensure we answered at least one question
  });
});