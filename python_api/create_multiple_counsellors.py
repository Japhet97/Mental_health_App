# create_multiple_counsellors.py - Create multiple counsellor accounts easily
from database import SessionLocal, engine
import models
import bcrypt

models.Base.metadata.create_all(bind=engine)

# Predefined counsellors
counsellors = [
    {
        "email": "dr.smith@yoneco.org",
        "name": "Dr. John Smith",
        "password": "DrSmith123"
    },
    {
        "email": "dr.jones@yoneco.org",
        "name": "Dr. Sarah Jones",
        "password": "DrJones123"
    },
    {
        "email": "dr.wilson@yoneco.org",
        "name": "Dr. Michael Wilson",
        "password": "DrWilson123"
    },
    {
        "email": "dr.brown@yoneco.org",
        "name": "Dr. Emily Brown",
        "password": "DrBrown123"
    },
    {
        "email": "dr.davis@yoneco.org",
        "name": "Dr. James Davis",
        "password": "DrDavis123"
    }
]

def hash_password(password: str) -> str:
    """Hash password using bcrypt"""
    return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

def create_counsellors():
    db = SessionLocal()
    try:
        created = 0
        existing = 0
        
        print("\n" + "="*50)
        print("Creating Counsellor Accounts")
        print("="*50 + "\n")
        
        for counsellor_data in counsellors:
            email = counsellor_data["email"]
            name = counsellor_data["name"]
            password = counsellor_data["password"]
            
            # Check if exists
            existing_counsellor = db.query(models.Counsellor).filter(
                models.Counsellor.email == email
            ).first()
            
            if existing_counsellor:
                print(f"⚠️  Already exists: {email}")
                existing += 1
            else:
                # Create new counsellor
                new_counsellor = models.Counsellor(
                    email=email,
                    name=name,
                    password_hash=hash_password(password)
                )
                db.add(new_counsellor)
                db.commit()
                print(f"✅ Created: {name} ({email})")
                created += 1
        
        print("\n" + "="*50)
        print(f"Summary: {created} created, {existing} already existed")
        print("="*50)
        
        # Show all counsellors
        print("\n📋 All Counsellors:")
        all_counsellors = db.query(models.Counsellor).all()
        for c in all_counsellors:
            print(f"   - {c.name} ({c.email}) - ID: {c.id}")
        
        print("\n💡 Login credentials:")
        print("   Email: dr.smith@yoneco.org   | Password: DrSmith123")
        print("   Email: dr.jones@yoneco.org   | Password: DrJones123")
        print("   Email: dr.wilson@yoneco.org  | Password: DrWilson123")
        print("   Email: dr.brown@yoneco.org   | Password: DrBrown123")
        print("   Email: dr.davis@yoneco.org   | Password: DrDavis123")
        print("\n")
        
    except Exception as e:
        print(f"❌ Error: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    create_counsellors()

