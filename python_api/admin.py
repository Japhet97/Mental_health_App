# admin.py - Admin endpoints for system monitoring
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from sqlalchemy import func, text
from database import SessionLocal
import models
from datetime import datetime, timedelta
from typing import Optional
from pydantic import BaseModel
import security

router = APIRouter(prefix="/admin", tags=["admin"])
security_scheme = HTTPBearer()

class IssueCreate(BaseModel):
    name_en: str
    name_ny: str
    description_en: Optional[str] = None
    description_ny: Optional[str] = None

class IssueUpdate(BaseModel):
    name_en: Optional[str] = None
    name_ny: Optional[str] = None
    description_en: Optional[str] = None
    description_ny: Optional[str] = None
    is_active: Optional[bool] = None

class LanguageCreate(BaseModel):
    code: str
    name_en: str
    native_name: str

class AdminLogin(BaseModel):
    email: str
    password: str

class CounsellorCreate(BaseModel):
    email: str
    name: str
    password: str

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def verify_admin_token(credentials: HTTPAuthorizationCredentials = Depends(security_scheme), db: Session = Depends(get_db)):
    """Verify admin JWT token"""
    try:
        payload = security.decode_access_token(credentials.credentials)
        email = payload.get("sub")
        if not email:
            raise HTTPException(status_code=401, detail="Invalid token")
        
        admin = db.query(models.Admin).filter(models.Admin.email == email).first()
        if not admin or not admin.is_active:
            raise HTTPException(status_code=401, detail="Admin not found or inactive")
        
        return admin
    except Exception as e:
        raise HTTPException(status_code=401, detail="Invalid authentication credentials")

@router.post("/login")
def admin_login(login_data: AdminLogin, db: Session = Depends(get_db)):
    """Admin login - also allows counsellors with admin role"""
    # Try admin table first
    admin = db.query(models.Admin).filter(models.Admin.email == login_data.email).first()
    if admin and admin.is_active and security.verify_password(login_data.password, admin.password_hash):
        access_token = security.create_access_token(admin.email)
        return {
            "access_token": access_token,
            "token_type": "bearer",
            "user": {
                "id": admin.id,
                "email": admin.email,
                "name": admin.name,
                "role": "admin"
            }
        }
    
    # Try counsellor table as fallback for admin privileges
    counsellor = db.query(models.Counsellor).filter(models.Counsellor.email == login_data.email).first()
    if counsellor and counsellor.is_active and security.verify_password(login_data.password, counsellor.password_hash):
        access_token = security.create_access_token(counsellor.email)
        return {
            "access_token": access_token,
            "token_type": "bearer",
            "user": {
                "id": counsellor.id,
                "email": counsellor.email,
                "name": counsellor.name,
                "role": "admin"
            }
        }
    
    raise HTTPException(status_code=401, detail="Invalid credentials")

