<template>
  <div class="page-container comment-page" v-loading="loading">
    <h1>发表评价</h1>
    <div class="panel">
      <el-form label-width="90px" style="max-width: 560px">
        <el-form-item label="评分" required>
          <el-rate v-model="form.scores" />
        </el-form-item>
        <el-form-item label="评价内容" required>
          <el-input v-model="form.content" type="textarea" :rows="4" maxlength="500" show-word-limit />
        </el-form-item>
        <el-form-item label="晒图">
          <el-upload
            list-type="picture-card"
            :http-request="uploadPic"
            :on-remove="onRemove"
            :file-list="fileList"
            accept="image/*"
            :limit="9"
          >
            <el-icon><Plus /></el-icon>
          </el-upload>
        </el-form-item>
        <el-form-item label="匿名">
          <el-switch v-model="form.anonymous" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :loading="submitting" @click="submit">提交评价</el-button>
          <el-button @click="$router.back()">返回</el-button>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, type UploadRequestOptions, type UploadUserFile } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { OrderApi } from '@/api/trade/order'
import { FileApi } from '@/api/infra/file'

const route = useRoute()
const router = useRouter()
const loading = ref(false)
const submitting = ref(false)
const fileList = ref<UploadUserFile[]>([])
const picUrls = ref<string[]>([])

const form = reactive({
  scores: 5,
  content: '',
  anonymous: false
})

async function uploadPic(options: UploadRequestOptions) {
  const res = await FileApi.upload(options.file as File, 'comment')
  picUrls.value.push(res.data)
  fileList.value.push({ name: (options.file as File).name, url: res.data })
}

function onRemove(file: UploadUserFile) {
  picUrls.value = picUrls.value.filter((u) => u !== file.url)
  fileList.value = fileList.value.filter((f) => f.url !== file.url)
}

async function submit() {
  const orderItemId = Number(route.query.orderItemId)
  if (!orderItemId || !form.content) {
    ElMessage.warning('请填写评价内容')
    return
  }
  submitting.value = true
  try {
    await OrderApi.createOrderItemComment({
      orderItemId,
      descriptionScores: form.scores,
      benefitScores: form.scores,
      content: form.content,
      picUrls: picUrls.value,
      anonymous: form.anonymous
    })
    ElMessage.success('评价成功')
    const orderId = route.query.orderId
    router.replace(orderId ? `/order/${orderId}` : '/order')
  } finally {
    submitting.value = false
  }
}
</script>

<style scoped lang="scss">
h1 {
  margin: 0 0 16px;
  font-size: 22px;
}

.panel {
  background: var(--mall-surface);
  border: 1px solid var(--mall-line);
  border-radius: var(--mall-radius);
  padding: 20px;
}
</style>
