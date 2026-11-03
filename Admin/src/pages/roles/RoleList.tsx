import { useEffect, useState } from 'react';
import { Table, Button, Modal, Form, Input, Space, Popconfirm, message } from 'antd';
import { roleApi, type Role } from '@/api/system';

export default function RoleList() {
  const [data, setData] = useState<Role[]>([]);
  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<Role | null>(null);
  const [form] = Form.useForm();

  const load = async () => setData(await roleApi.list());
  useEffect(() => {
    load();
  }, []);

  const onAdd = () => {
    setEditing(null);
    form.resetFields();
    setOpen(true);
  };
  const onEdit = (r: Role) => {
    setEditing(r);
    form.setFieldsValue(r);
    setOpen(true);
  };
  const onSubmit = async () => {
    const v = await form.validateFields();
    if (editing) await roleApi.update(editing.id, v);
    else await roleApi.create(v);
    message.success('保存成功');
    setOpen(false);
    load();
  };
  const onDelete = async (id: string) => {
    await roleApi.remove(id);
    message.success('已删除');
    load();
  };

  const columns = [
    { title: '名称', dataIndex: 'name' },
    { title: '描述', dataIndex: 'description' },
    { title: '创建时间', dataIndex: 'createdAt' },
    {
      title: '操作',
      render: (_: unknown, r: Role) => (
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
          新建角色
        </Button>
      </Space>
      <Table rowKey="id" dataSource={data} columns={columns} />
      <Modal
        title={editing ? '编辑角色' : '新建角色'}
        open={open}
        onOk={onSubmit}
        onCancel={() => setOpen(false)}
      >
        <Form form={form} layout="vertical">
          <Form.Item name="name" label="角色名称" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="description" label="描述">
            <Input.TextArea />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
}
