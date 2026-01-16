<template>
  <div class="admin-container">
    <!-- Loading state during auth check -->
    <AdminLoadingState v-if="!isAuthLoaded" />

    <!-- Admin Access Check -->
    <div v-else-if="!hasAdminAccess" class="admin-content">
      <div class="admin-header">
        <h1>⚠️ Admin Access Required</h1>
        <p class="admin-subtitle">You need administrator privileges to access the file manager.</p>
      </div>
      <ActionButton href="/docs/admin/" variant="secondary" icon="←">Back to Admin Hub</ActionButton>
    </div>

    <!-- File Manager with Tabs -->
    <div v-else class="admin-content">
      <div class="admin-header">
        <div class="header-main">
          <h1>📁 File Manager</h1>
          <p class="admin-subtitle">Upload and manage storage files - get URLs for use in content</p>
        </div>
      </div>

      <nav class="breadcrumb">
        <ActionButton href="/docs/admin/" variant="gray">Admin Hub</ActionButton>
        <span class="breadcrumb-separator">→</span>
        <span>File Manager</span>
      </nav>

      <!-- Storage Bucket Tabs -->
      <div class="table-tabs">
        <button 
          v-for="bucket in storageBuckets" 
          :key="bucket.id"
          @click="selectBucket(bucket.id)"
          :class="['tab', { active: activeBucket === bucket.id }]"
        >
          <span class="tab-icon">{{ bucket.icon }}</span>
          <span class="tab-label">{{ bucket.label }}</span>
          <span class="tab-count">{{ getBucketFileCount(bucket.id) }}</span>
        </button>
      </div>

      <!-- Tab Content -->
      <div class="tab-content">
        <div v-if="!activeBucket" class="empty-state">
          <h3>Select a storage bucket to manage files</h3>
          <p>Choose from PDFs, Images, or Documents above</p>
        </div>

        <div v-else class="bucket-section">
          <!-- Upload Section -->
          <div class="section-card upload-section">
            <div class="section-header">
              <div>
                <h2>📤 Upload Files</h2>
                <p class="section-description">Upload {{ getBucketInfo(activeBucket).description }} to {{ activeBucket }} storage</p>
              </div>
            </div>

            <div class="upload-area" 
                 :class="{ dragover: isDragOver }"
                 @dragover.prevent="isDragOver = true"
                 @dragleave.prevent="isDragOver = false"
                 @drop.prevent="handleFileDrop">
              
              <div class="upload-zone">
                <input 
                  ref="fileInput" 
                  type="file" 
                  :accept="getBucketInfo(activeBucket).accept"
                  multiple
                  class="file-input"
                  @change="handleFileSelect"
                >
                
                <div class="upload-content">
                  <div class="upload-icon">📤</div>
                  <h3>Drop files here or click to browse</h3>
                  <p class="upload-hint">{{ getBucketInfo(activeBucket).hint }}</p>
                  <button class="upload-button" @click="$refs.fileInput.click()">
                    Choose Files
                  </button>
                </div>
              </div>

              <!-- Upload Progress -->
              <div v-if="uploadQueue.length > 0" class="upload-progress">
                <div v-for="upload in uploadQueue" :key="upload.id" class="upload-item">
                  <div class="upload-info">
                    <span class="file-name">{{ upload.file.name }}</span>
                    <span class="file-size">{{ formatFileSize(upload.file.size) }}</span>
                  </div>
                  <div class="progress-bar">
                    <div class="progress-fill" :style="{ width: upload.progress + '%' }"></div>
                  </div>
                  <div class="upload-status">
                    <span v-if="upload.status === 'uploading'">{{ upload.progress }}%</span>
                    <span v-else-if="upload.status === 'completed'" class="status-success">✓</span>
                    <span v-else-if="upload.status === 'error'" class="status-error">✗</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Files List Section -->
          <div class="section-card">
            <div class="section-header">
              <div>
                <h2>🗂️ Files in {{ activeBucket }}</h2>
                <p class="section-description">{{ files.length }} files stored</p>
              </div>
              <div class="header-actions">
                <ActionButton @click="refreshFiles" variant="secondary" icon="🔄">Refresh</ActionButton>
              </div>
            </div>

            <!-- Loading State -->
            <div v-if="loading" class="loading-state">
              <div class="loading-spinner"></div>
              <p>Loading files...</p>
            </div>

            <!-- Files Table -->
            <AdminTableHeader v-if="files.length > 0" :columns="fileTableColumns">
              <div v-for="file in files" :key="file.name" class="table-row">
                <div class="col-file">
                  <div class="file-info">
                    <span class="file-icon">{{ getFileIcon(file.name) }}</span>
                    <div class="file-details">
                      <div class="file-name">{{ file.name }}</div>
                      <div class="file-type">{{ getFileType(file.name) }}</div>
                    </div>
                  </div>
                </div>
                <div class="col-size">{{ formatFileSize(file.metadata?.size) }}</div>
                <div class="col-date">{{ formatDate(file.updated_at) }}</div>
                <div class="col-url">
                  <div class="url-display">
                    <input 
                      :value="getPublicUrl(file.name)" 
                      readonly 
                      class="url-input"
                      @click="$event.target.select()"
                    >
                    <button 
                      @click="copyUrl(getPublicUrl(file.name))" 
                      class="copy-btn"
                      title="Copy URL"
                    >
                      📋
                    </button>
                  </div>
                </div>
                <div class="col-actions">
                  <div class="action-group">
                    <button @click="viewFile(file)" class="action-btn view" title="View">👁️</button>
                    <button @click="downloadFile(file)" class="action-btn download" title="Download">⬇️</button>
                    <button @click="deleteFile(file)" class="action-btn delete" title="Delete">🗑️</button>
                  </div>
                </div>
              </div>
            </AdminTableHeader>

            <!-- Empty State -->
            <div v-else class="empty-files">
              <div class="empty-state">
                <div class="empty-icon">📂</div>
                <h3>No files in {{ activeBucket }}</h3>
                <p>Upload some files to get started</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAdminSession } from '../composables/useAdminSession'
