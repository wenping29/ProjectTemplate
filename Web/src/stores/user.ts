import { defineStore } from 'pinia';

interface UserState {
  token: string | null;
  userId: string;
  username: string;
  displayName: string;
  avatarUrl: string;
}

export const useUserStore = defineStore('user', {
  state: (): UserState => ({
    token: localStorage.getItem('token'),
    userId: '',
    username: '',
    displayName: '',
    avatarUrl: '',
  }),
  actions: {
    setAuth(
      token: string,
      info: { userId: string; username: string; displayName?: string; roleId: string },
    ) {
      this.token = token;
      this.userId = info.userId;
      this.username = info.username;
      this.displayName = info.displayName ?? '';
      localStorage.setItem('token', token);
    },
    setProfile(p: { displayName?: string; avatarUrl?: string }) {
      if (p.displayName !== undefined) this.displayName = p.displayName;
      if (p.avatarUrl !== undefined) this.avatarUrl = p.avatarUrl;
    },
    logout() {
      this.token = null;
      localStorage.removeItem('token');
    },
  },
});
