import axios from 'axios';
import { useAuthStore } from '@/store/auth';

const http = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
  headers: { 'Content-Type': 'application/json' },
  withCredentials: true, // allow refresh cookie if you use it
});

http.interceptors.request.use((config) => {
  const auth = useAuthStore();
  if (auth.accessToken) {
    config.headers.Authorization = `Bearer ${auth.accessToken}`;
  }
  return config;
});

let refreshing = null;
http.interceptors.response.use(
  (res) => res,
  async (err) => {
    const { response, config } = err;
    if (response?.status === 401 && !config._retry) {
      const auth = useAuthStore();
      if (!refreshing) {
        refreshing = auth.refresh().finally(() => (refreshing = null));
      }
      await refreshing;
      config._retry = true;
      return http(config);
    }
    return Promise.reject(err);
  }
);

export default http;