import { useSupabase } from '../composables/useSupabase'
import ActionButton from './shared/ActionButton.vue'
import AdminLoadingState from './shared/AdminLoadingState.vue'
import AdminTableHeader from './shared/AdminTableHeader.vue'

const { hasAdminAccess } = useAdminSession()

// Authentication loading state
const isAuthLoaded = ref(false)
const { supabase } = useSupabase()

// Table configuration for AdminTableHeader
const fileTableColumns = [
  { label: 'File', width: '2fr' },
  { label: 'Size', width: '100px' },
  { label: 'Modified', width: '120px' },
  { label: 'Public URL', width: '3fr' },
  { label: 'Actions', width: '120px' }
]

// State
const activeBucket = ref('pdfs')
const files = ref([])
const loading = ref(false)
const isDragOver = ref(false)
const uploadQueue = ref([])

// Storage buckets configuration
const storageBuckets = [
  {
    id: 'pdfs',
    label: 'PDFs',
    icon: '📄',
    description: 'PDF documents',
    accept: '.pdf',
    hint: 'Upload PDF files for assessments and reports'
  },
  {
    id: 'images',
    label: 'Images',
    icon: '🖼️',
    description: 'images and graphics',
    accept: 'image/*',
    hint: 'Upload JPG, PNG, GIF, SVG images'
  },
  {
    id: 'documents',
    label: 'Documents',
    icon: '📄',
    description: 'documents and files',
    accept: '.doc,.docx,.txt,.csv,.xlsx,.xls',
    hint: 'Upload Word docs, spreadsheets, text files'
  }
]

// Computed
const getBucketFileCount = (bucketId) => {
  if (bucketId !== activeBucket.value) return '?'
  return files.value.length
}

const getBucketInfo = (bucketId) => {
  return storageBuckets.find(b => b.id === bucketId) || {}
}

// Methods
const selectBucket = async (bucketId) => {
  activeBucket.value = bucketId
  await loadFiles()
}

