import axios from 'axios'

const API_BASE_URL = 'http://localhost:8080'

const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
})

// Request interceptor to add auth token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('adminToken')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// Response interceptor for error handling
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('adminToken')
      localStorage.removeItem('adminUser')
      if (window.location.pathname !== '/login') {
        window.location.href = '/login'
      }
    }
    return Promise.reject(error)
  }
)

export default {
  // Health check
  healthCheck() {
    return api.get('/health')
  },

  // Auth
  login(email, password) {
    return api.post('/admin/login', { email, password })
  },

  // Dashboard
  getDashboard() {
    return api.get('/admin/dashboard')
  },

  getRecentSessions(limit = 10) {
    return api.get(`/admin/sessions/recent?limit=${limit}`)
  },

  // Issues
  getIssues() {
    return api.get('/admin/issues')
  },

  createIssue(data) {
    return api.post('/admin/issues', data)
  },

  updateIssue(id, data) {
    return api.put(`/admin/issues/${id}`, data)
  },

  deleteIssue(id) {
    return api.delete(`/admin/issues/${id}`)
  },

  // Languages
  getLanguages() {
    return api.get('/admin/languages')
  },

  createLanguage(data) {
    return api.post('/admin/languages', data)
  },

  updateLanguage(id, data) {
    return api.put(`/admin/languages/${id}`, data)
  },

  deleteLanguage(id) {
    return api.delete(`/admin/languages/${id}`)
  },

  // Sessions
  getPendingSessions() {
    return api.get('/sessions/pending')
  },

  getActiveSessions() {
    return api.get('/sessions/active')
  },

  getClosedSessions() {
    return api.get('/sessions/closed')
  },

  closeSession(id) {
    return api.post(`/sessions/${id}/close`)
  },

  // Counsellors
  getCounsellors() {
    return api.get('/admin/counsellors/active')
  },

  createCounsellor(data) {
    return api.post('/admin/counsellors', data)
  },

  updateCounsellor(id, data) {
    return api.put(`/admin/counsellors/${id}`, data)
  },

  deleteCounsellor(id) {
    return api.delete(`/admin/counsellors/${id}`)
  },
}
