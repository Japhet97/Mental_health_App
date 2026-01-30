import { defineStore } from 'pinia'
import { ref } from 'vue'
import api from '../services/api'
import { handleApiError } from '../utils/errorHandler'

export const useDashboardStore = defineStore('dashboard', () => {
  const stats = ref({
    totalSessions: 0,
    activeSessions: 0,
    pendingSessions: 0,
    totalCounsellors: 0,
    totalIssues: 0,
  })
  
  const issues = ref([])
  const languages = ref([])
  const sessions = ref([])
  const counsellors = ref([])
  const recentActivity = ref([])
  const loading = ref(false)
  let pollingInterval = null

  const loadDashboard = async () => {
    if (loading.value) return // Prevent multiple simultaneous requests
    
    loading.value = true
    try {
      const response = await api.getDashboard()
      const data = response.data
      
      stats.value = {
        totalSessions: data.overview?.total_sessions || 0,
        activeSessions: data.overview?.active_sessions || 0,
        pendingSessions: data.overview?.pending_sessions || 0,
        totalCounsellors: data.overview?.total_counsellors || 0,
        totalIssues: data.issues?.length || 0,
      }
      
      issues.value = data.issues || []
    } catch (error) {
      console.error('Failed to load dashboard:', handleApiError(error))
    } finally {
      loading.value = false
    }
  }

  const loadRecentActivity = async () => {
    try {
      const response = await api.getRecentSessions()
      recentActivity.value = response.data.sessions || []
    } catch (error) {
      console.error('Failed to load recent activity:', error)
    }
  }

  const loadIssues = async () => {
    if (loading.value) return
    
    loading.value = true
    try {
      const response = await api.getIssues()
      const data = response.data || []
      
      // Sort and renumber with "Other" always at the end
      const sortedData = data.sort((a, b) => {
        const aIsOther = (a.name_en || '').toLowerCase().includes('other')
        const bIsOther = (b.name_en || '').toLowerCase().includes('other')
        
        if (aIsOther && !bIsOther) return 1
        if (!aIsOther && bIsOther) return -1
        
        return (a.id || 0) - (b.id || 0)
      })
      
      // Renumber all issues dynamically
      issues.value = sortedData.map((issue, index) => ({
        ...issue,
        display_number: index + 1
      }))
    } catch (error) {
      console.error('Failed to load issues:', handleApiError(error))
      issues.value = []
    } finally {
      loading.value = false
    }
  }

  const loadLanguages = async () => {
    if (loading.value) return
    
    loading.value = true
    try {
      const response = await api.getLanguages()
      const data = response.data || []
      languages.value = data.sort((a, b) => (a.id || 0) - (b.id || 0))
    } catch (error) {
      console.error('Failed to load languages:', handleApiError(error))
      languages.value = []
    } finally {
      loading.value = false
    }
  }

  const loadSessions = async () => {
    try {
      const [pending, active, closed] = await Promise.all([
        api.getPendingSessions(),
        api.getActiveSessions(),
        api.getClosedSessions(),
      ])
      sessions.value = [
        ...(pending.data || []),
        ...(active.data || []),
        ...(closed.data || [])
      ]
    } catch (error) {
      console.error('Failed to load sessions:', error)
      sessions.value = []
    }
  }

  const loadCounsellors = async () => {
    if (loading.value) return
    
    loading.value = true
    try {
      const response = await api.getCounsellors()
      const counsellorsList = response.data?.counsellors || []
      counsellors.value = counsellorsList.sort((a, b) => (a.id || 0) - (b.id || 0))
    } catch (error) {
      console.error('Failed to load counsellors:', handleApiError(error))
      counsellors.value = []
    } finally {
      loading.value = false
    }
  }

  const updateSessionStatus = (sessionId, newStatus) => {
    const sessionIndex = sessions.value.findIndex(s => s.id === sessionId)
    if (sessionIndex !== -1) {
      sessions.value[sessionIndex].status = newStatus
      if (newStatus === 'closed') {
        sessions.value[sessionIndex].closed_at = new Date().toISOString()
      }
    }
  }

  const startPolling = () => {
    if (pollingInterval) return
    pollingInterval = setInterval(async () => {
      await loadDashboard()
      await loadRecentActivity()
    }, 30000) // Poll every 30 seconds
  }

  const stopPolling = () => {
    if (pollingInterval) {
      clearInterval(pollingInterval)
      pollingInterval = null
    }
  }

  const refreshSessions = async () => {
    await loadSessions()
  }

  return {
    stats,
    issues,
    languages,
    sessions,
    counsellors,
    recentActivity,
    loading,
    loadDashboard,
    loadRecentActivity,
    loadIssues,
    loadLanguages,
    loadSessions,
    loadCounsellors,
    updateSessionStatus,
    refreshSessions,
    startPolling,
    stopPolling,
  }
})
