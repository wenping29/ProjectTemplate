
import sqlite3
import os

db_path = os.path.join(os.path.dirname(__file__), "../Server", "chatserver.db")
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

print("=== Chat Sessions ===")
cursor.execute("SELECT * FROM chat_sessions")
sessions = cursor.fetchall()
for session in sessions:
    print(session)

print("\n=== Sample Chat Messages ===")
cursor.execute("SELECT * FROM chat_messages LIMIT 5")
messages = cursor.fetchall()
for msg in messages:
    print(msg)

conn.close()