@router.get("/dashboard")
def admin_dashboard(admin: models.Admin = Depends(verify_admin_token), db: Session = Depends(get_db)):
    """Get admin dashboard statistics"""
    
    # Overall stats
    total_sessions = db.query(models.Session).count()
    total_counsellors = db.query(models.Counsellor).count()
    total_messages = db.query(models.Message).count()
    
    # Current status
    pending_sessions = db.query(models.Session).filter(
        models.Session.status == "pending"
    ).count()
    
    active_sessions = db.query(models.Session).filter(
        models.Session.status == "active"
    ).count()
    
    # Today's activity
    today = datetime.utcnow().date()
    sessions_today = db.query(models.Session).filter(
        func.date(models.Session.created_at) == today
    ).count()
    
    messages_today = db.query(models.Message).filter(
        func.date(models.Message.timestamp) == today
    ).count()
    
    # Last 7 days activity
    week_ago = datetime.utcnow() - timedelta(days=7)
    sessions_this_week = db.query(models.Session).filter(
        models.Session.created_at >= week_ago
    ).count()
    
    # Sessions per day for the last 7 days
    sessions_by_day = []
    for i in range(6, -1, -1):
        day = datetime.utcnow().date() - timedelta(days=i)
        count = db.query(models.Session).filter(
            func.date(models.Session.created_at) == day
        ).count()
        sessions_by_day.append({
            "date": day.isoformat(),
            "count": count
        })
    
    # Issue breakdown
    issue_stats = db.query(
        models.Session.issue,
        func.count(models.Session.id).label('count')
    ).group_by(models.Session.issue).all()
    
    # Language breakdown
    language_stats = db.query(
        models.Session.language,
        func.count(models.Session.id).label('count')
    ).group_by(models.Session.language).all()
    
    # Enhanced Counsellor performance metrics
    counsellor_stats = db.query(
        models.Counsellor.id,
        models.Counsellor.name,
        models.Counsellor.email
    ).all()
    
    counsellor_performance = []
    for counsellor in counsellor_stats:
        # Total sessions handled
        total_handled = db.query(models.Session).filter(
            models.Session.counsellor_id == counsellor.id
        ).count()
        
        # Closed sessions (completed)
        closed_sessions = db.query(models.Session).filter(
            models.Session.counsellor_id == counsellor.id,
            models.Session.status == "closed"
        ).count()
        
        # Currently active sessions
        current_active = db.query(models.Session).filter(
            models.Session.counsellor_id == counsellor.id,
            models.Session.status == "active"
        ).count()
        
        # Average session duration for closed sessions
        closed_session_list = db.query(models.Session).filter(
            models.Session.counsellor_id == counsellor.id,
            models.Session.status == "closed",
            models.Session.closed_at.isnot(None)
        ).all()
        
        durations = []
        for session in closed_session_list:
            if session.closed_at and session.created_at:
                duration = (session.closed_at - session.created_at).total_seconds() / 60
                durations.append(duration)
        
        avg_duration = sum(durations) / len(durations) if durations else 0
        
        # Messages sent by counsellor
        messages_sent = db.query(models.Message).filter(
            models.Message.sender == "counsellor",
            models.Message.session_id.in_(
                db.query(models.Session.id).filter(
                    models.Session.counsellor_id == counsellor.id
                )
            )
        ).count()
        
        # Average response time (first message after client message)
        response_times = []
        for session in db.query(models.Session).filter(
            models.Session.counsellor_id == counsellor.id
        ).all():
            # Get first client message and first counsellor message
            first_client_msg = db.query(models.Message).filter(
                models.Message.session_id == session.id,
                models.Message.sender == "client"
            ).order_by(models.Message.timestamp.asc()).first()
            
            first_counsellor_msg = db.query(models.Message).filter(
                models.Message.session_id == session.id,
                models.Message.sender == "counsellor"
            ).order_by(models.Message.timestamp.asc()).first()
            
            if first_client_msg and first_counsellor_msg:
                response_time = (first_counsellor_msg.timestamp - first_client_msg.timestamp).total_seconds() / 60
                response_times.append(response_time)
        
        avg_response_time = sum(response_times) / len(response_times) if response_times else 0
        
        counsellor_performance.append({
            "id": counsellor.id,
            "name": counsellor.name,
            "email": counsellor.email,
            "sessions_handled": total_handled,
            "closed_sessions": closed_sessions,
            "active_sessions": current_active,
            "messages_sent": messages_sent,
            "avg_session_duration_minutes": round(avg_duration, 2),
            "avg_response_time_minutes": round(avg_response_time, 2),
            "completion_rate": round((closed_sessions / total_handled * 100), 2) if total_handled > 0 else 0
        })
    
    # Average response time across all counsellors
    accepted_sessions = db.query(models.Session).filter(
        models.Session.status.in_(["active", "closed"]),
        models.Session.counsellor_id.isnot(None)
    ).all()
    
    response_times = []
    for session in accepted_sessions:
        # Estimate based on updated_at vs created_at
        if session.updated_at:
            response_time = (session.updated_at - session.created_at).total_seconds() / 60
            response_times.append(response_time)
    
    avg_response_time = sum(response_times) / len(response_times) if response_times else 0
    
    return {
        "overview": {
            "total_sessions": total_sessions,
            "total_counsellors": total_counsellors,
            "total_messages": total_messages,
            "pending_sessions": pending_sessions,
            "active_sessions": active_sessions
        },
        "today": {
            "sessions": sessions_today,
            "messages": messages_today
        },
        "this_week": {
            "sessions": sessions_this_week
        },
        "sessions_by_day": sessions_by_day,
        "performance": {
            "average_response_time_minutes": round(avg_response_time, 2)
        },
        "issues": [
            {"issue": issue or "Unknown", "count": count}
            for issue, count in issue_stats
        ],
        "languages": [
            {"language": language or "en", "count": count}
            for language, count in language_stats
        ],
        "counsellors": counsellor_performance
    }

