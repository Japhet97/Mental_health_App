<template>
  <div class="bg-gray-100 min-h-screen">
    <header class="bg-white shadow-md">
      <div class="container mx-auto px-6 py-4">
        <h1 class="text-3xl font-bold text-gray-800">Dashboard</h1>
      </div>
    </header>

    <main class="container mx-auto px-6 py-8">
      <div class="bg-white p-6 rounded-lg shadow-lg">
        <h2 class="text-2xl font-semibold text-gray-700 mb-6">Active Sessions</h2>
        <div v-if="sessions.length === 0" class="text-gray-500">
          No active sessions at the moment.
        </div>
        <ul v-else class="space-y-4">
          <li v-for="session in sessions" :key="session.id" class="flex justify-between items-center p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors duration-200">
            <div>
              <p class="font-semibold text-gray-800">Session #{{ session.id }}</p>
              <p class="text-sm text-gray-600">Client: {{ session.client_name }}</p>
            </div>
            <router-link :to="`/chat/${session.id}`" class="px-6 py-2 bg-teal-500 text-white font-semibold rounded-full hover:bg-teal-600 focus:outline-none focus:ring-2 focus:ring-teal-500 transition-transform transform hover:scale-105">
              Join Session
            </router-link>
          </li>
        </ul>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'

const sessions = ref([])

onMounted(async () => {
  try {
    const { data } = await axios.get('http://localhost:8080/sessions/active')
    sessions.value = data
  } catch (err) {
    console.error('Failed to load active sessions:', err)
  }
})
</script>

<style scoped>
/* Scoped styles can go here if needed, but Tailwind is preferred */
</style>