# models.py
from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, DateTime, func
from sqlalchemy.orm import relationship
from database import Base

class Counsellor(Base):
    __tablename__ = "counsellors"
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    name = Column(String, nullable=False)
    password_hash = Column(String, nullable=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class Session(Base):
    __tablename__ = "sessions"
    id = Column(Integer, primary_key=True, index=True)
    client_name = Column(String, nullable=True)  # optional
    issue = Column(String, nullable=True)
    language = Column(String, nullable=True, default="en")  # client's preferred language
    status = Column(String, default="pending")  # pending, active, closed
    counsellor_id = Column(Integer, ForeignKey("counsellors.id"), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    closed_at = Column(DateTime(timezone=True), nullable=True)
    timeout_reason = Column(String, nullable=True)
    messages = relationship("Message", back_populates="session", cascade="all, delete-orphan")
    counsellor = relationship("Counsellor", backref="sessions")

class Message(Base):
    __tablename__ = "messages"
    id = Column(Integer, primary_key=True, index=True)
    session_id = Column(Integer, ForeignKey("sessions.id"))
    sender = Column(String)  # 'client' or 'counsellor'
    content = Column(String)
    timestamp = Column(DateTime(timezone=True), server_default=func.now())
    session = relationship("Session", back_populates="messages")

class Issue(Base):
    __tablename__ = "issues"
    id = Column(Integer, primary_key=True, index=True)
    name_en = Column(String, nullable=False)
    name_ny = Column(String, nullable=False)  # Chichewa
    description_en = Column(String, nullable=True)
    description_ny = Column(String, nullable=True)
    display_order = Column(Integer, nullable=False, default=999)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

class Language(Base):
    __tablename__ = "languages"
    id = Column(Integer, primary_key=True, index=True)
    code = Column(String, unique=True, nullable=False)  # 'en', 'ny'
    name = Column(String, nullable=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class Admin(Base):
    __tablename__ = "admins"
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    name = Column(String, nullable=False)
    password_hash = Column(String, nullable=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
