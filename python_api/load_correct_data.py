#!/usr/bin/env python3
# load_correct_data.py - Load correct issues, languages, and counsellor
from database import SessionLocal
import models
import security

def load_correct_data():
    db = SessionLocal()
    try:
        # Clear existing data
        db.query(models.Issue).delete()
        db.query(models.Language).delete()
        db.commit()
        
        # Load correct 15 issues
        issues_data = [
            {"name_en": "Depression", "name_ny": "Kupsinjika Maganizo", "display_order": 1},
            {"name_en": "Stress and Anxiety", "name_ny": "Kupsinjika ndi Nkhawa", "display_order": 2},
            {"name_en": "Relationship Issues", "name_ny": "Mavuto Aubwenzi", "display_order": 3},
            {"name_en": "Trauma and PTSD", "name_ny": "Zovulaza Mtima ndi PTSD", "display_order": 4},
            {"name_en": "Substance Abuse", "name_ny": "Kugwiritsa Ntchito Mankhwala Molakwika", "display_order": 5},
            {"name_en": "Self Harm", "name_ny": "Kudzivulaza", "display_order": 6},
            {"name_en": "Grief and Loss", "name_ny": "Chisoni ndi Kutaya", "display_order": 7},
            {"name_en": "Low Self Esteem", "name_ny": "Kudzinyoza", "display_order": 8},
            {"name_en": "Suicidal", "name_ny": "Kudzipha", "display_order": 9},
            {"name_en": "Insomnia/Sleep Problems", "name_ny": "Kusagona/Mavuto a Tulo", "display_order": 10},
            {"name_en": "Family Issues", "name_ny": "Mavuto a Banja", "display_order": 11},
            {"name_en": "Eating Disorder", "name_ny": "Mavuto a Kudya", "display_order": 12},
            {"name_en": "Work Stress", "name_ny": "Kupsinjika kwa Ntchito", "display_order": 13},
            {"name_en": "Academic Stress", "name_ny": "Kupsinjika kwa Maphunziro", "display_order": 14},
            {"name_en": "Other", "name_ny": "Zina", "display_order": 15}
        ]
        
        for issue_data in issues_data:
            issue = models.Issue(**issue_data)
            db.add(issue)
        
        # Load languages
        languages_data = [
            {"code": "en", "name": "English"},
            {"code": "ny", "name": "Chichewa"}
        ]
        
        for lang_data in languages_data:
            language = models.Language(**lang_data)
            db.add(language)
        
        # Add Dr Smith counsellor
        dr_smith = models.Counsellor(
            email="dr.smith@yoneco.org",
            name="Dr Smith",
            password_hash=security.hash_password("counsellor123"),
            is_active=True
        )
        db.add(dr_smith)
        
        db.commit()
        print("Successfully loaded:")
        print(f"- {len(issues_data)} issues")
        print(f"- {len(languages_data)} languages")
        print("- Dr Smith counsellor")
        
    except Exception as e:
        print(f"Error: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    load_correct_data()