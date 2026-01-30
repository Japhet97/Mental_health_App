<template>
  <div class="space-y-6">
    <!-- Stats Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      <StatCard
        title="Total Sessions"
        :value="dashboardStore.stats.totalSessions"
        icon="💬"
        color="text-blue-600"
        to="/sessions"
      />
      <StatCard
        title="Active Sessions"
        :value="dashboardStore.stats.activeSessions"
        icon="🟢"
        color="text-green-600"
        to="/sessions"
      />
      <StatCard
        title="Pending Sessions"
        :value="dashboardStore.stats.pendingSessions"
        icon="🟡"
        color="text-orange-600"
        to="/sessions"
      />
      <StatCard
        title="Counsellors"
        :value="dashboardStore.stats.totalCounsellors"
        icon="👨‍⚕️"
        color="text-purple-600"
        to="/counsellors"
      />
    </div>

    <!-- Recent Activity -->
    <div class="bg-white rounded-lg shadow p-6">
      <h3 class="text-xl font-bold text-primary mb-4">Recent Activity</h3>
      
      <div v-if="dashboardStore.loading" class="flex justify-center py-8">
        <div class="spinner"></div>
      </div>

      <div v-else-if="dashboardStore.recentActivity.length === 0" class="text-center py-8 text-gray-500">
        No recent activity
      </div>

      <div v-else class="space-y-3">
        <div
          v-for="session in dashboardStore.recentActivity"
          :key="session.id"
          class="flex justify-between items-center p-4 border border-gray-200 rounded-lg hover:bg-gray-50 transition"
        >
          <div class="flex-1">
            <div class="flex items-center gap-2">
              <span class="font-semibold">Session #{{ session.id }}</span>
              <span class="text-sm text-gray-600">- {{ session.issue || 'Unknown Issue' }}</span>
              <span
                class="px-2 py-1 text-xs rounded-full"
                :class="getStatusClass(session.status)"
              >
                {{ session.status }}
              </span>
            </div>
            <div class="text-sm text-gray-500 mt-1">
              {{ session.client_name || 'Anonymous' }} • {{ formatDate(session.created_at) }}
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Quick Actions -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
      <router-link
        to="/issues"
        class="bg-white rounded-lg shadow p-6 hover:shadow-lg transition border-l-4 border-primary"
      >
        <div class="text-3xl mb-2">🏷️</div>
        <h4 class="font-bold text-lg">Manage Issues</h4>
        <p class="text-sm text-gray-600 mt-1">Add or remove mental health issues</p>
      </router-link>

      <router-link
        to="/counsellors"
        class="bg-white rounded-lg shadow p-6 hover:shadow-lg transition border-l-4 border-secondary"
      >
        <div class="text-3xl mb-2">👥</div>
        <h4 class="font-bold text-lg">Manage Counsellors</h4>
        <p class="text-sm text-gray-600 mt-1">Add or remove counsellors</p>
      </router-link>

      <router-link
        to="/analytics"
        class="bg-white rounded-lg shadow p-6 hover:shadow-lg transition border-l-4 border-info"
      >
        <div class="text-3xl mb-2">📈</div>
        <h4 class="font-bold text-lg">View Analytics</h4>
        <p class="text-sm text-gray-600 mt-1">See charts and statistics</p>
      </router-link>
    </div>
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import { useDashboardStore } from '../stores/dashboard'
import StatCard from '../components/StatCard.vue'

const dashboardStore = useDashboardStore()

onMounted(async () => {
  await dashboardStore.loadDashboard()
  await dashboardStore.loadRecentActivity()
  
  // Auto-refresh every 10 seconds for real-time updates
  setInterval(() => {
    dashboardStore.loadDashboard()
    dashboardStore.loadRecentActivity()
  }, 10000)
})

const getStatusClass = (status) => {
  const classes = {
    pending: 'bg-yellow-100 text-yellow-800',
    active: 'bg-green-100 text-green-800',
    closed: 'bg-gray-100 text-gray-800',
  }
  return classes[status] || 'bg-gray-100 text-gray-800'
}

const formatDate = (dateString) => {
  const date = new Date(dateString)
  const now = new Date()
  const diff = now - date
  const minutes = Math.floor(diff / 60000)
  const hours = Math.floor(minutes / 60)
  const days = Math.floor(hours / 24)

  if (minutes < 1) return 'Just now'
  if (minutes < 60) return `${minutes}m ago`
  if (hours < 24) return `${hours}h ago`
  if (days < 7) return `${days}d ago`
  return date.toLocaleDateString()
}
</script>
