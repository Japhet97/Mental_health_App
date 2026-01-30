import { defineStore } from 'pinia'
import { ref } from 'vue'
import api from '../services/api'

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null)
  const token = ref(null)
  const isAuthenticated = ref(false)

  // Initialize from localStorage
  const init = () => {
    const storedToken = localStorage.getItem('adminToken')
    const storedUser = localStorage.getItem('adminUser')
    
    if (storedToken && storedUser) {
      token.value = storedToken
      user.value = JSON.parse(storedUser)
      isAuthenticated.value = true
    }
  }

  const login = async (email, password) => {
    try {
      const response = await api.login(email, password)
      const { access_token, user: userData } = response.data
      
      token.value = access_token
      user.value = userData
      isAuthenticated.value = true
      
      localStorage.setItem('adminToken', access_token)
      localStorage.setItem('adminUser', JSON.stringify(userData))
      
      return true
    } catch (error) {
      console.error('Login failed:', error)
      throw error
    }
  }

  const logout = () => {
    token.value = null
    user.value = null
    isAuthenticated.value = false
    
    localStorage.removeItem('adminToken')
    localStorage.removeItem('adminUser')
  }

  init()

  return {
    user,
    token,
    isAuthenticated,
    login,
    logout,
  }
})
