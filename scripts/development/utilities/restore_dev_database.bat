@echo off
REM ====================================================================
REM DEVELOPMENT DATABASE RESTORATION SCRIPT (Windows)
REM ====================================================================
REM
REM This script completely resets your development database and restores
REM it to match production with all fixes applied.
REM
REM USAGE: 
REM   scripts\restore_dev_database.bat
REM
REM ====================================================================

echo 🚀 Starting Development Database Restoration...
echo ==================================================

REM Check if supabase CLI is available
npx supabase --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Supabase CLI not found. Please install it first:
    echo    npm install -g supabase
    pause
    exit /b 1
)

echo 📋 Step 1: Checking Supabase project status...
npx supabase status >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️  Supabase not running. Starting local instance...
    npx supabase start
) else (
    echo ✅ Supabase is running
)

echo.
echo 🗑️  Step 2: Resetting database (this will delete all existing data)...
set /p "confirm=Are you sure you want to continue? This will delete ALL data in your dev database. (y/N): "

if /i not "%confirm%"=="y" (
    echo ❌ Operation cancelled by user
    pause
    exit /b 0
)

echo 🔄 Resetting local database...
npx supabase db reset --linked=false

if %errorlevel% neq 0 (
    echo ❌ Database reset failed
    pause
    exit /b 1
)

echo ✅ Database reset complete

echo.
echo 📊 Step 3: Applying database migrations...
npx supabase db push --include-all

if %errorlevel% neq 0 (
    echo ❌ Database migrations failed
    pause
    exit /b 1
)

echo ✅ Migrations applied

echo.
echo 🏗️  Step 4: Restoring production data and fixes...

REM Check if the restoration SQL file exists
if not exist "scripts\restore_dev_from_prod.sql" (
    echo ❌ Restoration script not found at scripts\restore_dev_from_prod.sql
    pause
    exit /b 1
)

REM Execute the restoration script
npx supabase sql exec --file scripts/restore_dev_from_prod.sql

if %errorlevel% neq 0 (
    echo ❌ Database restoration failed
    pause
    exit /b 1
)

echo.
echo 🎉 SUCCESS! Database restoration completed!
echo ==================================================
echo.
echo 📋 What was restored:
echo    ✅ 9 assessments (Core/ICF/AC × Beginner/Intermediate/Advanced)
echo    ✅ 20 sample questions for Core Beginner assessment
echo    ✅ All database functions with bug fixes applied
echo    ✅ All triggers and RLS policies
echo    ✅ Performance indexes
echo    ✅ Fixed assessment status constraints
echo    ✅ Fixed scoring calculations
echo.
echo 🚀 Your development environment is ready!
echo.
echo 📝 Next steps:
echo    1. Start your dev server: npm run dev
echo    2. Create a test user account via signup
echo    3. Test the assessment functionality
echo.
echo 💡 Tip: Run this script anytime you need to restore dev to production state
echo.
pause