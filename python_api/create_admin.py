# create_admin.py - Create admin user and initialize default data
from sqlalchemy.orm import Session
from database import SessionLocal, engine
import models
import security

def init_admin():
    """Create default admin user"""
    db = SessionLocal()
    try:
        # Check if admin already exists
        existing_admin = db.query(models.Admin).filter(
            models.Admin.email == "admin@yoneco.org"
        ).first()
        
        if existing_admin:
            print("[INFO] Admin already exists!")
            print(f"Email: admin@yoneco.org")
            return
        
        # Create admin
        admin = models.Admin(
            email="admin@yoneco.org",
            name="YONECO Admin",
            password_hash=security.hash_password("Admin@2025"),
            is_active=True
        )
        db.add(admin)
        db.commit()
        db.refresh(admin)
        
        print("[OK] Admin user created successfully!")
        print(f"Email: admin@yoneco.org")
        print(f"Password: Admin@2025")
        print(f"Name: {admin.name}")
        
    except Exception as e:
        print(f"[ERROR] Error creating admin: {e}")
        db.rollback()
    finally:
        db.close()

def init_default_issues():
    """Create default mental health issues"""
    db = SessionLocal()
    try:
        # Check if issues already exist
        existing_count = db.query(models.Issue).count()
        if existing_count > 0:
            print(f"[INFO] Issues already exist ({existing_count} found)")
            return
        
        default_issues = [
            {
                "name_en": "Depression",
                "name_ny": "Kupsinjika Maganizo",
                "description_en": "Feelings of sadness, hopelessness, or loss of interest",
                "description_ny": "Kukhumudwa, kusakhala ndi chiyembekezo, kapena kutaya chidwi"
            },
            {
                "name_en": "Anxiety",
                "name_ny": "Nkhawa",
                "description_en": "Excessive worry, fear, or nervousness",
                "description_ny": "Nkhawa zambiri, mantha, kapena kunjenjemera"
            },
            {
                "name_en": "Stress",
                "name_ny": "Kupsinjika Mtima",
                "description_en": "Feeling overwhelmed or under pressure",
                "description_ny": "Kumva ngati zinthu zikukulitsitsa kapena kukakamizidwa"
            },
            {
                "name_en": "Relationship Issues",
                "name_ny": "Mavuto Aubwenzi",
                "description_en": "Problems with family, friends, or romantic relationships",
                "description_ny": "Mavuto ndi achibale, abwenzi, kapena okondana"
            },
            {
                "name_en": "Trauma",
                "name_ny": "Zovulaza Mtima",
                "description_en": "Effects from past traumatic experiences",
                "description_ny": "Zotsatira za zochitika zowawa zakale"
            },
            {
                "name_en": "Substance Abuse",
                "name_ny": "Kugwiritsa Ntchito Mankhwala Molakwika",
                "description_en": "Problems with alcohol or drug use",
                "description_ny": "Mavuto ndi kumwa mowa kapena kugwiritsa ntchito mankhwala osokoneza bongo"
            },
            {
                "name_en": "Self-harm",
                "name_ny": "Kudzivulaza",
                "description_en": "Thoughts or actions of harming oneself",
                "description_ny": "Maganizo kapena kuchita zodzivulaza"
            },
            {
                "name_en": "Grief and Loss",
                "name_ny": "Chisoni ndi Kutaya",
                "description_en": "Coping with loss of a loved one",
                "description_ny": "Kukana chisoni chifukwa cha kutaya munthu wokondedwa"
            },
            {
                "name_en": "Low Self-esteem",
                "name_ny": "Kudzinyoza",
                "description_en": "Negative feelings about yourself",
                "description_ny": "Kuganiza zoipa za inu nokha"
            },
            {
                "name_en": "Other",
                "name_ny": "Zina",
                "description_en": "Other mental health concerns",
                "description_ny": "Mavuto ena a thanzi la m'maganizo"
            }
        ]
        
        for issue_data in default_issues:
            issue = models.Issue(**issue_data)
            db.add(issue)
        
        db.commit()
        print(f"[OK] Created {len(default_issues)} default issues")
        
    except Exception as e:
        print(f"[ERROR] Error creating issues: {e}")
        db.rollback()
    finally:
        db.close()

def init_default_languages():
    """Create default languages"""
    db = SessionLocal()
    try:
        # Check if languages already exist
        existing_count = db.query(models.Language).count()
        if existing_count > 0:
            print(f"[INFO] Languages already exist ({existing_count} found)")
            return
        
        default_languages = [
            {"code": "en", "name": "English"},
            {"code": "ny", "name": "Chichewa"}
        ]
        
        for lang_data in default_languages:
            lang = models.Language(**lang_data)
            db.add(lang)
        
        db.commit()
        print(f"[OK] Created {len(default_languages)} default languages")
        
    except Exception as e:
        print(f"[ERROR] Error creating languages: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    print("\nInitializing Admin Dashboard Data...\n")
    
    # Create tables if they don't exist
    models.Base.metadata.create_all(bind=engine)
    
    # Initialize data
    init_admin()
    init_default_issues()
    init_default_languages()
    
    print("\nInitialization complete!\n")
