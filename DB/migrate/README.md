# 数据库迁移 (Migration)

增量变更管理：每次结构变更都新增一个带时间戳的脚本，按顺序执行、可重复回放。

## 命名规范
`migrations/YYYYMMDD_NN_描述.sql`，例如：
```
migrations/
  20260101_01_add_user_avatar.sql
  20260102_01_add_audit_log.sql
```

## 推荐：使用迁移工具
- **dotnet**（Server 端）：EF Core Migrations（`dotnet ef migrations add`）。
- **通用**：Flyway / Liquibase / dbmate，可读取本目录脚本做版本控制。

## 手写迁移示例 20260101_01_add_user_avatar.sql
```sql
ALTER TABLE users ADD COLUMN IF NOT EXISTS avatar_url varchar(500);
```
