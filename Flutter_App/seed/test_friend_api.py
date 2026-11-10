import requests
import json

# 首先登录获取token
login_url = "http://localhost:5003/api/Auth/Login"
login_data = {
    "account": "admin",
    "password": "123456"
}

print("=== 登录 ===")
try:
    login_response = requests.post(login_url, json=login_data)
    print(f"状态码: {login_response.status_code}")
    print(f"响应: {login_response.text}")

    if login_response.status_code == 200:
        result = login_response.json()
        print(f"解析结果: {result}")
        if isinstance(result, dict) and result.get('code') == 200:
            token = result['data']
            print(f"获取到token: {token[:50]}...")

            # 使用token查询好友列表
            print("\n=== 查询好友列表 ===")
            friend_url = "http://localhost:5003/api/Friend/MyFriends"
            headers = {
                "Authorization": f"Bearer {token}"
            }

            friend_response = requests.get(friend_url, headers=headers)
            print(f"状态码: {friend_response.status_code}")
            print(f"响应: {json.dumps(friend_response.json(), indent=2, ensure_ascii=False)}")
        else:
            print(f"登录失败: {result.get('message')}")
    else:
        print(f"登录请求失败")

except Exception as e:
    print(f"请求异常: {e}")
    import traceback
    traceback.print_exc()
