<template>
  <router-link
    v-if="to"
    :to="to"
    class="block bg-white/80 backdrop-blur-sm rounded-xl shadow-lg p-6 hover:shadow-xl hover:scale-105 transition-all duration-200 border border-white/50 cursor-pointer"
  >
    <div class="flex items-center justify-between">
      <div class="flex-1">
        <p class="text-gray-700 text-lg font-medium mb-2">{{ title }}</p>
        <p class="text-4xl font-bold" :class="color">{{ value }}</p>
      </div>
      <div class="text-5xl" :class="getIconColor(title)">{{ icon }}</div>
    </div>
  </router-link>
  <div
    v-else
    class="bg-white/80 backdrop-blur-sm rounded-xl shadow-lg p-6 hover:shadow-xl hover:scale-105 transition-all duration-200 border border-white/50"
  >
    <div class="flex items-center justify-between">
      <div class="flex-1">
        <p class="text-gray-700 text-lg font-medium mb-2">{{ title }}</p>
        <p class="text-4xl font-bold" :class="color">{{ value }}</p>
      </div>
      <div class="text-5xl" :class="getIconColor(title)">{{ icon }}</div>
    </div>
  </div>
</template>

<script setup>
defineProps({
  title: String,
  value: [String, Number],
  icon: String,
  color: {
    type: String,
    default: 'text-primary'
  },
  to: {
    type: String,
    default: null
  }
})

const getIconColor = (title) => {
  const colors = {
    'Total Sessions': 'text-blue-500 drop-shadow-lg',
    'Active Sessions': 'text-green-500 drop-shadow-lg',
    'Pending Sessions': 'text-orange-500 drop-shadow-lg',
    'Counsellors': 'text-purple-500 drop-shadow-lg',
  }
  return colors[title] || 'text-gray-400'
}


</script>
