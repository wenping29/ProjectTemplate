import { createBrowserRouter, Navigate } from 'react-router-dom';
import type { JSX } from 'react';
import BasicLayout from '@/layouts/BasicLayout';
import Login from '@/pages/Login';
import Dashboard from '@/pages/Dashboard';
import RoleList from '@/pages/roles/RoleList';
import UserList from '@/pages/users/UserList';
import MenuList from '@/pages/menus/MenuList';
import FunctionList from '@/pages/functions/FunctionList';
import ConfigList from '@/pages/config/ConfigList';

function RequireAuth({ children }: { children: JSX.Element }) {
  const token = localStorage.getItem('token');
  return token ? children : <Navigate to="/login" replace />;
}

export const router = createBrowserRouter([
  { path: '/login', element: <Login /> },
  {
    path: '/',
    element: (
      <RequireAuth>
        <BasicLayout />
      </RequireAuth>
    ),
    children: [
      { index: true, element: <Navigate to="/dashboard" replace /> },
      { path: 'dashboard', element: <Dashboard /> },
      { path: 'system/users', element: <UserList /> },
      { path: 'system/roles', element: <RoleList /> },
      { path: 'system/menus', element: <MenuList /> },
      { path: 'system/functions', element: <FunctionList /> },
      { path: 'system/config', element: <ConfigList /> },
    ],
  },
]);
