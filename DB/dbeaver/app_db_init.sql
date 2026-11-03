-- ============================================================
-- app_db_init.sql  —  DBeaver 一键导入脚本 (PostgreSQL)
-- ============================================================
-- 用途：在 DBeaver 的 SQL 编辑器中打开本文件，全选后「执行 SQL 脚本」
--      （工具栏 ▶  Execute SQL Script，或 Ctrl+A 后 Ctrl+Enter）。
--
-- 前提步骤：
--   1) 若尚未建库，请在「postgres（或任意维护库）」连接上执行本文件末尾
--      「附录A：建库与角色」(已注释，取消注释后单独执行)。
--   2) 用 DBeaver 连接到目标库 app_db（建库后刷新即可看到）。
--   3) 打开本文件，全选执行即可完成：扩展 / 表结构 / 索引 / 种子数据。
--
-- 说明：
--   - 本脚本幂等：含 IF NOT EXISTS / ON CONFLICT DO NOTHING，可重复执行。
--   - 依赖：需 superuser 或具备 CREATE EXTENSION 权限（uuid-ossp、pgcrypto）。
--   - 管理员默认账号：admin / Admin@123456（密码以 bcrypt 存入，由 pgcrypto 生成）。
--   - 请勿在 DBeaver 中开启「每句事务」导致 CREATE EXTENSION 失败；使用默认自动提交即可。
-- ============================================================


-- ---------- 1. 扩展 ----------
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";


-- ---------- 2. 表结构 ----------
-- 角色
CREATE TABLE IF NOT EXISTS roles (
    id          uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        varchar(50) NOT NULL UNIQUE,
    description varchar(200),
    created_at  timestamptz NOT NULL DEFAULT now(),
    updated_at  timestamptz NOT NULL DEFAULT now()
);

-- 用户
CREATE TABLE IF NOT EXISTS users (
    id            uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    username      varchar(50)  NOT NULL UNIQUE,
    email         varchar(120) NOT NULL UNIQUE,
    password_hash text         NOT NULL,
    display_name  varchar(100),
    avatar_url    varchar(500),
    phone         varchar(30),
    role_id       uuid         NOT NULL REFERENCES roles(id),
    status        smallint     NOT NULL DEFAULT 1,   -- 1=启用 0=禁用
    last_login_at timestamptz,
    created_at    timestamptz  NOT NULL DEFAULT now(),
    updated_at    timestamptz  NOT NULL DEFAULT now(),
    deleted_at    timestamptz
);

-- 菜单（菜单管理）
CREATE TABLE IF NOT EXISTS menus (
    id         uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    parent_id  uuid REFERENCES menus(id),
    name       varchar(50)  NOT NULL,
    type       smallint     NOT NULL DEFAULT 2,   -- 1=目录 2=菜单 3=按钮
    path       varchar(200),
    icon       varchar(50),
    component  varchar(200),
    permission varchar(100),
    sort       integer      NOT NULL DEFAULT 0,
    status     smallint     NOT NULL DEFAULT 1,
    created_at timestamptz  NOT NULL DEFAULT now(),
    updated_at timestamptz  NOT NULL DEFAULT now()
);

-- 功能/权限（功能管理）
CREATE TABLE IF NOT EXISTS permissions (
    id          uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    code        varchar(100) NOT NULL UNIQUE,
    name        varchar(100) NOT NULL,
    menu_id     uuid REFERENCES menus(id),
    description varchar(200),
    created_at  timestamptz  NOT NULL DEFAULT now(),
    updated_at  timestamptz  NOT NULL DEFAULT now()
);

-- 角色-菜单
CREATE TABLE IF NOT EXISTS role_menus (
    role_id uuid NOT NULL REFERENCES roles(id),
    menu_id uuid NOT NULL REFERENCES menus(id),
    PRIMARY KEY (role_id, menu_id)
);

-- 角色-功能
CREATE TABLE IF NOT EXISTS role_permissions (
    role_id       uuid NOT NULL REFERENCES roles(id),
    permission_id uuid NOT NULL REFERENCES permissions(id),
    PRIMARY KEY (role_id, permission_id)
);

