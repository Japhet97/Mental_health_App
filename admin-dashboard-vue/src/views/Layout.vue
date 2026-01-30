<template>
  <div class="min-h-screen bg-gradient-to-br from-primary/10 to-primary/20 dark:from-primary-dark dark:to-primary transition-all">
    <!-- Top Navigation Bar -->
    <nav class="bg-white/90 dark:bg-gray-800/90 backdrop-blur-sm shadow-lg border-b-2 border-primary/30">
      <div class="w-full px-6 lg:px-8">
        <div class="flex justify-between items-center h-20">
          <!-- Logo -->
          <div class="flex items-center gap-4">
            <img src="/logo/logo.png" alt="Tithandizane Logo" class="w-12 h-12 object-contain" />
            <div>
              <h1 class="text-2xl font-bold text-primary-dark dark:text-white">Tithandizane</h1>
              <p class="text-sm text-primary-dark font-medium">Helpline Admin Dashboard</p>
            </div>
          </div>

          <!-- Right side - Theme toggle and Profile -->
          <div class="flex items-center gap-6">
            <!-- Theme Toggle -->
            <button
              @click="toggleTheme"
              class="p-3 rounded-xl bg-gray-100 dark:bg-gray-700 hover:bg-primary/10 dark:hover:bg-primary/20 transition-all duration-200 hover:scale-105"
              :title="isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode'"
            >
              <svg v-if="isDark" class="w-6 h-6 text-yellow-400" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M10 2a1 1 0 011 1v1a1 1 0 11-2 0V3a1 1 0 011-1zm4 8a4 4 0 11-8 0 4 4 0 018 0zm-.464 4.95l.707.707a1 1 0 001.414-1.414l-.707-.707a1 1 0 00-1.414 1.414zm2.12-10.607a1 1 0 010 1.414l-.706.707a1 1 0 11-1.414-1.414l.707-.707a1 1 0 011.414 0zM17 11a1 1 0 100-2h-1a1 1 0 100 2h1zm-7 4a1 1 0 011 1v1a1 1 0 11-2 0v-1a1 1 0 011-1zM5.05 6.464A1 1 0 106.465 5.05l-.708-.707a1 1 0 00-1.414 1.414l.707.707zm1.414 8.486l-.707.707a1 1 0 01-1.414-1.414l.707-.707a1 1 0 011.414 1.414zM4 11a1 1 0 100-2H3a1 1 0 000 2h1z" clip-rule="evenodd" />
              </svg>
              <svg v-else class="w-6 h-6 text-primary-dark" fill="currentColor" viewBox="0 0 20 20">
                <path d="M17.293 13.293A8 8 0 016.707 2.707a8.001 8.001 0 1010.586 10.586z" />
              </svg>
            </button>

            <!-- Profile -->
            <div class="flex items-center gap-4">
              <div class="text-right">
                <p class="text-lg font-bold text-primary-dark dark:text-white">{{ authStore.user?.name }}</p>
                <p class="text-sm text-primary-dark font-medium">Administrator</p>
              </div>
              <div class="w-12 h-12 bg-gradient-to-r from-primary to-primary-dark rounded-full flex items-center justify-center shadow-lg">
                <span class="text-white text-lg font-bold">{{ getInitials(authStore.user?.name) }}</span>
              </div>
              <button
                @click="handleLogout"
                class="p-3 text-gray-400 hover:text-red-400 hover:bg-red-100 dark:hover:bg-red-900/30 rounded-xl transition-all duration-200 hover:scale-105"
                title="Logout"
              >
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                </svg>
              </button>
            </div>
          </div>
        </div>
      </div>
    </nav>

    <!-- Horizontal Menu Bar -->
    <div class="bg-white/90 dark:bg-gray-800/90 backdrop-blur-sm border-b-2 border-primary/20 dark:border-primary/30 shadow-sm">
      <div class="w-full px-6 lg:px-8">
        <nav class="flex space-x-2 overflow-x-auto">
          <router-link
            v-for="item in menuItems"
            :key="item.path"
            :to="item.path"
            class="flex items-center gap-3 px-6 py-5 text-lg font-semibold border-b-4 border-transparent hover:bg-white hover:text-primary transition-all duration-200 whitespace-nowrap rounded-t-lg"
            :class="isActiveRoute(item.path) ? 'text-primary border-primary bg-white' : 'text-primary-dark dark:text-gray-200 hover:bg-white hover:text-primary'"
          >
            <svg class="w-6 h-6 drop-shadow-sm" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2.5">
              <path stroke-linecap="round" stroke-linejoin="round" :d="item.icon" />
            </svg>
            <span>{{ item.label }}</span>
          </router-link>
        </nav>
      </div>
    </div>

    <!-- Page Header -->
    <div class="bg-gradient-to-r from-white/80 to-primary/5 dark:from-gray-800/80 dark:to-primary-dark/20 backdrop-blur-sm border-b border-primary/20 dark:border-primary/30">
      <div class="w-full px-6 lg:px-8 py-8">
        <div class="flex justify-between items-center">
          <div>
            <h2 class="text-4xl font-bold text-primary-dark dark:text-white mb-2 drop-shadow-sm">{{ currentPageTitle }}</h2>
            <p class="text-lg text-primary-dark/80 dark:text-gray-200">Manage your helpline system efficiently</p>
          </div>
          <div class="text-right">
            <div class="text-lg font-semibold text-primary-dark">
              {{ new Date().toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' }) }}
            </div>
            <div class="text-sm text-primary-dark/70 dark:text-gray-300">
              {{ new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' }) }}
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Main Content -->
    <main class="w-full px-6 lg:px-8 py-8 flex-1">
      <div class="max-w-none bg-white/30 dark:bg-gray-800/30 backdrop-blur-sm rounded-2xl p-6 shadow-lg border border-white/50">
        <router-view />
      </div>
    </main>
  </div>
</template>

<script setup>
import { computed, ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()

const isDark = ref(false)

const menuItems = [
  { 
    path: '/', 
    label: 'Dashboard', 
    icon: 'M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6'
  },
  { 
    path: '/issues', 
    label: 'Issues', 
    icon: 'M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z'
  },
  { 
    path: '/languages', 
    label: 'Languages', 
    icon: 'M3 5h12M9 3v2m1.048 9.5A18.022 18.022 0 016.412 9m6.088 9h7M11 21l5-10 5 10M12.751 5C11.783 10.77 8.07 15.61 3 18.129'
  },
  { 
    path: '/sessions', 
    label: 'Sessions', 
    icon: 'M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z'
  },
  { 
    path: '/counsellors', 
    label: 'Counsellors', 
    icon: 'M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z'
  },
  { 
    path: '/analytics', 
    label: 'Analytics', 
    icon: 'M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z'
  },
]

const currentPageTitle = computed(() => {
  const item = menuItems.find(m => m.path === route.path)
  return item?.label || 'Dashboard'
})

const isActiveRoute = (path) => {
  if (path === '/') {
    return route.path === '/'
  }
  return route.path === path
}

const getInitials = (name) => {
  if (!name) return 'A'
  return name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)
}

const toggleTheme = () => {
  isDark.value = !isDark.value
  localStorage.setItem('theme', isDark.value ? 'dark' : 'light')
  updateTheme()
}

const updateTheme = () => {
  if (isDark.value) {
    document.documentElement.classList.add('dark')
  } else {
    document.documentElement.classList.remove('dark')
  }
}

const handleLogout = () => {
  authStore.logout()
  router.push('/login')
}

onMounted(() => {
  const savedTheme = localStorage.getItem('theme')
  isDark.value = savedTheme === 'dark'
  updateTheme()
})
</script>