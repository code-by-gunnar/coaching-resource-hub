import { test as base } from '@playwright/test';

// Extend basic test by providing "authenticatedPage" fixture
export const test = base.extend({
  authenticatedPage: async ({ page, browserName }, use) => {
    // Use browser-specific test users to prevent parallel test contamination
    const testUsers = {
      'chromium': 'test-chromium@coaching-hub.local',
      'firefox': 'test-firefox@coaching-hub.local', 
      'Mobile Chrome': 'test-mobile@coaching-hub.local',
      'webkit': 'test-webkit@coaching-hub.local' // fallback
    };
    
    const testEmail = testUsers[browserName] || 'test@coaching-hub.local';
    console.log(`🔐 Authenticating as ${testEmail} for ${browserName}`);
    
    // Go directly to the auth page
    await page.goto('http://localhost:5173/docs/auth/');
    
    // Wait for the auth form to be visible
    await page.waitForSelector('form input[type="email"]', { timeout: 10000 });
    
    // Fill in browser-specific credentials
    await page.fill('input[type="email"]', testEmail);
    await page.fill('input[type="password"]', 'test123456');
    
    // Click the Sign In button within the form (not the navigation)
    await page.locator('form').locator('button:has-text("Sign In")').click();
    
    // Wait for authentication redirect or success indicators
    await page.waitForFunction(
      () => {
        // Look for signs of successful auth
        return document.body.textContent?.includes('Sign Out') || 
               document.body.textContent?.includes('@coaching-hub.local') ||
               window.location.pathname !== '/docs/auth/';
      },
      { timeout: 10000 }
    );
    
    // Give a moment for any state updates to complete
    await page.waitForTimeout(1000);
    
    // Use the authenticated page in the test
    await use(page);
    
    // Clean up if needed
  },
});

export { expect } from '@playwright/test';