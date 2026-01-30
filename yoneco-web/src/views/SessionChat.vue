<template>
  <div class="flex flex-col h-screen bg-gray-100">
    <header class="bg-white shadow-md p-4 flex items-center">
      <div class="w-12 h-12 bg-gray-300 rounded-full mr-4"></div>
      <div>
        <h1 class="text-xl font-bold">Session Chat</h1>
        <p class="text-sm text-gray-500">Session ID: #{{ sessionId }}</p>
      </div>
    </header>

    <div class="flex-1 p-6 overflow-y-auto">
      <div v-for="(msg, index) in messages" :key="index" class="flex mb-4" :class="{'justify-end': msg.sender === 'You'}">
        <div class="w-10 h-10 bg-gray-300 rounded-full mr-3" v-if="msg.sender !== 'You'"></div>
        <div class="max-w-xs lg:max-w-md">
          <div class="rounded-lg p-3" :class="msg.sender === 'You' ? 'bg-teal-500 text-white' : 'bg-white'">
            <p class="text-sm">{{ msg.text }}</p>
          </div>
          <p class="text-xs text-gray-500 mt-1" :class="{'text-right': msg.sender === 'You'}">{{ msg.sender }}</p>
        </div>
        <div class="w-10 h-10 bg-gray-300 rounded-full ml-3" v-if="msg.sender === 'You'"></div>
      </div>
    </div>

    <footer class="bg-white p-4">
      <div class="flex items-center">
        <input
          v-model="newMessage"
          @keyup.enter="sendMessage"
          type="text"
          placeholder="Type a message..."
          class="flex-1 p-3 border rounded-full focus:outline-none focus:ring-2 focus:ring-teal-500"
        />
        <button
          @click="sendMessage"
          class="ml-4 px-6 py-3 bg-teal-500 text-white rounded-full hover:bg-teal-600 focus:outline-none focus:ring-2 focus:ring-teal-500"
        >
          Send
        </button>
      </div>
    </footer>
  </div>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'


const props = defineProps({
  sessionId: {
    type: String,
    required: true
  }
})

const ws = ref(null)
const messages = ref([
  { sender: 'Other', text: 'Hey there!' },
  { sender: 'You', text: 'Hi! How are you?' },
  { sender: 'Other', text: 'Doing great, thanks! This new UI is looking good.' },
])
const newMessage = ref('')

const connectWebSocket = () => {
  if (!props.sessionId) {
    return
  }

  ws.value = new WebSocket(`ws://localhost:8080/ws/session/${props.sessionId}`)

  ws.value.onopen = () => {
    // WebSocket connected
  }

  ws.value.onmessage = (event) => {
    try {
      messages.value.push(JSON.parse(event.data))
    } catch (err) {
      // Invalid message data
    }
  }

  ws.value.onerror = (err) => {
    // WebSocket error
  }

  ws.value.onclose = () => {
    // WebSocket closed
  }
}

const sendMessage = () => {
  if (!newMessage.value.trim()) return
  const payload = { sender: 'You', text: newMessage.value }
  ws.value.send(JSON.stringify(payload))
  messages.value.push(payload)
  newMessage.value = ''
}

onMounted(() => {
  connectWebSocket()
})

onBeforeUnmount(() => {
  if (ws.value) ws.value.close()
})
</script>
