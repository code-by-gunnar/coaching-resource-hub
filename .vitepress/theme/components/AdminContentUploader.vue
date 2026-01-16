<template>
  <div class="admin-container">
    <!-- Loading state during auth check -->
    <AdminLoadingState v-if="!isAuthLoaded" />

    <!-- Admin Access Check -->
    <div v-else-if="!hasAdminAccess" class="admin-content">
      <div class="admin-header">
        <h1>⚠️ Admin Access Required</h1>
        <p class="admin-subtitle">You need administrator privileges to access the content uploader.</p>
      </div>
      <ActionButton href="/docs/admin/" variant="secondary" icon="←">Back to Admin Hub</ActionButton>
    </div>

    <!-- Content Uploader -->
    <div v-else class="admin-content">
      <div class="admin-header">
        <h1>📤 Content Uploader</h1>
        <p class="admin-subtitle">Upload files to coaching-downloads storage with organized folder structure</p>
      </div>
      
      <nav class="breadcrumb">
        <ActionButton href="/docs/admin/" variant="gray">Admin Hub</ActionButton>
        <span class="breadcrumb-separator">→</span>
        <span>Content Uploader</span>
      </nav>

      <!-- Main Content Grid -->
      <div class="content-grid">
        <!-- Left Column: Folder Selection -->
        <div class="admin-section">
          <div class="section-header">
            <h2>📁 Destination Folder</h2>
            <p class="section-description">Choose upload location</p>
          </div>
          
          <div class="folder-selector">
            <select v-model="selectedFolder" class="folder-select">
            <option value="">Choose a folder...</option>
            <optgroup label="📋 Forms & Templates">
              <option value="forms/client-management">Client Management</option>
              <option value="forms/assessments">Assessments</option>
              <option value="forms/business-legal">Business & Legal</option>
              <option value="forms/progress-tracking">Progress Tracking</option>
              <option value="forms/contracts">Contracts & Agreements</option>
            </optgroup>
            <optgroup label="📚 Training Materials">
              <option value="training/ethics">Ethics in Coaching</option>
              <option value="training/interventions">Coaching Interventions</option>
              <option value="training/techniques">Coaching Techniques</option>
              <option value="training/basics">Coaching Basics</option>
              <option value="training/advanced">Advanced Methods</option>
            </optgroup>
            <optgroup label="🎓 Concepts & Theory">
              <option value="concepts/foundations-connection">Foundations & Connection</option>
              <option value="concepts/nlp-techniques">NLP Techniques</option>
              <option value="concepts/coaching-models">Coaching Models</option>
              <option value="concepts/advanced-coaching">Advanced Coaching</option>
              <option value="concepts/solution-focused">Solution-Focused Approaches</option>
              <option value="concepts/cognitive-behavioral">Cognitive Behavioral</option>
            </optgroup>
            <optgroup label="💼 Business Development">
              <option value="business/marketing">Marketing Resources</option>
              <option value="business/branding">Branding Materials</option>
              <option value="business/pricing">Pricing Guides</option>
              <option value="business/legal">Legal Documents</option>
              <option value="business/platforms">Platform Guides</option>
            </optgroup>
            <optgroup label="🛠️ Tools & Resources">
              <option value="tools/planners">Planners & Schedules</option>
              <option value="tools/worksheets">Worksheets</option>
              <option value="tools/guides">How-To Guides</option>
              <option value="tools/frameworks">Frameworks</option>
              <option value="tools/checklists">Checklists</option>
            </optgroup>
            <optgroup label="🏆 Certification">
              <option value="certification/ac">AC Certification</option>
              <option value="certification/icf">ICF Certification</option>
              <option value="certification/requirements">Requirements</option>
              <option value="certification/study-materials">Study Materials</option>
            </optgroup>
            <optgroup label="📖 Resources">
              <option value="resources/books">Books & Reading</option>
              <option value="resources/research">Research Papers</option>
              <option value="resources/case-studies">Case Studies</option>
              <option value="resources/videos">Video Resources</option>
            </optgroup>
          </select>
          
          <div v-if="selectedFolder" class="selected-path">
            <strong>Upload path:</strong> /coaching-downloads/{{ selectedFolder }}/
          </div>
        </div>
      </div>

      <!-- Right Column: File Upload Area -->
      <div class="admin-section" :class="{ disabled: !selectedFolder }">
        <div class="section-header">
          <h2>📎 Upload Files</h2>
          <p class="section-description">{{ selectedFolder ? 'Drag and drop or click to select' : 'Select a folder first' }}</p>
        </div>
        
        <div class="upload-area" @drop="handleDrop" @dragover.prevent @dragleave.prevent>
          <input 
            type="file" 
            ref="fileInput" 
            @change="handleFileSelect" 
            multiple 
            accept=".pdf,.doc,.docx,.xls,.xlsx,.txt,.png,.jpg,.jpeg"
            style="display: none"
          />
          
          <div class="upload-content" @click="$refs.fileInput.click()">
            <span class="upload-icon">📤</span>
            <h3>Drop files here or click to browse</h3>
            <p>Supports: PDF, Word, Excel, Text, Images</p>
            
            <div v-if="selectedFiles.length > 0" class="selected-files">
              <p class="file-count">{{ selectedFiles.length }} file(s) selected</p>
              <ul class="file-list">
                <li v-for="(file, index) in selectedFiles" :key="index">
                  {{ file.name }} ({{ formatFileSize(file.size) }})
                </li>
              </ul>
            </div>
          </div>
        </div>
        
        <div v-if="selectedFiles.length > 0" class="upload-actions">
          <ActionButton @click="uploadFiles" :disabled="uploading" variant="primary" icon="⬆️">
            {{ uploading ? `Uploading... ${uploadProgress}%` : `Upload ${selectedFiles.length} file(s)` }}
          </ActionButton>
          <ActionButton @click="clearFiles" variant="secondary" icon="🗑️">Clear</ActionButton>
        </div>
        
        <div v-if="uploading" class="progress-bar">
          <div class="progress-fill" :style="{ width: uploadProgress + '%' }"></div>
        </div>
      </div>
      </div>

      <!-- Full Width: Upload Results -->
      <div v-if="uploadResults.length > 0" class="admin-section full-width">
        <div class="section-header">
          <h2>✅ Upload Results</h2>
          <p class="section-description">{{ successfulUploads.length }} of {{ uploadResults.length }} files uploaded successfully</p>
        </div>
        
        <div class="results-grid">
          <div v-for="result in uploadResults" :key="result.filename" 
               class="result-card" :class="{ success: result.success, error: !result.success }">
            <div class="result-header">
              <span class="result-icon">{{ result.success ? '✅' : '❌' }}</span>
              <span class="result-filename">{{ result.filename }}</span>
            </div>
            
            <div v-if="result.success" class="result-url">
              <input 
                type="text" 
                :value="result.url" 
                readonly 
                class="url-input"
                @click="$event.target.select()"
              />
              <button @click="copyToClipboard(result.url)" class="copy-btn">📋</button>
            </div>
            
            <div v-else class="result-error">
              Error: {{ result.error }}
            </div>
          </div>
        </div>
        
        <!-- Bulk URL Copy -->
        <div v-if="successfulUploads.length > 1" class="bulk-copy-section">
          <h3>📋 All URLs for Documentation</h3>
          <textarea 
            :value="bulkUrls" 
            readonly 
            class="bulk-textarea"
            @click="$event.target.select()"
          ></textarea>
          <ActionButton @click="copyToClipboard(bulkUrls)" variant="primary" icon="📋">
            Copy All URLs
          </ActionButton>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAuth } from '../composables/useAuth'
