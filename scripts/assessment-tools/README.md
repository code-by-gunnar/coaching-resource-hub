# Assessment Management Tools

Simple CLI tools to manage AI assessments without a complex admin UI.

## Prerequisites

1. Node.js 18+
2. Set environment variables:
   ```bash
   export SUPABASE_URL="https://your-project.supabase.co"
   export SUPABASE_SERVICE_ROLE_KEY="your-service-role-key"
   ```

## Tools

### 1. Create New Assessment Level

Creates the skeleton for a new assessment (framework + level + competencies).

```bash
node create-assessment.js
```

This interactive script will prompt you for:
- Framework (core/icf/ac)
- Level (beginner/intermediate/advanced)
- Assessment name and description
- Competencies to include

### 2. Import Questions from CSV

Bulk import questions from a CSV file.

```bash
node import-questions.js questions.csv
```

### CSV Format

See `template-questions.csv` for the required format:

| Column | Description | Required |
|--------|-------------|----------|
| framework_code | `core`, `icf`, or `ac` | Yes |
| level_code | `beginner`, `intermediate`, or `advanced` | Yes |
| competency_code | Code matching existing competency | Yes |
| scenario_text | The scenario/context for the question | Yes |
| question_text | The actual question being asked | Yes |
| option_a | First answer option | Yes |
| option_b | Second answer option | Yes |
| option_c | Third answer option | Yes |
| option_d | Fourth answer option | Yes |
| correct_option | `a`, `b`, `c`, or `d` | Yes |
| concept_tag | Skill being tested (e.g., `active_listening`) | Yes |
| explanation | Why the correct answer is correct | Yes |
| ai_hint | Common mistake hint for AI (optional) | No |
| difficulty_weight | 1-3, affects scoring (default: 1) | No |

### 3. List Existing Assessments

View all configured assessments and their question counts.

```bash
node list-assessments.js
```

## Example Workflow

### Adding a new assessment (e.g., Core II - Intermediate)

1. **Create the assessment skeleton:**
   ```bash
   node create-assessment.js
   # Select: core framework, intermediate level
   # Enter competencies for this level
   ```

2. **Prepare your questions in CSV format:**
   - Copy `template-questions.csv`
   - Fill in questions (one per row)
   - Save as `core-intermediate-questions.csv`

3. **Import the questions:**
   ```bash
   node import-questions.js core-intermediate-questions.csv
   ```

4. **Verify:**
   ```bash
   node list-assessments.js
   ```

## Tips

- **Question Rotation**: Multiple questions can share the same `concept_tag`. The system randomly selects one per concept during assessments.
- **Competency Balance**: Aim for 3-5 questions per competency for good coverage.
- **AI Hints**: Adding `ai_hint` helps Claude generate better feedback for common mistakes.