const loadFiles = async () => {
  if (!activeBucket.value || !supabase) return
  
  loading.value = true
  try {
    const { data, error } = await supabase.storage
      .from(activeBucket.value)
      .list()

    if (error) {
      console.error('Error loading files:', error)
      return
    }

    files.value = data || []
  } catch (error) {
    console.error('Error loading files:', error)
  } finally {
    loading.value = false
  }
}

const refreshFiles = () => {
  loadFiles()
}

// File upload handling
const handleFileSelect = (event) => {
  const selectedFiles = Array.from(event.target.files)
  uploadFiles(selectedFiles)
  
  // Clear the input
  event.target.value = ''
}

const handleFileDrop = (event) => {
  isDragOver.value = false
  const droppedFiles = Array.from(event.dataTransfer.files)
  uploadFiles(droppedFiles)
}

const uploadFiles = async (fileList) => {
  if (!activeBucket.value || !supabase) return

  for (const file of fileList) {
    const uploadId = Date.now() + Math.random()
    
    // Add to upload queue
    const uploadItem = {
      id: uploadId,
      file: file,
      progress: 0,
      status: 'uploading'
    }
    uploadQueue.value.push(uploadItem)

    try {
      // Upload file
      const { data, error } = await supabase.storage
        .from(activeBucket.value)
        .upload(file.name, file, {
          onUploadProgress: (progress) => {
            const item = uploadQueue.value.find(u => u.id === uploadId)
            if (item) {
              item.progress = Math.round((progress.loaded / progress.total) * 100)
            }
          }
        })

      // Update status
      const item = uploadQueue.value.find(u => u.id === uploadId)
      if (item) {
        if (error) {
          item.status = 'error'
          console.error('Upload error:', error)
        } else {
          item.status = 'completed'
          item.progress = 100
        }
      }
    } catch (error) {
      const item = uploadQueue.value.find(u => u.id === uploadId)
      if (item) {
        item.status = 'error'
      }
      console.error('Upload error:', error)
    }
  }

  // Refresh files after uploads
  setTimeout(() => {
    loadFiles()
    // Clear completed uploads after a delay
    uploadQueue.value = uploadQueue.value.filter(u => u.status === 'uploading')
  }, 2000)
}

// File utilities
const getFileIcon = (filename) => {
  if (/\.(jpg|jpeg|png|gif|svg|webp)$/i.test(filename)) return '🖼️'
  if (/\.pdf$/i.test(filename)) return '📄'
  if (/\.(doc|docx)$/i.test(filename)) return '📝'
  if (/\.(xls|xlsx|csv)$/i.test(filename)) return '📊'
  return '📁'
}

const getFileType = (filename) => {
  const ext = filename.split('.').pop()?.toUpperCase()
  return ext ? `${ext} file` : 'File'
}

const formatFileSize = (bytes) => {
  if (!bytes) return 'Unknown'
  
  const sizes = ['B', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(1024))
  return Math.round(bytes / Math.pow(1024, i) * 100) / 100 + ' ' + sizes[i]
}

const formatDate = (dateString) => {
  if (!dateString) return 'Unknown'
  return new Date(dateString).toLocaleDateString() + ' ' + 
         new Date(dateString).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
}

const getPublicUrl = (filename) => {
  if (!supabase || !activeBucket.value) return ''
  
  const { data } = supabase.storage
    .from(activeBucket.value)
    .getPublicUrl(filename)
  
  return data?.publicUrl || ''
}

const copyUrl = async (url) => {
  try {
    await navigator.clipboard.writeText(url)
    // Could add a toast notification here
    alert('URL copied to clipboard!')
  } catch (error) {
    console.error('Failed to copy URL:', error)
  }
}

// File actions
const viewFile = async (file) => {
  const url = getPublicUrl(file.name)
  if (url) {
    window.open(url, '_blank')
  }
}

