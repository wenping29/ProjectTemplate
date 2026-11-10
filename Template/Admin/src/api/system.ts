import { get, post, put, del } from './request';

// ---- 角色管理 ----
export interface Role {
  id: string;
  name: string;
  description?: string;
  createdAt: string;
}
export const roleApi = {
  list: () => get<Role[]>('/roles'),
  get: (id: string) => get<Role>(`/roles/${id}`),
  create: (d: { name: string; description?: string }) => post<Role>('/roles', d),
  update: (id: string, d: { name: string; description?: string }) => put<Role>(`/roles/${id}`, d),
  remove: (id: string) => del(`/roles/${id}`),
  grant: (id: string, d: { menuIds: string[]; permissionIds: string[] }) => post(`/roles/${id}/grant`, d),
};

// ---- 用户管理 ----
export interface User {
  id: string;
  username: string;
  email: string;
  displayName?: string;
  avatarUrl?: string;
  phone?: string;
  roleId: string;
  status: number;
}
export const userApi = {
  list: (q?: string) => get<User[]>('/users', q ? { q } : undefined),
  get: (id: string) => get<User>(`/users/${id}`),
  create: (d: Partial<User> & { password?: string }) => post<User>('/users', d),
  update: (id: string, d: Partial<User> & { password?: string }) => put<User>(`/users/${id}`, d),
  remove: (id: string) => del(`/users/${id}`),
  updateProfile: (d: { displayName?: string; avatarUrl?: string; phone?: string }) =>
    put('/users/me/profile', d),
};

// ---- 菜单管理 ----
export interface Menu {
  id: string;
  parentId?: string | null;
  name: string;
  type: number; // 1=目录 2=菜单 3=按钮
  path?: string;
  icon?: string;
  component?: string;
  permission?: string;
  sort: number;
  status: number;
}
export const menuApi = {
  list: () => get<Menu[]>('/menus'),
  tree: () => get<Menu[]>('/menus/tree'),
  create: (d: Partial<Menu>) => post<Menu>('/menus', d),
  update: (id: string, d: Partial<Menu>) => put<Menu>(`/menus/${id}`, d),
  remove: (id: string) => del(`/menus/${id}`),
};

// ---- 功能管理 ----
export interface Permission {
  id: string;
  code: string;
  name: string;
  menuId?: string;
  description?: string;
}
export const permissionApi = {
  list: () => get<Permission[]>('/permissions'),
  create: (d: Partial<Permission>) => post<Permission>('/permissions', d),
  update: (id: string, d: Partial<Permission>) => put<Permission>(`/permissions/${id}`, d),
  remove: (id: string) => del(`/permissions/${id}`),
};

// ---- 系统配置 ----
export interface SystemConfig {
  id: string;
  configKey: string;
  configValue?: string;
  configGroup?: string;
  isPublic: number;
  description?: string;
}
export const configApi = {
  list: (group?: string) => get<SystemConfig[]>('/system-config', group ? { group } : undefined),
  public: () => get<Record<string, string>>('/system-config/public'),
  upsert: (d: Partial<SystemConfig>) => post<SystemConfig>('/system-config', d),
  remove: (id: string) => del(`/system-config/${id}`),
};
