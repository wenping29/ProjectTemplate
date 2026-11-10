-- ============================================================
-- import.sql  —  数据导入示例（CSV -> users）
-- 需先准备 sample_users.csv（含表头）
-- 在 psql 中执行: \i import.sql
-- ============================================================

-- 导入前确保角色存在
INSERT INTO roles (name, description)
VALUES ('user', '普通用户')
ON CONFLICT (name) DO NOTHING;

\copy users(username, email, display_name, password_hash, role_id, status)
FROM 'sample_users.csv'
WITH (FORMAT csv, HEADER true, QUOTE '"');

-- 导入后刷新统计信息
ANALYZE users;
