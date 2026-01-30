<template>
  <div class="space-y-6">
    <!-- Connection Status -->
    <div v-if="connectionError" class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
      <div class="flex items-center">
        <span class="font-bold">⚠️ Connection Error:</span>
        <span class="ml-2">{{ connectionError }}</span>
      </div>
      <div class="mt-2 text-sm">
        <p>Please ensure the backend API is running:</p>
        <code class="bg-red-200 px-2 py-1 rounded">python -m uvicorn main:app --reload --host 0.0.0.0 --port 8001</code>
      </div>
    </div>

    <div class="flex justify-between items-center">
      <h3 class="text-xl font-bold">Mental Health Issues</h3>
      <button
        @click="showModal = true"
        :disabled="!!connectionError"
        class="bg-primary hover:bg-primary-dark text-white px-4 py-2 rounded-lg transition flex items-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
      >
        <span>+</span> Add Issue
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
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Name (English)</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Name (Chichewa)</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Description</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Actions</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-200">
          <tr v-for="issue in dashboardStore.issues" :key="issue.id" class="hover:bg-gray-50">
            <td class="px-6 py-4">{{ issue.display_number || issue.id }}</td>
            <td class="px-6 py-4">{{ issue.display_number }}. {{ issue.name_en }}</td>
            <td class="px-6 py-4">{{ issue.display_number }}. {{ issue.name_ny }}</td>
            <td class="px-6 py-4 text-sm text-gray-600">{{ issue.description_en }}</td>
            <td class="px-6 py-4">
              <div class="flex gap-2">
                <button
                  @click="editIssue(issue)"
                  class="bg-blue-500 hover:bg-blue-600 text-white px-3 py-1 rounded text-sm transition"
                >
                  Edit
                </button>
                <button
                  @click="deleteIssue(issue.id)"
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

    <!-- Add/Edit Issue Modal -->
    <div v-if="showModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-md">
        <h3 class="text-xl font-bold mb-4">{{ editingIssue ? 'Edit' : 'Add' }} Mental Health Issue</h3>
        
        <form @submit.prevent="handleAddIssue" class="space-y-4">
          <div>
            <label class="block text-sm font-medium mb-1">Name (English) *</label>
            <input
              v-model="newIssue.name_en"
              required
              class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary"
              placeholder="e.g., Depression"
            />
          </div>

          <div>
            <label class="block text-sm font-medium mb-1">Name (Chichewa) *</label>
            <input
              v-model="newIssue.name_ny"
              required
              class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary"
              placeholder="e.g., Kukhumudwa"
            />
          </div>

          <div>
            <label class="block text-sm font-medium mb-1">Description (English)</label>
            <textarea
              v-model="newIssue.description_en"
              rows="2"
              class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary"
              placeholder="Describe the issue"
            ></textarea>
          </div>

          <div>
            <label class="block text-sm font-medium mb-1">Description (Chichewa)</label>
            <textarea
              v-model="newIssue.description_ny"
              rows="2"
              class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary"
              placeholder="Fotokozani vutoli"
            ></textarea>
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
              {{ saving ? (editingIssue ? 'Updating...' : 'Adding...') : (editingIssue ? 'Update Issue' : 'Add Issue') }}
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
const editingIssue = ref(null)
const connectionError = ref(null)
const newIssue = ref({
  name_en: '',
  name_ny: '',
  description_en: '',
  description_ny: '',
})

onMounted(async () => {
  try {
    // Test connection first
    await api.healthCheck()
    connectionError.value = null
    await dashboardStore.loadIssues()
  } catch (error) {
    connectionError.value = handleApiError(error)
  }
})

const handleAddIssue = async () => {
  if (saving.value) return
  
  saving.value = true
  try {
    if (editingIssue.value) {
      await api.updateIssue(editingIssue.value.id, newIssue.value)
      alert('Issue updated successfully!')
    } else {
      await api.createIssue(newIssue.value)
      alert('Issue added successfully!')
    }
    showModal.value = false
    resetForm()
    // Add delay to prevent glitches
    setTimeout(async () => {
      await dashboardStore.loadIssues()
    }, 100)
  } catch (error) {
    const errorMessage = handleApiError(error)
    if (errorMessage.includes('Cannot connect to server') || errorMessage.includes('Network error')) {
      connectionError.value = errorMessage
    }
    alert(`Failed to ${editingIssue.value ? 'update' : 'add'} issue: ` + errorMessage)
  } finally {
    saving.value = false
  }
}

const editIssue = (issue) => {
  editingIssue.value = issue
  newIssue.value = {
    name_en: issue.name_en,
    name_ny: issue.name_ny,
    description_en: issue.description_en || '',
    description_ny: issue.description_ny || '',
  }
  showModal.value = true
}

const resetForm = () => {
  editingIssue.value = null
  newIssue.value = { name_en: '', name_ny: '', description_en: '', description_ny: '' }
}

const deleteIssue = async (id) => {
  if (!confirm('Are you sure you want to delete this issue?')) return
  
  try {
    await api.deleteIssue(id)
    // Add delay to prevent glitches
    setTimeout(async () => {
      await dashboardStore.loadIssues()
    }, 100)
    alert('Issue deleted successfully!')
  } catch (error) {
    alert('Failed to delete issue: ' + handleApiError(error))
  }
}
</script>
