<script setup lang="ts">
import { reactive } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { ElMessage } from 'element-plus';
import { authApi } from '@/api/auth';
import { useUserStore } from '@/stores/user';

const user = useUserStore();
const router = useRouter();
const route = useRoute();

const form = reactive({ username: '', password: '' });

async function onSubmit() {
  try {
    const data = await authApi.login(form);
    user.setAuth(data.accessToken, data);
    ElMessage.success('登录成功');
    const redirect = (route.query.redirect as string) || '/';
    router.push(redirect);
  } catch {
    /* 拦截器已提示 */
  }
}
</script>

<template>
  <el-card class="box">
    <template #header>登录</template>
    <el-form :model="form" label-width="80px" @submit.prevent="onSubmit">
      <el-form-item label="用户名">
        <el-input v-model="form.username" placeholder="admin" />
      </el-form-item>
      <el-form-item label="密码">
        <el-input v-model="form.password" type="password" placeholder="Admin@123456" show-password />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="onSubmit">登录</el-button>
        <el-link type="primary" :underline="false" class="ml" @click="router.push('/register')">
          没有账号？去注册
        </el-link>
      </el-form-item>
    </el-form>
  </el-card>
</template>

<style scoped>
.box {
  max-width: 420px;
  margin: 32px auto;
}
.ml {
  margin-left: 12px;
}
</style>
