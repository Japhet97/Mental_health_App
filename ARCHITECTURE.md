# YONECO System Architecture

## System Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                         YONECO PLATFORM                             │
│                      Mental Health Support System                   │
└─────────────────────────────────────────────────────────────────────┘

┌───────────────────┐         ┌───────────────────┐         ┌──────────────────┐
│                   │         │                   │         │                  │
│   CLIENT APP      │◄───────►│   BACKEND API     │◄───────►│  COUNSELLOR APP  │
│   (Flutter)       │  HTTP/  │   (FastAPI)       │  HTTP/  │   (Flutter)      │
│                   │  WS     │                   │  WS     │                  │
└───────────────────┘         └───────────────────┘         └──────────────────┘
         │                              │                            │
         │                              ▼                            │
         │                    ┌──────────────────┐                  │
         │                    │                  │                  │
         └───────────────────►│   DATABASE       │◄─────────────────┘
                              │   (SQLite/       │
                              │   PostgreSQL)    │
                              └──────────────────┘
```

## Detailed Flow Diagram

```
CLIENT JOURNEY                    API PROCESSING                 COUNSELLOR JOURNEY
═══════════════                   ══════════════                 ══════════════════

1. Open App                                                      1. Login
   ↓                                                                ↓
2. Select Issue                                                  2. Dashboard
   (Depression)                                                     (Wait for clients)
   ↓                                                                ↓
3. Chat with Bot                                                 3. See pending list
   (Optional)                   ┌─────────────────┐                 (Real-time updates)
   ↓                           │  WebSocket       │                 ↓
4. Click "Talk to             │  Notification    │              4. Session appears
   Counsellor"                │  System          │                 with issue info
   ↓                           └────────┬────────┘                 ↓
5. Enter Name                          │                        5. Click "Accept"
   ↓                                    │                           ↓
6. Session Created ──────POST /sessions/create                  6. Session assigned
   ↓                          │                                     ↓
   │                          ├─► DB: INSERT session           7. Navigate to chat
   │                          │   (status: pending)               ↓
   │                          │                                    │
   │                          ├─► Broadcast to                    │
   │                          │   counsellors ──────────────────► │
   │                          │   via WebSocket                   │
   ↓                          ▼                                    ▼
7. Chat Screen            Session created                     8. Chat Screen
   (Waiting...)           in database                            (Active)
   ↓                          │                                    ↓
   │                          │                                    │
   │ ◄────────────────────────┴──────POST /sessions/1/accept───── │
   │                          │                                    │
   │                          ├─► DB: UPDATE session              │
   │                          │   (status: active)                │
   │                          │   (counsellor_id: 1)              │
   ↓                          ▼                                    ↓
8. Counsellor Joined!    Broadcast to                         9. Start chatting
   ↓                     session room                             ↓
   │                          │                                    │
   │ ◄────────────────────────┼────────────────────────────────► │
   │         Real-time Chat via WebSocket                         │
   │                          │                                    │
   │ ──POST /chat/1/send─────►│                                   │
   │  {sender: client,        ├─► DB: INSERT message              │
   │   content: "Hello"}      │                                    │
   │                          ├─► Broadcast to room──────────────►│
   │                          │                                    │
   │◄─────────────────────────┤                                   │
   │  WebSocket: message      │                                   │
   │  received                │                                   │
   ↓                          ▼                                    ↓
   Continue chatting...    Messages stored                    Continue chatting...
                          and broadcast
```

## Database Schema Relationships

```
┌─────────────────────────┐
│     COUNSELLORS         │
├─────────────────────────┤
│ id (PK)                 │
│ email                   │
│ name                    │
│ password_hash           │
│ is_active               │
│ created_at              │
└───────────┬─────────────┘
            │
            │ 1:N relationship
            │ (one counsellor, many sessions)
            ▼
┌─────────────────────────┐
│      SESSIONS           │
├─────────────────────────┤
│ id (PK)                 │
│ client_name             │
│ issue                   │◄─── Selected from issues screen
│ status                  │◄─── pending → active → closed
│ counsellor_id (FK)      │◄─── Links to counsellors table
│ created_at              │
└───────────┬─────────────┘
            │
            │ 1:N relationship
            │ (one session, many messages)
            ▼
