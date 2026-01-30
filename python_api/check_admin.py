#!/usr/bin/env python3
# check_admin.py - Check admin credentials
from database import SessionLocal
import models
import security

def check_admin():
    db = SessionLocal()
    try:
        # Get all admins
        admins = db.query(models.Admin).all()
        
        print("=== ADMIN ACCOUNTS ===")
        for admin in admins:
            print(f"ID: {admin.id}")
            print(f"Email: {admin.email}")
            print(f"Name: {admin.name}")
            print(f"Active: {admin.is_active}")
            print(f"Created: {admin.created_at}")
            print("-" * 30)
        
        if not admins:
            print("No admin accounts found!")
            return
        
        # Test login with default credentials
        test_email = "admin@yoneco.org"
        test_password = "Admin@2025"
        
        admin = db.query(models.Admin).filter(models.Admin.email == test_email).first()
        if admin:
            print(f"\nTesting login for: {test_email}")
            print(f"Password hash: {admin.password_hash[:50]}...")
            
            # Test password verification
            is_valid = security.verify_password(test_password, admin.password_hash)
            print(f"Password '{test_password}' is valid: {is_valid}")
            
            if is_valid and admin.is_active:
                print("[SUCCESS] Admin login should work!")
            else:
                print("[FAILED] Admin login will fail")
                if not admin.is_active:
                    print("  - Admin account is inactive")
                if not is_valid:
                    print("  - Password verification failed")
        else:
            print(f"Admin with email {test_email} not found!")
            
    except Exception as e:
        print(f"Error: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    check_admin()