const downloadFile = async (file) => {
  if (!supabase) return
  
  try {
    const { data, error } = await supabase.storage
      .from(activeBucket.value)
      .download(file.name)
    
    if (error) {
      console.error('Error downloading file:', error)
      return
    }
    
    // Create download link
    const url = URL.createObjectURL(data)
    const a = document.createElement('a')
    a.href = url
    a.download = file.name
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
  } catch (error) {
    console.error('Error downloading file:', error)
  }
}

const deleteFile = async (file) => {
  if (!confirm(`Are you sure you want to delete "${file.name}"?`)) return
  
  if (!supabase) return
  
  try {
    const { error } = await supabase.storage
      .from(activeBucket.value)
      .remove([file.name])
    
    if (error) {
      console.error('Error deleting file:', error)
      return
    }
    
    // Refresh file list
    await loadFiles()
  } catch (error) {
    console.error('Error deleting file:', error)
  }
}

onMounted(() => {
  isAuthLoaded.value = true
  loadFiles()
})
</script>

<style scoped>
/* Reuse the same base styles as other admin tabbed interfaces */
.admin-container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 20px;
}

.admin-header {
  margin-bottom: 30px;
}

.header-main h1 {
  font-size: 32px;
  margin-bottom: 8px;
}

.admin-subtitle {
  color: var(--vp-c-text-2);
}

.breadcrumb {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 24px;
  padding: 12px;
  background: var(--vp-c-bg-soft);
  border-radius: 6px;
}

.breadcrumb-separator {
  color: var(--vp-c-text-3);
}

/* Table Tabs */
.table-tabs {
  display: flex;
  gap: 4px;
  background: var(--vp-c-bg-soft);
  padding: 4px;
  border-radius: 8px;
  margin-bottom: 24px;
}

.tab {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 16px;
  background: transparent;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s;
  color: var(--vp-c-text-2);
}

.tab:hover {
  background: var(--vp-c-bg);
  color: var(--vp-c-text-1);
}

.tab.active {
  background: var(--vp-c-bg);
  color: var(--vp-c-brand);
  font-weight: 500;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.tab-icon {
  font-size: 18px;
}

.tab-count {
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand);
  padding: 2px 8px;
  border-radius: 10px;
  font-size: 11px;
  font-weight: 600;
}

/* Tab Content */
.tab-content {
  background: var(--vp-c-bg-soft);
  border-radius: 8px;
  padding: 24px;
}

.section-card {
  background: var(--vp-c-bg);
  border: 1px solid var(--vp-c-border);
  border-radius: 8px;
  padding: 24px;
  margin-bottom: 24px;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: start;
  margin-bottom: 24px;
}

.section-header h2 {
  font-size: 20px;
  margin-bottom: 4px;
}

.section-description {
  color: var(--vp-c-text-2);
  font-size: 14px;
}

.header-actions {
  display: flex;
  gap: 12px;
}

/* Upload Section */
.upload-area {
  border: 2px dashed var(--vp-c-border);
  border-radius: 8px;
  transition: all 0.2s;
}

.upload-area.dragover {
  border-color: var(--vp-c-brand);
  background: var(--vp-c-brand-soft);
}

.upload-zone {
  position: relative;
  padding: 40px;
  text-align: center;
}

.file-input {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  opacity: 0;
  cursor: pointer;
}

.upload-content {
  pointer-events: none;
}

.upload-icon {
  font-size: 48px;
  margin-bottom: 16px;
  opacity: 0.5;
}

.upload-content h3 {
  margin: 0 0 8px 0;
  color: var(--vp-c-text-1);
}

.upload-hint {
  color: var(--vp-c-text-2);
  margin: 8px 0 20px 0;
}

.upload-button {
  background: var(--vp-c-brand);
  color: white;
  border: none;
  padding: 10px 24px;
  border-radius: 6px;
  font-weight: 500;
  cursor: pointer;
  pointer-events: all;
}

.upload-button:hover {
  background: var(--vp-c-brand-dark);
}

/* Upload Progress */
.upload-progress {
  margin-top: 20px;
  border-top: 1px solid var(--vp-c-border);
  padding-top: 20px;
}

