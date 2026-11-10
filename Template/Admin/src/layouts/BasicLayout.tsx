import { Layout, Menu, Button, Avatar, Dropdown } from 'antd';
import { Outlet, useNavigate } from 'react-router-dom';
import { useAuth } from '@/store/auth';
import {
  DashboardOutlined,
  TeamOutlined,
  UserOutlined,
  MenuOutlined,
  ApiOutlined,
  SettingOutlined,
  LogoutOutlined,
} from '@ant-design/icons';
import type { MenuProps } from 'antd';

const { Sider, Header, Content } = Layout;

const items: MenuProps['items'] = [
  { key: '/dashboard', icon: <DashboardOutlined />, label: '仪表盘' },
  {
    key: 'system',
    icon: <SettingOutlined />,
    label: '系统管理',
    children: [
      { key: '/system/users', icon: <UserOutlined />, label: '用户管理' },
      { key: '/system/roles', icon: <TeamOutlined />, label: '角色管理' },
      { key: '/system/menus', icon: <MenuOutlined />, label: '菜单管理' },
      { key: '/system/functions', icon: <ApiOutlined />, label: '功能管理' },
      { key: '/system/config', icon: <SettingOutlined />, label: '系统配置' },
    ],
  },
];

export default function BasicLayout() {
  const navigate = useNavigate();
  const { user, logout } = useAuth();

  const onClick: MenuProps['onClick'] = ({ key }) => {
    if (!key.startsWith('system')) navigate(key);
  };

  const userMenu: MenuProps['items'] = [
    {
      key: 'logout',
      icon: <LogoutOutlined />,
      label: '退出登录',
      onClick: () => {
        logout();
        navigate('/login');
      },
    },
  ];

  return (
    <Layout style={{ minHeight: '100vh' }}>
      <Sider theme="dark" breakpoint="lg" collapsible>
        <div style={{ color: '#fff', textAlign: 'center', padding: '16px', fontWeight: 600 }}>
          后台管理
        </div>
        <Menu theme="dark" mode="inline" defaultSelectedKeys={['/dashboard']} items={items} onClick={onClick} />
      </Sider>
      <Layout>
        <Header style={{ background: '#fff', display: 'flex', justifyContent: 'flex-end', alignItems: 'center', gap: 12 }}>
          <Avatar icon={<UserOutlined />} />
          <span>{user?.displayName || user?.username || '未登录'}</span>
          <Dropdown menu={{ items: userMenu }} trigger={['click']}>
            <Button icon={<LogoutOutlined />}>账户</Button>
          </Dropdown>
        </Header>
        <Content style={{ margin: 16, padding: 16, background: '#fff', borderRadius: 8, minHeight: 280 }}>
          <Outlet />
        </Content>
      </Layout>
    </Layout>
  );
}