import ActionButton from './shared/ActionButton.vue'
import AdminLoadingState from './shared/AdminLoadingState.vue'

const { user } = useAuth()

// Initialize our own Supabase client for admin operations
const isBrowser = typeof window !== 'undefined'
let supabase = null

// Authentication
const isAuthLoaded = ref(false)
const hasAdminAccess = computed(() => {
  if (!user.value) return false
  const metaData = user.value.raw_user_meta_data || user.value.user_metadata || {}
  const isDeveloper = user.value.email === 'gunnar.finkeldeh@gmail.com'
  const isTestAdmin = user.value.email === 'test@coaching-hub.local'
  const hasAdminFlag = metaData.admin === true
  return isDeveloper || isTestAdmin || hasAdminFlag
})

// Upload state
const selectedFolder = ref('')
const selectedFiles = ref([])
const uploading = ref(false)
const uploadProgress = ref(0)
const uploadResults = ref([])

// Computed properties
const successfulUploads = computed(() => 
  uploadResults.value.filter(result => result.success)
)

const bulkUrls = computed(() => 
  successfulUploads.value.map(result => result.url).join('\n')
)

// Methods
const handleDrop = (e) => {
  e.preventDefault()
  const files = Array.from(e.dataTransfer.files)
  selectedFiles.value = files
}

const handleFileSelect = (event) => {
  selectedFiles.value = Array.from(event.target.files)
}

const clearFiles = () => {
  selectedFiles.value = []
  if (fileInput.value) fileInput.value.value = ''
}

const formatFileSize = (bytes) => {
  const sizes = ['B', 'KB', 'MB', 'GB']
  if (bytes === 0) return '0 B'
  const i = Math.floor(Math.log(bytes) / Math.log(1024))
  return Math.round(bytes / Math.pow(1024, i) * 100) / 100 + ' ' + sizes[i]
}