-- 系统配置
CREATE TABLE IF NOT EXISTS system_config (
    id           uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    config_key   varchar(100) NOT NULL UNIQUE,
    config_value text,
    config_group varchar(50),
    is_public    smallint     NOT NULL DEFAULT 0,   -- 1=对外可查
    description  varchar(200),
    created_at   timestamptz  NOT NULL DEFAULT now(),
    updated_at   timestamptz  NOT NULL DEFAULT now()
);

-- 商品（示例业务表）
CREATE TABLE IF NOT EXISTS products (
    id          uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        varchar(150) NOT NULL,
    description text,
    price       numeric(12,2) NOT NULL DEFAULT 0,
    stock       integer       NOT NULL DEFAULT 0,
    status      smallint      NOT NULL DEFAULT 1,
    created_by  uuid          REFERENCES users(id),
    created_at  timestamptz   NOT NULL DEFAULT now(),
    updated_at  timestamptz   NOT NULL DEFAULT now(),
    deleted_at  timestamptz
);


-- ---------- 3. updated_at 自动维护触发器 ----------
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS trigger AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE t text;
BEGIN
    FOREACH t IN ARRAY ARRAY['roles','users','menus','permissions','system_config','products']
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS trg_%1$s_updated ON %1$s;', t);
        EXECUTE format(
            'CREATE TRIGGER trg_%1$s_updated BEFORE UPDATE ON %1$s
             FOR EACH ROW EXECUTE FUNCTION set_updated_at();', t);
    END LOOP;
END
$$;


-- ---------- 4. 索引 ----------
CREATE INDEX IF NOT EXISTS idx_users_username ON users (username);
CREATE INDEX IF NOT EXISTS idx_users_email    ON users (email);
CREATE INDEX IF NOT EXISTS idx_users_role_id  ON users (role_id);
CREATE INDEX IF NOT EXISTS idx_users_status   ON users (status);
CREATE INDEX IF NOT EXISTS idx_users_deleted  ON users (deleted_at) WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_menus_parent   ON menus (parent_id);
CREATE INDEX IF NOT EXISTS idx_menus_type     ON menus (type);
CREATE INDEX IF NOT EXISTS idx_menus_status   ON menus (status);

CREATE INDEX IF NOT EXISTS idx_permissions_menu ON permissions (menu_id);
CREATE INDEX IF NOT EXISTS idx_permissions_code ON permissions (code);

CREATE INDEX IF NOT EXISTS idx_syscfg_key    ON system_config (config_key);
CREATE INDEX IF NOT EXISTS idx_syscfg_group  ON system_config (config_group);

CREATE INDEX IF NOT EXISTS idx_products_created_by ON products (created_by);
CREATE INDEX IF NOT EXISTS idx_products_status     ON products (status);
CREATE INDEX IF NOT EXISTS idx_products_name       ON products (name);
CREATE INDEX IF NOT EXISTS idx_products_deleted    ON products (deleted_at) WHERE deleted_at IS NULL;


-- ---------- 5. 种子数据 ----------
-- 角色
INSERT INTO roles (name, description)
VALUES ('admin', '系统管理员'), ('user', '普通用户')
ON CONFLICT (name) DO NOTHING;

-- 管理员账号：admin / Admin@123456（bcrypt 哈希由 pgcrypto 生成）
INSERT INTO users (username, email, password_hash, display_name, role_id, status)
SELECT 'admin', 'admin@example.com',
       crypt('Admin@123456', gen_salt('bf')),
       'Administrator', r.id, 1
FROM roles r
WHERE r.name = 'admin'
ON CONFLICT (username) DO NOTHING;

-- 菜单：系统管理（目录）下挂 用户/角色/菜单/功能/配置
INSERT INTO menus (id, parent_id, name, type, path, icon, component, sort, status)
VALUES
  ('11111111-1111-1111-1111-111111111101', NULL, '系统管理', 1, '/system', 'setting', 'Layout', 100, 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO menus (id, parent_id, name, type, path, icon, component, permission, sort, status)
VALUES
  ('11111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111101', '用户管理', 2, '/system/users',    'user',   'system/user',     'user:view',     1, 1),
  ('11111111-1111-1111-1111-111111111112', '11111111-1111-1111-1111-111111111101', '角色管理', 2, '/system/roles',    'team',   'system/role',     'role:view',     2, 1),
  ('11111111-1111-1111-1111-111111111113', '11111111-1111-1111-1111-111111111101', '菜单管理', 2, '/system/menus',    'menu',   'system/menu',     'menu:view',     3, 1),
  ('11111111-1111-1111-1111-111111111114', '11111111-1111-1111-1111-111111111101', '功能管理', 2, '/system/functions','api',    'system/function',  'function:view', 4, 1),
  ('11111111-1111-1111-1111-111111111115', '11111111-1111-1111-1111-111111111101', '系统配置', 2, '/system/config',   'setting','system/config',    'config:view',   5, 1)
ON CONFLICT (id) DO NOTHING;

-- 功能（按钮级权限）
INSERT INTO permissions (code, name, menu_id, description)
VALUES
  ('user:view',   '查看用户', '11111111-1111-1111-1111-111111111111', '用户列表查看'),
  ('user:create', '新建用户', '11111111-1111-1111-1111-111111111111', '新增用户'),
  ('user:update', '编辑用户', '11111111-1111-1111-1111-111111111111', '修改用户'),
  ('user:delete', '删除用户', '11111111-1111-1111-1111-111111111111', '删除用户'),
  ('role:view',   '查看角色', '11111111-1111-1111-1111-111111111112', '角色列表查看'),
  ('role:assign', '角色授权', '11111111-1111-1111-1111-111111111112', '分配角色菜单/功能'),
  ('menu:view',   '查看菜单', '11111111-1111-1111-1111-111111111113', '菜单查看'),
  ('menu:edit',   '编辑菜单', '11111111-1111-1111-1111-111111111113', '菜单增删改'),
  ('function:view',   '查看功能', '11111111-1111-1111-1111-111111111114', '功能查看'),
  ('function:edit',   '编辑功能', '11111111-1111-1111-1111-111111111114', '功能增删改'),
  ('config:view',   '查看配置', '11111111-1111-1111-1111-111111111115', '配置查看'),
  ('config:edit',   '编辑配置', '11111111-1111-1111-1111-111111111115', '配置修改')
ON CONFLICT (code) DO NOTHING;

-- 授权：admin 角色拥有全部菜单与功能
INSERT INTO role_menus (role_id, menu_id)
SELECT r.id, m.id FROM roles r, menus m WHERE r.name = 'admin'
ON CONFLICT DO NOTHING;

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM roles r, permissions p WHERE r.name = 'admin'
ON CONFLICT DO NOTHING;

-- 系统配置
INSERT INTO system_config (config_key, config_value, config_group, is_public, description)
VALUES
  ('site_name',    '项目模板',   'base', 1, '站点名称'),
  ('site_logo',    '/logo.png',  'base', 1, '站点 Logo'),
  ('enable_register', 'true',    'auth', 1, '是否开放注册'),
  ('maintenance',  'false',      'base', 0, '维护模式')
ON CONFLICT (config_key) DO NOTHING;

-- 示例商品（演示数据，可删除）
INSERT INTO products (name, description, price, stock, status)
SELECT '示例商品 A', '模板内置示例', 99.00, 100, 1
WHERE NOT EXISTS (SELECT 1 FROM products)
ON CONFLICT DO NOTHING;


-- ============================================================
-- 附录A：建库与角色（在 postgres 连接上执行，按需取消注释）
-- ============================================================
-- DO $$
-- BEGIN
--   IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'app_db') THEN
--     CREATE DATABASE app_db
--       WITH OWNER = postgres
--       ENCODING = 'UTF8'
--       LC_COLLATE = 'C'
--       LC_CTYPE = 'C'
--       TEMPLATE = template0;
--   END IF;
-- END
-- $$;
--
-- DO $$
-- BEGIN
--   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'app_rw') THEN
--     CREATE ROLE app_rw LOGIN PASSWORD 'app_rw_pass';
--   END IF;
--   IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'app_ro') THEN
--     CREATE ROLE app_ro LOGIN PASSWORD 'app_ro_pass';
--   END IF;
-- END
-- $$;
--
-- GRANT CONNECT ON DATABASE app_db TO app_rw, app_ro;
-- GRANT USAGE, CREATE ON SCHEMA public TO app_rw;
-- GRANT USAGE ON SCHEMA public TO app_ro;
-- ALTER DEFAULT PRIVILEGES IN SCHEMA public
--     GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_rw;
-- ALTER DEFAULT PRIVILEGES IN SCHEMA public
--     GRANT SELECT ON TABLES TO app_ro;
