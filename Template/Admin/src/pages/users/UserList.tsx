import { useEffect, useState } from 'react';
import { Table, Button, Modal, Form, Input, Select, Space, Popconfirm, Input as AntInput, message } from 'antd';
import { userApi, roleApi, type User, type Role } from '@/api/system';

export default function UserList() {
  const [data, setData] = useState<User[]>([]);
  const [roles, setRoles] = useState<Role[]>([]);
  const [q, setQ] = useState('');
  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<User | null>(null);
  const [form] = Form.useForm();

  const load = async () => setData(await userApi.list(q || undefined));
  useEffect(() => {
    load();
    roleApi.list().then(setRoles);
  }, [q]);

  const onAdd = () => {
    setEditing(null);
    form.resetFields();
    setOpen(true);
  };
  const onEdit = (r: User) => {
    setEditing(r);
    form.setFieldsValue(r);
    setOpen(true);
  };
  const onSubmit = async () => {
    const v = await form.validateFields();
    if (editing) await userApi.update(editing.id, v);
    else await userApi.create(v);
    message.success('保存成功');
    setOpen(false);
    load();
  };
  const onDelete = async (id: string) => {
    await userApi.remove(id);
    message.success('已删除');
    load();
  };

  const columns = [
    { title: '用户名', dataIndex: 'username' },
    { title: '邮箱', dataIndex: 'email' },
    { title: '显示名', dataIndex: 'displayName' },
    {
      title: '角色',
      dataIndex: 'roleId',
      render: (id: string) => roles.find((r) => r.id === id)?.name ?? id,
    },
    {
      title: '状态',
      dataIndex: 'status',
      render: (s: number) => (s === 1 ? '启用' : '禁用'),
    },
    {
      title: '操作',
      render: (_: unknown, r: User) => (
        <Space>
          <Button size="small" onClick={() => onEdit(r)}>
            编辑
          </Button>
          <Popconfirm title="确认删除？" onConfirm={() => onDelete(r.id)}>
            <Button size="small" danger>
              删除
            </Button>
          </Popconfirm>
        </Space>
      ),
    },
  ];

  return (
    <div>
      <Space style={{ marginBottom: 12 }}>
        <AntInput.Search
          placeholder="搜索用户名/邮箱"
          allowClear
          onSearch={(v) => setQ(v)}
          style={{ width: 240 }}
        />
        <Button type="primary" onClick={onAdd}>
          新建用户
        </Button>
      </Space>
      <Table rowKey="id" dataSource={data} columns={columns} />
      <Modal
        title={editing ? '编辑用户' : '新建用户'}
        open={open}
        onOk={onSubmit}
        onCancel={() => setOpen(false)}
      >
        <Form form={form} layout="vertical">
          <Form.Item name="username" label="用户名" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="email" label="邮箱" rules={[{ required: true, type: 'email' }]}>
            <Input />
          </Form.Item>
          <Form.Item name="displayName" label="显示名">
            <Input />
          </Form.Item>
          <Form.Item name="phone" label="手机号">
            <Input />
          </Form.Item>
          <Form.Item name="roleId" label="角色" rules={[{ required: true }]}>
            <Select options={roles.map((r) => ({ value: r.id, label: r.name }))} />
          </Form.Item>
          {!editing && (
            <Form.Item name="password" label="初始密码" rules={[{ required: true }]}>
              <Input.Password />
            </Form.Item>
          )}
          <Form.Item name="status" label="状态" initialValue={1}>
            <Select
              options={[
                { value: 1, label: '启用' },
                { value: 0, label: '禁用' },
              ]}
            />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
}
