# 🎯 Coaching Resource Hub

*Professional Coaching Development & Assessment Platform*

A comprehensive coaching development platform featuring skill assessments, training materials, video resources, and interactive learning tools. Built for professional coaches seeking evidence-based skill development and certification support.

## ✨ What Makes This Special

### 🎯 **Assessment-Driven Skill Development**
- **Professional Coaching Assessments** - Core Beginner & Intermediate assessments with 26 distinct skills
- **Evidence-Based Results** - Skills aligned to actual assessment questions using proven methodology  
- **Personalized Development** - Strength/weakness insights with actionable strategic actions
- **Multi-Framework Support** - Core, ICF, and AC competency frameworks (expanding)

### 🚀 **Production-Ready Platform**
- ⚡ **Lightning Fast** - Sub-100ms page loads and instant search
- 🎥 **Rich Video Content** - 16+ embedded training videos with expert instruction  
- 📁 **Downloadable Resources** - Ethics documents, coaching scripts, and templates
- 📱 **Mobile Perfect** - Responsive design that works everywhere
- 🔍 **Advanced Search** - Built-in search across assessments and content
- 💻 **Admin Interface** - Professional assessment creation and management tools

## 🏗️ Architecture & Technology

### **Frontend:** VitePress + Vue 3 + Supabase
- **VitePress** - Lightning-fast static site generation with Vue 3
- **Interactive Components** - Assessment interface, results dashboard, admin tools
- **Real-time Database** - Supabase integration for assessments and user data
- **Authentication** - Secure user accounts with beta access controls

### **Assessment System:** Evidence-Based Skill Development
- **Assessment-Skills Alignment Methodology** - Proven framework for creating skill-aligned assessments
- **Multi-Framework Architecture** - Supports Core, ICF, AC competency frameworks
- **Production Database** - PostgreSQL with comprehensive skill and content management
- **Admin Tools** - Professional assessment creation and management interface

## 🚀 Quick Start

### Prerequisites
- **Node.js** v18+ 
- **npm** v8+

### Development Setup

```bash
# 1. Clone and enter directory
git clone https://github.com/your-org/coaching-resource-hub.git
cd coaching-resource-hub

# 2. Install dependencies
npm install

# 3. Set up environment variables
cp .env.example .env.local
# Edit .env.local with your Supabase credentials

# 4. Start development server  
npm run dev
```

Your platform opens at `http://localhost:5173` with instant hot reloads! 🎉

### Environment Setup
Create `.env.local` with:
```bash
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
VITE_SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
```

## 📝 Commands

```bash
# Development
npm run dev          # Start dev server (instant hot reloads)

# Production
npm run build        # Build for production
npm run preview      # Preview production build locally
```

## 🎯 Assessment System Features

### **Current Assessments**
- ✅ **Core I (Beginner)**: 15 questions, 9 skills, 3 competencies
- ✅ **Core II (Intermediate)**: 26 questions, 26 skills, 5 competencies  
- 🔄 **Core III (Advanced)**: In development

### **Assessment Features**
- **Realistic Coaching Scenarios** - Based on actual coaching situations across diverse life areas
- **Skills-Based Results** - Each question maps to specific coaching skills
- **Personalized Insights** - Strength/weakness analysis with strategic development actions
- **Professional Language** - ICF/EMCC appropriate terminology and guidance
- **Life Area Balance** - Questions span work, relationships, health, personal growth, finance, recreation

### **Admin Capabilities**
- **Assessment Creation** - Comprehensive wizard for building new assessments
- **Skills Management** - Create and manage skills, insights, and strategic actions  
- **User Management** - Beta user access controls and progress tracking
- **Content Management** - Professional assessment content creation and editing

## 📚 Platform Structure

