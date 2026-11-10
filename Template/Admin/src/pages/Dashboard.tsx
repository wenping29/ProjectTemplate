import { Typography, Row, Col, Card, Statistic } from 'antd';

export default function Dashboard() {
  return (
    <div>
      <Typography.Title level={3}>仪表盘</Typography.Title>
      <Row gutter={16}>
        <Col span={6}>
          <Card>
            <Statistic title="用户数" value={0} />
          </Card>
        </Col>
        <Col span={6}>
          <Card>
            <Statistic title="角色数" value={0} />
          </Card>
        </Col>
        <Col span={6}>
          <Card>
            <Statistic title="菜单数" value={0} />
          </Card>
        </Col>
        <Col span={6}>
          <Card>
            <Statistic title="功能数" value={0} />
          </Card>
        </Col>
      </Row>
    </div>
  );
}
