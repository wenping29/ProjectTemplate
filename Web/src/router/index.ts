import { createRouter, createWebHistory } from 'vue-router';
import type { RouteRecordRaw } from 'vue-router';

const routes: RouteRecordRaw[] = [
  { path: '/', name: 'home', component: () => import('@/views/Home.vue') },
  { path: '/login', name: 'login', component: () => import('@/views/Login.vue') },
  { path: '/register', name: 'register', component: () => import('@/views/Register.vue') },
  {
    path: '/profile',
    name: 'profile',
    meta: { auth: true },
    component: () => import('@/views/Profile.vue'),
  },
  { path: '/about', name: 'about', component: () => import('@/views/About.vue') },
  { path: '/recruitment', name: 'recruitment', component: () => import('@/views/Recruitment.vue') },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

router.beforeEach((to) => {
  const token = localStorage.getItem('token');
  if (to.meta.auth && !token) {
    return { name: 'login', query: { redirect: to.fullPath } };
  }
});

export { router };