```
📁 coaching-resource-hub/
├── 📄 index.md                 # Homepage with assessment overview
├── 📁 docs/
│   ├── 📁 assessments/         # Assessment taking and results
│   ├── 📁 admin/               # Assessment creation and management
│   ├── 📁 auth/                # Authentication and user management
│   ├── 📁 training/            # Core coaching skills & interventions
│   │   ├── 📁 basics/          # Active listening, questioning
│   │   ├── 📁 interventions/   # Behavior, anxiety, confidence, etc.
│   │   └── 📁 ethics/          # AC & ICF ethics documents
│   ├── 📁 concepts/            # Advanced coaching techniques
│   ├── 📁 resources/           # Tools, templates, frameworks
│   ├── 📁 business/            # Starting a coaching practice
│   └── 📁 getting-started/     # For coaches and clients
├── 📁 .vitepress/
│   ├── 📁 theme/               # Vue components and composables
│   │   ├── 📁 components/      # Assessment interface components
│   │   └── 📁 composables/     # Assessment logic and data management
│   └── 📁 config.js           # Site configuration
├── 📁 scripts/
│   ├── 📁 documentation/       # Assessment methodology documentation
│   └── 📁 production/         # Database deployment scripts
└── 📁 public/                  # Images and static assets
```

## 🎥 Training Content & Resources

### **Assessment-Driven Learning**
- **Personalized Development Plans** - Based on individual assessment results
- **Skills-Specific Actions** - Strategic guidance aligned to tested coaching skills
- **Professional Development Pathways** - Structured learning based on competency areas
- **Evidence-Based Insights** - Content aligned to actual assessment performance

### **Traditional Learning Resources**  
- **16+ Embedded Videos** - GROW Model, NLP techniques, core coaching skills
- **Downloadable Resources** - Ethics documents, coaching scripts, professional forms
- **Interactive Workbooks** - Practical exercises and client tools
- **Professional Templates** - Session records, intake forms, feedback tools

### **Assessment Methodology Documentation**
- **Assessment-Skills Alignment Methodology** - Complete framework for creating skill-aligned assessments
- **Life Area Balance Framework** - Guidelines for diverse, inclusive assessment scenarios
- **Multi-Framework Expansion Strategy** - Roadmap for ICF and AC framework integration

## 🔧 Development & Extension

### **Assessment Development**
Use the proven **Assessment-Skills Alignment Methodology**:

1. **Write Questions First** - Create realistic coaching scenarios
2. **Extract Skills** - Map each question to specific coaching behaviors  
3. **Create Content** - Develop insights and actions aligned to skills
4. **Validate & Deploy** - Professional review and production deployment

### **Adding Training Content**
1. Create `.md` file in appropriate `docs/` subdirectory
2. Add frontmatter with title and description
3. Content appears automatically in navigation

### **Database Management**
```bash
# Local Supabase development
npx supabase start              # Start local instance
npx supabase db reset --local   # Reset local database  
npx supabase migration new name  # Create new migration
npx supabase db push --local    # Apply migrations locally
```

### **Assessment Creation Example**
```markdown
---
title: New Assessment Creation
description: Building skill-aligned coaching assessments
---

# Creating New Assessments

Follow the Assessment-Skills Alignment Methodology:

## Phase 1: Question Analysis
Write realistic coaching scenarios first, then identify skills being tested.

## Phase 2: Skills Extraction  
Map each question to distinct, measurable coaching behaviors.

## Phase 3: Content Creation
Create insights and actions aligned to actual skill performance.
```

## 🔍 Search & Discovery

### **Built-in Search**
- Instant search across all content and assessments
- Finds content by title, headings, and body text
- No configuration needed

### **Assessment Discovery**
- Browse assessments by framework and level
- Filter by competency areas and skill types
- Smart recommendations based on assessment results

## 🎨 Configuration & Customization

### **Site Configuration**
Edit `.vitepress/config.js`:
```javascript
export default {
  title: 'Coaching Resource Hub',
  description: 'Professional coaching assessment platform',
  // Add navigation, themes, and assessment settings
}
```

### **Assessment Configuration**
- Framework settings in Supabase database
- Assessment-level configurations
- User access controls and beta management
- Professional content standards and validation

### **Styling & Components**
- Vue 3 components in `.vitepress/theme/components/`
- Assessment interface components
- Custom styling in `.vitepress/theme/style/`

## 🚀 Deployment & Production

