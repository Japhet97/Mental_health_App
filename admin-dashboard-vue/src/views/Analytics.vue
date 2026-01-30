<template>
  <div class="space-y-6">
    <div class="flex justify-between items-center">
      <div>
        <h3 class="text-2xl font-bold text-primary">Analytics & Reports</h3>
        <p class="text-gray-600 mt-1">Visual insights into your helpline performance</p>
      </div>
      <button
        @click="loadData"
        class="bg-primary hover:bg-primary-dark text-white px-4 py-2 rounded-lg transition flex items-center gap-2"
      >
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
        </svg>
        Refresh
      </button>
    </div>

    <!-- Charts Grid -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- Sessions by Issue -->
      <div class="bg-white rounded-2xl shadow-lg p-6">
        <h4 class="text-lg font-semibold mb-4 text-primary flex items-center gap-2">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 3.055A9.001 9.001 0 1020.945 13H11V3.055z" />
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.488 9H15V3.512A9.025 9.025 0 0120.488 9z" />
          </svg>
          Sessions by Issue
        </h4>
        <div class="h-64">
          <canvas ref="issuesChart"></canvas>
        </div>
      </div>

      <!-- Sessions by Language -->
      <div class="bg-white rounded-2xl shadow-lg p-6">
        <h4 class="text-lg font-semibold mb-4 text-primary flex items-center gap-2">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
          </svg>
          Sessions by Language
        </h4>
        <div class="h-64">
          <canvas ref="languagesChart"></canvas>
        </div>
      </div>

      <!-- Sessions Over Time -->
      <div class="bg-white rounded-2xl shadow-lg p-6 lg:col-span-2">
        <h4 class="text-lg font-semibold mb-4 text-primary flex items-center gap-2">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 12l3-3 3 3 4-4M8 21l4-4 4 4M3 4h18M4 4h16v12a1 1 0 01-1 1H5a1 1 0 01-1-1V4z" />
          </svg>
          Sessions Over Last 7 Days
        </h4>
        <div class="h-64">
          <canvas ref="timeChart"></canvas>
        </div>
      </div>

      <!-- Counsellor Performance -->
      <div class="bg-white rounded-2xl shadow-lg p-6 lg:col-span-2">
        <h4 class="text-lg font-semibold mb-4 text-primary flex items-center gap-2">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
          </svg>
          Counsellor Performance
        </h4>
        <div class="h-64">
          <canvas ref="counsellorChart"></canvas>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { Chart, registerables } from 'chart.js'
import api from '../services/api'

Chart.register(...registerables)

const issuesChart = ref(null)
const languagesChart = ref(null)
const timeChart = ref(null)
const counsellorChart = ref(null)

let charts = []

onMounted(async () => {
  await loadData()
})

const loadData = async () => {
  try {
    const response = await api.getDashboard()
    const data = response.data

    // Destroy existing charts
    charts.forEach(chart => chart.destroy())
    charts = []

    // Create charts
    createIssuesChart(data.issues)
    createLanguagesChart(data)
    createTimeChart(data)
    createCounsellorChart(data.counsellors)
  } catch (error) {
    console.error('Failed to load analytics:', error)
  }
}

const createIssuesChart = (issues) => {
  if (!issuesChart.value) return

  const labels = issues.map(i => i.issue || 'Unknown')
  const counts = issues.map(i => i.count)

  const chart = new Chart(issuesChart.value, {
    type: 'doughnut',
    data: {
      labels: labels,
      datasets: [{
        data: counts,
        backgroundColor: [
          '#0A3D0A', '#2ecc71', '#27ae60', '#16a085',
          '#3498db', '#9b59b6', '#e74c3c', '#f39c12'
        ],
        borderWidth: 2,
        borderColor: '#fff'
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          position: 'bottom',
          labels: {
            padding: 15,
            font: { size: 12 }
          }
        }
      }
    }
  })
  charts.push(chart)
}

const createLanguagesChart = (data) => {
  if (!languagesChart.value) return

  const languages = data.languages || []
  const labels = languages.map(l => l.language.toUpperCase())
  const counts = languages.map(l => l.count)
  
  const chart = new Chart(languagesChart.value, {
    type: 'bar',
    data: {
      labels: labels.length > 0 ? labels : ['English', 'Chichewa'],
      datasets: [{
        label: 'Sessions',
        data: counts.length > 0 ? counts : [0, 0],
        backgroundColor: '#2ecc71',
        borderRadius: 8,
        barThickness: 60
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: { display: false }
      },
      scales: {
        y: {
          beginAtZero: true,
          grid: { color: '#f0f0f0' }
        },
        x: { grid: { display: false } }
      }
    }
  })
  charts.push(chart)
}

const createTimeChart = (data) => {
  if (!timeChart.value) return

  const sessionsByDay = data.sessions_by_day || []
  const labels = sessionsByDay.map(d => {
    const date = new Date(d.date)
    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
  })
  const values = sessionsByDay.map(d => d.count)

  const chart = new Chart(timeChart.value, {
    type: 'line',
    data: {
      labels: labels.length > 0 ? labels : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      datasets: [{
        label: 'Sessions',
        data: values.length > 0 ? values : [0, 0, 0, 0, 0, 0, 0],
        borderColor: '#0A3D0A',
        backgroundColor: 'rgba(10, 61, 10, 0.1)',
        tension: 0.4,
        fill: true,
        pointRadius: 4,
        pointBackgroundColor: '#2ecc71',
        pointBorderColor: '#0A3D0A',
        pointBorderWidth: 2
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: { display: false }
      },
      scales: {
        y: {
          beginAtZero: true,
          grid: { color: '#f0f0f0' }
        },
        x: { grid: { display: false } }
      }
    }
  })
  charts.push(chart)
}

const createCounsellorChart = (counsellors) => {
  if (!counsellorChart.value) return

  const names = counsellors.map(c => c.name)
  const sessionCounts = counsellors.map(c => c.sessions_handled || 0)

  const chart = new Chart(counsellorChart.value, {
    type: 'bar',
    data: {
      labels: names,
      datasets: [{
        label: 'Sessions Handled',
        data: sessionCounts,
        backgroundColor: '#3498db',
        borderRadius: 8,
        barThickness: 40
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      indexAxis: 'y',
      plugins: {
        legend: { display: false }
      },
      scales: {
        x: {
          beginAtZero: true,
          grid: { color: '#f0f0f0' }
        },
        y: { grid: { display: false } }
      }
    }
  })
  charts.push(chart)
}
</script>
