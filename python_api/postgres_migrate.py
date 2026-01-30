# postgres_migrate.py - Create tables in PostgreSQL database
import os
import sqlite3
from sqlalchemy import text
from database import engine, SessionLocal
import models

def create_postgres_tables():
    """Create all tables in PostgreSQL database"""
    print("Creating tables in PostgreSQL database...")
    print("="*50)
    
    try:
        # Create all tables
        models.Base.metadata.create_all(bind=engine)
        print("[OK] All tables created successfully in PostgreSQL")
        
        # Verify tables were created
        with engine.connect() as conn:
            result = conn.execute(text("""
                SELECT table_name 
                FROM information_schema.tables 
                WHERE table_schema = 'public'
                ORDER BY table_name
            """))
            tables = [row[0] for row in result]
            
            print(f"[OK] Created tables: {', '.join(tables)}")
            
            # Check sessions table schema
            result = conn.execute(text("""
                SELECT column_name, data_type 
                FROM information_schema.columns 
                WHERE table_name = 'sessions'
                ORDER BY ordinal_position
            """))
            columns = [(row[0], row[1]) for row in result]
            
            print("\nSessions table schema:")
            for col_name, col_type in columns:
                print(f"  - {col_name}: {col_type}")
        
        return True
        
    except Exception as e:
        print(f"[ERROR] Failed to create tables: {e}")
        return False

def migrate_sqlite_to_postgres():
    """Migrate data from SQLite to PostgreSQL"""
    sqlite_path = "yoneco.db"
    
    if not os.path.exists(sqlite_path):
        print("No SQLite database found - starting with empty PostgreSQL database")
        return True
    
    print(f"Migrating data from {sqlite_path} to PostgreSQL...")
    
    # Connect to SQLite
    sqlite_conn = sqlite3.connect(sqlite_path)
    sqlite_conn.row_factory = sqlite3.Row
    
    try:
        with engine.connect() as pg_conn:
            # Migrate counsellors
            cursor = sqlite_conn.execute("SELECT * FROM counsellors")
            counsellors = [dict(row) for row in cursor.fetchall()]
            
            for counsellor in counsellors:
                # Convert integer to boolean for is_active
                counsellor['is_active'] = bool(counsellor['is_active'])
                pg_conn.execute(text("""
                    INSERT INTO counsellors (id, email, name, password_hash, is_active, created_at)
                    VALUES (:id, :email, :name, :password_hash, :is_active, :created_at)
                    ON CONFLICT (id) DO NOTHING
                """), counsellor)
            
            print(f"[OK] Migrated {len(counsellors)} counsellors")
            
            # Migrate sessions
            cursor = sqlite_conn.execute("SELECT * FROM sessions")
            sessions = [dict(row) for row in cursor.fetchall()]
            
            for session in sessions:
                # Ensure all required fields exist
                session['updated_at'] = session.get('updated_at') or session.get('created_at')
                session['closed_at'] = session.get('closed_at')
                session['timeout_reason'] = session.get('timeout_reason')
                session['language'] = session.get('language', 'en')
                
                pg_conn.execute(text("""
                    INSERT INTO sessions (id, client_name, issue, language, status, counsellor_id, 
                                        created_at, updated_at, closed_at, timeout_reason)
                    VALUES (:id, :client_name, :issue, :language, :status, :counsellor_id, 
                           :created_at, :updated_at, :closed_at, :timeout_reason)
                    ON CONFLICT (id) DO NOTHING
                """), session)
            
            print(f"[OK] Migrated {len(sessions)} sessions")
            
            # Migrate messages
            cursor = sqlite_conn.execute("SELECT * FROM messages")
            messages = [dict(row) for row in cursor.fetchall()]
            
            for message in messages:
                pg_conn.execute(text("""
                    INSERT INTO messages (id, session_id, sender, content, timestamp)
                    VALUES (:id, :session_id, :sender, :content, :timestamp)
                    ON CONFLICT (id) DO NOTHING
                """), message)
            
            print(f"[OK] Migrated {len(messages)} messages")
            
            # Migrate other tables if they exist
            for table_name in ['issues', 'languages', 'admins']:
                try:
                    cursor = sqlite_conn.execute(f"SELECT * FROM {table_name}")
                    rows = [dict(row) for row in cursor.fetchall()]
                    
                    for row in rows:
                        if table_name == 'issues':
                            row['is_active'] = bool(row['is_active'])
                            pg_conn.execute(text("""
                                INSERT INTO issues (id, name_en, name_ny, description_en, description_ny, is_active, created_at, updated_at)
                                VALUES (:id, :name_en, :name_ny, :description_en, :description_ny, :is_active, :created_at, :updated_at)
                                ON CONFLICT (id) DO NOTHING
                            """), row)
                        elif table_name == 'languages':
                            row['is_active'] = bool(row['is_active'])
                            pg_conn.execute(text("""
                                INSERT INTO languages (id, code, name, is_active, created_at)
                                VALUES (:id, :code, :name, :is_active, :created_at)
                                ON CONFLICT (id) DO NOTHING
                            """), row)
                        elif table_name == 'admins':
                            row['is_active'] = bool(row['is_active'])
                            pg_conn.execute(text("""
                                INSERT INTO admins (id, email, name, password_hash, is_active, created_at)
                                VALUES (:id, :email, :name, :password_hash, :is_active, :created_at)
                                ON CONFLICT (id) DO NOTHING
                            """), row)
                    
                    print(f"[OK] Migrated {len(rows)} {table_name}")
                    
                except sqlite3.OperationalError:
                    print(f"[INFO] Table {table_name} not found in SQLite - skipping")
            
            pg_conn.commit()
            
    except Exception as e:
        print(f"[ERROR] Migration failed: {e}")
        return False
    finally:
        sqlite_conn.close()
    
    return True

def main():
    print("PostgreSQL Migration Script")
    print("="*50)
    
    # Step 1: Create tables
    if not create_postgres_tables():
        return
    
    # Step 2: Migrate data from SQLite (if exists)
    if not migrate_sqlite_to_postgres():
        return
    
    print("\n" + "="*50)
    print("Migration to PostgreSQL completed successfully!")
    print("\nNext steps:")
    print("1. Update your .env file with correct PostgreSQL credentials")
    print("2. Start API: python -m uvicorn main:app --reload")
    print("3. Test endpoints to verify everything works")
    print("4. Check your PostgreSQL database for all tables and data")

if __name__ == "__main__":
    main()