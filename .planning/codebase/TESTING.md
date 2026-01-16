# Testing Patterns

**Analysis Date:** 2026-01-16

## Test Framework

**Runner:**
- Playwright 1.54.2 - E2E browser testing
- Config: `playwright.config.js` in project root

**Assertion Library:**
- Playwright built-in `expect` API
- Matchers: `toBeVisible`, `toHaveText`, `toHaveCount`

**Run Commands:**
```bash
npm run test:e2e              # Run all E2E tests
npm run test:e2e:ui           # Interactive UI mode
npm run test:e2e:debug        # Debug mode
npm run test:e2e:headed       # Run with visible browser
npm run test:e2e:report       # View HTML report
```

## Test File Organization

**Location:**
- `tests/e2e/specs/*.spec.js` - Test specifications
- `tests/e2e/fixtures/*.js` - Test utilities and helpers

**Naming:**
- `feature-name.spec.js` for test files
- Descriptive names: `basic-assessment-test.spec.js`, `comprehensive-assessment-validation.spec.js`

**Structure:**
```
tests/
└── e2e/
    ├── fixtures/
    │   ├── auth.js              # Authentication helper/fixture
    │   ├── databaseHelper.js    # Database cleanup utilities
    │   └── testData.js          # Test data factories
    └── specs/
        ├── assessment-results-validation.spec.js
        ├── basic-assessment-test.spec.js
        ├── comprehensive-assessment-validation.spec.js
        └── streamlined-assessment-flow.spec.js
```

## Test Structure

**Suite Organization:**
```javascript
import { test, expect } from '../fixtures/auth.js';
import { databaseHelper } from '../fixtures/databaseHelper.js';

test.describe('Feature Name', () => {
  // Optional cleanup (often commented out to preserve data)
  // test.afterEach(async () => {
  //   await databaseHelper.cleanupAllAssessments();
  // });

  test('should do expected behavior', async ({ authenticatedPage: page }) => {
    console.log('=== Test Section Header ===');

    // Navigate
    await page.goto('/path');

    // Wait and verify
    await expect(page.locator('.selector')).toBeVisible({ timeout: 10000 });
    console.log('✅ Step completed');

    // Interact
    await page.click('.button');

    // Assert
    await expect(page.locator('.result')).toHaveText('expected');
  });
});
```

**Patterns:**
- Custom auth fixture provides `authenticatedPage`
- Console logging with emoji prefixes for visual scanning
- Explicit timeouts for visibility checks
- Cleanup often disabled to preserve test data for inspection

## Mocking

**Framework:**
- No mocking framework detected
- Tests run against real Supabase development database

**Patterns:**
- Integration tests against live dev environment
- `databaseHelper.js` provides cleanup utilities
- Test data created during test runs

**What to Mock:**
- Currently: Nothing mocked (full integration tests)
- Recommended: Consider mocking external APIs for speed

**What NOT to Mock:**
- Database interactions (tested against real Supabase)
- Authentication flow (uses real Supabase Auth)

## Fixtures and Factories

**Test Data (`tests/e2e/fixtures/testData.js`):**
- Provides test data generation utilities
- Used for creating assessment scenarios

**Auth Fixture (`tests/e2e/fixtures/auth.js`):**
- Extends Playwright's test fixture
- Provides `authenticatedPage` for tests requiring login
- Handles login flow before tests

**Database Helper (`tests/e2e/fixtures/databaseHelper.js`):**
- `cleanupAllAssessments()` - Remove test assessment data
- Database operations via Supabase client

## Coverage

**Requirements:**
- No enforced coverage target
- E2E tests focus on critical user flows
- Coverage for awareness only

**Configuration:**
- No unit test coverage tool configured
- Playwright provides test result reporting

**View Reports:**
```bash
npm run test:e2e:report       # Opens HTML report in browser
```

## Test Types

**Unit Tests:**
- Not currently implemented
- No Jest/Vitest configuration
- Business logic tested via E2E

**Integration Tests:**
- Not explicitly separated
- E2E tests serve as integration tests

**E2E Tests:**
- Framework: Playwright
- Scope: Full user flows (assessment completion, authentication)
- Browser: Chromium (configured in `playwright.config.js`)
- Location: `tests/e2e/specs/*.spec.js`

## Common Patterns

**Authenticated Testing:**
```javascript
import { test, expect } from '../fixtures/auth.js';

test('requires login', async ({ authenticatedPage: page }) => {
  // page is already logged in
  await page.goto('/protected-route');
});
```

**Waiting for Elements:**
```javascript
// Wait with explicit timeout
await expect(page.locator('.element')).toBeVisible({ timeout: 10000 });

// Wait for text content
await expect(page.locator('.status')).toHaveText('Complete');

// Wait for arbitrary time (avoid when possible)
await page.waitForTimeout(2000);
```

**Dynamic Loop Testing:**
```javascript
let questionCount = 0;
const maxQuestions = 20; // Safety limit

while (questionCount < maxQuestions) {
  const hasMore = await page.locator('.answer-option').count() > 0;
  if (!hasMore) break;

  questionCount++;
  await page.click('.answer-option:nth-child(1)');

  // Check for completion
  const finishBtn = page.locator('button:has-text("Finish")');
  if (await finishBtn.count() > 0) {
    await finishBtn.click();
    break;
  }
}
```

**Console Logging in Tests:**
```javascript
console.log('=== Test Section ===');
console.log(`Processing item ${index}`);
console.log('✅ Step passed');
console.log('❌ Step failed');
```

## Playwright Configuration Highlights

**From `playwright.config.js`:**
- Test directory: `./tests/e2e`
- Base URL: `http://localhost:5173`
- Parallel execution: Enabled locally, sequential on CI
- Retries: 2 on CI, 0 locally
- Browser: Chromium only
- Screenshots: On failure
- Video: Retained on failure
- Trace: On first retry
- Web server: Auto-starts `npm run dev`

---

*Testing analysis: 2026-01-16*
*Update when test patterns change*
