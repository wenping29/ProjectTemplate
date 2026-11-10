import { post, put } from './request';

export interface LoginResp {
  accessToken: string;
  userId: string;
  username: string;
  displayName?: string;
  roleId: string;
}

export const authApi = {
  login: (d: { username: string; password: string }) => post<LoginResp>('/auth/login', d),
  register: (d: { username: string; email: string; password: string }) =>
    post<LoginResp>('/auth/register', d),
  updateProfile: (d: { displayName?: string; avatarUrl?: string; phone?: string }) =>
    put('/users/me/profile', d),
};
