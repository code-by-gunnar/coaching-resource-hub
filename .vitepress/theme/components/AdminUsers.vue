<template>
  <div class="admin-container">
    <!-- Loading state during auth check -->
    <AdminLoadingState v-if="!isAuthLoaded" />

    <!-- Admin Access Check -->
    <div v-else-if="!hasAdminAccess" class="admin-content">
      <div class="admin-header">
        <h1>⚠️ Admin Access Required</h1>
        <p class="admin-subtitle">You need administrator privileges to manage users.</p>
      </div>
      <ActionButton href="/docs/admin/" variant="secondary" icon="←">Back to Admin Hub</ActionButton>
    </div>

    <!-- User Management -->
    <div v-else class="admin-content">
      <div class="admin-header">
        <div class="header-main">
          <h1>👥 User Management</h1>
          <p class="admin-subtitle">Manage user accounts, beta access, and permissions</p>
        </div>
        
        <div class="header-actions">
          <ActionButton @click="refreshUsers" variant="secondary" icon="🔄">Refresh</ActionButton>
          <ActionButton @click="createNewUser" icon="➕" disabled>Create User</ActionButton>
        </div>
      </div>
      
      <!-- Service Role Notice -->
      <div class="notice-card warning">
        <h3>⚙️ Configuration Required</h3>
        <p>Full user management requires Supabase service role key configuration.</p>
        <p>Currently showing placeholder data for current user only.</p>
      </div>

      <nav class="breadcrumb">
        <ActionButton href="/docs/admin/" variant="gray">Admin Hub</ActionButton>
        <span class="breadcrumb-separator">→</span>
        <span>Users</span>
      </nav>

      <!-- User Stats -->
      <div class="stats-grid">
        <div class="stat-card">
          <h3>📊 Total Users</h3>
          <div class="stat-number">{{ stats.totalUsers }}</div>
        </div>
        <div class="stat-card">
          <h3>🧪 Beta Users</h3>
          <div class="stat-number">{{ stats.betaUsers }}</div>
        </div>
        <div class="stat-card">
          <h3>🛠️ Admin Users</h3>
          <div class="stat-number">{{ stats.adminUsers }}</div>
        </div>
        <div class="stat-card">
          <h3>✅ Confirmed</h3>
          <div class="stat-number">{{ stats.confirmedUsers }}</div>
        </div>
      </div>

      <!-- Filter Controls -->
      <div class="filter-controls">
        <input 
          v-model="searchQuery" 
          type="text" 
          placeholder="Search users by email..."
          @input="filterUsers"
        >
        
        <select v-model="selectedRole" @change="filterUsers">
          <option value="">All Users</option>
          <option value="beta">Beta Users</option>
          <option value="admin">Admin Users</option>
          <option value="regular">Regular Users</option>
        </select>
        
        <select v-model="selectedStatus" @change="filterUsers">
          <option value="">All Status</option>
          <option value="confirmed">Confirmed</option>
          <option value="unconfirmed">Unconfirmed</option>
        </select>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="loading">
        <div class="loading-spinner"></div>
        <p>Loading users...</p>
      </div>

      <!-- Users List -->
      <div v-else class="users-list">
        <div v-if="filteredUsers.length === 0" class="no-results">
          <p>No users found matching your criteria.</p>
        </div>

        <div v-else class="users-list">
          <div class="list-header">
            <div class="col-email">User</div>
            <div class="col-status">Status</div>
            <div class="col-roles">Roles</div>
            <div class="col-created">Created</div>
            <div class="col-last-signin">Last Sign In</div>
            <div class="col-actions">Actions</div>
          </div>
          
          <div class="list-items">
            <div 
              v-for="user in filteredUsers" 
              :key="user.id"
              class="list-item"
            >
              <div class="col-email">
                <div class="user-info">
                  <strong class="user-email">{{ user.email }}</strong>
                  <div class="verification-status">
                    <span v-if="user.email_confirmed_at" class="verified">✅ Verified</span>
                    <span v-else class="unverified">⚠️ Unverified</span>
                  </div>
                </div>
              </div>
              <div class="col-status">
                <span class="status-badge" :class="getUserStatus(user)">
                  {{ getUserStatus(user) }}
                </span>
              </div>
              <div class="col-roles">
                <div class="role-badges">
                  <span v-if="isBetaUser(user)" class="role-badge beta">Beta</span>
                  <span v-if="isAdminUser(user)" class="role-badge admin">Admin</span>
                  <span v-if="!isBetaUser(user) && !isAdminUser(user)" class="role-badge regular">Regular</span>
                </div>
              </div>
              <div class="col-created">
                <span class="date-text">{{ formatDate(user.created_at) }}</span>
              </div>
              <div class="col-last-signin">
                <span class="date-text">{{ formatDate(user.last_sign_in_at) }}</span>
              </div>
              <div class="col-actions">
                <button @click="editUser(user)" class="action-btn edit" title="Edit User">
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                    <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                  </svg>
                </button>
                <button @click="toggleBetaAccess(user)" class="action-btn beta" title="Toggle Beta Access">
                  <svg v-if="isBetaUser(user)" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M9.75 9.5 12 7.25 14.25 9.5v2.25l-2.25 2.25L9.75 11.75V9.5Z"></path>
                    <path d="M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"></path>
                  </svg>
                  <svg v-else width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <circle cx="12" cy="12" r="10"></circle>
                    <circle cx="12" cy="10" r="3"></circle>
                    <path d="M7 20.662V19a2 2 0 0 1 2-2h6a2 2 0 0 1 2 2v1.662"></path>
                  </svg>
                </button>
                <button @click="deleteUser(user)" class="action-btn delete" title="Delete User">
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <polyline points="3 6 5 6 21 6"></polyline>
                    <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
                    <line x1="10" y1="11" x2="10" y2="17"></line>
                    <line x1="14" y1="11" x2="14" y2="17"></line>
                  </svg>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Create/Edit Modal -->
      <div v-if="showModal" class="modal-overlay" @click="closeModal">
        <div class="modal-content" @click.stop>
          <h2>{{ editingUser ? 'Edit' : 'Create' }} User</h2>
          
          <form @submit.prevent="saveUser">
            <div class="form-group">
              <label>Email Address</label>
              <input 
                v-model="currentUser.email" 
                type="email" 
                required
                :disabled="editingUser"
                placeholder="user@example.com"
              >
            </div>
            
            <div class="form-group" v-if="!editingUser">
              <label>Password</label>
              <input 
                v-model="currentUser.password" 
                type="password" 
                :required="!editingUser"
                placeholder="Minimum 6 characters"
                minlength="6"
              >
            </div>
            
            <div class="form-group">
              <label>
                <input v-model="currentUser.beta_user" type="checkbox">
                Beta User Access
              </label>
            </div>
            
            <div class="form-group">
              <label>
                <input v-model="currentUser.admin" type="checkbox">
                Admin Access
              </label>
            </div>
            
            <div class="form-group">
              <label>
                <input v-model="currentUser.email_confirmed" type="checkbox">
                Email Confirmed
              </label>
            </div>
            
            <div class="modal-actions">
              <ActionButton type="button" @click="closeModal" variant="secondary">Cancel</ActionButton>
              <ActionButton type="submit" :disabled="saving">
                {{ saving ? 'Saving...' : 'Save' }}
              </ActionButton>
            </div>
          </form>
        </div>
      </div>

      <!-- Beta Access Management Info -->
      <div class="info-section">
        <h3>🧪 Beta Access Management</h3>
        <div class="tip custom-block">
          <p class="custom-block-title">Beta User Management</p>
          <p>Beta users have access to the assessment system. Use the toggle button to grant or revoke beta access.</p>
          <p><strong>Current beta users:</strong> {{ stats.betaUsers }} of {{ stats.totalUsers }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useAuth } from '../composables/useAuth'
