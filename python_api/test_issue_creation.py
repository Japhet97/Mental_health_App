#!/usr/bin/env python3

import sys
import traceback
from database import SessionLocal
import models
from sqlalchemy import func

def test_issue_creation():
    db = SessionLocal()
    try:
        print("Testing issue creation...")
        
        # Test data
        issue_data = {
            "name_en": "Test Issue",
            "name_ny": "Vuto la Test",
            "description_en": "Test description",
            "description_ny": "Kufotokoza kwa test"
        }
        
        print(f"Creating issue: {issue_data}")
        
        # Find "Other" issue to insert before it
        other_issue = db.query(models.Issue).filter(
            models.Issue.name_en.ilike('%other%')
        ).first()
        
        if other_issue:
            print(f"Found 'Other' issue with order: {other_issue.display_order}")
            new_order = other_issue.display_order
            other_issue.display_order = new_order + 1
        else:
            print("No 'Other' issue found, getting max order")
            max_order = db.query(func.max(models.Issue.display_order)).scalar() or 0
            new_order = max_order + 1
            print(f"Max order: {max_order}, new order: {new_order}")
        
        # Create new issue
        new_issue = models.Issue(
            name_en=issue_data["name_en"],
            name_ny=issue_data["name_ny"],
            description_en=issue_data.get("description_en"),
            description_ny=issue_data.get("description_ny"),
            display_order=new_order
        )
        
        print("Adding issue to database...")
        db.add(new_issue)
        db.commit()
        db.refresh(new_issue)
        
        print(f"Issue created successfully with ID: {new_issue.id}")
        return True
        
    except Exception as e:
        print(f"Error creating issue: {e}")
        print("Full traceback:")
        traceback.print_exc()
        db.rollback()
        return False
    finally:
        db.close()

if __name__ == "__main__":
    success = test_issue_creation()
    sys.exit(0 if success else 1)