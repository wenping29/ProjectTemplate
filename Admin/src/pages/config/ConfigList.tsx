import { useEffect, useState } from 'react';
import { Table, Button, Modal, Form, Input, Switch, Space, Popconfirm, message } from 'antd';
import { configApi, type SystemConfig } from '@/api/system';

export default function ConfigList() {
  const [data, setData] = useState<SystemConfig[]>([]);
  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<SystemConfig | null>(null);
  const [form] = Form.useForm();

  const load = async () => setData(await configApi.list());
  useEffect(() => {
    load();
  }, []);

  const onAdd = () => {
    setEditing(null);
    form.resetFields();
    form.setFieldsValue({ isPublic: 0 });
    setOpen(true);
  };
  const onEdit = (r: SystemConfig) => {
    setEditing(r);
    form.setFieldsValue(r);
    setOpen(true);
  };
  const onSubmit = async () => {
    const v = await form.validateFields();
    await configApi.upsert({ ...v, isPublic: v.isPublic ? 1 : 0 });
    message.success('保存成功');
    setOpen(false);
    load();
  };
  const onDelete = async (id: string) => {
    await configApi.remove(id);
    message.success('已删除');
    load();
  };

  const columns = [
    { title: '配置键', dataIndex: 'configKey' },
    { title: '配置值', dataIndex: 'configValue' },
    { title: '分组', dataIndex: 'configGroup' },
    {
      title: '公开',
      dataIndex: 'isPublic',
      render: (v: number) => (v === 1 ? '是' : '否'),
    },
    { title: '描述', dataIndex: 'description' },
    {
      title: '操作',
      render: (_: unknown, r: SystemConfig) => (
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
          新建配置
        </Button>
      </Space>
      <Table rowKey="id" dataSource={data} columns={columns} />
      <Modal
        title={editing ? '编辑配置' : '新建配置'}
        open={open}
        onOk={onSubmit}
        onCancel={() => setOpen(false)}
      >
        <Form form={form} layout="vertical">
          <Form.Item name="configKey" label="配置键" rules={[{ required: true }]}>
            <Input placeholder="如 site_name" />
          </Form.Item>
          <Form.Item name="configValue" label="配置值">
            <Input.TextArea />
          </Form.Item>
          <Form.Item name="configGroup" label="分组">
            <Input />
          </Form.Item>
          <Form.Item name="description" label="描述">
            <Input />
          </Form.Item>
          <Form.Item name="isPublic" label="对外公开" valuePropName="checked">
            <Switch />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
}