import { useAdminSupabase } from '../composables/useAdminSupabase'
import { useAdminSession } from '../composables/useAdminSession'
import ActionButton from './shared/ActionButton.vue'
import AdminLoadingState from './shared/AdminLoadingState.vue'

const { user } = useAuth()
const { adminSupabase } = useAdminSupabase()
const { hasAdminAccess } = useAdminSession()

// Auth state to prevent flash
const isAuthLoaded = ref(false)

// State
const users = ref([])
const filteredUsers = ref([])
const loading = ref(false)
const showModal = ref(false)
const editingUser = ref(null)
const saving = ref(false)

// Filters
const searchQuery = ref('')
const selectedRole = ref('')
const selectedStatus = ref('')

// Stats
const stats = ref({
  totalUsers: 0,
  betaUsers: 0,
  adminUsers: 0,
  confirmedUsers: 0
})

// Current user for editing
const currentUser = ref({
  email: '',
  password: '',
  beta_user: false,
  admin: false,
  email_confirmed: false
})

// Helper functions
const isBetaUser = (user) => {
  const metadata = user.raw_user_meta_data || user.user_metadata || {}
  return metadata.beta_user === true
}

const isAdminUser = (user) => {
  const metadata = user.raw_user_meta_data || user.user_metadata || {}
  return metadata.admin === true || user.email === 'gunnar.finkeldeh@gmail.com' || user.email === 'test@coaching-hub.local'
}

