<template>
  <div class="min-h-screen flex items-center justify-center bg-gradient-to-br from-green-50 to-green-100">
    <div class="max-w-md w-full mx-4">
      <!-- Logo/Header -->
      <div class="text-center mb-8">
        <h1 class="text-4xl font-bold text-green-700 mb-2">YONECO</h1>
        <p class="text-green-600">Admin Dashboard</p>
      </div>

      <!-- Login Card -->
      <div class="bg-white rounded-2xl shadow-xl p-8">
        <h2 class="text-2xl font-semibold text-gray-800 mb-6">Sign In</h2>

        <form @submit.prevent="handleLogin">
          <!-- Email -->
          <div class="mb-4">
            <label class="block text-gray-700 text-sm font-medium mb-2">Email</label>
            <input
              v-model="email"
              type="email"
              required
              class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
              placeholder="admin@yoneco.org"
            />
          </div>

          <!-- Password -->
          <div class="mb-6">
            <label class="block text-gray-700 text-sm font-medium mb-2">Password</label>
            <input
              v-model="password"
              type="password"
              required
              class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
              placeholder="••••••••"
            />
          </div>

          <!-- Error Message -->
          <div v-if="error" class="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg text-red-700 text-sm">
            {{ error }}
          </div>

          <!-- Login Button -->
          <button
            type="submit"
            :disabled="loading"
            class="w-full bg-green-600 hover:bg-green-700 text-white font-semibold py-3 px-4 rounded-lg transition duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <span v-if="loading">Signing in...</span>
            <span v-else>Sign In</span>
          </button>
        </form>
      </div>

      <!-- Footer -->
      <p class="text-center text-gray-600 text-sm mt-6">
        YONECO Mental Health Support System
      </p>
    </div>
  </div>
</template>

<script>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'

export default {
  name: 'AdminLogin',
  setup() {
    const router = useRouter()
    const email = ref('admin@yoneco.org')
    const password = ref('')
    const error = ref('')
    const loading = ref(false)

    const handleLogin = async () => {
      loading.value = true
      error.value = ''

      try {
        const response = await axios.post('http://localhost:8080/admin/login', {
          email: email.value,
          password: password.value
        })

        // Save token and admin info
        localStorage.setItem('adminToken', response.data.access_token)
        localStorage.setItem('adminUser', JSON.stringify(response.data.admin))

        // Redirect to admin dashboard
        router.push('/admin/dashboard')
      } catch (err) {
        error.value = err.response?.data?.detail || 'Login failed. Please try again.'
      } finally {
        loading.value = false
      }
    }

    return {
      email,
      password,
      error,
      loading,
      handleLogin
    }
  }
}
</script>
