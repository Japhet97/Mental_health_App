import http from './http';

export const Api = {
  async login(email, password) {
    const { data } = await http.post('/auth/login', { email, password });
    // Expect { access_token, user: { id, name, ... } }
    return data;
  },
  async logout() {
    await http.post('/auth/logout');
  },
  async refresh() {
    const { data } = await http.post('/auth/refresh'); // returns { access_token }
    return data;
  },

  async getActiveChats() {
    const { data } = await http.get('/counsellor/chats');
    // Expect [{ user_id, last_message, unread, last_ts }, ...]
    return data;
  },

  async getMessages(userId, cursor = null) {
    const { data } = await http.get('/chat/messages', { params: { user_id: userId, cursor }});
    // Expect { messages: [{ id, sender, message, ts }], next_cursor: null|string }
    return data;
  },

  async sendMessage(userId, message) {
    const { data } = await http.post('/chat/send', { user_id: userId, sender: 'counsellor', message });
    // Expect { id, ts } or 200 OK
    return data;
  },
};
