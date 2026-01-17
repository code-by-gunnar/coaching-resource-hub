# Coaching Resource Hub

A free coaching knowledge base with AI-powered assessments. Built for coaches who want practical resources and evidence-based skill development.

**Live site:** [yourcoachinghub.co.uk](https://www.yourcoachinghub.co.uk)

## Features

### Free Content (No sign-up required)
- 30+ coaching concepts and techniques
- Getting started guides for coaches and clients
- Basic training materials

### Member Content (Free sign-up)
- 25+ advanced training modules
- Professional intervention guides
- Business resources for starting a coaching practice
- Ethics training materials
- Downloadable templates and frameworks

### AI-Powered Assessments
- **Core Coaching Fundamentals** - Beginner assessment with 15 questions across 3 competencies
- **AI-Generated Reports** - Personalized insights using Claude Sonnet analyzing your specific answers
- **Client-Side PDF Export** - Download professional reports instantly (no external API costs)
- **Progress Tracking** - View history and compare attempts

## Tech Stack

- **Frontend:** VitePress + Vue 3
- **Database:** Supabase (PostgreSQL)
- **Authentication:** Supabase Auth with Google OAuth
- **AI Reports:** Anthropic Claude API (via Supabase Edge Functions)
- **PDF Generation:** pdfmake (client-side, zero cost)
- **Hosting:** Static site deployment

## Quick Start

### Prerequisites
- Node.js v18+
- npm v8+

### Development Setup

```bash
# Clone repository
git clone https://github.com/code-by-gunnar/coaching-resource-hub.git
cd coaching-resource-hub

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env.local
# Edit .env.local with your Supabase credentials

# Start development server
npm run dev
```

Opens at `http://localhost:5173`

### Environment Variables

```bash
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

## Project Structure

```
coaching-resource-hub/
├── index.md                    # Homepage
├── docs/
│   ├── assessments/            # Assessment interface
│   ├── auth/                   # Login/signup pages
│   ├── profile/                # User profile
│   ├── concepts/               # Coaching concepts (30+ pages)
│   ├── training/               # Training materials
│   │   ├── interventions/      # Specific intervention guides
│   │   └── ethics/             # Ethics resources
│   ├── business/               # Starting a coaching practice
│   ├── resources/              # Templates and tools
│   ├── workshops/              # Workshop materials
│   └── getting-started/        # Intro guides
├── .vitepress/
│   ├── config.js               # Site configuration
│   └── theme/
│       ├── components/         # Vue components
│       └── composables/        # Business logic
├── supabase/
│   ├── functions/              # Edge functions (AI reports, email)
│   └── migrations/             # Database migrations
└── public/                     # Static assets
```

## Key Components

### Content Access Control
- `ProtectedContent.vue` - Wrapper for member-only content
- `ContentTeaser.vue` - Teaser with sign-up CTA for locked pages
- Frontmatter `protected: true` marks pages as member-only

### Assessment System
- `AssessmentResults.vue` - Results display with AI report integration
- `useAiAssessments.js` - Assessment data management
- `usePdfReport.js` - Client-side PDF generation with pdfmake

### Authentication
- `Auth.vue` - Login/signup with Google OAuth support
- `useAuth.js` - Authentication state management
- `useBetaAccess.js` - Beta user access control

## Supabase Edge Functions

| Function | Purpose |
|----------|---------|
| `generate-ai-report` | Generates personalized AI analysis using Claude |
| `email-assessment-report` | Sends assessment notification emails |

## Commands

```bash
npm run dev       # Start dev server
npm run build     # Build for production
npm run preview   # Preview production build
```

## Database

Uses Supabase PostgreSQL with tables for:
- User assessment attempts and responses
- AI report caching
- Assessment questions and competencies
- Learning resources and insights

Migrations are managed via Supabase CLI:
```bash
npx supabase migration new <name>   # Create migration
npx supabase db push --linked       # Deploy to production
```

## Content Management

### Adding Public Content
Create `.md` file in `docs/getting-started/` or other public directories.

### Adding Protected Content
```markdown
---
title: Your Page Title
protected: true
---

<ProtectedContent>

Your content here...

</ProtectedContent>
```

## License

MIT License

---

*Built for coaches who want practical, evidence-based development resources.*
