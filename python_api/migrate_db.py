# migrate_db.py - Database migration script
from database import engine
from sqlalchemy import text, inspect

def migrate():
    """Add new columns to sessions table if they don't exist"""
    
    print("Starting database migration...")
    
    with engine.connect() as conn:
        # Get existing columns
        inspector = inspect(engine)
        existing_columns = [col['name'] for col in inspector.get_columns('sessions')]
        
        print(f"Existing columns: {existing_columns}")
        
        migrations_applied = []
        
        # Add updated_at column
        if 'updated_at' not in existing_columns:
            try:
                conn.execute(text(
                    "ALTER TABLE sessions ADD COLUMN updated_at DATETIME DEFAULT CURRENT_TIMESTAMP"
                ))
                conn.commit()
                migrations_applied.append("updated_at")
                print("✓ Added updated_at column")
            except Exception as e:
                print(f"✗ Error adding updated_at: {e}")
        else:
            print("  updated_at column already exists")
        
        # Add closed_at column
        if 'closed_at' not in existing_columns:
            try:
                conn.execute(text(
                    "ALTER TABLE sessions ADD COLUMN closed_at DATETIME"
                ))
                conn.commit()
                migrations_applied.append("closed_at")
                print("✓ Added closed_at column")
            except Exception as e:
                print(f"✗ Error adding closed_at: {e}")
        else:
            print("  closed_at column already exists")
        
        # Add timeout_reason column
        if 'timeout_reason' not in existing_columns:
            try:
                conn.execute(text(
                    "ALTER TABLE sessions ADD COLUMN timeout_reason TEXT"
                ))
                conn.commit()
                migrations_applied.append("timeout_reason")
                print("✓ Added timeout_reason column")
            except Exception as e:
                print(f"✗ Error adding timeout_reason: {e}")
        else:
            print("  timeout_reason column already exists")
        
        print("\n" + "="*50)
        if migrations_applied:
            print(f"Migration complete! Added {len(migrations_applied)} column(s):")
            for col in migrations_applied:
                print(f"  - {col}")
        else:
            print("No migrations needed - database is up to date!")
        print("="*50)

if __name__ == "__main__":
    migrate()
