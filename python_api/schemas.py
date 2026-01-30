# schemas.py
from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime

# Auth
class LoginIn(BaseModel):
    email: EmailStr
    password: str

class CounsellorOut(BaseModel):
    id: int
    email: EmailStr
    name: str
    class Config:
        from_attributes = True

class TokenOut(BaseModel):
    access_token: str
    user: CounsellorOut

# Sessions
class SessionCreate(BaseModel):
    client_name: Optional[str] = None
    issue: Optional[str] = None
    language: Optional[str] = "en"
    
    class Config:
        json_schema_extra = {
            "example": {
                "client_name": "John Doe",
                "issue": "Depression",
                "language": "en"
            }
        }

class SessionOut(BaseModel):
    id: int
    client_name: Optional[str]
    issue: Optional[str]
    language: Optional[str] = "en"
    status: str
    counsellor_id: Optional[int] = None
    created_at: datetime
    updated_at: Optional[datetime] = None
    closed_at: Optional[datetime] = None
    timeout_reason: Optional[str] = None
    client_token: Optional[str] = None  # Token for client to connect to WebSocket
    
    class Config:
        from_attributes = True

# Messages
class MessageIn(BaseModel):
    session_id: int
    sender: str
    content: str
    
    class Config:
        json_schema_extra = {
            "example": {
                "session_id": 1,
                "sender": "client",
                "content": "Hello, I need help"
            }
        }

class MessageSend(BaseModel):
    sender: str
    content: str
    
    class Config:
        json_schema_extra = {
            "example": {
                "sender": "client",
                "content": "Hello, I need help"
            }
        }

class MessageOut(BaseModel):
    id: int
    session_id: int
    sender: str
    content: str
    timestamp: datetime
    class Config:
        from_attributes = True

class MessagesResponse(BaseModel):
    messages: List[MessageOut]

class TypingIndicator(BaseModel):
    sender: str  # "client" or "counsellor"
    is_typing: bool
    
    class Config:
        json_schema_extra = {
            "example": {
                "sender": "client",
                "is_typing": True
            }
        }

