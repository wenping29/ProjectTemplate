
import sqlite3
import random
import datetime
import os

def main():
    db_path = os.path.join(os.path.dirname(__file__), "../Server", "chatserver.db")

    if not os.path.exists(db_path):
        print(f"Database not found: {db_path}")
        db_path = "chatserver.db"

    print(f"Using database: {db_path}")

    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # Find admin user
    cursor.execute("SELECT id, username FROM users WHERE username LIKE '%admin%' OR username = 'admin'")
    admin_user = cursor.fetchone()

    if not admin_user:
        cursor.execute("SELECT id, username FROM users ORDER BY id LIMIT 1")
        admin_user = cursor.fetchone()

    if not admin_user:
        print("No users found!")
        return

    admin_id, admin_username = admin_user
    print(f"Using user: {admin_username} (ID: {admin_id})")

    # Get other users
    cursor.execute("SELECT id, username FROM users WHERE id != ?", (admin_id,))
    other_users = cursor.fetchall()

    if len(other_users) < 50:
        print(f"Only {len(other_users)} other users available")
        friend_count = len(other_users)
    else:
        friend_count = 50

    # Randomly select users
    selected_friends = random.sample(other_users, friend_count)

    print(f"\nAdding {friend_count} friends...")

    added = 0
    skipped = 0

    for friend_id, friend_username in selected_friends:
        # Check if friendship already exists
        cursor.execute('''
            SELECT id FROM Friends
            WHERE (UserId = ? AND FriendUserId = ?) OR (UserId = ? AND FriendUserId = ?)
        ''', (admin_id, friend_id, friend_id, admin_id))

        if cursor.fetchone():
            print(f"Skipping existing friendship: {admin_username} <-> {friend_username}")
            skipped += 1
            continue

        create_time = (datetime.datetime.now() - datetime.timedelta(days=random.randint(1, 100))).isoformat()

        # Add both directions
        cursor.execute('''
            INSERT INTO Friends (UserId, FriendUserId, RemarkName, Status, CreateTime)
            VALUES (?, ?, ?, ?, ?)
        ''', (admin_id, friend_id, friend_username, 1, create_time))

        cursor.execute('''
            INSERT INTO Friends (UserId, FriendUserId, RemarkName, Status, CreateTime)
            VALUES (?, ?, ?, ?, ?)
        ''', (friend_id, admin_id, admin_username, 1, create_time))

        print(f"Added friend: {admin_username} <-> {friend_username}")
        added += 1

    conn.commit()

    cursor.execute('''
        SELECT COUNT(*) FROM Friends
        WHERE UserId = ? AND Status = 1
    ''', (admin_id,))
    total_friends = cursor.fetchone()[0]

    conn.close()

    print(f"\nDone!")
    print(f"New friendships: {added} pairs")
    print(f"Skipped: {skipped} pairs")
    print(f"{admin_username} now has {total_friends} friends.")

if __name__ == "__main__":
    main()