const uploadFiles = async () => {
  if (!supabase || !selectedFolder.value || selectedFiles.value.length === 0) {
    alert('Please select a folder and files to upload')
    return
  }

  uploading.value = true
  uploadProgress.value = 0
  uploadResults.value = []

  const totalFiles = selectedFiles.value.length
  let completedFiles = 0

  for (const file of selectedFiles.value) {
    try {
      // Clean filename for storage
      const cleanFilename = file.name.replace(/[^a-zA-Z0-9.-]/g, '-')
      const filePath = `${selectedFolder.value}/${cleanFilename}`
      
      console.log('🔄 Upload attempt:', {
        originalName: file.name,
        cleanName: cleanFilename,
        fullPath: filePath,
        bucket: 'coaching-downloads',
        fileSize: file.size,
        fileType: file.type
      })
      
      const { data, error } = await supabase.storage
        .from('coaching-downloads')
        .upload(filePath, file, {
          contentType: file.type,
          upsert: true // Allow overwriting existing files
        })

      if (error) {
        console.error('Upload error for', file.name, ':', error)
        console.error('Error details:', {
          message: error.message,
          details: error.details,
          hint: error.hint,
          code: error.code
        })
        uploadResults.value.push({
          filename: file.name,
          success: false,
          error: error.message + (error.details ? ` (${error.details})` : ''),
          url: ''
        })
      } else {
        // Get public URL
        const { data: urlData } = supabase.storage
          .from('coaching-downloads')
          .getPublicUrl(filePath)
        
        uploadResults.value.push({
          filename: file.name,
          success: true,
          error: null,
          url: urlData.publicUrl
        })
      }
    } catch (err) {
      console.error('Upload exception:', err)
      uploadResults.value.push({
        filename: file.name,
        success: false,
        error: err.message,
        url: ''
      })
    }

    completedFiles++
    uploadProgress.value = Math.round((completedFiles / totalFiles) * 100)
  }

  uploading.value = false
  selectedFiles.value = []
  if (fileInput.value) fileInput.value.value = ''
}

const copyToClipboard = async (text) => {
  try {
    await navigator.clipboard.writeText(text)
    // Show brief success indication
    const button = event.target
    const originalText = button.textContent
    button.textContent = '✅ Copied!'
    setTimeout(() => {
      button.textContent = originalText
    }, 2000)
  } catch (err) {
    console.error('Failed to copy to clipboard:', err)
    alert('Failed to copy to clipboard')
  }
}

// Refs
const fileInput = ref(null)

onMounted(async () => {
  isAuthLoaded.value = true
  
  // Initialize Supabase client for uploads with service role key
  if (isBrowser) {
    try {
      const { createClient } = await import('@supabase/supabase-js')
      const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
      const supabaseServiceKey = import.meta.env.VITE_SUPABASE_SERVICE_ROLE_KEY
      
      console.log('🔧 Environment check:', {
        hasUrl: !!supabaseUrl,
        hasServiceKey: !!supabaseServiceKey,
        isDev: import.meta.env.DEV,
        mode: import.meta.env.MODE
      })
      
      if (supabaseUrl && supabaseServiceKey) {
        // Use service role key for admin operations
        supabase = createClient(supabaseUrl, supabaseServiceKey, {
          auth: {
            autoRefreshToken: false,
            persistSession: false
          }
        })
        console.log('✅ Supabase admin client initialized with service role')
        console.log('🔑 Using service role key for RLS bypass')
      } else {
        console.error('❌ Supabase service role credentials not found')
        console.error('💡 Make sure VITE_SUPABASE_SERVICE_ROLE_KEY is set in .env.local')
      }
    } catch (error) {
      console.error('❌ Failed to initialize Supabase:', error)
    }
  }
})
</script>

<style scoped>
/* Base Container */
.admin-container {
  position: fixed;
  top: var(--vp-nav-height);
  left: 0;
  right: 0;
  bottom: 0;
  background: var(--vp-c-bg);
  overflow-y: auto;
}

.admin-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
  padding-bottom: 8rem; /* Generous space for expanding content */
  min-height: calc(100vh - var(--vp-nav-height) - 8rem);
}

/* Header */
.admin-header {
  margin-bottom: 2rem;
}

.admin-header h1 {
  font-size: 2rem;
  margin-bottom: 0.5rem;
  font-weight: 600;
}

.admin-subtitle {
  color: var(--vp-c-text-2);
  margin: 0;
}

/* Breadcrumb */
.breadcrumb {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 2rem;
}

.breadcrumb-separator {
  color: var(--vp-c-text-3);
}

/* Content Grid */
.content-grid {
  display: grid;
  grid-template-columns: 1fr 1.5fr;
  gap: 2rem;
  margin-bottom: 2rem;
}

