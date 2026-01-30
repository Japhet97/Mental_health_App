import axios from 'axios';

const API_BASE_URL = 'http://localhost:8080';

export const clientApi = {
  // Get available issues for client selection
  async getIssues() {
    const response = await axios.get(`${API_BASE_URL}/issues`);
    return response.data;
  },

  // Create a new session
  async createSession(sessionData) {
    const response = await axios.post(`${API_BASE_URL}/sessions`, sessionData);
    return response.data;
  },

  // Get session by ID
  async getSession(sessionId) {
    const response = await axios.get(`${API_BASE_URL}/sessions/${sessionId}`);
    return response.data;
  }
};