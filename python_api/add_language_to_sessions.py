"""
Migration script to add language column to sessions table
"""
import sqlite3

def migrate():
    conn = sqlite3.connect('yoneco.db')
    cursor = conn.cursor()
    
    try:
        # Check if language column already exists
        cursor.execute("PRAGMA table_info(sessions)")
        columns = [column[1] for column in cursor.fetchall()]
        
        if 'language' not in columns:
            print("Adding 'language' column to sessions table...")
            cursor.execute("ALTER TABLE sessions ADD COLUMN language TEXT DEFAULT 'en'")
            conn.commit()
            print("✓ Successfully added 'language' column")
        else:
            print("'language' column already exists")
            
    except Exception as e:
        print(f"Error during migration: {e}")
        conn.rollback()
    finally:
        conn.close()

if __name__ == "__main__":
    migrate()
