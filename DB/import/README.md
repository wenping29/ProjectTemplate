# 数据导入 (Data Import)

将外部数据（CSV / SQL）导入 PostgreSQL。

## 方式一：CSV 通过 `\copy` 导入
示例见 `sample_users.csv` 与 `import.sql`：

```bash
psql -U app_rw -d app_db -f import.sql
# 或在 psql 交互式执行：
# \copy users(username,email,display_name,password_hash,role_id,status)
#   FROM 'sample_users.csv' WITH (FORMAT csv, HEADER true);
```

## 方式二：批量 SQL
直接编写 `INSERT` 脚本后执行：

```bash
psql -U app_rw -d app_db -f import.sql
```

> 注意：密码字段请使用 `crypt('明文', gen_salt('bf'))` 生成哈希，切勿直接写入明文。
> 大批量导入建议先 `COPY` 落表，再建立索引（参考 `build/` 的拆分顺序）。