const getUserStatus = (user) => {
  return user.email_confirmed_at ? 'confirmed' : 'unconfirmed'
}

const formatDate = (dateString) => {
  if (!dateString) return 'Never'
  return new Date(dateString).toLocaleDateString()
}

// Methods
const loadUsers = async () => {
  if (!adminSupabase || !hasAdminAccess.value) return
  
  loading.value = true
  try {
    console.log('Loading users with admin client...')
    
    // Load real users from auth.admin API
    const { data: usersData, error } = await adminSupabase.auth.admin.listUsers()
    
    if (error) {
      console.error('Error loading users:', error)
      throw error
    }
    
    console.log('Loaded users:', usersData.users.length)
    
    users.value = usersData.users
    
    // Calculate stats
    stats.value = {
      totalUsers: users.value.length,
      betaUsers: users.value.filter(u => isBetaUser(u)).length,
      adminUsers: users.value.filter(u => isAdminUser(u)).length,
      confirmedUsers: users.value.filter(u => u.email_confirmed_at).length
    }
    
    filterUsers()
    
  } catch (error) {
    console.error('Error loading users:', error)
  } finally {
    loading.value = false
  }
}

const filterUsers = () => {
  let filtered = users.value

  // Search filter
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(user => 
      user.email.toLowerCase().includes(query)
    )
  }

  // Role filter
  if (selectedRole.value) {
    switch (selectedRole.value) {
      case 'beta':
        filtered = filtered.filter(user => isBetaUser(user))
        break
      case 'admin':
        filtered = filtered.filter(user => isAdminUser(user))
        break
      case 'regular':
        filtered = filtered.filter(user => !isBetaUser(user) && !isAdminUser(user))
        break
    }
  }

  // Status filter
  if (selectedStatus.value) {
    switch (selectedStatus.value) {
      case 'confirmed':
        filtered = filtered.filter(user => user.email_confirmed_at)
        break
      case 'unconfirmed':
        filtered = filtered.filter(user => !user.email_confirmed_at)
        break
    }
  }

  filteredUsers.value = filtered
}

const refreshUsers = () => {
  loadUsers()
}

const createNewUser = () => {
  editingUser.value = null
  currentUser.value = {
    email: '',
    password: '',
    beta_user: false,
    admin: false,
    email_confirmed: true
  }
  showModal.value = true
}

