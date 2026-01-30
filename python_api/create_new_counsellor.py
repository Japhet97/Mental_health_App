from database import SessionLocal, engine
import models, security

models.Base.metadata.create_all(bind=engine)
db = SessionLocal()
try:
    # New counsellor details
    email = 'dr.thompson@yoneco.org'
    name = 'Dr. Thompson'
    pw = 'counsellor789'
    
    # Check if exists
    existing = db.query(models.Counsellor).filter(models.Counsellor.email == email).first()
    if existing:
        print(f'❌ Counsellor already exists: {email}')
        print(f'   Name: {existing.name}')
        print(f'   Active: {existing.is_active}')
    else:
        # Create new counsellor
        obj = models.Counsellor(
            email=email, 
            name=name, 
            password_hash=security.hash_password(pw),
            is_active=True
        )
        db.add(obj)
        db.commit()
        print('✅ Counsellor created successfully!')
        print(f'   Email: {email}')
        print(f'   Name: {name}')
        print(f'   Password: {pw}')
        print(f'   Status: Active')
finally:
    db.close()
