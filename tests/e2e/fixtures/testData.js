// Test data helper for creating consistent test scenarios
export const testData = {
  // Clean up all assessment data for test user
  async cleanupAssessments(page) {
    // This would run a cleanup via API call or direct database access
    const response = await page.evaluate(async () => {
      // Try to get Supabase from window or create it
      let supabase = window.supabase;
      
      // If not on window, try to get from Vue app
      if (!supabase) {
        try {
          const app = document.querySelector('#app')?.__vue_app__;
          if (app && app.config.globalProperties.$supabase) {
            supabase = app.config.globalProperties.$supabase;
          }
        } catch (e) {
          // Continue with other methods
        }
      }
      
      // If still not available, create a new instance
      if (!supabase) {
        try {
          const { createClient } = await import('@supabase/supabase-js');
          supabase = createClient(
            'http://localhost:54321',
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0'
          );
        } catch (e) {
          return { error: 'Could not create Supabase client: ' + e.message };
        }
      }
      
      if (!supabase) return { error: 'Supabase not available' };
      
      try {
        const user = (await supabase.auth.getUser()).data.user;
        if (!user) return { error: 'No authenticated user' };

        // First, get all attempt IDs for this user
        const { data: attempts, error: fetchError } = await supabase
          .from('user_assessment_attempts')
          .select('id')
          .eq('user_id', user.id);

        if (fetchError) throw fetchError;

        if (attempts && attempts.length > 0) {
          const attemptIds = attempts.map(a => a.id);

          // Delete responses first (foreign key constraint)
          const { error: responseError } = await supabase
            .from('user_question_responses')
            .delete()
            .in('attempt_id', attemptIds);

          if (responseError) throw responseError;

          // Delete attempts
          const { error: attemptError } = await supabase
            .from('user_assessment_attempts')
            .delete()
            .eq('user_id', user.id);

          if (attemptError) throw attemptError;
        }

        return { success: true };
      } catch (error) {
        return { error: error.message };
      }
    });
    
    return response;
  },

  // Create a partial assessment for testing resume functionality
  async createPartialAssessment(page, assessmentId = '00000000-0000-0000-0000-000000000001') {
    return await page.evaluate(async (assessmentId) => {
      // Try to get Supabase from window or create it
      let supabase = window.supabase;
      
      // If not on window, try to import and create it
      if (!supabase) {
        try {
          // Try to get from Vue app instance if available
          const app = document.querySelector('#app')?.__vue_app__;
          if (app && app.config.globalProperties.$supabase) {
            supabase = app.config.globalProperties.$supabase;
          }
        } catch (e) {
          // Continue with other methods
        }
      }
      
      // If still not available, create a new instance
      if (!supabase) {
        try {
          const { createClient } = await import('@supabase/supabase-js');
          supabase = createClient(
            'http://localhost:54321',
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0'
          );
        } catch (e) {
          return { error: 'Could not create Supabase client: ' + e.message };
        }
      }
      
      if (!supabase) return { error: 'Supabase not available' };

      try {
        const user = (await supabase.auth.getUser()).data.user;
        
        // Create an in-progress attempt
        const { data: attempt, error: attemptError } = await supabase
          .from('user_assessment_attempts')
          .insert({
            user_id: user.id,
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

        return { success: true, attemptId: attempt.id };
      } catch (error) {
        return { error: error.message };
      }
    }, assessmentId);
  }
};