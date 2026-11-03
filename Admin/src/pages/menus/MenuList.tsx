import { useEffect, useState } from 'react';
import { Table, Button, Modal, Form, Input, Select, InputNumber, Space, Popconfirm, Tag, message } from 'antd';
import { menuApi, type Menu } from '@/api/system';

const typeOptions = [
  { value: 1, label: '目录' },
  { value: 2, label: '菜单' },
  { value: 3, label: '按钮' },
];

export default function MenuList() {
  const [data, setData] = useState<Menu[]>([]);
  const [parents, setParents] = useState<Menu[]>([]);
  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<Menu | null>(null);
  const [form] = Form.useForm();

  const load = async () => {
    const list = await menuApi.list();
    setData(list);
    setParents(list.filter((m) => m.type === 1 || m.type === 2));
  };
  useEffect(() => {
    load();
  }, []);

  const onAdd = () => {
    setEditing(null);
    form.resetFields();
    form.setFieldsValue({ type: 2, status: 1, sort: 0 });
    setOpen(true);
  };
  const onEdit = (r: Menu) => {
    setEditing(r);
    form.setFieldsValue(r);
    setOpen(true);
  };
  const onSubmit = async () => {
    const v = await form.validateFields();
    if (editing) await menuApi.update(editing.id, v);
    else await menuApi.create(v);
    message.success('保存成功');
    setOpen(false);
    load();
  };
  const onDelete = async (id: string) => {
    await menuApi.remove(id);
    message.success('已删除');
    load();
  };

  const columns = [
    { title: '名称', dataIndex: 'name' },
    {
      title: '类型',
      dataIndex: 'type',
      render: (t: number) => <Tag color={t === 1 ? 'blue' : t === 2 ? 'green' : 'orange'}>{typeOptions.find((o) => o.value === t)?.label}</Tag>,
    },
    { title: '路径', dataIndex: 'path' },
    { title: '权限标识', dataIndex: 'permission' },
    { title: '排序', dataIndex: 'sort' },
    {
      title: '操作',
      render: (_: unknown, r: Menu) => (
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
          新建菜单
        </Button>
      </Space>
      <Table rowKey="id" dataSource={data} columns={columns} />
      <Modal
        title={editing ? '编辑菜单' : '新建菜单'}
        open={open}
        onOk={onSubmit}
        onCancel={() => setOpen(false)}
      >
        <Form form={form} layout="vertical">
          <Form.Item name="parentId" label="父级">
            <Select allowClear options={parents.map((p) => ({ value: p.id, label: p.name }))} />
          </Form.Item>
          <Form.Item name="name" label="名称" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="type" label="类型" rules={[{ required: true }]}>
            <Select options={typeOptions} />
          </Form.Item>
          <Form.Item name="path" label="路由路径">
            <Input />
          </Form.Item>
          <Form.Item name="icon" label="图标">
            <Input />
          </Form.Item>
          <Form.Item name="component" label="组件">
            <Input />
          </Form.Item>
          <Form.Item name="permission" label="权限标识">
            <Input />
          </Form.Item>
          <Form.Item name="sort" label="排序">
            <InputNumber min={0} />
          </Form.Item>
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
