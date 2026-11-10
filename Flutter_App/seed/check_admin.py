import sqlite3
import os

db_path = os.path.join(os.path.dirname(__file__), "../Server", "chatserver.db")
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

print("=== admin用户信息 ===")
cursor.execute("SELECT * FROM Users WHERE username = 'admin'")
admin = cursor.fetchone()
if admin:
    print(f"ID: {admin[0]}")
    print(f"Username: {admin[1]}")
    print(f"Email: {admin[2]}")
    print(f"Password hash: {admin[3]}")
    print(f"Avatar: {admin[4]}")
    print(f"CreateTime: {admin[5]}")

print("\n=== 所有用户的密码hash前20个字符 ===")
cursor.execute("SELECT id, username, password FROM Users LIMIT 5")
users = cursor.fetchall()
for u in users:
    print(f"ID: {u[0]}, Username: {u[1]}, Password hash: {u[2][:20]}...")

conn.close()