@router.get("/sessions/recent")
def get_recent_sessions(limit: int = 20, db: Session = Depends(get_db)):
    """Get recent sessions"""
    sessions = db.query(models.Session).order_by(
        models.Session.created_at.desc()
    ).limit(limit).all()
    
    return {
        "sessions": [
            {
                "id": s.id,
                "client_name": s.client_name,
                "issue": s.issue,
                "status": s.status,
                "counsellor_id": s.counsellor_id,
                "created_at": s.created_at.isoformat(),
                "closed_at": s.closed_at.isoformat() if s.closed_at else None
            }
            for s in sessions
        ]
    }

@router.get("/sessions/pending")
def get_admin_pending_sessions(admin: models.Admin = Depends(verify_admin_token), db: Session = Depends(get_db)):
    """Get all pending sessions for admin dashboard"""
    sessions = db.query(models.Session).filter(
        models.Session.status == "pending"
    ).order_by(models.Session.created_at.desc()).all()
    
    return [
        {
            "id": s.id,
            "client_name": s.client_name,
            "issue": s.issue,
            "language": s.language,
            "status": s.status,
            "counsellor_id": s.counsellor_id,
            "counsellor_name": s.counsellor.name if s.counsellor else None,
            "created_at": s.created_at.isoformat(),
            "updated_at": s.updated_at.isoformat() if s.updated_at else None,
            "closed_at": s.closed_at.isoformat() if s.closed_at else None
        }
        for s in sessions
    ]

@router.get("/sessions/active")
def get_admin_active_sessions(admin: models.Admin = Depends(verify_admin_token), db: Session = Depends(get_db)):
    """Get all active sessions for admin dashboard"""
    sessions = db.query(models.Session).filter(
        models.Session.status == "active"
    ).order_by(models.Session.created_at.desc()).all()
    
    return [
        {
            "id": s.id,
            "client_name": s.client_name,
            "issue": s.issue,
            "language": s.language,
            "status": s.status,
            "counsellor_id": s.counsellor_id,
            "counsellor_name": s.counsellor.name if s.counsellor else None,
            "created_at": s.created_at.isoformat(),
            "updated_at": s.updated_at.isoformat() if s.updated_at else None,
            "closed_at": s.closed_at.isoformat() if s.closed_at else None
        }
        for s in sessions
    ]

@router.get("/sessions/closed")
def get_admin_closed_sessions(admin: models.Admin = Depends(verify_admin_token), db: Session = Depends(get_db)):
    """Get all closed sessions for admin dashboard"""
    sessions = db.query(models.Session).filter(
        models.Session.status == "closed"
    ).order_by(models.Session.closed_at.desc()).all()
    
    return [
        {
            "id": s.id,
            "client_name": s.client_name,
            "issue": s.issue,
            "language": s.language,
            "status": s.status,
            "counsellor_id": s.counsellor_id,
            "counsellor_name": s.counsellor.name if s.counsellor else None,
            "created_at": s.created_at.isoformat(),
            "updated_at": s.updated_at.isoformat() if s.updated_at else None,
            "closed_at": s.closed_at.isoformat() if s.closed_at else None,
            "closed_by": "Admin" if s.closed_at else None,
            "action_taken": "Session completed"
        }
        for s in sessions
    ]

