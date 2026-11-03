<script setup lang="ts">
import { computed } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { useUserStore } from '@/stores/user';

const user = useUserStore();
const route = useRoute();
const router = useRouter();
const isAuth = computed(() => !!user.token);

function logout() {
  user.logout();
  router.push('/');
}
</script>

<template>
  <el-container class="app">
    <el-header class="hd">
      <div class="logo">官网模板</div>
      <el-menu mode="horizontal" :ellipsis="false" router :default-active="route.path" class="nav">
        <el-menu-item index="/">首页</el-menu-item>
        <el-menu-item index="/about">关于</el-menu-item>
        <el-menu-item index="/recruitment">招聘</el-menu-item>
      </el-menu>
      <div class="right">
        <template v-if="isAuth">
          <el-link type="primary" :underline="false" @click="router.push('/profile')">
            {{ user.displayName || user.username }}
          </el-link>
          <el-button text @click="logout">退出</el-button>
        </template>
        <template v-else>
          <el-link type="primary" :underline="false" @click="router.push('/login')">登录</el-link>
          <el-link type="primary" :underline="false" @click="router.push('/register')">注册</el-link>
        </template>
      </div>
    </el-header>
    <el-main class="main">
      <RouterView />
    </el-main>
  </el-container>
</template>

<style scoped>
.app {
  min-height: 100vh;
}
.hd {
  display: flex;
  align-items: center;
  gap: 24px;
  border-bottom: 1px solid #eee;
  background: #fff;
}
.logo {
  font-weight: 700;
  font-size: 18px;
  color: var(--el-color-primary);
}
.nav {
  flex: 1;
  border-bottom: none;
}
.right {
  display: flex;
  align-items: center;
  gap: 12px;
}
.main {
  max-width: 1080px;
  margin: 0 auto;
  width: 100%;
}
</style>