┌─────────────────────────┐
│      MESSAGES           │
├─────────────────────────┤
│ id (PK)                 │
│ session_id (FK)         │
│ sender                  │◄─── 'client' or 'counsellor'
│ content                 │
│ timestamp               │
└─────────────────────────┘
```

## WebSocket Connection Flow

```
CLIENT                         API SERVER                      COUNSELLOR
══════                         ══════════                      ══════════

                    ┌─────────────────────┐
                    │  Connection         │
                    │  Manager            │
                    ├─────────────────────┤
                    │ counselors: Set[]   │
                    │ rooms: Dict{        │
                    │   session_id: Set[] │
                    │ }                   │
                    └──────────┬──────────┘
                               │
                               │
1. Connect to             2. Store           3. Connect to
   ws://...                  connection          ws://counselors
   /session/1                                    ↓
   ↓                          ↓                  │
   │                          │                  │
ws.connect() ────────────────►│◄─────────────── ws.connect()
   │                     rooms[1].add(ws)        │
   │                     counselors.add(ws)      │
   │                          │                  │
   │                          │                  │
4. Send message          5. Process &       6. Receive via
   "Hello"                  broadcast          WebSocket
   ↓                          ↓                  ↓
   │                          │                  │
POST /chat/1/send ───────────►│                  │
   │                    DB: save message         │
   │                          │                  │
   │                    For ws in rooms[1]:      │
   │                      ws.send(message) ──────┼─► Message displayed
   │                          │                  │
   │◄─────────────────────────┘                  │
   │  Message displayed                          │
   │                                              │
   │                                              │
7. Both see the message in real-time             │
   ↓                                              ↓
```

## Session State Machine

```
                    ┌──────────────────┐
                    │  Session Created │
                    │  by Client       │
                    └────────┬─────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │    PENDING      │◄─────┐
                    │                 │      │
                    │ Waiting for     │      │ No counsellors
                    │ counsellor      │      │ available
                    └────────┬────────┘      │
                             │                │
                 Counsellor  │                │
                 accepts     │                │
                             ▼                │
                    ┌─────────────────┐      │
                    │    ACTIVE       │      │
                    │                 │      │
                    │ Chat ongoing    │      │
                    │ Messages flow   │      │
                    └────────┬────────┘      │
                             │                │
                 Either      │                │
                 party       │                │
                 closes      │                │
                             ▼                │
                    ┌─────────────────┐      │
                    │    CLOSED       │      │
                    │                 │      │
                    │ Session ended   │      │
                    │ Archive chat    │      │
                    └─────────────────┘      │
                                              │
                    Timeout (24h)             │
                    No counsellor             │
                    ──────────────────────────┘
```

## API Endpoints Map

```
BASE URL: http://localhost:8000

