#!/usr/bin/env python
"""Reset counsellor passwords"""
from database import SessionLocal
from models import Counsellor
import bcrypt

def hash_password(password: str) -> str:
    """Hash password using bcrypt (same as security.py)"""
    return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

def reset_passwords():
    db = SessionLocal()
    try:
        # Get all counsellors
        counsellors = db.query(Counsellor).all()
        
        # Set all to same password: "counsellor123"
        new_password_hash = hash_password("counsellor123")
        
        for counsellor in counsellors:
            print(f"Resetting password for: {counsellor.email} ({counsellor.name})")
            counsellor.password_hash = new_password_hash
        
        db.commit()
        print(f"\n✅ Updated {len(counsellors)} counsellors")
        print(f"   New password for all: counsellor123")
        
        print("\nUpdated counsellors:")
        for c in counsellors:
            print(f"  - {c.email} → counsellor123")
            
    except Exception as e:
        print(f"❌ Error: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    print("🔑 Resetting all counsellor passwords...")
    print("-" * 50)
    reset_passwords()
