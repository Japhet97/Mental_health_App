# session_monitor.py - Background task to handle session timeouts
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
import models
from database import SessionLocal
import asyncio
import logging

logger = logging.getLogger(__name__)

class SessionMonitor:
    def __init__(self, pending_timeout_minutes=30, inactive_timeout_minutes=120):
        self.pending_timeout = timedelta(minutes=pending_timeout_minutes)
        self.inactive_timeout = timedelta(minutes=inactive_timeout_minutes)
        self.is_running = False

    async def start(self):
        """Start the session monitor background task"""
        self.is_running = True
        logger.info("Session monitor started")
        
        while self.is_running:
            try:
                await self._check_sessions()
                await asyncio.sleep(60)  # Check every minute
            except Exception as e:
                logger.error(f"Session monitor error: {e}")
                await asyncio.sleep(60)

    async def stop(self):
        """Stop the session monitor"""
        self.is_running = False
        logger.info("Session monitor stopped")

    async def _check_sessions(self):
        """Check for timed-out sessions"""
        db = SessionLocal()
        try:
            now = datetime.utcnow()
            
            # Check pending sessions (no counsellor after 30 minutes)
            pending_sessions = db.query(models.Session).filter(
                models.Session.status == "pending",
                models.Session.created_at < now - self.pending_timeout
            ).all()
            
            for session in pending_sessions:
                logger.info(f"Closing pending session {session.id} due to timeout")
                session.status = "closed"
                session.timeout_reason = "No counsellor available"
            
            # Check inactive sessions (no messages in 2 hours)
            active_sessions = db.query(models.Session).filter(
                models.Session.status == "active"
            ).all()
            
            for session in active_sessions:
                # Get last message time
                last_message = db.query(models.Message).filter(
                    models.Message.session_id == session.id
                ).order_by(models.Message.timestamp.desc()).first()
                
                if last_message:
                    time_since_last_message = now - last_message.timestamp
                    if time_since_last_message > self.inactive_timeout:
                        logger.info(f"Closing inactive session {session.id}")
                        session.status = "closed"
                        session.timeout_reason = "Session inactive"
            
            db.commit()
            
        except Exception as e:
            logger.error(f"Error checking sessions: {e}")
            db.rollback()
        finally:
            db.close()

# Global instance
session_monitor = SessionMonitor()
