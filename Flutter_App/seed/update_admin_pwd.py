import sqlite3
import os
import hashlib

def get_md5(text):
    md5 = hashlib.md5()
    md5.update(text.encode('utf-8'))
    return md5.hexdigest()

db_path = os.path.join(os.path.dirname(__file__), "../Server", "chatserver.db")
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

# 更新admin密码为123456
new_password = get_md5("123456")
print(f"123456的MD5: {new_password}")

cursor.execute("UPDATE Users SET Password = ? WHERE Username = 'admin'", (new_password,))
conn.commit()
print("admin密码已更新为123456")

# 验证
cursor.execute("SELECT Username, Password FROM Users WHERE Username = 'admin'")
user = cursor.fetchone()
print(f"验证: Username={user[0]}, Password hash={user[1]}")

conn.close()