const editUser = (user) => {
  editingUser.value = user
  const metadata = user.raw_user_meta_data || user.user_metadata || {}
  currentUser.value = {
    id: user.id,
    email: user.email,
    password: '',
    beta_user: metadata.beta_user || false,
    admin: metadata.admin || false,
    email_confirmed: !!user.email_confirmed_at
  }
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  editingUser.value = null
}

const saveUser = async () => {
  if (!supabase || saving.value) return
  
  saving.value = true
  try {
    const userData = {
      email: currentUser.value.email,
      user_metadata: {
        beta_user: currentUser.value.beta_user,
        admin: currentUser.value.admin
      },
      email_confirm: currentUser.value.email_confirmed
    }

    if (currentUser.value.password) {
      userData.password = currentUser.value.password
    }
    
    if (editingUser.value) {
      // Update existing user
      const { error } = await adminSupabase.auth.admin.updateUserById(
        editingUser.value.id,
        userData
      )
      if (error) throw error
    } else {
      // Create new user
      userData.password = currentUser.value.password
      const { error } = await adminSupabase.auth.admin.createUser(userData)
      if (error) throw error
    }
    
    await loadUsers()
    closeModal()
  } catch (error) {
    console.error('Error saving user:', error)
    alert('Error saving user: ' + error.message)
  } finally {
    saving.value = false
  }
}

const toggleBetaAccess = async (user) => {
  try {
    const metadata = user.raw_user_meta_data || user.user_metadata || {}
    const newBetaStatus = !metadata.beta_user
    
    const { error } = await adminSupabase.auth.admin.updateUserById(user.id, {
      user_metadata: {
        ...metadata,
        beta_user: newBetaStatus
      }
    })
    
    if (error) throw error
    
    await loadUsers()
  } catch (error) {
    console.error('Error toggling beta access:', error)
  }
}

const deleteUser = async (user) => {
  if (!confirm(`Are you sure you want to delete ${user.email}? This action cannot be undone.`)) {
    return
  }
  
  try {
    const { error } = await adminSupabase.auth.admin.deleteUser(user.id)
    if (error) throw error
    
    await loadUsers()
  } catch (error) {
    console.error('Error deleting user:', error)
  }
}

// Watch for admin access changes
watch(hasAdminAccess, (newValue) => {
  if (newValue) {
    loadUsers()
  }
}, { immediate: true })

onMounted(() => {
  // Set auth loaded state to prevent flash
  isAuthLoaded.value = true
  
  if (hasAdminAccess.value) {
    loadUsers()
  }
})
</script>

<style scoped>
/* Base Admin Container */
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
  padding: 2rem 2rem 12rem 2rem; /* Extra bottom padding for footer */
  min-height: calc(100vh - var(--vp-nav-height) - 8rem); /* Ensure minimum height */
}

/* Admin Header */
.admin-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 2rem;
  gap: 2rem;
}

.header-main h1 {
  font-size: 2rem;
  margin-bottom: 0.5rem;
  font-weight: 600;
  color: var(--vp-c-text-1);
}

.admin-subtitle {
  font-size: 1rem;
  opacity: 0.7;
  margin: 0;
  color: var(--vp-c-text-2);
}

.header-actions {
  display: flex;
  gap: 1rem;
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
  font-size: 0.9rem;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 1rem;
  margin-bottom: 2rem;
}

.stat-card {
  padding: 1rem;
  border: 1px solid var(--vp-c-border);
  border-radius: 8px;
  text-align: center;
  background: var(--vp-c-bg-soft);
}

.stat-card h3 {
  margin: 0 0 0.5rem 0;
  font-size: 0.9rem;
}

.stat-number {
  font-size: 1.5rem;
  font-weight: 600;
  color: var(--vp-c-brand-1);
}

.filter-controls {
  display: flex;
  gap: 1rem;
  margin-bottom: 2rem;
  flex-wrap: wrap;
}

