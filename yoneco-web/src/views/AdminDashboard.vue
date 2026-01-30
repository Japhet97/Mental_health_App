<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <nav class="bg-white shadow-sm border-b border-gray-200">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center h-16">
          <div class="flex items-center">
            <h1 class="text-2xl font-bold text-green-700">YONECO Admin</h1>
          </div>
          <div class="flex items-center space-x-4">
            <span class="text-gray-700">{{ adminUser?.name }}</span>
            <button
              @click="handleLogout"
              class="px-4 py-2 bg-red-500 hover:bg-red-600 text-white rounded-lg transition"
            >
              Logout
            </button>
          </div>
        </div>
      </div>
    </nav>

    <!-- Main Content -->
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <!-- Tabs -->
      <div class="mb-6">
        <div class="border-b border-gray-200">
          <nav class="-mb-px flex space-x-8">
            <button
              v-for="tab in tabs"
              :key="tab.id"
              @click="activeTab = tab.id"
              :class="[
                activeTab === tab.id
                  ? 'border-green-500 text-green-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300',
                'whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm'
              ]"
            >
              {{ tab.name }}
            </button>
          </nav>
        </div>
      </div>

      <!-- Dashboard Tab -->
      <div v-if="activeTab === 'dashboard'" class="space-y-6">
        <!-- Stats Grid -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <div v-for="stat in stats" :key="stat.label" class="bg-white rounded-xl shadow-sm p-6 border border-gray-200">
            <div class="flex items-center justify-between">
              <div>
                <p class="text-sm font-medium text-gray-600">{{ stat.label }}</p>
                <p class="text-3xl font-bold text-gray-900 mt-2">{{ stat.value }}</p>
              </div>
              <div :class="[stat.color, 'p-3 rounded-full']">
                <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="stat.icon" />
                </svg>
              </div>
            </div>
          </div>
        </div>

        <!-- Charts Row -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <!-- Issue Breakdown -->
          <div class="bg-white rounded-xl shadow-sm p-6 border border-gray-200">
            <h3 class="text-lg font-semibold text-gray-900 mb-4">Issues Breakdown</h3>
            <div class="space-y-3">
              <div v-for="issue in dashboardData?.issues || []" :key="issue.issue" class="flex items-center justify-between">
                <span class="text-sm text-gray-600">{{ issue.issue }}</span>
                <div class="flex items-center">
                  <div class="w-32 bg-gray-200 rounded-full h-2 mr-3">
                    <div
                      class="bg-green-600 h-2 rounded-full"
                      :style="{ width: `${(issue.count / getTotalIssues()) * 100}%` }"
                    ></div>
                  </div>
                  <span class="text-sm font-semibold text-gray-900 w-8">{{ issue.count }}</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Counsellor Performance -->
          <div class="bg-white rounded-xl shadow-sm p-6 border border-gray-200">
            <h3 class="text-lg font-semibold text-gray-900 mb-4">Counsellor Performance</h3>
            <div class="space-y-3">
              <div v-for="counsellor in dashboardData?.counsellors || []" :key="counsellor.name" class="flex items-center justify-between">
                <span class="text-sm text-gray-600">{{ counsellor.name }}</span>
                <span class="text-sm font-semibold text-gray-900">{{ counsellor.sessions_handled }} sessions</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Recent Sessions -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-200">
          <div class="px-6 py-4 border-b border-gray-200">
            <h3 class="text-lg font-semibold text-gray-900">Recent Sessions</h3>
          </div>
          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Client</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Issue</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Created</th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <tr v-for="session in recentSessions" :key="session.id">
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{{ session.id }}</td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{{ session.client_name || 'Anonymous' }}</td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">{{ session.issue }}</td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <span :class="getStatusBadge(session.status)">
                      {{ session.status }}
                    </span>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">{{ formatDate(session.created_at) }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Issues Tab -->
      <div v-if="activeTab === 'issues'" class="space-y-6">
        <div class="bg-white rounded-xl shadow-sm border border-gray-200">
          <div class="px-6 py-4 border-b border-gray-200 flex justify-between items-center">
            <h3 class="text-lg font-semibold text-gray-900">Mental Health Issues</h3>
            <button
              @click="showAddIssueModal = true"
              class="px-4 py-2 bg-green-600 hover:bg-green-700 text-white rounded-lg transition"
            >
              + Add Issue
            </button>
          </div>
          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">English</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Chichewa</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <tr v-for="issue in issues" :key="issue.id">
                  <td class="px-6 py-4 text-sm text-gray-900">
                    <div class="font-medium">{{ issue.name_en }}</div>
                    <div class="text-gray-500 text-xs">{{ issue.description_en }}</div>
                  </td>
                  <td class="px-6 py-4 text-sm text-gray-900">
                    <div class="font-medium">{{ issue.name_ny }}</div>
                    <div class="text-gray-500 text-xs">{{ issue.description_ny }}</div>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <span :class="issue.is_active ? 'px-2 py-1 text-xs rounded-full bg-green-100 text-green-800' : 'px-2 py-1 text-xs rounded-full bg-gray-100 text-gray-800'">
                      {{ issue.is_active ? 'Active' : 'Inactive' }}
                    </span>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm space-x-2">
                    <button
                      @click="editIssue(issue)"
                      class="text-blue-600 hover:text-blue-800"
                    >
                      Edit
                    </button>
                    <button
                      @click="deleteIssue(issue.id)"
                      class="text-red-600 hover:text-red-800"
                    >
                      Delete
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Languages Tab -->
      <div v-if="activeTab === 'languages'" class="space-y-6">
        <div class="bg-white rounded-xl shadow-sm border border-gray-200">
          <div class="px-6 py-4 border-b border-gray-200 flex justify-between items-center">
            <h3 class="text-lg font-semibold text-gray-900">Languages</h3>
            <button
              @click="showAddLanguageModal = true"
              class="px-4 py-2 bg-green-600 hover:bg-green-700 text-white rounded-lg transition"
            >
              + Add Language
            </button>
          </div>
          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Code</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Name</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <tr v-for="lang in languages" :key="lang.id">
                  <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{{ lang.code }}</td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{{ lang.name }}</td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <span :class="lang.is_active ? 'px-2 py-1 text-xs rounded-full bg-green-100 text-green-800' : 'px-2 py-1 text-xs rounded-full bg-gray-100 text-gray-800'">
                      {{ lang.is_active ? 'Active' : 'Inactive' }}
                    </span>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm">
                    <button
                      @click="deleteLanguage(lang.id)"
                      class="text-red-600 hover:text-red-800"
                    >
                      Delete
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Counsellors Tab -->
      <div v-if="activeTab === 'counsellors'" class="space-y-6">
        <div class="bg-white rounded-xl shadow-sm border border-gray-200">
          <div class="px-6 py-4 border-b border-gray-200">
            <h3 class="text-lg font-semibold text-gray-900">Counsellors</h3>
          </div>
          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Name</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Email</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Active Sessions</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Total Sessions</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <tr v-for="counsellor in counsellors" :key="counsellor.id">
                  <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{{ counsellor.name }}</td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">{{ counsellor.email }}</td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{{ counsellor.active_sessions }}</td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{{ counsellor.total_sessions }}</td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <span :class="counsellor.is_active ? 'px-2 py-1 text-xs rounded-full bg-green-100 text-green-800' : 'px-2 py-1 text-xs rounded-full bg-gray-100 text-gray-800'">
                      {{ counsellor.is_active ? 'Active' : 'Inactive' }}
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- Add Issue Modal -->
    <div v-if="showAddIssueModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-xl shadow-xl max-w-2xl w-full mx-4 p-6">
        <h3 class="text-xl font-semibold mb-4">{{ editingIssue ? 'Edit Issue' : 'Add New Issue' }}</h3>
        <form @submit.prevent="saveIssue">
          <div class="grid grid-cols-2 gap-4 mb-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">English Name</label>
              <input
                v-model="issueForm.name_en"
                type="text"
                required
                class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
              />
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Chichewa Name</label>
              <input
                v-model="issueForm.name_ny"
                type="text"
                required
                class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
              />
            </div>
          </div>
          <div class="grid grid-cols-2 gap-4 mb-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">English Description</label>
              <textarea
                v-model="issueForm.description_en"
                rows="3"
                class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
              ></textarea>
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Chichewa Description</label>
              <textarea
                v-model="issueForm.description_ny"
                rows="3"
                class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
              ></textarea>
            </div>
          </div>
          <div class="flex justify-end space-x-3">
            <button
              type="button"
              @click="cancelIssueForm"
              class="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50"
            >
              Cancel
            </button>
            <button
              type="submit"
              class="px-4 py-2 bg-green-600 hover:bg-green-700 text-white rounded-lg"
            >
              {{ editingIssue ? 'Update' : 'Create' }}
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Add Language Modal -->
    <div v-if="showAddLanguageModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-xl shadow-xl max-w-md w-full mx-4 p-6">
        <h3 class="text-xl font-semibold mb-4">Add New Language</h3>
        <form @submit.prevent="saveLanguage">
          <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-1">Language Code</label>
            <input
              v-model="languageForm.code"
              type="text"
              required
              maxlength="5"
              placeholder="e.g., en, ny, fr"
              class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
            />
          </div>
          <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-1">Language Name</label>
            <input
              v-model="languageForm.name"
              type="text"
              required
              placeholder="e.g., English, Chichewa"
              class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
            />
          </div>
          <div class="flex justify-end space-x-3">
            <button
              type="button"
              @click="showAddLanguageModal = false"
              class="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50"
            >
              Cancel
            </button>
            <button
              type="submit"
              class="px-4 py-2 bg-green-600 hover:bg-green-700 text-white rounded-lg"
            >
              Create
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'

