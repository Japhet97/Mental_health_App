# create_counsellor.py
from database import SessionLocal, engine
import models, security
from getpass import getpass

models.Base.metadata.create_all(bind=engine)
db = SessionLocal()
try:
    email = input("Counsellor email: ").strip().lower()
    name = input("Counsellor name: ").strip()
    pw = getpass("Password: ")
    if not email or not pw:
        print("email and password required")
        raise SystemExit(1)
    existing = db.query(models.Counsellor).filter(models.Counsellor.email == email).first()
    if existing:
        print("Counsellor already exists")
    else:
        obj = models.Counsellor(email=email, name=name, password_hash=security.hash_password(pw))
        db.add(obj)
        db.commit()
        print("✅ Counsellor created:", email)
finally:
    db.close()
