#!/usr/bin/env python3
# load_complete_issues.py - Load all 15 issues including the missing ones
from database import SessionLocal
import models

def load_complete_issues():
    db = SessionLocal()
    try:
        # Clear existing issues
        db.query(models.Issue).delete()
        db.commit()
        
        # Complete 15 issues list
        issues_data = [
            {
                "name_en": "Depression",
                "name_ny": "Kupsinjika Maganizo",
                "description_en": "Feelings of sadness, hopelessness, or loss of interest",
                "description_ny": "Kukhumudwa, kusakhala ndi chiyembekezo, kapena kutaya chidwi",
                "display_order": 1
            },
            {
                "name_en": "Anxiety",
                "name_ny": "Nkhawa",
                "description_en": "Excessive worry, fear, or nervousness",
                "description_ny": "Nkhawa zambiri, mantha, kapena kunjenjemera",
                "display_order": 2
            },
            {
                "name_en": "Stress",
                "name_ny": "Kupsinjika Mtima",
                "description_en": "Feeling overwhelmed or under pressure",
                "description_ny": "Kumva ngati zinthu zikukulitsitsa kapena kukakamizidwa",
                "display_order": 3
            },
            {
                "name_en": "Relationship Issues",
                "name_ny": "Mavuto Aubwenzi",
                "description_en": "Problems with family, friends, or romantic relationships",
                "description_ny": "Mavuto ndi achibale, abwenzi, kapena okondana",
                "display_order": 4
            },
            {
                "name_en": "Trauma",
                "name_ny": "Zovulaza Mtima",
                "description_en": "Effects from past traumatic experiences",
                "description_ny": "Zotsatira za zochitika zowawa zakale",
                "display_order": 5
            },
            {
                "name_en": "Substance Abuse",
                "name_ny": "Kugwiritsa Ntchito Mankhwala Molakwika",
                "description_en": "Problems with alcohol or drug use",
                "description_ny": "Mavuto ndi kumwa mowa kapena kugwiritsa ntchito mankhwala osokoneza bongo",
                "display_order": 6
            },
            {
                "name_en": "Self-harm",
                "name_ny": "Kudzivulaza",
                "description_en": "Thoughts or actions of harming oneself",
                "description_ny": "Maganizo kapena kuchita zodzivulaza",
                "display_order": 7
            },
            {
                "name_en": "Grief and Loss",
                "name_ny": "Chisoni ndi Kutaya",
                "description_en": "Coping with loss of a loved one",
                "description_ny": "Kukana chisoni chifukwa cha kutaya munthu wokondedwa",
                "display_order": 8
            },
            {
                "name_en": "Low Self-esteem",
                "name_ny": "Kudzinyoza",
                "description_en": "Negative feelings about yourself",
                "description_ny": "Kuganiza zoipa za inu nokha",
                "display_order": 9
            },
            {
                "name_en": "Bipolar Disorder",
                "name_ny": "Matenda a Bipolar",
                "description_en": "Extreme mood swings between mania and depression",
                "description_ny": "Kusintha kwakukulu kwa maganizo pakati pa chisangalalo ndi chisoni",
                "display_order": 10
            },
            {
                "name_en": "Eating Disorders",
                "name_ny": "Mavuto a Kudya",
                "description_en": "Unhealthy eating patterns and body image issues",
                "description_ny": "Njira zosayenera za kudya ndi mavuto a maganizo a thupi",
                "display_order": 11
            },
            {
                "name_en": "Sleep Disorders",
                "name_ny": "Mavuto a Tulo",
                "description_en": "Problems with sleeping patterns",
                "description_ny": "Mavuto ndi njira za tulo",
                "display_order": 12
            },
            {
                "name_en": "Academic/Work Stress",
                "name_ny": "Kupsinjika kwa Maphunziro/Ntchito",
                "description_en": "Stress related to school or work performance",
                "description_ny": "Kupsinjika kokhudzana ndi maphunziro kapena ntchito",
                "display_order": 13
            },
            {
                "name_en": "Financial Stress",
                "name_ny": "Kupsinjika kwa Ndalama",
                "description_en": "Worry and stress about money and financial security",
                "description_ny": "Nkhawa ndi kupsinjika za ndalama ndi chitetezo cha zachuma",
                "display_order": 14
            },
            {
                "name_en": "Other",
                "name_ny": "Zina",
                "description_en": "Other mental health concerns",
                "description_ny": "Mavuto ena a thanzi la m'maganizo",
                "display_order": 15
            }
        ]
        
        for issue_data in issues_data:
            issue = models.Issue(**issue_data)
            db.add(issue)
        
        db.commit()
        print(f"Successfully loaded {len(issues_data)} issues")
        
    except Exception as e:
        print(f"Error: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    load_complete_issues()