<template>
  <nav class="auth-nav" aria-label="Authentication">
    <a v-if="!user" href="/docs/auth/" class="nav-link" aria-label="Sign in to your account">
      <UserIcon class="nav-icon" aria-hidden="true" />
      <span>Sign In</span>
    </a>
    <template v-else>
      <a v-if="isAdmin" href="/docs/admin/" class="nav-link admin-link" aria-label="Admin dashboard">
        <Cog6ToothIcon class="nav-icon" aria-hidden="true" />
        <span>Admin</span>
      </a>
      <a href="/docs/profile/" class="nav-link" aria-label="View your profile">
        <UserCircleIcon class="nav-icon" aria-hidden="true" />
        <span>My Profile</span>
      </a>
    </template>
  </nav>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { UserIcon, UserCircleIcon, Cog6ToothIcon } from '@heroicons/vue/24/outline'
import { useSupabase } from '../composables/useSupabase.js'

const user = ref(null)

const isAdmin = computed(() => {
  if (!user.value) return false
  const metaData = user.value.raw_user_meta_data || user.value.user_metadata || {}
  
  // Check for admin flag or specific admin emails
  const hasAdminFlag = metaData.admin === true
  const isDevEmail = user.value.email === 'gunnar.finkeldeh@gmail.com' || user.value.email === 'test@coaching-hub.local'
  
  return hasAdminFlag || isDevEmail
})

onMounted(async () => {
  if (typeof window !== 'undefined') {
    const { supabase } = useSupabase()

    const { data: { session } } = await supabase.auth.getSession()
    if (session?.user?.email_confirmed_at) {
      user.value = session.user
    }
    
    supabase.auth.onAuthStateChange((event, session) => {
      user.value = session?.user?.email_confirmed_at ? session.user : null
    })
  }
})
</script>

<style scoped>
.auth-nav {
  opacity: 0;
  animation: fadeIn 0.3s ease-in-out 0.1s forwards;
  display: flex;
  gap: var(--space-4, 1rem);
  align-items: center;
}

@keyframes fadeIn {
  to {
    opacity: 1;
  }
}

.admin-link {
  color: var(--vp-c-brand-1) !important;
  font-weight: var(--font-weight-semibold, 600) !important;
}

.nav-link {
  color: var(--vp-c-text-1);
  text-decoration: none;
  font-weight: var(--font-weight-medium, 500);
  font-size: var(--font-size-sm, 14px);
  line-height: 24px;
  transition: color var(--duration-normal, 0.25s) var(--ease-in-out, ease);
  padding: 0 var(--space-3, 12px);
  display: inline-flex;
  align-items: center;
  gap: var(--space-2, 0.5rem);
  border-radius: var(--radius-md, 6px);
}

.nav-link:hover {
  color: var(--vp-c-brand-1);
}

.nav-link:focus-visible {
  outline: var(--focus-ring, 2px solid var(--color-brand-primary));
  outline-offset: var(--focus-ring-offset, 2px);
}

.nav-icon {
  width: var(--icon-size-md, 1.25rem);
  height: var(--icon-size-md, 1.25rem);
  flex-shrink: 0;
  color: currentColor;
}

/* Dark mode - icons inherit text color, but brand link gets brighter brand color */
.dark .admin-link .nav-icon {
  color: #818cf8;
}

@media (max-width: 768px) {
  .nav-link {
    font-size: var(--font-size-sm, 14px);
    padding: var(--space-2, 0.5rem) 0;
    display: flex;
    width: 100%;
    text-align: left;
    border-radius: var(--radius-sm, 4px);
  }
  
  .nav-link:hover {
    background: var(--vp-c-bg-alt);
  }
}
</style>