.upload-item {
  display: grid;
  grid-template-columns: 2fr 3fr 60px;
  gap: 12px;
  align-items: center;
  padding: 8px 0;
  border-bottom: 1px solid var(--vp-c-divider);
}

.upload-item:last-child {
  border-bottom: none;
}

.upload-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.file-name {
  font-weight: 500;
  font-size: 13px;
}

.file-size {
  font-size: 11px;
  color: var(--vp-c-text-2);
}

.progress-bar {
  background: var(--vp-c-bg-soft);
  border-radius: 10px;
  height: 6px;
  overflow: hidden;
}

.progress-fill {
  background: var(--vp-c-brand);
  height: 100%;
  transition: width 0.3s;
}

.upload-status {
  text-align: center;
  font-size: 12px;
}

.status-success {
  color: var(--vp-c-green);
  font-weight: bold;
}

.status-error {
  color: var(--vp-c-danger);
  font-weight: bold;
}

/* Loading State */
.loading-state {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  padding: 40px;
  color: var(--vp-c-text-2);
}

.loading-spinner {
  width: 20px;
  height: 20px;
  border: 2px solid var(--vp-c-border);
  border-top: 2px solid var(--vp-c-brand);
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

/* Data Table */
.data-table {
  background: var(--vp-c-bg);
  border: 1px solid var(--vp-c-border);
  border-radius: 6px;
  overflow: hidden;
}

.table-header {
  display: grid;
  grid-template-columns: 2fr 80px 140px 3fr 120px;
  padding: 12px 16px;
  background: var(--vp-c-bg-soft);
  border-bottom: 1px solid var(--vp-c-border);
  font-weight: 600;
  font-size: 12px;
  text-transform: uppercase;
  color: var(--vp-c-text-2);
}

.table-row {
  display: grid;
  grid-template-columns: 2fr 80px 140px 3fr 120px;
  padding: 16px;
  border-bottom: 1px solid var(--vp-c-divider);
  align-items: center;
  transition: background 0.2s;
}

.table-row:hover {
  background: var(--vp-c-bg-soft);
}

.table-row:last-child {
  border-bottom: none;
}

/* File Info */
.file-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.file-icon {
  font-size: 24px;
}

.file-details {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.file-name {
  font-weight: 500;
  font-size: 14px;
}

.file-type {
  font-size: 11px;
  color: var(--vp-c-text-2);
}

.col-size,
.col-date {
  font-size: 13px;
  color: var(--vp-c-text-2);
}

/* URL Display */
.url-display {
  display: flex;
  gap: 8px;
  align-items: center;
}

.url-input {
  flex: 1;
  padding: 4px 8px;
  border: 1px solid var(--vp-c-border);
  border-radius: 4px;
  background: var(--vp-c-bg-soft);
  font-size: 11px;
  font-family: monospace;
}

.copy-btn {
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand);
  border: none;
  padding: 4px 8px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 12px;
}

.copy-btn:hover {
  background: var(--vp-c-brand);
  color: white;
}

/* Actions */
.action-group {
  display: flex;
  gap: 4px;
}

.action-btn {
  padding: 6px 8px;
  background: var(--vp-c-bg-soft);
  border: 1px solid var(--vp-c-border);
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  transition: all 0.2s;
}

.action-btn:hover {
  background: var(--vp-c-bg-mute);
}

.action-btn.delete:hover {
  background: var(--vp-c-danger-soft);
  color: var(--vp-c-danger);
  border-color: var(--vp-c-danger);
}

/* Empty State */
.empty-state {
  text-align: center;
  padding: 60px 20px;
}

.empty-icon {
  font-size: 48px;
  opacity: 0.3;
  margin-bottom: 16px;
}

.empty-state h3 {
  margin: 0 0 8px 0;
  color: var(--vp-c-text-1);
}

.empty-state p {
  color: var(--vp-c-text-2);
  margin: 0;
}

.empty-files {
  border: 1px solid var(--vp-c-border);
  border-radius: 6px;
  background: var(--vp-c-bg);
}
</style>