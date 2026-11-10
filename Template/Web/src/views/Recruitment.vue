<script setup lang="ts">
import { ref } from 'vue';
import { ElMessage } from 'element-plus';

interface Job {
  id: number;
  title: string;
  dept: string;
  location: string;
  type: string;
}

const jobs = ref<Job[]>([
  { id: 1, title: '前端工程师', dept: '研发部', location: '远程 / 上海', type: '全职' },
  { id: 2, title: '后端工程师 (C#)', dept: '研发部', location: '上海', type: '全职' },
  { id: 3, title: '产品设计师', dept: '设计部', location: '北京', type: '全职' },
  { id: 4, title: '运维工程师', dept: '基础架构', location: '远程', type: '兼职' },
]);

function apply(job: Job) {
  ElMessage.success(`已收到「${job.title}」的应聘意向（演示）`);
}
</script>

<template>
  <div class="page">
    <h1>招聘信息</h1>
    <el-table :data="jobs" style="width: 100%; margin-top: 16px">
      <el-table-column prop="title" label="职位" />
      <el-table-column prop="dept" label="部门" />
      <el-table-column prop="location" label="地点" />
      <el-table-column prop="type" label="类型" />
      <el-table-column label="操作">
        <template #default="{ row }">
          <el-button size="small" type="primary" @click="apply(row)">投递简历</el-button>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<style scoped>
.page {
  padding: 16px 0;
}
</style>
