import { useEffect, useState } from 'react';
import { Table, Button, Modal, Form, Input, Select, Space, Popconfirm, message } from 'antd';
import { permissionApi, menuApi, type Permission, type Menu } from '@/api/system';

export default function FunctionList() {
  const [data, setData] = useState<Permission[]>([]);
  const [menus, setMenus] = useState<Menu[]>([]);
  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<Permission | null>(null);
  const [form] = Form.useForm();

  const load = async () => setData(await permissionApi.list());
  useEffect(() => {
    load();
    menuApi.list().then(setMenus);
  }, []);

  const onAdd = () => {
    setEditing(null);
    form.resetFields();
    setOpen(true);
  };
  const onEdit = (r: Permission) => {
    setEditing(r);
    form.setFieldsValue(r);
    setOpen(true);
  };
  const onSubmit = async () => {
    const v = await form.validateFields();
    if (editing) await permissionApi.update(editing.id, v);
    else await permissionApi.create(v);
    message.success('保存成功');
    setOpen(false);
    load();
  };
  const onDelete = async (id: string) => {
    await permissionApi.remove(id);
    message.success('已删除');
    load();
  };

  const columns = [
    { title: '编码', dataIndex: 'code' },
    { title: '名称', dataIndex: 'name' },
    {
      title: '所属菜单',
      dataIndex: 'menuId',
      render: (id?: string) => menus.find((m) => m.id === id)?.name ?? '-',
    },
    { title: '描述', dataIndex: 'description' },
    {
      title: '操作',
      render: (_: unknown, r: Permission) => (
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
        <Button type="primary" onClick={onAdd}>
          新建功能
        </Button>
      </Space>
      <Table rowKey="id" dataSource={data} columns={columns} />
      <Modal
        title={editing ? '编辑功能' : '新建功能'}
        open={open}
        onOk={onSubmit}
        onCancel={() => setOpen(false)}
      >
        <Form form={form} layout="vertical">
          <Form.Item name="code" label="功能编码" rules={[{ required: true }]}>
            <Input placeholder="如 user:create" />
          </Form.Item>
          <Form.Item name="name" label="功能名称" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="menuId" label="所属菜单">
            <Select allowClear options={menus.map((m) => ({ value: m.id, label: m.name }))} />
          </Form.Item>
          <Form.Item name="description" label="描述">
            <Input.TextArea />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
}
