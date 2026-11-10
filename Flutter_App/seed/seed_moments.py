
import sqlite3
import random
import datetime
import os
import json

def generate_moment_content():
    """生成朋友圈内容"""
    contents = [
        "今天天气真好！",
        "刚吃完饭，好饱~",
        "工作好累啊，但还是要加油！",
        "周末去爬山了，风景真美",
        "分享一下今天的心情",
        "生日快乐！又长大了一岁",
        "和朋友一起聚会真开心",
        "读了一本好书，推荐给大家",
        "看了一部很棒的电影",
        "运动后的感觉真好",
        "今天学习了新技能",
        "分享一下美食",
        "旅行日记，第一天",
        "终于完成了这个项目！",
        "感谢身边的每一个人",
        "今天是个值得纪念的日子",
        "努力工作，认真生活",
        "记录生活的小美好",
        "和家人在一起的时光最珍贵",
        "今天的日落真美",
        "Hello World!",
        "Just setting up my moments",
        "Coffee time ☕",
        "Beautiful day today!",
        "Working hard",
        "Life is good",
        "Enjoying the moment",
        "Great weekend!",
        "Love this place",
        "Amazing food!"
    ]
    return random.choice(contents)

def generate_images():
    """生成随机图片列表"""
    image_count = random.randint(0, 9)
    if image_count == 0:
        return "[]"

    images = []
    for i in range(image_count):
        images.append(f"https://picsum.photos/400/300?random={random.randint(1, 10000)}")

    return json.dumps(images, ensure_ascii=False)

def main():
    db_path = os.path.join(os.path.dirname(__file__), "../Server", "chatserver.db")

    if not os.path.exists(db_path):
        print(f"Database not found: {db_path}")
        db_path = "chatserver.db"

    print(f"Using database: {db_path}")

    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # 获取所有用户
    cursor.execute("SELECT id, username FROM users")
    users = cursor.fetchall()

    print(f"Found {len(users)} users")

    total_moments = 0

    for user_id, username in users:
        print(f"\nAdding moments for {username} (ID: {user_id})...")

        # 检查该用户已有的朋友圈数量
        cursor.execute("SELECT COUNT(*) FROM Moments WHERE UserId = ?", (user_id,))
        existing_count = cursor.fetchone()[0]

        if existing_count >= 10:
            print(f"  {username} already has {existing_count} moments, skipping")
            continue

        moments_to_add = 10 - existing_count

        for i in range(moments_to_add):
            content = generate_moment_content()
            images = generate_images()
            like_count = random.randint(0, 50)
            comment_count = random.randint(0, 20)
            visibility = random.choice([0, 1, 2])  # 0-仅自己，1-好友可见，2-公开
            create_time = (datetime.datetime.now() - datetime.timedelta(
                days=random.randint(0, 365),
                hours=random.randint(0, 23),
                minutes=random.randint(0, 59)
            )).isoformat()

            cursor.execute('''
                INSERT INTO Moments (UserId, Content, Images, CreateTime, LikeCount, CommentCount, Visibility)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            ''', (user_id, content, images, create_time, like_count, comment_count, visibility))

            print(f"  Added moment {i + 1}/{moments_to_add}")
            total_moments += 1

    conn.commit()

    # 统计总数
    cursor.execute("SELECT COUNT(*) FROM Moments")
    total_in_db = cursor.fetchone()[0]

    conn.close()

    print(f"\nDone!")
    print(f"Total new moments added: {total_moments}")
    print(f"Total moments in database: {total_in_db}")

if __name__ == "__main__":
    main()