export default {
  name: 'AdminDashboard',
  setup() {
    const router = useRouter()
    const activeTab = ref('dashboard')
    const adminUser = ref(null)
    
    // Data
    const dashboardData = ref(null)
    const recentSessions = ref([])
    const issues = ref([])
    const languages = ref([])
    const counsellors = ref([])
    
    // Modals
    const showAddIssueModal = ref(false)
    const showAddLanguageModal = ref(false)
    const editingIssue = ref(null)
    
    // Forms
    const issueForm = ref({
      name_en: '',
      name_ny: '',
      description_en: '',
      description_ny: ''
    })
    
    const languageForm = ref({
      code: '',
      name: ''
    })

    const tabs = [
      { id: 'dashboard', name: 'Dashboard' },
      { id: 'issues', name: 'Issues' },
      { id: 'languages', name: 'Languages' },
      { id: 'counsellors', name: 'Counsellors' }
    ]

    const stats = computed(() => {
      if (!dashboardData.value) return []
      
      return [
        {
          label: 'Total Sessions',
          value: dashboardData.value.overview.total_sessions,
          icon: 'M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z',
          color: 'bg-blue-500'
        },
        {
          label: 'Active Sessions',
          value: dashboardData.value.overview.active_sessions,
          icon: 'M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z',
          color: 'bg-green-500'
        },
        {
          label: 'Pending Sessions',
          value: dashboardData.value.overview.pending_sessions,
          icon: 'M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z',
          color: 'bg-yellow-500'
        },
        {
          label: 'Total Counsellors',
          value: dashboardData.value.overview.total_counsellors,
          icon: 'M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z',
          color: 'bg-purple-500'
        }
      ]
    })

    const getTotalIssues = () => {
      if (!dashboardData.value?.issues) return 1
      return dashboardData.value.issues.reduce((sum, issue) => sum + issue.count, 0)
    }

    const getStatusBadge = (status) => {
      const badges = {
        pending: 'px-2 py-1 text-xs rounded-full bg-yellow-100 text-yellow-800',
        active: 'px-2 py-1 text-xs rounded-full bg-green-100 text-green-800',
        closed: 'px-2 py-1 text-xs rounded-full bg-gray-100 text-gray-800'
      }
      return badges[status] || badges.pending
    }

    const formatDate = (dateStr) => {
      const date = new Date(dateStr)
      return date.toLocaleString()
    }

    const getAuthHeaders = () => {
      const token = localStorage.getItem('adminToken')
      return {
        headers: {
          Authorization: `Bearer ${token}`
        }
      }
    }

    const loadDashboardData = async () => {
      try {
        const response = await axios.get('http://localhost:8080/admin/dashboard', getAuthHeaders())
        dashboardData.value = response.data
      } catch (error) {
        console.error('Failed to load dashboard data:', error)
        if (error.response?.status === 401) {
          router.push('/admin/login')
        }
      }
    }

    const loadRecentSessions = async () => {
      try {
        const response = await axios.get('http://localhost:8080/admin/sessions/recent', getAuthHeaders())
        recentSessions.value = response.data.sessions
      } catch (error) {
        console.error('Failed to load recent sessions:', error)
      }
    }

    const loadIssues = async () => {
      try {
        const response = await axios.get('http://localhost:8080/admin/issues', getAuthHeaders())
        issues.value = response.data.issues
      } catch (error) {
        console.error('Failed to load issues:', error)
      }
    }

    const loadLanguages = async () => {
      try {
        const response = await axios.get('http://localhost:8080/admin/languages', getAuthHeaders())
        languages.value = response.data.languages
      } catch (error) {
        console.error('Failed to load languages:', error)
      }
    }

    const loadCounsellors = async () => {
      try {
        const response = await axios.get('http://localhost:8080/admin/counsellors/active', getAuthHeaders())
        counsellors.value = response.data.counsellors
      } catch (error) {
        console.error('Failed to load counsellors:', error)
      }
    }

    const saveIssue = async () => {
      try {
        if (editingIssue.value) {
          await axios.put(
            `http://localhost:8080/admin/issues/${editingIssue.value.id}`,
            issueForm.value,
            getAuthHeaders()
          )
        } else {
          await axios.post('http://localhost:8080/admin/issues', issueForm.value, getAuthHeaders())
        }
        cancelIssueForm()
        loadIssues()
      } catch (error) {
        console.error('Failed to save issue:', error)
        alert('Failed to save issue')
      }
    }

    const editIssue = (issue) => {
      editingIssue.value = issue
      issueForm.value = {
        name_en: issue.name_en,
        name_ny: issue.name_ny,
        description_en: issue.description_en || '',
        description_ny: issue.description_ny || ''
      }
      showAddIssueModal.value = true
    }

    const cancelIssueForm = () => {
      showAddIssueModal.value = false
      editingIssue.value = null
      issueForm.value = {
        name_en: '',
        name_ny: '',
        description_en: '',
        description_ny: ''
      }
    }

    const deleteIssue = async (id) => {
      if (!confirm('Are you sure you want to delete this issue?')) return
      
      try {
        await axios.delete(`http://localhost:8080/admin/issues/${id}`, getAuthHeaders())
        loadIssues()
      } catch (error) {
        console.error('Failed to delete issue:', error)
        alert('Failed to delete issue')
      }
    }

    const saveLanguage = async () => {
      try {
        await axios.post('http://localhost:8080/admin/languages', languageForm.value, getAuthHeaders())
        showAddLanguageModal.value = false
        languageForm.value = { code: '', name: '' }
        loadLanguages()
      } catch (error) {
        console.error('Failed to save language:', error)
        alert(error.response?.data?.detail || 'Failed to save language')
      }
    }

    const deleteLanguage = async (id) => {
      if (!confirm('Are you sure you want to delete this language?')) return
      
      try {
        await axios.delete(`http://localhost:8080/admin/languages/${id}`, getAuthHeaders())
        loadLanguages()
      } catch (error) {
        console.error('Failed to delete language:', error)
        alert('Failed to delete language')
      }
    }

    const handleLogout = () => {
      localStorage.removeItem('adminToken')
      localStorage.removeItem('adminUser')
      router.push('/admin/login')
    }

    onMounted(() => {
      // Check if logged in
      const token = localStorage.getItem('adminToken')
      const user = localStorage.getItem('adminUser')
      
      if (!token || !user) {
        router.push('/admin/login')
        return
      }
      
      adminUser.value = JSON.parse(user)
      
      // Load data
      loadDashboardData()
      loadRecentSessions()
      loadIssues()
      loadLanguages()
      loadCounsellors()
      
      // Refresh dashboard every 30 seconds
      setInterval(() => {
        if (activeTab.value === 'dashboard') {
          loadDashboardData()
          loadRecentSessions()
        }
      }, 30000)
    })

    return {
      activeTab,
      tabs,
      adminUser,
      dashboardData,
      recentSessions,
      issues,
      languages,
      counsellors,
      stats,
      showAddIssueModal,
      showAddLanguageModal,
      editingIssue,
      issueForm,
      languageForm,
      getTotalIssues,
      getStatusBadge,
      formatDate,
      saveIssue,
      editIssue,
      cancelIssueForm,
      deleteIssue,
      saveLanguage,
      deleteLanguage,
      handleLogout
    }
  }
}
</script>
