
import sqlite3
import os
import json

db_path = os.path.join(os.path.dirname(__file__), "../Server", "chatserver.db")
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# 查看表结构
print("=== chat_sessions table schema ===")
cursor.execute("PRAGMA table_info(chat_sessions)")
for col in cursor.fetchall():
    print(col)

print("\n=== chat_messages table schema ===")
cursor.execute("PRAGMA table_info(chat_messages)")
for col in cursor.fetchall():
    print(col)

print("\n=== Sample session data ===")
cursor.execute("SELECT * FROM chat_sessions LIMIT 1")
session = cursor.fetchone()
print(session)

print("\n=== Sample message data ===")
cursor.execute("SELECT * FROM chat_messages LIMIT 1")
msg = cursor.fetchone()
print(msg)

conn.close()