┌─────────────────────────────────────────────────────────────┐
│                    AUTHENTICATION                           │
├─────────────────────────────────────────────────────────────┤
│ POST   /auth/login      → Counsellor login (JWT)            │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    SESSION MANAGEMENT                       │
├─────────────────────────────────────────────────────────────┤
│ POST   /sessions/create          → Create new session       │
│ GET    /sessions/pending         → Get pending sessions     │
│ GET    /sessions/active          → Get active sessions      │
│ GET    /sessions/{id}            → Get session details      │
│ POST   /sessions/{id}/accept     → Counsellor accepts       │
│ POST   /sessions/{id}/close      → Close session            │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    CHAT / MESSAGING                         │
├─────────────────────────────────────────────────────────────┤
│ GET    /chat/{id}/messages       → Get all messages         │
│ POST   /chat/{id}/send           → Send message             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    WEBSOCKET ENDPOINTS                      │
├─────────────────────────────────────────────────────────────┤
│ WS     /ws/counselors            → Counsellor notifications │
│ WS     /ws/session/{id}          → Session chat room        │
└─────────────────────────────────────────────────────────────┘
```

## Technology Stack Details

```
┌──────────────────────────────────────────────────────────────┐
│                      CLIENT APP                              │
├──────────────────────────────────────────────────────────────┤
│ Framework:    Flutter 3.8.1                                  │
│ Language:     Dart                                           │
│ UI:           Material Design                                │
│ State Mgmt:   StatefulWidget                                 │
│ HTTP Client:  http package                                   │
│ WebSocket:    web_socket_channel                             │
│ Platform:     Android, iOS, Web                              │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│                      BACKEND API                             │
├──────────────────────────────────────────────────────────────┤
│ Framework:    FastAPI (async)                                │
│ Language:     Python 3.10+                                   │
│ ORM:          SQLAlchemy                                     │
│ Auth:         JWT (PyJWT)                                    │
│ Password:     Bcrypt                                         │
│ WebSocket:    FastAPI WebSocket                              │
│ Validation:   Pydantic                                       │
│ Server:       Uvicorn (ASGI)                                 │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│                      DATABASE                                │
├──────────────────────────────────────────────────────────────┤
│ Development:  SQLite                                         │
│ Production:   PostgreSQL (recommended)                       │
│ Migrations:   Alembic (to be added)                          │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│                   FUTURE ENHANCEMENTS                        │
├──────────────────────────────────────────────────────────────┤
│ Caching:      Redis                                          │
│ Queue:        Celery                                         │
│ Push Notif:   Firebase Cloud Messaging                       │
│ Storage:      AWS S3 / CloudFlare                            │
│ Monitoring:   Sentry, Datadog                                │
│ Analytics:    Mixpanel, Google Analytics                     │
└──────────────────────────────────────────────────────────────┘
```

## Security Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    SECURITY LAYERS                          │
└─────────────────────────────────────────────────────────────┘

Layer 1: Transport Security
├─ HTTPS (TLS 1.3) in production
├─ WebSocket Secure (WSS) in production
└─ Certificate pinning (optional)

Layer 2: Authentication
├─ JWT tokens for counsellors
├─ Token expiration (24h)
├─ Refresh tokens (future)
└─ Password hashing (Bcrypt)

Layer 3: Authorization
├─ Counsellors can only see their sessions
├─ Clients can only access their session
└─ Role-based access control

Layer 4: Data Protection
├─ Input validation (Pydantic)
├─ SQL injection prevention (ORM)
├─ XSS protection
└─ CORS configuration

Layer 5: Privacy
├─ Optional client names
├─ Session isolation
├─ Message encryption in transit
└─ Data retention policies (future)
```

## Scalability Considerations

```
Current: Single Server
┌────────────────┐
│   API Server   │ ─── SQLite DB
│  (1 instance)  │
└────────────────┘

Future: Horizontal Scaling
┌────────────────┐
│ Load Balancer  │
└───────┬────────┘
        │
        ├──────────┬──────────┐
        │          │          │
  ┌─────▼────┐ ┌──▼─────┐ ┌──▼─────┐
  │ API      │ │ API    │ │ API    │
  │ Server 1 │ │ Server│ │ Server│
  └─────┬────┘ └──┬─────┘ └──┬─────┘
        │         │           │
        └─────────┴───────────┘
                  │
          ┌───────▼────────┐
          │  PostgreSQL    │
          │  (Primary)     │
          └────────────────┘
                  │
          ┌───────▼────────┐
          │  Redis Cache   │
          └────────────────┘
```

---

## Quick Reference

**Documentation Files:**
- `IMPLEMENTATION_SUMMARY.md` - What we built
- `COUNSELLOR_APP_GUIDE.md` - How to build counsellor app
- `SETUP_GUIDE.md` - How to run everything
- `ARCHITECTURE.md` - This file (system design)

**Key URLs:**
- API Docs: http://localhost:8000/docs
- API Base: http://localhost:8000
- Client: Flutter app on device/emulator
- Counsellor: To be built

**Status:** ✅ Core system complete, ready for counsellor app development
