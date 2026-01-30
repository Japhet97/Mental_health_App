import sqlite3

conn = sqlite3.connect('yoneco.db')
cursor = conn.cursor()

cursor.execute('SELECT id, email, name FROM counsellors WHERE is_active=1')

print('ID | Email | Name')
print('-' * 70)

for row in cursor.fetchall():
    print(f'{row[0]:2} | {row[1]:35} | {row[2]}')

conn.close()
