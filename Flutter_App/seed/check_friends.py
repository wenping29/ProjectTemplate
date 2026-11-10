import sqlite3
import os

db_path = os.path.join(os.path.dirname(__file__), "../Server", "chatserver.db")
conn = sqlite3.connect(db_path)
cursor = conn.cursor()

print("=== 好友表数据 ===")
cursor.execute("SELECT * FROM Friends")
friends = cursor.fetchall()
print(f"共 {len(friends)} 条好友关系")
for f in friends[:10]:  # 只显示前10条
    print(f)

print("\n=== 用户表数据 ===")
cursor.execute("SELECT id, username FROM Users")
users = cursor.fetchall()
print(f"共 {len(users)} 个用户")
for u in users[:10]:
    print(u)

print("\n=== admin的好友关系 ===")
cursor.execute("SELECT * FROM Friends WHERE UserId = 1")
admin_friends = cursor.fetchall()
print(f"admin共有 {len(admin_friends)} 个好友")
for f in admin_friends[:10]:
    print(f)

print("\n=== 反向检查admin的好友关系 ===")
cursor.execute("SELECT * FROM Friends WHERE FriendUserId = 1")
admin_friends2 = cursor.fetchall()
print(f"作为好友被添加 {len(admin_friends2)} 次")
for f in admin_friends2[:10]:
    print(f)

conn.close()
