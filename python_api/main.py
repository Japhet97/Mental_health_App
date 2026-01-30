# main.py
import os
import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI, WebSocket, WebSocketDisconnect, Query, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from dotenv import load_dotenv

import models
from database import engine, SessionLocal
import auth, sessions, chat
from ws_manager import ConnectionManager
from session_monitor import session_monitor

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

load_dotenv()
models.Base.metadata.create_all(bind=engine)

# Lifespan context manager for startup/shutdown events
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    logger.info("Starting Tithandizane Helpline Backend API...")
    logger.info("Starting session monitor...")
    import asyncio
    monitor_task = asyncio.create_task(session_monitor.start())
    yield
    # Shutdown
    logger.info("Shutting down session monitor...")
    await session_monitor.stop()
    monitor_task.cancel()
    logger.info("Tithandizane Helpline Backend API stopped")

app = FastAPI(
    title="Tithandizane Helpline Backend",
    description="Mental Health Support System API",
    version="1.0.0",
    lifespan=lifespan
)

# CORS - Allow all origins for development
origins_env = os.getenv("ALLOWED_ORIGINS")
if origins_env:
    origins = [o.strip() for o in origins_env.split(",") if o.strip()]
else:
    # Default dev origins
    origins = [
        "http://localhost:5173",
        "http://127.0.0.1:5173",
        "http://localhost:5174",
        "http://127.0.0.1:5174"
    ]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_origin_regex=r"https?://(localhost|127\.0\.0\.1|10\.0\.2\.2|192\.168\.[0-9]{1,3}\.[0-9]{1,3})(:[0-9]+)?",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global manager instance
manager = ConnectionManager()

# Include routers
sessions.include_session_routes(sessions.router, manager)
chat.include_chat_routes(chat.router, manager)
app.include_router(sessions.router)
app.include_router(chat.router)
app.include_router(auth.router)

# Admin routes
import admin
app.include_router(admin.router)

# Root endpoint
@app.get("/")
def read_root():
    return {
        "message": "Tithandizane Helpline Mental Health Support API",
        "version": "1.0.0",
        "status": "running"
    }

# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Health check
@app.get("/health")
def health_check():
    return {"status": "healthy", "service": "tithandizane-api"}

# Public Issues endpoint (for mobile apps)
@app.get("/issues")
def get_public_issues(db: Session = Depends(get_db)):
    """Public endpoint for fetching issues"""
    issues = db.query(models.Issue).filter(models.Issue.is_active == True).all()
    
    # Sort issues by display_order
    sorted_issues = sorted(issues, key=lambda x: x.display_order)
    
    return [
        {
            "id": issue.id,
            "name_en": issue.name_en,
            "name_ny": issue.name_ny,
            "description_en": issue.description_en,
            "description_ny": issue.description_ny,
        }
        for issue in sorted_issues
    ]

# WebSocket endpoints
@app.websocket("/ws/counselors")
async def ws_counselors(websocket: WebSocket, token: str = Query(...)):
    """Counsellor WebSocket - requires valid counsellor token"""
    from security import decode_token
    from database import SessionLocal
    import models
    
    # Verify counsellor token
    payload = decode_token(token)
    if not payload or payload.get("type") != "access":
        # Must accept before closing
        await websocket.accept()
        await websocket.close(code=1008, reason="Invalid or expired token")
        logger.warning("Counsellor WebSocket rejected: Invalid token")
        return
    
    # Make sure it's not a client token
    subject = payload.get("sub", "")
    if subject.startswith("client_session_"):
        await websocket.accept()
        await websocket.close(code=1008, reason="Not authorized as counsellor")
        logger.warning("Counsellor WebSocket rejected: Client token used")
        return
    
    await manager.connect_counselor(websocket)
    logger.info(f"Counsellor {subject} connected to WebSocket")
    try:
        while True:
            await websocket.receive_text()
    except WebSocketDisconnect:
        manager.disconnect_counselor(websocket)
        logger.info(f"Counsellor {subject} disconnected from WebSocket")

@app.websocket("/ws/session/{session_id}")
async def ws_session(websocket: WebSocket, session_id: int, token: str = Query(...)):
    """Session WebSocket - accepts both client session tokens and counsellor tokens"""
    from security import decode_token
    import crud
    
    # Verify the token
    payload = decode_token(token)
    if not payload:
        await websocket.accept()
        await websocket.close(code=1008, reason="Invalid or expired token")
        logger.warning(f"WebSocket rejected for session {session_id}: Invalid token")
        return
    
    subject = payload.get("sub", "")
    
    # Accept either client session token OR counsellor token
    is_client = subject == f"client_session_{session_id}"
    is_counsellor = not subject.startswith("client_session_")
    
    if not (is_client or is_counsellor):
        await websocket.accept()
        await websocket.close(code=1008, reason="Unauthorized for this session")
        logger.warning(f"WebSocket rejected for session {session_id}: Wrong session")
        return
    
    # If counsellor, verify they're assigned to this session
    if is_counsellor:
        db = SessionLocal()
        try:
            session = db.query(models.Session).filter(models.Session.id == session_id).first()
            counsellor = crud.get_counsellor_by_email(db, subject)
            if not session or not counsellor or session.counsellor_id != counsellor.id:
                await websocket.accept()
                await websocket.close(code=1008, reason="Not assigned to this session")
                logger.warning(f"Counsellor WebSocket rejected: Not assigned to session {session_id}")
                return
        finally:
            db.close()
    
    user_type = "Client" if is_client else "Counsellor"
    await manager.connect_to_room(session_id, websocket)
    logger.info(f"{user_type} connected to session {session_id} WebSocket")
    try:
        while True:
            await websocket.receive_text()
    except WebSocketDisconnect:
        manager.disconnect_from_room(session_id, websocket)
        logger.info(f"{user_type} disconnected from session {session_id} WebSocket")

