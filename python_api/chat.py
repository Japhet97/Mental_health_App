# chat.py
from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends, HTTPException
from sqlalchemy.orm import Session
from database import SessionLocal
import crud, models, schemas
from ws_manager import ConnectionManager
import json
from datetime import datetime

router = APIRouter(prefix="/chat", tags=["chat"])
manager: ConnectionManager = None

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def include_chat_routes(r: APIRouter, m: ConnectionManager):
    global manager
    manager = m

@router.get("/{session_id}/messages")
def get_session_messages(session_id: int, db: Session = Depends(get_db)):
    """Get all messages for a session"""
    messages = crud.get_messages_for_session(db, session_id)
    return {"messages": [
        {
            "id": m.id,
            "sender": m.sender,
            "content": m.content,
            "timestamp": m.timestamp.isoformat()
        } for m in messages
    ]}

@router.post("/{session_id}/send")
async def send_message(
    session_id: int, 
    message_data: schemas.MessageSend, 
    db: Session = Depends(get_db)
):
    """Send a message in a session and broadcast to all participants"""
    
    # Validate inputs
    if not message_data.content or not message_data.content.strip():
        raise HTTPException(status_code=400, detail="Message content cannot be empty")
    
    if message_data.sender not in ["client", "counsellor"]:
        raise HTTPException(status_code=400, detail="Sender must be 'client' or 'counsellor'")
    
    # Check session exists and is active
    session = db.query(models.Session).filter(models.Session.id == session_id).first()
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
    
    if session.status == "closed":
        raise HTTPException(status_code=400, detail="Cannot send message to closed session")
    
    # Trim content
    content = message_data.content.strip()[:2000]  # Limit message length
    
    # Save message to database
    message = crud.create_message(db, session_id, message_data.sender, content)
    
    # Update session timestamp
    session.updated_at = datetime.utcnow()
    db.commit()
    
    # Broadcast to all connected WebSocket clients in this session room
    if manager:
        notification = json.dumps({
            "type": "message",
            "message": {
                "id": message.id,
                "sender": message_data.sender,
                "content": content,
                "timestamp": message.timestamp.isoformat()
            }
        })
        await manager.broadcast_to_room(session_id, notification)
    
    return {"status": "ok", "message_id": message.id}

@router.post("/{session_id}/typing")
async def send_typing_indicator(
    session_id: int,
    typing_data: schemas.TypingIndicator,
    db: Session = Depends(get_db)
):
    """Send typing indicator to other participant"""
    
    # Check session exists
    session = db.query(models.Session).filter(models.Session.id == session_id).first()
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
    
    if session.status == "closed":
        raise HTTPException(status_code=400, detail="Session is closed")
    
    # Broadcast typing status to all participants (will be excluded on client by sender check)
    if manager:
        notification = json.dumps({
            "type": "typing",
            "sender": typing_data.sender,
            "is_typing": typing_data.is_typing
        })
        await manager.broadcast_to_room(session_id, notification)
    
    return {"status": "ok"}