/* Sections */
.admin-section {
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-border);
  border-radius: 8px;
  padding: 1.5rem;
}

.admin-section.disabled {
  opacity: 0.6;
  pointer-events: none;
}

.admin-section.full-width {
  margin-bottom: 2rem;
}

.section-header {
  margin-bottom: 1.5rem;
}

.section-header h2 {
  font-size: 1.5rem;
  font-weight: 600;
  margin: 0 0 0.5rem 0;
}

.section-description {
  color: var(--vp-c-text-2);
  margin: 0;
}

/* Folder Selector */
.folder-selector {
  max-width: 600px;
}

.folder-select {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid var(--vp-c-border);
  border-radius: 4px;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-1);
  font-size: 1rem;
  margin-bottom: 1rem;
}

.selected-path {
  padding: 0.75rem;
  background: var(--vp-c-bg);
  border-radius: 4px;
  font-family: monospace;
  color: var(--vp-c-brand-1);
}

/* Upload Area */
.upload-area {
  border: 2px dashed var(--vp-c-border);
  border-radius: 8px;
  padding: 2rem;
  text-align: center;
  transition: all 0.3s;
  cursor: pointer;
}

.upload-area:hover {
  border-color: var(--vp-c-brand-1);
  background: var(--vp-c-bg-soft);
}

.upload-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
}

.upload-icon {
  font-size: 3rem;
  opacity: 0.5;
}

.upload-content h3 {
  margin: 0;
  color: var(--vp-c-text-1);
}

.upload-content p {
  margin: 0;
  color: var(--vp-c-text-2);
}

.selected-files {
  margin-top: 1rem;
  padding: 1rem;
  background: var(--vp-c-bg);
  border-radius: 4px;
  text-align: left;
  width: 100%;
}

.file-count {
  font-weight: 600;
  margin: 0 0 0.5rem 0;
}

.file-list {
  margin: 0;
  padding-left: 1.5rem;
  max-height: 150px;
  overflow-y: auto;
}

.file-list li {
  color: var(--vp-c-text-2);
  font-size: 0.9rem;
}

/* Upload Actions */
.upload-actions {
  display: flex;
  gap: 1rem;
  margin-top: 1rem;
}

/* Progress Bar */
.progress-bar {
  width: 100%;
  height: 8px;
  background: var(--vp-c-bg);
  border-radius: 4px;
  overflow: hidden;
  margin-top: 1rem;
}

.progress-fill {
  height: 100%;
  background: var(--vp-c-brand-1);
  transition: width 0.3s ease;
}

/* Results */
.results-grid {
  display: grid;
  gap: 1rem;
  margin-bottom: 2rem;
}

.result-card {
  padding: 1rem;
  border: 1px solid var(--vp-c-border);
  border-radius: 4px;
  background: var(--vp-c-bg);
}

.result-card.success {
  border-color: var(--vp-c-green-soft);
  background: var(--vp-c-green-soft);
}

.result-card.error {
  border-color: var(--vp-custom-block-danger-border);
  background: var(--vp-custom-block-danger-bg);
}

.result-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.5rem;
}

.result-icon {
  font-size: 1.2rem;
}

.result-filename {
  font-weight: 600;
}

.result-url {
  display: flex;
  gap: 0.5rem;
}

.url-input {
  flex: 1;
  padding: 0.5rem;
  border: 1px solid var(--vp-c-border);
  border-radius: 4px;
  font-family: monospace;
  font-size: 0.85rem;
  background: var(--vp-c-bg);
}

.copy-btn {
  padding: 0.5rem 1rem;
  background: var(--vp-c-brand-soft);
  border: 1px solid var(--vp-c-brand-1);
  border-radius: 4px;
  cursor: pointer;
  font-size: 1.2rem;
}

.copy-btn:hover {
  background: var(--vp-c-brand-1);
}

.result-error {
  color: var(--vp-custom-block-danger-text);
  font-size: 0.9rem;
}

/* Bulk Copy */
.bulk-copy-section {
  padding: 1.5rem;
  background: var(--vp-c-bg);
  border-radius: 4px;
  margin-top: 1rem;
}

.bulk-copy-section h3 {
  margin: 0 0 1rem 0;
  font-size: 1.2rem;
}

.bulk-textarea {
  width: 100%;
  height: 200px;
  padding: 0.75rem;
  border: 1px solid var(--vp-c-border);
  border-radius: 4px;
  font-family: monospace;
  font-size: 0.85rem;
  background: var(--vp-c-bg-soft);
  resize: vertical;
  margin-bottom: 1rem;
}

/* Responsive */
@media (max-width: 768px) {
  .admin-content {
    padding: 1rem;
  }
  
  .content-grid {
    grid-template-columns: 1fr;
    gap: 1rem;
  }
  
  .upload-actions {
    flex-direction: column;
  }
}
</style>