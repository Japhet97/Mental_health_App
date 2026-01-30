<template>
  <div class="space-y-6">
    <div class="flex justify-between items-center">
      <h3 class="text-xl font-bold">Supported Languages</h3>
      <button
        @click="showModal = true"
        class="bg-primary hover:bg-primary-dark text-white px-4 py-2 rounded-lg transition flex items-center gap-2"
      >
        <span>+</span> Add Language
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
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Code</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Name</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Native Name</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Status</th>
            <th class="px-6 py-3 text-left text-sm font-semibold text-primary">Actions</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-200">
          <tr v-for="lang in dashboardStore.languages" :key="lang.id" class="hover:bg-gray-50">
            <td class="px-6 py-4">{{ lang.id }}</td>
            <td class="px-6 py-4 font-mono">{{ lang.code }}</td>
            <td class="px-6 py-4">{{ lang.name_en }}</td>
            <td class="px-6 py-4">{{ lang.native_name }}</td>
            <td class="px-6 py-4">
              <span class="px-2 py-1 text-xs rounded-full bg-green-100 text-green-800">Active</span>
            </td>
            <td class="px-6 py-4">
              <div class="flex gap-2">
                <button
                  @click="editLanguage(lang)"
                  class="bg-blue-500 hover:bg-blue-600 text-white px-3 py-1 rounded text-sm transition"
                >
                  Edit
                </button>
                <button
                  @click="deleteLanguage(lang.id)"
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

    <!-- Add/Edit Language Modal -->
    <div v-if="showModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
      <div class="bg-white rounded-lg p-6 w-full max-w-md">
        <h3 class="text-xl font-bold mb-4">{{ editingLanguage ? 'Edit' : 'Add' }} Language</h3>
        
        <form @submit.prevent="handleAddLanguage" class="space-y-4">
          <div>
            <label class="block text-sm font-medium mb-1">Language Code *</label>
            <input
              v-model="newLanguage.code"
              required
              maxlength="5"
              class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary"
              placeholder="e.g., en, ny"
            />
          </div>

          <div>
            <label class="block text-sm font-medium mb-1">Name (English) *</label>
            <input
              v-model="newLanguage.name_en"
              required
              class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary"
              placeholder="e.g., English"
            />
          </div>

          <div>
            <label class="block text-sm font-medium mb-1">Native Name *</label>
            <input
              v-model="newLanguage.native_name"
              required
              class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-primary"
              placeholder="e.g., Chichewa"
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
              {{ saving ? (editingLanguage ? 'Updating...' : 'Adding...') : (editingLanguage ? 'Update Language' : 'Add Language') }}
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
const editingLanguage = ref(null)
const newLanguage = ref({
  code: '',
  name_en: '',
  native_name: '',
})

onMounted(() => {
  dashboardStore.loadLanguages()
})

const handleAddLanguage = async () => {
  if (saving.value) return
  
  saving.value = true
  try {
    if (editingLanguage.value) {
      await api.updateLanguage(editingLanguage.value.id, newLanguage.value)
      alert('Language updated successfully!')
    } else {
      await api.createLanguage(newLanguage.value)
      alert('Language added successfully!')
    }
    showModal.value = false
    resetForm()
    await dashboardStore.loadLanguages()
  } catch (error) {
    alert(`Failed to ${editingLanguage.value ? 'update' : 'add'} language: ` + handleApiError(error))
  } finally {
    saving.value = false
  }
}

const editLanguage = (language) => {
  editingLanguage.value = language
  newLanguage.value = {
    code: language.code,
    name_en: language.name_en,
    native_name: language.native_name,
  }
  showModal.value = true
}

const resetForm = () => {
  editingLanguage.value = null
  newLanguage.value = { code: '', name_en: '', native_name: '' }
}

const deleteLanguage = async (id) => {
  if (!confirm('Are you sure you want to delete this language?')) return
  
  try {
    await api.deleteLanguage(id)
    await dashboardStore.loadLanguages()
    alert('Language deleted successfully!')
  } catch (error) {
    alert('Failed to delete language: ' + handleApiError(error))
  }
}
</script>
