<template>
  <div class="space-y-6">
    <h3 class="text-xl font-bold">Sessions Management</h3>

    <!-- Filters -->
    <div class="bg-white rounded-lg shadow p-4">
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Filter by Date</label>
          <input
            v-model="filters.date"
            type="date"
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
          />
        </div>
        <div>
          <label class="block text-sm font-medium text-gray-700 mb-1">Filter by Issue</label>
          <select
            v-model="filters.issue"
            class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary"
          >
            <option value="">All Issues</option>
            <option v-for="issue in uniqueIssues" :key="issue" :value="issue">
              {{ issue }}
            </option>
          </select>
        </div>
        <div class="flex items-end">
          <button
            @click="clearFilters"
            class="px-4 py-2 bg-gray-500 text-white rounded-md hover:bg-gray-600 transition"
          >
            Clear Filters
          </button>
        </div>
      </div>
    </div>

    <!-- Tabs -->
    <div class="border-b border-gray-200">
      <nav class="-mb-px flex space-x-8">
        <button
          @click="activeTab = 'active'"
          :class="[
            'py-2 px-1 border-b-2 font-medium text-sm',
            activeTab === 'active'
              ? 'border-primary text-primary'
              : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
          ]"
        >
          Active Sessions
        </button>
        <button
          @click="activeTab = 'pending'"
          :class="[
            'py-2 px-1 border-b-2 font-medium text-sm',
            activeTab === 'pending'
              ? 'border-primary text-primary'
              : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
          ]"
        >
          Pending Sessions
        </button>
        <button
          @click="activeTab = 'closed'"
          :class="[
            'py-2 px-1 border-b-2 font-medium text-sm',
            activeTab === 'closed'
              ? 'border-primary text-primary'
              : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
          ]"
        >
          Closed Sessions
        </button>
      </nav>
    </div>

    <div v-if="dashboardStore.loading" class="flex justify-center py-12">
      <div class="spinner"></div>
    </div>

    <!-- Active Sessions Tab -->
    <div v-else-if="activeTab === 'active'" class="bg-white rounded-lg shadow overflow-hidden">
      <table class="w-full">
        <thead class="bg-secondary-light">
          <tr>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Session ID</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Issue</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Language</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Client</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Counsellor</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Status</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Started</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Duration</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Actions</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-200">
          <tr v-if="filteredActiveSessions.length === 0">
            <td colspan="9" class="px-6 py-8 text-center text-gray-500">No active sessions found</td>
          </tr>
          <tr v-for="session in filteredActiveSessions" :key="session.id" class="hover:bg-gray-50">
            <td class="px-6 py-4">#{{ session.id }}</td>
            <td class="px-6 py-4">{{ session.issue || 'N/A' }}</td>
            <td class="px-6 py-4">{{ session.language || 'en' }}</td>
            <td class="px-6 py-4">{{ session.client_name || 'Anonymous' }}</td>
            <td class="px-6 py-4">{{ session.counsellor_name || 'N/A' }}</td>
            <td class="px-6 py-4">
              <span class="px-2 py-1 text-xs rounded-full bg-green-100 text-green-800">
                {{ session.status }}
              </span>
            </td>
            <td class="px-6 py-4 text-sm text-gray-600">{{ formatDate(session.created_at) }}</td>
            <td class="px-6 py-4 text-sm text-gray-600">{{ calculateDuration(session.created_at) }}</td>
            <td class="px-6 py-4">
              <button
                @click="closeSession(session.id)"
                class="bg-danger hover:bg-red-600 text-white px-3 py-1 rounded text-sm transition"
              >
                Close
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Pending Sessions Tab -->
    <div v-else-if="activeTab === 'pending'" class="bg-white rounded-lg shadow overflow-hidden">
      <table class="w-full">
        <thead class="bg-secondary-light">
          <tr>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Session ID</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Issue</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Language</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Client</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Status</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Waiting Since</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Wait Time</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-200">
          <tr v-if="filteredPendingSessions.length === 0">
            <td colspan="7" class="px-6 py-8 text-center text-gray-500">No pending sessions found</td>
          </tr>
          <tr v-for="session in filteredPendingSessions" :key="session.id" class="hover:bg-gray-50">
            <td class="px-6 py-4">#{{ session.id }}</td>
            <td class="px-6 py-4">{{ session.issue || 'N/A' }}</td>
            <td class="px-6 py-4">{{ session.language || 'en' }}</td>
            <td class="px-6 py-4">{{ session.client_name || 'Anonymous' }}</td>
            <td class="px-6 py-4">
              <span class="px-2 py-1 text-xs rounded-full bg-yellow-100 text-yellow-800">
                {{ session.status }}
              </span>
            </td>
            <td class="px-6 py-4 text-sm text-gray-600">{{ formatDate(session.created_at) }}</td>
            <td class="px-6 py-4 text-sm text-gray-600">{{ calculateDuration(session.created_at) }}</td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Closed Sessions Tab -->
    <div v-else-if="activeTab === 'closed'" class="bg-white rounded-lg shadow overflow-hidden">
      <table class="w-full">
        <thead class="bg-secondary-light">
          <tr>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Session ID</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Issue</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Client</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Counsellor</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Closed By</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Action Taken</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Closed Date</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Closed Time</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Duration</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-200">
          <tr v-if="filteredClosedSessions.length === 0">
            <td colspan="9" class="px-6 py-8 text-center text-gray-500">No closed sessions found</td>
          </tr>
          <tr v-for="session in filteredClosedSessions" :key="session.id" class="hover:bg-gray-50">
            <td class="px-6 py-4">#{{ session.id }}</td>
            <td class="px-6 py-4">{{ session.issue || 'N/A' }}</td>
            <td class="px-6 py-4">{{ session.client_name || 'Anonymous' }}</td>
            <td class="px-6 py-4">{{ session.counsellor_name || 'N/A' }}</td>
            <td class="px-6 py-4">{{ session.closed_by || 'System' }}</td>
            <td class="px-6 py-4">{{ session.action_taken || 'Session completed' }}</td>
            <td class="px-6 py-4 text-sm text-gray-600">{{ formatDateOnly(session.closed_at) }}</td>
            <td class="px-6 py-4 text-sm text-gray-600">{{ formatTimeOnly(session.closed_at) }}</td>
            <td class="px-6 py-4 text-sm text-gray-600">{{ calculateSessionDuration(session.created_at, session.closed_at) }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup>
import { onMounted, ref, computed } from 'vue'
import { useDashboardStore } from '../stores/dashboard'
import api from '../services/api'

const dashboardStore = useDashboardStore()
const activeTab = ref('active')
const filters = ref({
  date: '',
  issue: ''
})

onMounted(() => {
  dashboardStore.loadSessions()
  
  // Auto-refresh every 10 seconds
  setInterval(() => {
    dashboardStore.loadSessions()
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
  return date.toLocaleString()
}

const activeSessions = computed(() => {
  return dashboardStore.sessions.filter(session => session.status === 'active')
})

const pendingSessions = computed(() => {
  return dashboardStore.sessions.filter(session => session.status === 'pending')
})

const closedSessions = computed(() => {
  return dashboardStore.sessions.filter(session => session.status === 'closed')
})

const uniqueIssues = computed(() => {
  const issues = dashboardStore.sessions.map(session => session.issue).filter(Boolean)
  return [...new Set(issues)]
})

const filteredActiveSessions = computed(() => {
  return filterSessions(activeSessions.value)
})

const filteredPendingSessions = computed(() => {
  return filterSessions(pendingSessions.value)
})

const filteredClosedSessions = computed(() => {
  return filterSessions(closedSessions.value)
})

const filterSessions = (sessions) => {
  return sessions.filter(session => {
    const matchesDate = !filters.value.date || 
      new Date(session.created_at || session.closed_at).toISOString().split('T')[0] === filters.value.date
    const matchesIssue = !filters.value.issue || session.issue === filters.value.issue
    return matchesDate && matchesIssue
  })
}

const clearFilters = () => {
  filters.value.date = ''
  filters.value.issue = ''
}

const calculateDuration = (startDate) => {
  const start = new Date(startDate)
  const now = new Date()
  const diff = now - start
  const minutes = Math.floor(diff / 60000)
  const hours = Math.floor(minutes / 60)
  
  if (hours > 0) {
    return `${hours}h ${minutes % 60}m`
  }
  return `${minutes}m`
}

const calculateSessionDuration = (startDate, endDate) => {
  const start = new Date(startDate)
  const end = new Date(endDate)
  const diff = end - start
  const minutes = Math.floor(diff / 60000)
  const hours = Math.floor(minutes / 60)
  
  if (hours > 0) {
    return `${hours}h ${minutes % 60}m`
  }
  return `${minutes}m`
}

const formatDateOnly = (dateString) => {
  const date = new Date(dateString)
  return date.toLocaleDateString()
}

const formatTimeOnly = (dateString) => {
  const date = new Date(dateString)
  return date.toLocaleTimeString()
}

const closeSession = async (id) => {
  if (!confirm('Are you sure you want to close this session?')) return
  
  try {
    await api.closeSession(id)
    await dashboardStore.loadSessions()
    alert('Session closed successfully!')
  } catch (error) {
    alert('Failed to close session: ' + (error.response?.data?.detail || 'Unknown error'))
  }
}
</script>