### **Production Architecture**
- **Frontend**: VitePress static site with Vue 3 components
- **Database**: Supabase PostgreSQL with real-time features
- **Authentication**: Supabase Auth with beta user controls
- **Hosting**: Static hosting + database backend

### **Build for Production**
```bash
npm run build                    # Build static site
# Database migrations handled via Supabase CLI
npx supabase db push --linked    # Deploy database changes
```

### **Deployment Options**
- **Vercel + Supabase** - Recommended full-stack deployment
- **Netlify + Supabase** - Alternative static + database hosting
- **Self-hosted** - VitePress static files + PostgreSQL database

### **Environment Management**
```bash
# Production environment variables
VITE_SUPABASE_URL=your_production_url
VITE_SUPABASE_ANON_KEY=your_production_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
```

## 📊 Performance & Features

### **Platform Performance**
- ⚡ **<100ms** page loads with instant hot reloads
- 🚀 **<2 seconds** full site builds
- 📱 **Perfect mobile** responsiveness across all devices
- 🔍 **Instant search** across content and assessments
- 🎯 **Optimized bundles** with code splitting

### **Assessment Performance**
- **Real-time Results** - Instant scoring and feedback
- **Scalable Architecture** - Handles multiple concurrent assessments
- **Professional UI** - Clean, distraction-free assessment interface
- **Data Integrity** - Reliable scoring and progress tracking

## 🔧 Troubleshooting

### **Development Issues**

**Port already in use?**
```bash
npm run dev -- --port 3000
```

**Database connection issues?**
```bash
# Check Supabase status
npx supabase status --local
# Restart local instance
npx supabase stop && npx supabase start
```

**Assessment not loading?**
- Verify environment variables in `.env.local`
- Check Supabase database connection
- Ensure user has proper authentication and beta access

### **Assessment Issues**
**Results not saving?**
- Check authentication status
- Verify database permissions
- Review browser console for errors

**Admin access denied?**
- Confirm admin privileges in user metadata
- Check admin session management
- Verify service role key configuration

## 📖 Learn More & Documentation

### **Platform Documentation**
- **Assessment-Skills Alignment Methodology**: `scripts/documentation/ASSESSMENT_SKILLS_ALIGNMENT_METHODOLOGY.md`
- **Core II Assessment Specification**: `CORE_II_INTERMEDIATE_ASSESSMENT.md`
- **Admin Hub Guide**: `docs/admin/index.md`

### **External Resources**
- [VitePress Documentation](https://vitepress.dev/)
- [Supabase Documentation](https://supabase.com/docs)
- [Vue 3 Composition API](https://vuejs.org/guide/extras/composition-api-faq.html)

## 🤝 Contributing & Development

### **Assessment Development**
1. Follow Assessment-Skills Alignment Methodology
2. Create realistic coaching scenarios first
3. Extract skills from actual questions
4. Validate with professional coaching community

### **Platform Development**
1. Fork the repository
2. Create feature branch
3. Follow Vue 3 + VitePress best practices
4. Submit pull request with comprehensive testing

### **Content Contribution**
1. Add training materials in `docs/` structure
2. Follow professional coaching language standards
3. Include practical, actionable guidance
4. Test across devices and browsers

## 📄 License

MIT License - see LICENSE file for details.

---

## 🎯 Assessment-Driven Coaching Development

**The Coaching Resource Hub represents a paradigm shift from generic coaching resources to evidence-based, skill-specific development.**

### **What Makes This Different:**

**Traditional Approach:**
- 😱 Generic coaching advice
- 😱 No skill measurement  
- 😱 One-size-fits-all content
- 😱 No development tracking
- 😱 Scattered resources

**Assessment-Skills Alignment Approach:**
- ✅ **Evidence-based development** - Skills aligned to actual test performance
- ✅ **Personalized insights** - Content based on individual strengths/weaknesses
- ✅ **Professional standards** - ICF/EMCC appropriate language and guidance
- ✅ **Scalable methodology** - Works across multiple coaching frameworks
- ✅ **Integrated platform** - Assessments, training, and tools in one place

**Result:** Professional coaching development that actually measures and improves specific skills! 🎊

---

*Built with evidence-based methodology for professional coaches who demand measurable skill development*