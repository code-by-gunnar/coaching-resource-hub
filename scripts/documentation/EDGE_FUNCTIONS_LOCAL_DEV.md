# Edge Functions Local Development Guide

## The Challenge

Supabase local development dashboard doesn't show Edge Functions. This is a known limitation (GitHub Issue #28934). However, you can still develop and test functions locally with these workarounds.

## Setup for Local Development

### 1. Environment Variables

Create `supabase/functions/.env.local`:

```env
# Local Supabase
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Real API Keys for Testing
RESEND_API_KEY=your_actual_resend_key
PDFSHIFT_API_KEY=your_actual_pdfshift_key
```

### 2. Start Development Environment

```bash
# Terminal 1: Start Supabase
npx supabase start

# Terminal 2: Start Edge Functions with logging
npx supabase functions serve --debug --env-file supabase/functions/.env.local

# Terminal 3: Your development work
```

## Testing Edge Functions

### Option 1: Using Test Script

```bash
# Run our custom test script
node scripts/test-edge-functions-locally.js
```

### Option 2: Manual curl Testing

```bash
# Test PDF Generation
curl -X POST 'http://127.0.0.1:54321/functions/v1/generate-pdf-report' \
  -H 'Authorization: Bearer SERVICE_ROLE_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "attemptId": "test-123",
    "assessmentData": {
      "overall_stats": {"score": 75},
      "competency_performance": [...],
      "assessment_framework": "core"
    },
    "userEmail": "test@example.com"
  }'

# Test Email Function
curl -X POST 'http://127.0.0.1:54321/functions/v1/email-assessment-report' \
  -H 'Authorization: Bearer SERVICE_ROLE_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "email": "test@example.com",
    "attemptId": "test-123"
  }'
```

### Option 3: Frontend Integration Testing

Test through your actual frontend by:

1. Ensuring frontend uses local Supabase URL
2. Creating test assessment data
3. Triggering PDF/email generation through UI
4. Watching terminal logs for function execution

## Viewing Logs and Debugging

### Real-time Logs

When you run `npx supabase functions serve --debug`, you'll see:
- Function invocations
- Console logs from your functions
- Errors and stack traces
- HTTP request/response details

### Enhanced Logging in Functions

Add detailed logging to your functions:

```typescript
console.log('🔍 Function started with payload:', JSON.stringify(payload, null, 2));
console.log('✅ Database query successful:', result);
console.error('❌ Error occurred:', error);
```

## Development Workflow

1. **Code**: Edit function files in your editor
2. **Test**: Use curl, test script, or frontend
3. **Debug**: Watch terminal logs from `serve --debug`
4. **Iterate**: Functions auto-reload on file changes
5. **Deploy**: Test on production when ready

## API Keys Management

### For Local Development:
- Use real API keys in `.env.local` (gitignored)
- Test with actual services (Resend, PDFShift)

### For Production:
- Set secrets in Supabase dashboard
- Never commit real keys to git

## Common Issues and Solutions

### "Function not found"
- Ensure `supabase functions serve` is running
- Check function name spelling in URL

### "Environment variable not found"
- Verify `.env.local` file exists and has correct keys
- Restart `functions serve` after adding new variables

### API Rate Limits
- Use test/development API keys with higher limits
- Implement proper error handling for rate limits

### Database Connection Issues
- Ensure local Supabase is running
- Check SERVICE_ROLE_KEY is correct for local instance

## Production Deployment

When ready for production:

```bash
# Deploy specific function
npx supabase functions deploy generate-pdf-report --project-ref YOUR_PROJECT_REF

# Deploy all functions
npx supabase functions deploy --project-ref YOUR_PROJECT_REF
```

Set production secrets in Supabase dashboard:
- `RESEND_API_KEY`
- `PDFSHIFT_API_KEY`

## Monitoring in Production

Once deployed, use the Supabase dashboard to:
- View function invocations and responses
- Monitor error rates and performance
- Stream real-time logs
- Set up alerts for failures

This workflow gives you full local development capabilities despite the dashboard limitation!