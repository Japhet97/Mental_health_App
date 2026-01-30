from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import SessionLocal
import crud, schemas, models
import json
from security import get_current_counsellor_email

router = APIRouter(prefix="/sessions", tags=["sessions"])
manager = None  # will be set from main.py if needed

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def include_session_routes(r: APIRouter, m):
    global manager
    manager = m

@router.get("/issues/list")
async def get_available_issues(db: Session = Depends(get_db)):
    """Get list of active issues for client selection - no authentication required"""
    issues = db.query(models.Issue).filter(models.Issue.is_active == True).all()
    return {
        "issues": [
            {
                "id": issue.id,
                "name_en": issue.name_en,
                "name_ny": issue.name_ny,
                "description_en": issue.description_en,
                "description_ny": issue.description_ny
            }
            for issue in issues
        ]
    }

@router.post("/create", response_model=schemas.SessionOut)
async def create_session(session_data: schemas.SessionCreate, db: Session = Depends(get_db)):
    """Create a new session when client wants to talk to counsellor"""
    from security import create_access_token
    
    new_session = crud.create_session(
        db, 
        session_data.client_name, 
        session_data.issue,
        session_data.language
    )
    
    # Generate a temporary token for the client to use this session
    client_token = create_access_token(f"client_session_{new_session.id}")
    
    # Notify all connected counsellors about new pending session
    if manager:
        notification = json.dumps({
            "type": "new_session",
            "session": {
                "id": new_session.id,
                "client_name": new_session.client_name,
                "issue": new_session.issue,
                "language": new_session.language,
                "status": new_session.status,
                "created_at": new_session.created_at.isoformat()
            }
        })
        await manager.broadcast_to_counselors(notification)
    
    # Return session with client token
    return {
        **new_session.__dict__,
        "client_token": client_token
    }

@router.get("/pending", response_model=list[schemas.SessionOut])
def get_pending_sessions(db: Session = Depends(get_db)):
    """Get all pending sessions (not yet accepted by counsellor)"""
    return db.query(models.Session).filter(models.Session.status == "pending").order_by(models.Session.created_at.desc()).all()

@router.get("/active", response_model=list[schemas.SessionOut])
def get_active_sessions(db: Session = Depends(get_db)):
    """Get all active sessions (accepted by counsellor, ongoing)"""
    return db.query(models.Session).filter(models.Session.status == "active").order_by(models.Session.created_at.desc()).all()

@router.get("/closed", response_model=list[schemas.SessionOut])
def get_closed_sessions(db: Session = Depends(get_db)):
    """Get all closed sessions"""
    return db.query(models.Session).filter(models.Session.status == "closed").order_by(models.Session.closed_at.desc()).all()

@router.get("/{session_id}", response_model=schemas.SessionOut)
def get_session(session_id: int, db: Session = Depends(get_db)):
    """Get specific session details"""
    session = crud.get_session(db, session_id)
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
    return session

@router.post("/{session_id}/accept")
async def accept_session(
    session_id: int, 
    counsellor_id: int,
    db: Session = Depends(get_db),
    counsellor_email: str = Depends(get_current_counsellor_email)
):
    """Counsellor accepts a pending session (requires authentication)"""
    
    # Verify the counsellor exists and matches the ID
    counsellor = crud.get_counsellor_by_email(db, counsellor_email)
    if not counsellor or counsellor.id != counsellor_id:
        raise HTTPException(status_code=403, detail="Forbidden: counsellor ID mismatch")
    
    session = crud.get_session(db, session_id)
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
    
    if session.status != "pending":
        raise HTTPException(status_code=400, detail="Session already accepted or closed")
    
    session.status = "active"
    session.counsellor_id = counsellor_id
    db.commit()
    
    # Notify the client that counsellor accepted
    if manager:
        notification = json.dumps({
            "type": "session_accepted",
            "session_id": session_id,
            "message": "A counsellor has joined the session"
        })
        await manager.broadcast_to_room(session_id, notification)
    
    return {"status": "accepted", "session_id": session_id}

@router.post("/{session_id}/close")
async def close_session(
    session_id: int,
    db: Session = Depends(get_db),
    counsellor_email: str = Depends(get_current_counsellor_email)
):
    """Close an active session (requires authentication)"""
    from datetime import datetime
    
    session = crud.get_session(db, session_id)
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
    
    session.status = "closed"
    session.closed_at = datetime.utcnow()
    db.commit()
    
    # Notify all participants
    if manager:
        notification = json.dumps({
            "type": "session_closed",
            "session_id": session_id,
            "message": "Session has been closed"
        })
        await manager.broadcast_to_room(session_id, notification)
    
    return {"status": "closed", "session_id": session_id}

@router.get("/statistics")
def get_statistics(db: Session = Depends(get_db)):
    """Get system statistics"""
    from sqlalchemy import func
    from datetime import datetime, timedelta
    
    # Total sessions
    total_sessions = db.query(models.Session).count()
    
    # Sessions by status
    pending_count = db.query(models.Session).filter(models.Session.status == "pending").count()
    active_count = db.query(models.Session).filter(models.Session.status == "active").count()
    closed_count = db.query(models.Session).filter(models.Session.status == "closed").count()
    
    # Sessions today
    today = datetime.utcnow().date()
    sessions_today = db.query(models.Session).filter(
        func.date(models.Session.created_at) == today
    ).count()
    
    # Average session duration (for closed sessions)
    closed_sessions = db.query(models.Session).filter(
        models.Session.status == "closed",
        models.Session.closed_at.isnot(None)
    ).all()
    
    avg_duration_minutes = 0
    if closed_sessions:
        durations = []
        for session in closed_sessions:
            if session.closed_at and session.created_at:
                duration = (session.closed_at - session.created_at).total_seconds() / 60
                durations.append(duration)
        if durations:
            avg_duration_minutes = sum(durations) / len(durations)
    
    # Total messages
    total_messages = db.query(models.Message).count()
    
    # Active counsellors (have at least one session)
    active_counsellors = db.query(models.Session.counsellor_id).filter(
        models.Session.counsellor_id.isnot(None)
    ).distinct().count()
    
    return {
        "total_sessions": total_sessions,
        "pending_sessions": pending_count,
        "active_sessions": active_count,
        "closed_sessions": closed_count,
        "sessions_today": sessions_today,
        "total_messages": total_messages,
        "active_counsellors": active_counsellors,
        "average_session_duration_minutes": round(avg_duration_minutes, 2)
    }
