#!/usr/bin/env python3
# check_data.py - Check database contents
from database import SessionLocal
import models

def check_data():
    db = SessionLocal()
    try:
        # Check sessions
        sessions = db.query(models.Session).all()
        print(f"Sessions: {len(sessions)}")
        
        # Check counsellors
        counsellors = db.query(models.Counsellor).all()
        print(f"Counsellors: {len(counsellors)}")
        
        # Check messages
        messages = db.query(models.Message).all()
        print(f"Messages: {len(messages)}")
        
        # Check issues
        issues = db.query(models.Issue).all()
        print(f"Issues: {len(issues)}")
        
        if sessions:
            print("\nSample sessions:")
            for s in sessions[:3]:
                print(f"  ID: {s.id}, Client: {s.client_name}, Status: {s.status}")
                
    except Exception as e:
        print(f"Error: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    check_data()