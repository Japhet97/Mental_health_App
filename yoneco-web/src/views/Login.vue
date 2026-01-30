<template>
  <div class="min-h-screen flex items-center justify-center bg-gray-100">
    <div class="bg-white p-10 rounded-xl shadow-lg w-full max-w-md">
      <div class="text-center mb-8">
        <h1 class="text-4xl font-bold text-gray-800">Welcome Back</h1>
        <p class="text-gray-500">Please login to continue</p>
      </div>

      <form @submit.prevent="login">
        <div class="mb-6">
          <label for="email" class="block mb-2 text-sm font-medium text-gray-600">Email</label>
          <input
            v-model="email"
            id="email"
            type="email"
            placeholder="you@example.com"
            class="w-full p-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-teal-500"
            required
          />
        </div>

        <div class="mb-6">
          <label for="password" class="block mb-2 text-sm font-medium text-gray-600">Password</label>
          <input
            v-model="password"
            id="password"
            type="password"
            placeholder="••••••••"
            class="w-full p-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-teal-500"
            required
          />
        </div>

        <div v-if="error" class="text-red-500 text-sm mb-4 text-center">{{ error }}</div>

        <div>
          <button
            type="submit"
            class="w-full bg-teal-500 text-white p-3 rounded-lg hover:bg-teal-600 focus:outline-none focus:ring-2 focus:ring-teal-500 font-semibold"
          >
            Login
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref } from "vue";
import axios from "axios";
import { useRouter } from "vue-router";

const router = useRouter();
const email = ref("");
const password = ref("");
const error = ref("");

const login = async () => {
  try {
    const res = await axios.post("http://localhost:8080/auth/login", {
      email: email.value,
      password: password.value,
    });
    localStorage.setItem("token", res.data.access_token);
    router.push("/dashboard");
  } catch (err) {
    error.value = "Invalid credentials";
  }
};
</script>