# crud.py
from sqlalchemy.orm import Session
import models, security

def get_counsellor_by_email(db: Session, email: str):
    return db.query(models.Counsellor).filter(models.Counsellor.email == email).first()

def create_counsellor(db: Session, email: str, name: str, password: str):
    obj = models.Counsellor(email=email, name=name, password_hash=security.hash_password(password))
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

def create_session(db: Session, client_name: str | None, issue: str | None, language: str | None = "en"):
    s = models.Session(client_name=client_name, issue=issue, language=language)
    db.add(s)
    db.commit()
    db.refresh(s)
    return s

def get_session(db: Session, session_id: int):
    return db.query(models.Session).filter(models.Session.id == session_id).first()

def list_open_sessions(db: Session):
    return db.query(models.Session).order_by(models.Session.created_at.desc()).all()

def create_message(db: Session, session_id: int, sender: str, content: str):
    m = models.Message(session_id=session_id, sender=sender, content=content)
    db.add(m)
    db.commit()
    db.refresh(m)
    return m

def get_messages_for_session(db: Session, session_id: int):
    msgs = db.query(models.Message).filter(models.Message.session_id == session_id).order_by(models.Message.timestamp.asc()).all()
    return msgs
