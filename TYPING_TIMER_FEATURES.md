# Typing Indicators & Session Timer Features

## Overview
We've successfully implemented real-time typing indicators and session timers for both the client and counsellor applications.

## Features Implemented

### 1. Typing Indicators ✅

**Backend (Python API)**
- Added `/chat/{session_id}/typing` endpoint to handle typing events
- Created `TypingIndicator` schema with `sender` and `is_typing` fields
- WebSocket broadcasts typing status to other participants in real-time
- Updated `ws_manager.py` to support excluding sender from broadcasts

**Client App (yoneco_app)**
- Shows "Counsellor is typing..." indicator with animated dots
- Sends typing status when client starts/stops typing
- Auto-stops typing indicator after 2 seconds of inactivity
- Typing indicator appears at bottom of message list

**Counsellor App (yoneco_counsellor_app)**
- Shows "Client is typing..." indicator with animated dots
- Sends typing status when counsellor starts/stops typing
- Auto-stops typing indicator after 2 seconds of inactivity
- Typing indicator appears at bottom of message list

**How it Works:**
1. User starts typing → App sends `is_typing: true` to server
2. Server broadcasts typing status to other participant via WebSocket
3. Other participant sees animated typing indicator
4. After 2 seconds of no typing OR message sent → App sends `is_typing: false`
5. Typing indicator disappears

### 2. Session Timer ✅

**Client App**
- Session timer starts when chat screen opens
- Displays duration in MM:SS format in app bar
- Updates every second
- Shows elapsed time of conversation

**Counsellor App**
- Session timer starts when accepting a session
- Displays duration in MM:SS format in app bar
- Updates every second
- Helps counsellor track session length

**Display Location:**
- Timer appears in the app bar, below the issue description
- Format: `00:00` (minutes:seconds)
- Color: White with 70% opacity for subtle appearance

## API Endpoints

### Typing Indicator
```http
POST /chat/{session_id}/typing
Content-Type: application/json

{
  "sender": "client" | "counsellor",
  "is_typing": true | false
}
```

**Response:** `200 OK`

## WebSocket Events

### Typing Event
```json
{
  "type": "typing",
  "sender": "client" | "counsellor",
  "is_typing": true | false
}
```

**Clients should:**
- Display typing indicator when `is_typing: true` from other party
- Hide typing indicator when `is_typing: false` from other party
- Ignore typing events from self (same sender)

## UI Components

### Typing Indicator
- **Design:** Three animated dots in a bubble
- **Colors:** Grey background (#E0E0E0), grey dots
- **Animation:** Pulsing opacity effect (0.3 to 1.0)
- **Position:** Aligned left (like incoming message)
- **Border Radius:** Rounded corners matching message bubbles

### Session Timer
- **Font Size:** 10px
- **Color:** White with 70% opacity
- **Position:** App bar, third line below title
- **Update Frequency:** Every 1 second

## Code Structure

### Client App Files Modified:
1. `lib/screens/chat_screen.dart` - Added typing & timer logic
2. `lib/services/api_service.dart` - Added typing indicator API call

### Counsellor App Files Modified:
1. `lib/screens/chat_screen.dart` - Added typing & timer logic
2. `lib/services/api_service.dart` - Added typing indicator API call

### Backend Files Modified:
1. `python_api/chat.py` - Added typing endpoint
2. `python_api/schemas.py` - Added TypingIndicator schema
3. `python_api/ws_manager.py` - Added exclude parameter to broadcasts

## Benefits

### User Experience
- ✅ Makes chat feel more responsive and alive
- ✅ Reduces uncertainty about whether other person is responding
- ✅ Provides context about conversation flow
- ✅ Professional chat experience similar to WhatsApp/Messenger

### Counsellor Productivity
- ✅ Session timer helps manage time effectively
- ✅ Can track how long they've been with each client
- ✅ Helps with workload management
- ✅ Typing indicators reduce "is client still there?" anxiety

### Technical Benefits
- ✅ Minimal server load (typing events don't persist to database)
- ✅ Real-time via WebSocket (no polling needed)
- ✅ Graceful degradation (failures don't break chat)
- ✅ Clean separation of concerns

## Testing

### To Test Typing Indicators:
1. Open client app and create a session
2. Open counsellor app and accept the session
3. Start typing in client app → Counsellor should see "typing..."
4. Start typing in counsellor app → Client should see "typing..."
5. Send message → Typing indicator should disappear
6. Stop typing for 2 seconds → Typing indicator should disappear

### To Test Session Timer:
1. Open a chat session
2. Observe timer in app bar updates every second
3. Timer should show accurate elapsed time
4. Format should be MM:SS (e.g., 01:30 for 1 minute 30 seconds)

## Future Enhancements (Optional)

### Possible Improvements:
1. **Auto-close inactive sessions** - Close sessions after X minutes of no activity
2. **Session warnings** - Alert counsellor when session exceeds typical duration
3. **Typing timeout** - Auto-stop typing indicator if no message after 10 seconds
4. **Read receipts** - Show when messages are seen by other party
5. **Sound notifications** - Subtle sound when typing indicator appears
6. **Vibration** - Mobile vibration when receiving typing indicator

## Notes
- Typing indicators are NOT stored in database (ephemeral data)
- Failed typing indicator calls are silently ignored (non-critical feature)
- Session timer resets if user leaves and returns to chat
- Timer shows session duration, not total conversation time across multiple sessions

## Status
✅ **COMPLETE AND READY FOR TESTING**

Both features are fully implemented and integrated into the client and counsellor apps. The API is ready to handle the new endpoints, and the UI provides a smooth, professional chat experience.
