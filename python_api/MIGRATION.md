# Database Migration Guide

## New Fields Added to Session Table

The following fields have been added to improve session tracking:

```sql
ALTER TABLE sessions ADD COLUMN updated_at DATETIME;
ALTER TABLE sessions ADD COLUMN closed_at DATETIME;
ALTER TABLE sessions ADD COLUMN timeout_reason VARCHAR(255);
```

## Option 1: Fresh Start (Development)

If you don't have important data:

```bash
cd python_api

# Delete old database
rm yoneco.db  # or del yoneco.db on Windows

# Restart API - new database will be created automatically
uvicorn main:app --reload
```

The new database will have all the updated fields.

## Option 2: Manual Migration (If you have data)

If you want to keep existing data:

```bash
cd python_api

# Open database
sqlite3 yoneco.db

# Add new columns
ALTER TABLE sessions ADD COLUMN updated_at DATETIME DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE sessions ADD COLUMN closed_at DATETIME;
ALTER TABLE sessions ADD COLUMN timeout_reason TEXT;

# Verify changes
.schema sessions

# Exit
.quit
```

## Option 3: Python Migration Script

Create and run this migration:

```python
# migrate_db.py
from database import engine
from sqlalchemy import text

def migrate():
    with engine.connect() as conn:
        # Check if columns exist
        result = conn.execute(text("PRAGMA table_info(sessions)"))
        columns = [row[1] for row in result]
        
        # Add missing columns
        if 'updated_at' not in columns:
            conn.execute(text(
                "ALTER TABLE sessions ADD COLUMN updated_at DATETIME DEFAULT CURRENT_TIMESTAMP"
            ))
            print("Added updated_at column")
        
        if 'closed_at' not in columns:
            conn.execute(text(
                "ALTER TABLE sessions ADD COLUMN closed_at DATETIME"
            ))
            print("Added closed_at column")
        
        if 'timeout_reason' not in columns:
            conn.execute(text(
                "ALTER TABLE sessions ADD COLUMN timeout_reason TEXT"
            ))
            print("Added timeout_reason column")
        
        conn.commit()
        print("Migration complete!")

if __name__ == "__main__":
    migrate()
```

Run it:
```bash
python migrate_db.py
```

## Verification

After migration, verify the schema:

```bash
sqlite3 yoneco.db
.schema sessions
.quit
```

You should see:
```sql
CREATE TABLE sessions (
    id INTEGER NOT NULL,
    client_name VARCHAR,
    issue VARCHAR,
    status VARCHAR,
    counsellor_id INTEGER,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    closed_at DATETIME,
    timeout_reason VARCHAR,
    PRIMARY KEY (id),
    FOREIGN KEY(counsellor_id) REFERENCES counsellors (id)
);
```

## Recommended Approach

For development: **Option 1** (Fresh start)
For production: **Option 3** (Python script with backups)

## After Migration

1. Restart the API
2. Create a test session
3. Check `/sessions/statistics` endpoint
4. Verify logs show session monitor starting

Done! ✅
