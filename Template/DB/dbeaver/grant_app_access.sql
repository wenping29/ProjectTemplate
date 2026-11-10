-- ============================================================
-- grant_app_access.sql  —  修复应用账号对既有表的访问权限
-- ============================================================
-- 适用场景：
--   用 app_rw / app_ro 连接查询时报
--     ERROR 42501: permission denied for table xxx
--   原因：表在授权生效之前已由其他所有者创建，app_rw/app_ro
--        没有这些"既有表"的权限（默认权限只作用于"之后新建"的表）。
--
-- 用法：在 DBeaver 中用【表的所有者 / superuser（如 postgres）】
--      连接并切换到 app_db，打开本文件 → 全选 → 「执行 SQL 脚本」。
-- 幂等：可重复执行，无副作用。
-- ============================================================

-- 1) 角色（若尚未创建则补建）
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'app_rw') THEN
        CREATE ROLE app_rw LOGIN PASSWORD 'app_rw_pass';
    END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'app_ro') THEN
        CREATE ROLE app_ro LOGIN PASSWORD 'app_ro_pass';
    END IF;
END
$$;

-- 2) 模式使用权限
GRANT CONNECT ON DATABASE app_db TO app_rw, app_ro;
GRANT USAGE ON SCHEMA public TO app_rw, app_ro;

-- 3) 授权既有表 / 序列
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES    IN SCHEMA public TO app_rw;
GRANT USAGE,  SELECT                    ON ALL SEQUENCES IN SCHEMA public TO app_rw;
GRANT SELECT                            ON ALL TABLES    IN SCHEMA public TO app_ro;
GRANT SELECT                            ON ALL SEQUENCES IN SCHEMA public TO app_ro;

-- 4) 默认权限：此后由本所有者新建的表/序列也自动授权
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_rw;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT, INSERT, UPDATE, DELETE ON SEQUENCES TO app_rw;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT ON TABLES TO app_ro;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT ON SEQUENCES TO app_ro;

-- 5) 验证（执行后应能看到各表的权限列表，app_rw 含 arwd）
-- SELECT grantee, table_name, privilege_type
-- FROM information_schema.role_table_grants
-- WHERE table_schema = 'public' AND grantee IN ('app_rw','app_ro')
-- ORDER BY table_name, grantee;
