<script setup lang="ts">
import { reactive, ref } from 'vue';
import { ElMessage, type UploadRawFile } from 'element-plus';
import { authApi } from '@/api/auth';
import { useUserStore } from '@/stores/user';

const user = useUserStore();
const form = reactive({
  displayName: user.displayName,
  phone: '',
  avatarUrl: user.avatarUrl,
});
const preview = ref(user.avatarUrl || '');

// 头像修改：本地预览 + 保存到后端。
// 生产环境应先将文件上传至文件服务 / OSS，再把返回的 URL 写入 avatarUrl。
function beforeUpload(rawFile: UploadRawFile) {
  const reader = new FileReader();
  reader.onload = () => {
    preview.value = reader.result as string;
    form.avatarUrl = reader.result as string; // 演示用 dataURL；生产请替换为上传后的地址
  };
  reader.readAsDataURL(rawFile);
  return false; // 阻止自动上传，使用自定义逻辑
}

async function onSave() {
  try {
    await authApi.updateProfile({
      displayName: form.displayName,
      phone: form.phone,
      avatarUrl: form.avatarUrl,
    });
    user.setProfile({ displayName: form.displayName, avatarUrl: form.avatarUrl });
    ElMessage.success('已保存');
  } catch {
    /* 拦截器已提示 */
  }
}
</script>

<template>
  <el-card class="box">
    <template #header>个人信息</template>
    <el-form :model="form" label-width="90px">
      <el-form-item label="头像">
        <el-avatar :size="72" :src="preview || undefined">{{ user.displayName || user.username }}</el-avatar>
        <el-upload
          class="ml"
          :show-file-list="false"
          :before-upload="beforeUpload"
          accept="image/*"
        >
          <el-button size="small">修改头像</el-button>
        </el-upload>
      </el-form-item>
      <el-form-item label="用户名">
        <span>{{ user.username }}</span>
      </el-form-item>
      <el-form-item label="显示名称">
        <el-input v-model="form.displayName" />
      </el-form-item>
      <el-form-item label="手机号">
        <el-input v-model="form.phone" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="onSave">保存修改</el-button>
      </el-form-item>
    </el-form>
  </el-card>
</template>

<style scoped>
.box {
  max-width: 560px;
  margin: 24px auto;
}
.ml {
  margin-left: 16px;
}
</style>
