
import sqlite3
import random
import datetime
import os
import uuid

def generate_message():
    """生成随机聊天消息"""
    messages = [
        "你好！",
        "在吗？",
        "最近怎么样？",
        "有空聊聊吗？",
        "今天天气真好",
        "周末有什么安排？",
        "吃饭了吗？",
        "早上好",
        "晚上好",
        "晚安",
        "谢谢！",
        "不客气",
        "好的",
        "明白了",
        "没问题",
        "稍等一下",
        "我来了",
        "好巧",
        "真的假的？",
        "太棒了！",
        "Hello!",
        "How are you?",
        "Nice to meet you!",
        "What's up?",
        "See you later!",
        "Long time no see!",
        "That's great!",
        "Interesting",
        "I see",
        "Okay"
    ]
    return random.choice(messages)

def main():
    db_path = os.path.join(os.path.dirname(__file__), "../Server", "chatserver.db")

    if not os.path.exists(db_path):
        print(f"Database not found: {db_path}")
        db_path = "chatserver.db"

    print(f"Using database: {db_path}")

    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # 找到admin用户
    cursor.execute("SELECT id, username FROM users WHERE username = 'admin'")
    admin = cursor.fetchone()

    if not admin:
        cursor.execute("SELECT id, username FROM users ORDER BY id LIMIT 1")
        admin = cursor.fetchone()

    admin_id, admin_username = admin
    print(f"Using admin: {admin_username} (ID: {admin_id})")

    # 获取其他用户
    cursor.execute("SELECT id, username FROM users WHERE id != ?", (admin_id,))
    other_users = cursor.fetchall()

    if len(other_users) < 10:
        print(f"Only {len(other_users)} other users available, using all")
        chat_partners = other_users
    else:
        chat_partners = random.sample(other_users, 10)

    print(f"Selected {len(chat_partners)} chat partners")

    total_messages = 0

    for partner_id, partner_username in chat_partners:
        # 生成会话ID
        user_ids = sorted([admin_id, partner_id])
        session_id = f"user_{user_ids[0]}_user_{user_ids[1]}"

        # 检查会话是否已存在
        cursor.execute("SELECT id FROM chat_sessions WHERE session_id = ?", (session_id,))
        if cursor.fetchone():
            print(f"Session with {partner_username} already exists, skipping")
            continue

        print(f"\nCreating session with {partner_username}...")

        # 创建会话
        cursor.execute('''
            INSERT INTO chat_sessions (session_id, user_id1, user_id2, session_name, last_message, last_message_time, unread_count, is_group)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            session_id,
            admin_id,
            partner_id,
            partner_username,
            None,
            None,
            0,
            False
        ))

        # 生成100条聊天记录
        messages = []
        current_time = datetime.datetime.now()

        for i in range(100):
            # 随机决定谁发送消息
            sender_id = admin_id if random.choice([True, False]) else partner_id
            content = generate_message()
            send_time = (current_time - datetime.timedelta(
                minutes=(100 - i) * 5  # 每条消息间隔5分钟
            )).isoformat()

            messages.append((session_id, sender_id, content, send_time, True))

        # 批量插入消息
        cursor.executemany('''
            INSERT INTO chat_messages (session_id, sender_id, content, send_time, is_read)
            VALUES (?, ?, ?, ?, ?)
        ''', messages)

        # 更新会话的最后消息
        last_msg = messages[-1]
        cursor.execute('''
            UPDATE chat_sessions
            SET last_message = ?, last_message_time = ?
            WHERE session_id = ?
        ''', (last_msg[2], last_msg[3], session_id))

        print(f"  Created session and added {len(messages)} messages")
        total_messages += len(messages)

    conn.commit()

    # 统计总数
    cursor.execute("SELECT COUNT(*) FROM chat_sessions")
    total_sessions = cursor.fetchone()[0]
    cursor.execute("SELECT COUNT(*) FROM chat_messages")
    total_messages_in_db = cursor.fetchone()[0]

    conn.close()

    print(f"\nDone!")
    print(f"Total messages added: {total_messages}")
    print(f"Total sessions in database: {total_sessions}")
    print(f"Total messages in database: {total_messages_in_db}")

if __name__ == "__main__":
    main()

