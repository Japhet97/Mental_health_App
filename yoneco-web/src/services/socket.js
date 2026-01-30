import { io } from 'socket.io-client';
import { useAuthStore } from '@/store/auth';

let socket = null;

export function useSocket() {
  const auth = useAuthStore();

  function connect() {
    if (socket?.connected) return socket;
    socket = io(import.meta.env.VITE_WS_URL, {
      autoConnect: false,
      transports: ['websocket'],
      auth: (cb) => cb({ token: auth.accessToken }),
      reconnection: true,
      reconnectionAttempts: Infinity,
      reconnectionDelay: 500,
      reconnectionDelayMax: 5000,
      timeout: 20000,
    });

    socket.connect();
    return socket;
  }

  function joinRoom(userId) {
    socket?.emit('chat:join', { user_id: userId });
  }
  function leaveRoom(userId) {
    socket?.emit('chat:leave', { user_id: userId });
  }
  function sendMessage(userId, message, clientMsgId) {
    socket?.emit('message:send', { user_id: userId, sender: 'counsellor', message, client_msg_id: clientMsgId });
  }
  function typing(userId, isTyping) {
    socket?.emit('typing', { user_id: userId, typing: isTyping });
  }

  return { connect, socket: () => socket, joinRoom, leaveRoom, sendMessage, typing };
}
