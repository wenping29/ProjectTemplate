
import sqlite3
import random
import hashlib
import datetime
import os

def get_md5(input_string):
    """生成MD5哈希"""
    md5 = hashlib.md5()
    md5.update(input_string.encode('utf-8'))
    return md5.hexdigest()

def generate_users(count):
    """生成用户数据"""
    users = []

    first_names = ["张", "李", "王", "刘", "陈", "杨", "黄", "赵", "周", "吴",
                  "徐", "孙", "马", "朱", "胡", "郭", "何", "林", "高", "罗",
                  "Alice", "Bob", "Charlie", "David", "Emma", "Frank", "Grace", "Henry", "Ivy", "Jack"]

    last_names = ["伟", "芳", "娜", "敏", "静", "丽", "强", "磊", "军", "洋",
                  "勇", "艳", "杰", "涛", "明", "超", "秀英", "华", "平", "刚",
                  "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Martinez"]

    domains = ["gmail.com", "qq.com", "163.com", "outlook.com", "yahoo.com", "hotmail.com", "icloud.com", "126.com"]

    for i in range(count):
        first_name = random.choice(first_names)
        last_name = random.choice(last_names)
        username = f"user_{i + 1}_{random.randint(1000, 9999)}"
        email = f"{username}@{random.choice(domains)}"
        phone = f"1{random.randint(3, 9)}{random.randint(100000000, 999999999)}"
        password = get_md5("123456")
        avatar = f"https://api.dicebear.com/7.x/avataaars/svg?seed={username}"
        create_time = (datetime.datetime.now() - datetime.timedelta(days=random.randint(1, 365))).isoformat()
        last_login_time = (datetime.datetime.now() - datetime.timedelta(days=random.randint(0, 30))).isoformat()

        users.append((username, email, password, avatar, create_time, last_login_time, phone))

    return users

def main():
    db_path = os.path.join(os.path.dirname(__file__), "../Server", "chatserver.db")

    if not os.path.exists(db_path):
        print(f"数据库文件不存在: {db_path}")
        # 尝试当前目录
        db_path = "chatserver.db"

    print(f"使用数据库: {db_path}")

    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # 检查users表是否存在
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='users'")
    if not cursor.fetchone():
        print("users表不存在，先创建表...")
        cursor.execute('''
            CREATE TABLE users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT NOT NULL UNIQUE,
                email TEXT NOT NULL UNIQUE,
                password TEXT NOT NULL,
                avatar TEXT,
                create_time TEXT,
                last_login_time TEXT,
                Phone TEXT
            )
        ''')

    # 生成用户数据
    users = generate_users(100)
    added = 0
    skipped = 0

    print("开始添加100条用户数据...")

    for user in users:
        username, email, password, avatar, create_time, last_login_time, phone = user

        # 检查用户是否已存在
        cursor.execute("SELECT id FROM users WHERE username = ? OR email = ?", (username, email))
        if cursor.fetchone():
            print(f"跳过已存在的用户: {username}")
            skipped += 1
            continue

        # 插入新用户
        cursor.execute('''
            INSERT INTO users (username, email, password, avatar, create_time, last_login_time, Phone)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ''', (username, email, password, avatar, create_time, last_login_time, phone))
        print(f"添加用户: {username}")
        added += 1

    conn.commit()

    # 显示当前用户总数
    cursor.execute("SELECT COUNT(*) FROM users")
    total_count = cursor.fetchone()[0]

    conn.close()

    print(f"\n完成！")
    print(f"新增用户: {added} 条")
    print(f"跳过用户: {skipped} 条")
    print(f"数据库中共有 {total_count} 条用户记录。")

if __name__ == "__main__":
    main()