@router.post("/sessions/{session_id}/close")
def admin_close_session(
    session_id: int,
    admin: models.Admin = Depends(verify_admin_token),
    db: Session = Depends(get_db)
):
    """Admin close session endpoint"""
    from datetime import datetime
    
    session = db.query(models.Session).filter(models.Session.id == session_id).first()
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
    
    if session.status == "closed":
        raise HTTPException(status_code=400, detail="Session already closed")
    
    session.status = "closed"
    session.closed_at = datetime.utcnow()
    db.commit()
    
    return {"status": "closed", "session_id": session_id, "message": "Session closed by admin"}

@router.get("/counsellors/active")
def get_active_counsellors(db: Session = Depends(get_db)):
    """Get list of counsellors with their current status"""
    counsellors = db.query(models.Counsellor).all()
    
    result = []
    for counsellor in counsellors:
        active_sessions = db.query(models.Session).filter(
            models.Session.counsellor_id == counsellor.id,
            models.Session.status == "active"
        ).count()
        
        total_sessions = db.query(models.Session).filter(
            models.Session.counsellor_id == counsellor.id
        ).count()
        
        result.append({
            "id": counsellor.id,
            "name": counsellor.name,
            "email": counsellor.email,
            "active_sessions": active_sessions,
            "total_sessions": total_sessions,
            "is_active": counsellor.is_active
        })
    
    return {"counsellors": result}

# ===== COUNSELLOR MANAGEMENT =====
@router.post("/counsellors")
def create_counsellor(counsellor_data: CounsellorCreate, admin: models.Admin = Depends(verify_admin_token), db: Session = Depends(get_db)):
    """Create new counsellor"""
    # Check if email already exists
    existing = db.query(models.Counsellor).filter(models.Counsellor.email == counsellor_data.email).first()
    if existing:
        raise HTTPException(status_code=400, detail="Email already exists")
    
    # Create new counsellor
    new_counsellor = models.Counsellor(
        email=counsellor_data.email,
        name=counsellor_data.name,
        password_hash=security.hash_password(counsellor_data.password)
    )
    db.add(new_counsellor)
    db.commit()
    db.refresh(new_counsellor)
    
    return {
        "message": "Counsellor created successfully",
        "counsellor": {
            "id": new_counsellor.id,
            "email": new_counsellor.email,
            "name": new_counsellor.name,
            "is_active": new_counsellor.is_active
        }
    }

@router.delete("/counsellors/{counsellor_id}")
def delete_counsellor(counsellor_id: int, admin: models.Admin = Depends(verify_admin_token), db: Session = Depends(get_db)):
    """Delete counsellor"""
    counsellor = db.query(models.Counsellor).filter(models.Counsellor.id == counsellor_id).first()
    if not counsellor:
        raise HTTPException(status_code=404, detail="Counsellor not found")
    
    db.delete(counsellor)
    db.commit()
    return {"message": "Counsellor deleted successfully"}

# ===== ISSUE MANAGEMENT =====
@router.get("/issues")
def get_issues(db: Session = Depends(get_db)):
    """Get all issues - public endpoint"""
    issues = db.query(models.Issue).order_by(models.Issue.display_order).all()
    return [
        {
            "id": issue.id,
            "name_en": issue.name_en,
            "name_ny": issue.name_ny,
            "description_en": issue.description_en,
            "description_ny": issue.description_ny,
            "display_order": issue.display_order,
            "is_active": issue.is_active,
            "created_at": issue.created_at.isoformat(),
            "updated_at": issue.updated_at.isoformat()
        }
        for issue in issues
    ]

