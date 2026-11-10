<script setup lang="ts"></script>

<template>
  <div class="page">
    <h1>关于我们</h1>
    <el-divider />
    <p>
      这是我们基于 Vue 3 + TypeScript + Vite + Element Plus 搭建的官网模板示例。
      你可以基于此模板快速扩展出真实的产品官网。
    </p>
    <el-row :gutter="16" class="blocks">
      <el-col :span="8"><el-card><template #header>使命</template>用技术创造简单可控的数字体验。</el-card></el-col>
      <el-col :span="8"><el-card><template #header>愿景</template>成为可信赖的技术合作伙伴。</el-card></el-col>
      <el-col :span="8"><el-card><template #header>价值观</template>开放、务实、长期主义。</el-card></el-col>
    </el-row>
  </div>
</template>

<style scoped>
.page {
  padding: 16px 0;
}
.blocks {
  margin-top: 16px;
}
</style>