.filter-controls input,
.filter-controls select {
  padding: 0.5rem;
  border: 1px solid var(--vp-c-border);
  border-radius: 4px;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-1);
}

.filter-controls input {
  flex: 1;
  min-width: 200px;
}

.loading {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 2rem;
  justify-content: center;
}

.loading-spinner {
  width: 20px;
  height: 20px;
  border: 2px solid var(--vp-c-border);
  border-top: 2px solid var(--vp-c-brand-1);
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.users-list {
  background: var(--vp-c-bg-soft);
  border-radius: 12px;
  overflow: hidden;
  margin: 1rem 0 4rem 0;
  border: 1px solid var(--vp-c-border);
}

.list-header {
  display: grid;
  grid-template-columns: 2.5fr 1fr 1.2fr 1fr 1fr 1.2fr;
  gap: 1rem;
  padding: 1rem 1.5rem;
  background: var(--vp-c-bg);
  border-bottom: 2px solid var(--vp-c-border);
  font-weight: 600;
  font-size: 0.9rem;
  color: var(--vp-c-text-2);
}

.list-items {
  background: var(--vp-c-bg);
}

.list-item {
  display: grid;
  grid-template-columns: 2.5fr 1fr 1.2fr 1fr 1fr 1.2fr;
  gap: 1rem;
  padding: 1rem 1.5rem;
  border-bottom: 1px solid var(--vp-c-divider);
  align-items: center;
  transition: background 0.2s ease;
}

.list-item:hover {
  background: var(--vp-c-bg-soft);
}

.list-item:last-child {
  border-bottom: none;
}

.user-info {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.user-email {
  color: var(--vp-c-text-1);
  font-size: 0.95rem;
  font-weight: 500;
}

.verification-status {
  display: flex;
  align-items: center;
}

.verified {
  color: #15803d;
  font-size: 0.75rem;
  font-weight: 500;
}

.unverified {
  color: #f57c00;
  font-size: 0.75rem;
  font-weight: 500;
}

.status-badge {
  padding: 0.2rem 0.6rem;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: capitalize;
  display: inline-block;
}

.status-badge.confirmed { 
  background: #bbf7d0; 
  color: #15803d; 
}

.status-badge.unconfirmed { 
  background: #fed7aa; 
  color: #c2410c; 
}

.role-badges {
  display: flex;
  gap: 0.4rem;
  flex-wrap: wrap;
}

.role-badge {
  padding: 0.15rem 0.5rem;
  border-radius: 10px;
  font-size: 0.7rem;
  font-weight: 600;
  text-transform: uppercase;
}

.role-badge.beta { 
  background: #dbeafe; 
  color: #1e40af; 
}

.role-badge.admin { 
  background: #fecaca; 
  color: #dc2626; 
}

.role-badge.regular { 
  background: var(--vp-c-gray-soft); 
  color: var(--vp-c-text-2); 
}

.date-text {
  font-size: 0.85rem;
  color: var(--vp-c-text-2);
}

.col-actions {
  display: flex;
  gap: 0.5rem;
  justify-content: flex-start;
}

.action-btn {
  background: var(--vp-c-bg);
  border: 1px solid var(--vp-c-border);
  border-radius: 6px;
  padding: 0.4rem;
  cursor: pointer;
  color: var(--vp-c-text-2);
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
}

.action-btn:hover {
  border-color: var(--vp-c-brand-1);
  color: var(--vp-c-brand-1);
  transform: translateY(-1px);
}

.action-btn.edit:hover {
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand-1);
}

.action-btn.beta:hover {
  background: var(--vp-c-indigo-soft);
  color: var(--vp-c-indigo-1);
}

.action-btn.delete:hover {
  background: var(--vp-c-danger-soft);
  color: var(--vp-c-danger-1);
  border-color: var(--vp-c-danger-1);
}

.action-btn svg {
  width: 16px;
  height: 16px;
}

.action-btn::after {
  content: attr(title);
  position: absolute;
  bottom: 100%;
  left: 50%;
  transform: translateX(-50%);
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-1);
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.75rem;
  white-space: nowrap;
  opacity: 0;
  pointer-events: none;
  transition: opacity 0.2s ease;
  border: 1px solid var(--vp-c-border);
  margin-bottom: 0.25rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.action-btn:hover::after {
  opacity: 1;
}

.no-results {
  text-align: center;
  padding: 3rem;
}

.modal-overlay {
  position: fixed;
  top: calc(var(--vp-nav-height) + 1rem);
  left: 0;
  right: 0;
  bottom: 6rem;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  overflow-y: auto;
}

.modal-content {
  background: var(--vp-c-bg);
  padding: 1.5rem;
  border-radius: 12px;
  width: 90%;
  max-width: 500px;
  max-height: calc(100vh - var(--vp-nav-height) - 8rem);
  overflow-y: auto;
  border: 1px solid var(--vp-c-border);
  margin: 1rem;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
}

.modal-content h2 {
  margin: 0 0 1.5rem 0;
}

.form-group {
  margin-bottom: 1rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.3rem;
  font-weight: 500;
}

.form-group input,
.form-group select {
  width: 100%;
  padding: 0.5rem;
  border: 1px solid var(--vp-c-border);
  border-radius: 4px;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-1);
}