@router.post("/issues")
def create_issue(issue_data: IssueCreate, db: Session = Depends(get_db)):
    """Create new issue"""
    try:
        # Find "Other" issue to insert before it
        other_issue = db.query(models.Issue).filter(
            models.Issue.name_en.ilike('%other%')
        ).first()
        
        if other_issue:
            # Insert before "Other"
            new_order = other_issue.display_order
            # Update "Other" issue to have a higher order
            other_issue.display_order = new_order + 1
        else:
            # No "Other" found, get next available order
            max_order = db.query(func.max(models.Issue.display_order)).scalar() or 0
            new_order = max_order + 1
        
        # Create new issue
        new_issue = models.Issue(
            name_en=issue_data.name_en,
            name_ny=issue_data.name_ny,
            description_en=issue_data.description_en,
            description_ny=issue_data.description_ny,
            display_order=new_order
        )
        db.add(new_issue)
        db.commit()
        db.refresh(new_issue)
        
        return {
            "message": "Issue created successfully",
            "issue": {
                "id": new_issue.id,
                "name_en": new_issue.name_en,
                "name_ny": new_issue.name_ny,
                "display_order": new_issue.display_order
            }
        }
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Failed to create issue: {str(e)}")

@router.put("/issues/{issue_id}")
def update_issue(issue_id: int, issue_data: IssueUpdate, db: Session = Depends(get_db)):
    """Update issue"""
    issue = db.query(models.Issue).filter(models.Issue.id == issue_id).first()
    if not issue:
        raise HTTPException(status_code=404, detail="Issue not found")
    
    if issue_data.name_en is not None:
        issue.name_en = issue_data.name_en
    if issue_data.name_ny is not None:
        issue.name_ny = issue_data.name_ny
    if issue_data.description_en is not None:
        issue.description_en = issue_data.description_en
    if issue_data.description_ny is not None:
        issue.description_ny = issue_data.description_ny
    if issue_data.is_active is not None:
        issue.is_active = issue_data.is_active
    
    db.commit()
    db.refresh(issue)
    return {"message": "Issue updated successfully"}

@router.delete("/issues/{issue_id}")
def delete_issue(issue_id: int, db: Session = Depends(get_db)):
    """Delete issue"""
    issue = db.query(models.Issue).filter(models.Issue.id == issue_id).first()
    if not issue:
        raise HTTPException(status_code=404, detail="Issue not found")
    
    db.delete(issue)
    db.commit()
    return {"message": "Issue deleted successfully"}

# ===== LANGUAGE MANAGEMENT =====
@router.get("/languages")
def get_languages(db: Session = Depends(get_db)):
    """Get all languages - public endpoint"""
    languages = db.query(models.Language).all()
    return [
        {
            "id": lang.id,
            "code": lang.code,
            "name_en": lang.name,
            "native_name": lang.name,
            "is_active": lang.is_active,
            "created_at": lang.created_at.isoformat()
        }
        for lang in languages
    ]

@router.post("/languages")
def create_language(lang_data: LanguageCreate, admin: models.Admin = Depends(verify_admin_token), db: Session = Depends(get_db)):
    """Create new language"""
    existing = db.query(models.Language).filter(models.Language.code == lang_data.code).first()
    if existing:
        raise HTTPException(status_code=400, detail="Language code already exists")
    
    new_lang = models.Language(
        code=lang_data.code,
        name=lang_data.name_en  # Use name field instead of name_en
    )
    db.add(new_lang)
    db.commit()
    db.refresh(new_lang)
    return {
        "message": "Language created successfully",
        "language": {
            "id": new_lang.id,
            "code": new_lang.code,
            "name_en": new_lang.name,
            "native_name": new_lang.name
        }
    }

@router.delete("/languages/{lang_id}")
def delete_language(lang_id: int, admin: models.Admin = Depends(verify_admin_token), db: Session = Depends(get_db)):
    """Delete language"""
    language = db.query(models.Language).filter(models.Language.id == lang_id).first()
    if not language:
        raise HTTPException(status_code=404, detail="Language not found")
    
    db.delete(language)
    db.commit()
    return {"message": "Language deleted successfully"}
