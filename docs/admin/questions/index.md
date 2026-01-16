---
layout: page
title: Question Management
description: Question management has moved to assessments interface
---

<script setup>
// Redirect to the proper assessments interface
if (typeof window !== 'undefined') {
  window.location.href = '/docs/admin/assessments/'
}
</script>

<div class="redirect-notice">
  <h1>📍 Question Management Moved</h1>
  <p>Question management is now part of the assessments interface for better organization.</p>
  <p><strong>You will be automatically redirected to:</strong></p>
  <p><a href="/docs/admin/assessments/">📊 Admin Assessments Interface</a></p>
  
  <div class="redirect-info">
    <h2>New Locations:</h2>
    <ul>
      <li><strong>View Questions:</strong> Admin Hub → Assessments → Questions tab</li>
      <li><strong>Edit Questions:</strong> Click Edit button on any question</li>
      <li><strong>Create Questions:</strong> Use Add Question button in assessments</li>
      <li><strong>Import Questions:</strong> Use CSV Import in assessments interface</li>
    </ul>
  </div>
</div>

<style scoped>
.redirect-notice {
  max-width: 600px;
  margin: 2rem auto;
  padding: 2rem;
  background: #f0f9ff;
  border: 1px solid #0ea5e9;
  border-radius: 8px;
  text-align: center;
}

.redirect-notice h1 {
  color: #0c4a6e;
  margin-bottom: 1rem;
}

.redirect-notice p {
  color: #0c4a6e;
  margin: 0.5rem 0;
}

.redirect-notice a {
  color: #0ea5e9;
  text-decoration: none;
  font-weight: 600;
}

.redirect-notice a:hover {
  text-decoration: underline;
}

.redirect-info {
  margin-top: 2rem;
  text-align: left;
  background: white;
  padding: 1.5rem;
  border-radius: 6px;
}

.redirect-info h2 {
  color: #0c4a6e;
  margin-bottom: 1rem;
}

.redirect-info ul {
  list-style: none;
  padding: 0;
}

.redirect-info li {
  margin: 0.5rem 0;
  padding: 0.5rem;
  background: #f8fafc;
  border-radius: 4px;
}
</style>