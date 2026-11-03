import { Form, Input, Button, Card, Typography, message } from 'antd';
import { UserOutlined, LockOutlined } from '@ant-design/icons';
import { useNavigate } from 'react-router-dom';
import { post } from '@/api/request';
import { useAuth } from '@/store/auth';

interface LoginResp {
  accessToken: string;
  userId: string;
  username: string;
  displayName?: string;
  roleId: string;
}

export default function Login() {
  const navigate = useNavigate();
  const login = useAuth((s) => s.login);

  const onFinish = async (v: { username: string; password: string }) => {
    try {
      const data = await post<LoginResp>('/auth/login', v);
      login(data.accessToken, {
        userId: data.userId,
        username: data.username,
        displayName: data.displayName,
        roleId: data.roleId,
      });
      message.success('登录成功');
      navigate('/dashboard');
    } catch {
      /* 拦截器已提示 */
    }
  };

  return (
    <div style={{ height: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', background: '#f0f2f5' }}>
      <Card title="后台管理系统" style={{ width: 360 }}>
        <Form onFinish={onFinish} size="large">
          <Form.Item name="username" rules={[{ required: true, message: '请输入用户名' }]}>
            <Input prefix={<UserOutlined />} placeholder="用户名" />
          </Form.Item>
          <Form.Item name="password" rules={[{ required: true, message: '请输入密码' }]}>
            <Input.Password prefix={<LockOutlined />} placeholder="密码" />
          </Form.Item>
          <Form.Item>
            <Button type="primary" htmlType="submit" block>
              登录
            </Button>
          </Form.Item>
          <Typography.Text type="secondary">默认管理员：admin / Admin@123456</Typography.Text>
        </Form>
      </Card>
    </div>
  );
}
