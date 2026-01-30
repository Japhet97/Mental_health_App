#!/usr/bin/env python3
# create_test_data.py - Create test data for dashboard
from database import SessionLocal
import models
import security
from datetime import datetime, timedelta

def create_test_data():
    db = SessionLocal()
    try:
        # Create counsellor
        counsellor = models.Counsellor(
            email="counsellor@yoneco.org",
            name="Test Counsellor",
            password_hash=security.hash_password("password123"),
            is_active=True
        )
        db.add(counsellor)
        db.commit()
        db.refresh(counsellor)
        
        # Create issues
        issues_data = [
            {"name_en": "Depression", "name_ny": "Kupsinjika Maganizo", "display_order": 1},
            {"name_en": "Anxiety", "name_ny": "Nkhawa", "display_order": 2},
            {"name_en": "Stress", "name_ny": "Kupsinjika Mtima", "display_order": 3},
        ]
        
        for issue_data in issues_data:
            issue = models.Issue(**issue_data)
            db.add(issue)
        
        db.commit()
        
        # Create test sessions
        now = datetime.utcnow()
        sessions_data = [
            {"client_name": "John Doe", "issue": "Depression", "status": "pending", "language": "en", "created_at": now - timedelta(hours=2)},
            {"client_name": "Jane Smith", "issue": "Anxiety", "status": "active", "language": "en", "counsellor_id": counsellor.id, "created_at": now - timedelta(hours=1)},
            {"client_name": "Mike Johnson", "issue": "Stress", "status": "closed", "language": "ny", "counsellor_id": counsellor.id, "created_at": now - timedelta(days=1), "closed_at": now - timedelta(hours=23)},
        ]
        
        for session_data in sessions_data:
            session = models.Session(**session_data)
            db.add(session)
        
        db.commit()
        print("Test data created successfully!")
        
    except Exception as e:
        print(f"Error: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    create_test_data()