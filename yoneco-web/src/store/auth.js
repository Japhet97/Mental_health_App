import { defineStore } from 'pinia';
import { Api } from '@/services/api';

export const useAuthStore = defineStore('auth', {
  state: () => ({
    accessToken: null,
    user: null,
    loading: false,
    error: null,
  }),
  getters: {
    isAuthenticated: (s) => !!s.accessToken,
  },
  actions: {
    async login(email, password) {
      this.loading = true; this.error = null;
      try {
        const data = await Api.login(email, password);
        this.accessToken = data.access_token;
        this.user = data.user;
      } catch (e) {
        this.error = 'Invalid credentials';
        throw e;
      } finally {
        this.loading = false;
      }
    },
    async logout() {
      try { await Api.logout(); } catch {}
      this.$reset();
    },
    async refresh() {
      const data = await Api.refresh();
      this.accessToken = data.access_token;
    },
  },
});