.form-group input[type="checkbox"] {
  width: auto;
  margin-right: 0.5rem;
}

.modal-actions {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
  margin-top: 2rem;
  padding-top: 1rem;
  border-top: 1px solid var(--vp-c-border);
}

.info-section {
  margin-top: 3rem;
  padding-top: 2rem;
  border-top: 1px solid var(--vp-c-border);
}

.info-section h3 {
  margin-bottom: 1rem;
}

/* Notice Card */
.notice-card {
  padding: 1.5rem;
  border-radius: 8px;
  margin-bottom: 2rem;
  border-left: 4px solid var(--vp-c-warning);
}

.notice-card.warning {
  background: var(--vp-c-warning-soft);
  border-left-color: #f57c00;
}

.notice-card h3 {
  margin: 0 0 0.5rem 0;
  font-size: 1rem;
  color: var(--vp-c-text-1);
}

.notice-card p {
  margin: 0.3rem 0;
  font-size: 0.9rem;
  color: var(--vp-c-text-2);
}

/* Responsive Design */
@media (max-width: 768px) {
  .admin-content {
    padding: 1rem 1rem 10rem 1rem; /* Increased bottom padding on mobile */
  }
  
  .admin-header {
    flex-direction: column;
    gap: 1rem;
  }
  
  .filter-controls {
    flex-direction: column;
  }
  
  .list-header,
  .list-item {
    grid-template-columns: 2fr 80px 100px 80px 80px 100px;
    font-size: 0.85rem;
  }
  
  .list-header {
    display: none;
  }
  
  .list-item {
    grid-template-columns: 1fr;
    gap: 0.75rem;
    padding: 1rem;
  }
  
  .list-item > div {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  
  .list-item > div::before {
    content: attr(data-label);
    font-weight: 600;
    font-size: 0.8rem;
    color: var(--vp-c-text-3);
    text-transform: uppercase;
  }
  
  .col-email::before { content: 'User'; }
  .col-status::before { content: 'Status'; }
  .col-roles::before { content: 'Roles'; }
  .col-created::before { content: 'Created'; }
  .col-last-signin::before { content: 'Last Sign In'; }
  .col-actions::before { content: 'Actions'; }
  
  .col-email {
    flex-direction: column;
    align-items: flex-start !important;
  }
  
  .user-info {
    margin-top: 0.5rem;
  }
  
  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .action-btn {
    margin-right: 0.2rem;
    min-width: 32px;
  }
  
  .modal-content {
    padding: 1rem;
    margin: 0.5rem;
    max-height: calc(100vh - var(--vp-nav-height) - 6rem);
  }
}
</style>