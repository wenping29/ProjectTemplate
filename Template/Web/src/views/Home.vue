<script setup lang="ts">
import { useRouter } from 'vue-router';
const router = useRouter();
</script>

<template>
  <section class="hero">
    <h1>欢迎使用官网模板</h1>
    <p>基于 Vue 3 + TypeScript + Vite + Element Plus 构建的官网示例。</p>
    <div class="actions">
      <el-button type="primary" size="large" @click="router.push('/register')">免费注册</el-button>
      <el-button size="large" @click="router.push('/recruitment')">查看招聘</el-button>
    </div>
  </section>

  <el-row :gutter="16" class="cards">
    <el-col :span="8">
      <el-card><template #header>账号体系</template>支持注册、登录、个人信息与头像修改。</el-card>
    </el-col>
    <el-col :span="8">
      <el-card><template #header>关于我们</template>了解公司的使命、愿景与团队。</el-card>
    </el-col>
    <el-col :span="8">
      <el-card><template #header>加入我们</template>查看最新职位，开启职业新篇章。</el-card>
    </el-col>
  </el-row>
</template>

<style scoped>
.hero {
  text-align: center;
  padding: 48px 0;
}
.hero h1 {
  font-size: 32px;
  margin-bottom: 12px;
}
.actions {
  margin-top: 24px;
  display: flex;
  gap: 12px;
  justify-content: center;
}
.cards {
  margin-top: 24px;
}
</style>
