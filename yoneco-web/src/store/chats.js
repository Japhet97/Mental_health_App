import { defineStore } from 'pinia';
import { Api } from '@/services/api';
import sanitizeHtml from 'sanitize-html';

export const useChatsStore = defineStore('chats', {
  state: () => ({
    chats: [],             // list of { user_id, last_message, unread, last_ts }
    activeUserId: null,
    messages: {},          // { [userId]: [{ id?, sender, text, ts, pending?, client_msg_id? }] }
    typing: {},            // { [userId]: boolean }
    nextCursor: {},        // { [userId]: string|null }
    loading: false,
  }),
  getters: {
    currentMessages(state) {
      return state.messages[state.activeUserId] || [];
    },
    activeChat(state) {
      return state.chats.find(c => c.user_id === state.activeUserId) || null;
    },
  },
  actions: {
    setActive(userId) {
      this.activeUserId = userId;
      // mark unread as read locally
      const chat = this.chats.find(c => c.user_id === userId);
      if (chat) chat.unread = 0;
    },
    upsertChat(item) {
      const idx = this.chats.findIndex(c => c.user_id === item.user_id);
      if (idx >= 0) this.chats[idx] = { ...this.chats[idx], ...item };
      else this.chats.unshift(item);
      this.chats.sort((a, b) => (b.last_ts || 0) - (a.last_ts || 0));
    },
    pushMessage(userId, msg) {
      if (!this.messages[userId]) this.messages[userId] = [];
      this.messages[userId].push(msg);
    },
    replacePending(userId, clientMsgId, serverMsg) {
      const list = this.messages[userId] || [];
      const idx = list.findIndex(m => m.client_msg_id === clientMsgId);
      if (idx >= 0) {
        list[idx] = { ...serverMsg };
      }
    },

    async loadChats() {
      const res = await Api.getActiveChats();
      this.chats = res || [];
    },

    async loadHistory(userId, cursor = null) {
      this.loading = true;
      const res = await Api.getMessages(userId, cursor);
      const sanitized = (res.messages || []).map(m => ({
        id: m.id,
        sender: m.sender,
        text: sanitizeHtml(String(m.message), { allowedTags: [], allowedAttributes: {} }),
        ts: m.ts,
      }));
      if (!this.messages[userId]) this.messages[userId] = [];
      this.messages[userId] = sanitized.concat(this.messages[userId]);
      this.nextCursor[userId] = res.next_cursor || null;
      this.loading = false;
    },

    receiveSocketMessage(payload) {
      const { user_id, sender, message, ts, id } = payload;
      const clean = sanitizeHtml(String(message), { allowedTags: [], allowedAttributes: {} });
      this.pushMessage(user_id, { id, sender, text: clean, ts });
      this.upsertChat({ user_id, last_message: clean, last_ts: ts, unread: this.activeUserId === user_id ? 0 : 1 });
    },

    setTyping(userId, isTyping) {
      this.typing[userId] = !!isTyping;
    },
  },
});
