<template>
  <div class="space-y-6">
    <div class="flex justify-between items-center">
      <h3 class="text-xl font-bold">Counsellors</h3>
      <button
        @click="showModal = true"
        class="bg-primary hover:bg-primary-dark text-white px-4 py-2 rounded-lg transition flex items-center gap-2"
      >
        <span>+</span> Add Counsellor
      </button>
    </div>

    <div v-if="dashboardStore.loading" class="flex justify-center py-12">
      <div class="spinner"></div>
    </div>

    <div v-else class="bg-white rounded-lg shadow overflow-hidden">
      <table class="w-full">
        <thead class="bg-secondary-light">
          <tr>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">ID</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Name</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Email</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Total Sessions</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Closed</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Active Now</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Completion</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Avg Response</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Actions</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-200">
          <tr v-for="counsellor in dashboardStore.counsellors" :key="counsellor.id" class="hover:bg-gray-50">
            <td class="px-6 py-4">{{ counsellor.id }}</td>
            <td class="px-6 py-4 font-semibold">{{ counsellor.name }}</td>
            <td class="px-6 py-4 text-sm">{{ counsellor.email }}</td>
            <td class="px-6 py-4">
              <span class="px-2 py-1 bg-blue-100 text-blue-800 rounded-full text-sm font-semibold">
                {{ counsellor.sessions_handled }}
              </span>
            </td>
            <td class="px-6 py-4">
              <span class="px-2 py-1 bg-green-100 text-green-800 rounded-full text-sm font-semibold">
                {{ counsellor.closed_sessions }}
              </span>
            </td>
            <td class="px-6 py-4">
              <span class="px-2 py-1 bg-yellow-100 text-yellow-800 rounded-full text-sm font-semibold">
                {{ counsellor.active_sessions }}
              </span>
            </td>
            <td class="px-6 py-4">
              <div class="flex items-center gap-2">
                <div class="w-16 bg-gray-200 rounded-full h-2">
                  <div 
                    class="bg-primary h-2 rounded-full" 
                    :style="{ width: counsellor.completion_rate + '%' }"
                  ></div>
                </div>
                <span class="text-sm font-semibold">{{ counsellor.completion_rate }}%</span>
              </div>
            </td>
            <td class="px-6 py-4">
              <span class="text-sm" :class="getResponseTimeClass(counsellor.avg_response_time_minutes)">
                {{ counsellor.avg_response_time_minutes }}min
              </span>
            </td>
            <td class="px-6 py-4">
              <div class="flex gap-2">
                <button
                  @click="editCounsellor(counsellor)"
                  class="bg-blue-500 hover:bg-blue-600 text-white px-3 py-1 rounded text-sm transition"
                >
                  Edit
                </button>
                <button
                  @click="deleteCounsellor(counsellor.id)"
                  class="bg-danger hover:bg-red-600 text-white px-3 py-1 rounded text-sm transition"
                >
                  Delete
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Add/Edit Counsellor Modal -->
    <div v-if="showModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-md">
        <h3 class="text-xl font-bold mb-4">{{ editingCounsellor ? 'Edit' : 'Add' }} Counsellor</h3>
        
        <form @submit.prevent="handleAddCounsellor" class="space-y-4">
          <div>
            <label class="block text-sm font-medium mb-1">Full Name *</label>
            <input
              v-model="newCounsellor.name"
              required
              class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary"
              placeholder="e.g., Dr. Jane Smith"
            />
          </div>

          <div>
            <label class="block text-sm font-medium mb-1">Email *</label>
            <input
              v-model="newCounsellor.email"
              type="email"
              required
              class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary"
              placeholder="counsellor@tithandizane.org"
            />
          </div>

          <div v-if="!editingCounsellor">
            <label class="block text-sm font-medium mb-1">Password *</label>
            <input
              v-model="newCounsellor.password"
              type="password"
              required
              class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary"
              placeholder="Secure password"
            />
          </div>
          <div v-else>
            <label class="block text-sm font-medium mb-1">New Password (leave blank to keep current)</label>
            <input
              v-model="newCounsellor.password"
              type="password"
              class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary"
              placeholder="New password (optional)"
            />
          </div>

          <div class="flex gap-3 pt-4">
            <button
              type="button"
              @click="showModal = false; resetForm()"
              class="flex-1 bg-gray-300 hover:bg-gray-400 px-4 py-2 rounded-lg transition"
            >
              Cancel
            </button>
            <button
              type="submit"
              :disabled="saving"
              class="flex-1 bg-primary hover:bg-primary-dark text-white px-4 py-2 rounded-lg transition disabled:opacity-50"
            >
              {{ saving ? (editingCounsellor ? 'Updating...' : 'Adding...') : (editingCounsellor ? 'Update Counsellor' : 'Add Counsellor') }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useDashboardStore } from '../stores/dashboard'
import api from '../services/api'
import { handleApiError } from '../utils/errorHandler'

const dashboardStore = useDashboardStore()

const showModal = ref(false)
const saving = ref(false)
const editingCounsellor = ref(null)
const newCounsellor = ref({
  name: '',
  email: '',
  password: '',
})

onMounted(() => {
  dashboardStore.loadCounsellors()
})

const handleAddCounsellor = async () => {
  if (saving.value) return
  
  saving.value = true
  try {
    if (editingCounsellor.value) {
      const updateData = {
        name: newCounsellor.value.name,
        email: newCounsellor.value.email,
      }
      if (newCounsellor.value.password) {
        updateData.password = newCounsellor.value.password
      }
      await api.updateCounsellor(editingCounsellor.value.id, updateData)
      alert('Counsellor updated successfully!')
    } else {
      await api.createCounsellor(newCounsellor.value)
      alert('Counsellor added successfully!')
    }
    showModal.value = false
    resetForm()
    await dashboardStore.loadCounsellors()
  } catch (error) {
    alert(`Failed to ${editingCounsellor.value ? 'update' : 'add'} counsellor: ` + handleApiError(error))
  } finally {
    saving.value = false
  }
}

const editCounsellor = (counsellor) => {
  editingCounsellor.value = counsellor
  newCounsellor.value = {
    name: counsellor.name,
    email: counsellor.email,
    password: '',
  }
  showModal.value = true
}

const resetForm = () => {
  editingCounsellor.value = null
  newCounsellor.value = { name: '', email: '', password: '' }
}

const deleteCounsellor = async (id) => {
  if (!confirm('Are you sure you want to delete this counsellor?')) return
  
  try {
    await api.deleteCounsellor(id)
    await dashboardStore.loadCounsellors()
    alert('Counsellor deleted successfully!')
  } catch (error) {
    alert('Failed to delete counsellor: ' + handleApiError(error))
  }
}

const getResponseTimeClass = (minutes) => {
  if (minutes === 0) return 'text-gray-500'
  if (minutes < 5) return 'text-green-600 font-semibold'
  if (minutes < 15) return 'text-yellow-600 font-semibold'
  return 'text-red-600 font-semibold'
}
</script>
