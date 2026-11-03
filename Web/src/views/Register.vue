<script setup lang="ts">
import { reactive } from 'vue';
import { useRouter } from 'vue-router';
import { ElMessage } from 'element-plus';
import { authApi } from '@/api/auth';
import { useUserStore } from '@/stores/user';

const user = useUserStore();
const router = useRouter();
const form = reactive({ username: '', email: '', password: '' });

async function onSubmit() {
  try {
    const data = await authApi.register(form);
    user.setAuth(data.accessToken, data);
    ElMessage.success('注册成功');
    router.push('/');
  } catch {
    /* 拦截器已提示 */
  }
}
</script>

<template>
  <el-card class="box">
    <template #header>注册账号</template>
    <el-form :model="form" label-width="80px" @submit.prevent="onSubmit">
      <el-form-item label="用户名">
        <el-input v-model="form.username" />
      </el-form-item>
      <el-form-item label="邮箱">
        <el-input v-model="form.email" type="email" />
      </el-form-item>
      <el-form-item label="密码">
        <el-input v-model="form.password" type="password" show-password />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="onSubmit">注册</el-button>
        <el-link type="primary" :underline="false" class="ml" @click="router.push('/login')">
          已有账号？去登录
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
