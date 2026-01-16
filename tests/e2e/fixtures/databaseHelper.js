import { createClient } from '@supabase/supabase-js';

// Create a Supabase client with service role for test cleanup (bypasses RLS)
const supabase = createClient(
  'http://localhost:54321',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU' // service_role key
);

export const databaseHelper = {
  // Get user ID - simplified to only use test@coaching-hub.local
  getUserIdByEmail(email = 'test@coaching-hub.local') {
    // Always return the standard test user ID
    return '903ee426-964e-40f4-ac96-903675e91d64';
  },

  // Clean up all assessment attempts for a specific user
  async cleanupUserAssessments(userEmail = 'test@coaching-hub.local') {
    try {
      // Use the browser-specific test user ID
      const userId = this.getUserIdByEmail(userEmail);

      // Get all attempt IDs for this user
      const { data: attempts } = await supabase
        .from('user_assessment_attempts')
        .select('id')
        .eq('user_id', userId);

      if (attempts && attempts.length > 0) {
        const attemptIds = attempts.map(a => a.id);
        
        // Delete responses first (foreign key constraint)
        await supabase
          .from('user_question_responses')
          .delete()
          .in('attempt_id', attemptIds);

        // Delete attempts
        await supabase
          .from('user_assessment_attempts')
          .delete()
          .eq('user_id', userId);

        console.log(`Cleaned up ${attempts.length} assessment attempts`);
      }

      return { success: true };
    } catch (error) {
      console.error('Cleanup error:', error);
      return { error: error.message };
    }
  },

  // Create a partial assessment for testing
  async createPartialAssessment(userEmail = 'test@coaching-hub.local', assessmentId = '00000000-0000-0000-0000-000000000001') {
    try {
      // Use the browser-specific test user ID
      const userId = this.getUserIdByEmail(userEmail);

      // Create an in-progress attempt
      const { data: attempt, error: attemptError } = await supabase
        .from('user_assessment_attempts')
        .insert({
          user_id: userId,
          assessment_id: assessmentId,
          status: 'in_progress',
          total_questions: 3,
          created_at: new Date().toISOString()
        })
        .select()
        .single();

      if (attemptError) throw attemptError;

      // Add one answered question
      const { error: responseError } = await supabase
        .from('user_question_responses')
        .insert({
          attempt_id: attempt.id,
          question_id: '0305369e-faec-41a3-ae8c-9ced51d7345d', // First question ID
          selected_answer: 'A',
          is_correct: true,
          time_spent: 10
        });

      if (responseError) throw responseError;

      console.log('Created partial assessment with ID:', attempt.id);
      return { success: true, attemptId: attempt.id };
    } catch (error) {
      console.error('Create partial assessment error:', error);
      return { error: error.message };
    }
  },

  // Create a completed assessment for testing
  async createCompletedAssessment(userEmail = 'test@coaching-hub.local', assessmentId = '00000000-0000-0000-0000-000000000001') {
    try {
      // Use the browser-specific test user ID
      const userId = this.getUserIdByEmail(userEmail);

      // Create a completed attempt
      const { data: attempt, error: attemptError } = await supabase
        .from('user_assessment_attempts')
        .insert({
          user_id: userId,
          assessment_id: assessmentId,
          status: 'completed',
          total_questions: 3,
          score: 100,
          completed_at: new Date().toISOString(),
          time_spent: 120,
          created_at: new Date().toISOString()
        })
        .select()
        .single();

      if (attemptError) throw attemptError;

      // Add all answered questions
      const questions = [
        '0305369e-faec-41a3-ae8c-9ced51d7345d',
        '12345678-1234-1234-1234-123456789012', // Placeholder IDs
        '23456789-2345-2345-2345-234567890123'
      ];

      for (let i = 0; i < questions.length; i++) {
        await supabase
          .from('user_question_responses')
          .insert({
            attempt_id: attempt.id,
            question_id: questions[i],
            selected_answer: 'A',
            is_correct: true,
            time_spent: 30 + (i * 5)
          });
      }

      console.log('Created completed assessment with ID:', attempt.id);
      return { success: true, attemptId: attempt.id };
    } catch (error) {
      console.error('Create completed assessment error:', error);
      return { error: error.message };
    }
  },

  // Delete ALL assessment attempts (use with caution)
  async cleanupAllAssessments(preserveCompleted = false) {
    try {
      // Get count before cleanup
      const { count: beforeAttempts } = await supabase
        .from('user_assessment_attempts')
        .select('*', { count: 'exact', head: true });

      let deleteCondition = supabase
        .from('user_question_responses')
        .delete()
        .gte('created_at', '2000-01-01');

      let attemptDeleteCondition = supabase
        .from('user_assessment_attempts')
        .delete()
        .gte('created_at', '2000-01-01');

      if (preserveCompleted) {
        // Only delete non-completed attempts and their responses
        const { data: nonCompletedAttempts } = await supabase
          .from('user_assessment_attempts')
          .select('id')
          .neq('status', 'completed');

        if (nonCompletedAttempts && nonCompletedAttempts.length > 0) {
          const nonCompletedIds = nonCompletedAttempts.map(a => a.id);
          
          // Delete responses for non-completed attempts only
          await supabase
            .from('user_question_responses')
            .delete()
            .in('attempt_id', nonCompletedIds);

          // Delete non-completed attempts only
          await supabase
            .from('user_assessment_attempts')
            .delete()
            .neq('status', 'completed');
        }
      } else {
        // Delete all responses first
        await supabase
          .from('user_question_responses')
          .delete()
          .gte('created_at', '2000-01-01'); // Delete all

        // Delete all attempts
        await supabase
          .from('user_assessment_attempts')
          .delete()
          .gte('created_at', '2000-01-01'); // Delete all
      }

      // Get count after cleanup to verify
      const { count: afterAttempts } = await supabase
        .from('user_assessment_attempts')
        .select('*', { count: 'exact', head: true });

      console.log(`Cleaned up ${beforeAttempts || 0} → ${afterAttempts || 0} assessment attempts${preserveCompleted ? ' (preserved completed)' : ''}`);
      return { success: true };
    } catch (error) {
      console.error('Cleanup all error:', error);
      return { error: error.message };
    }
  }
};