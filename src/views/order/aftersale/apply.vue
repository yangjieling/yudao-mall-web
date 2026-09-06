<template>
  <div class="page-container aftersale-apply" v-loading="loading">
    <h1>申请售后</h1>
    <div v-if="item" class="panel">
      <div class="goods">
        <img :src="item.picUrl" :alt="item.spuName" />
        <div>
          <div>{{ item.spuName }}</div>
          <div class="muted">x{{ item.count }} · {{ formatPrice(item.payPrice || item.price) }}</div>
        </div>
      </div>

      <el-form label-width="100px" style="max-width: 560px; margin-top: 20px">
        <el-form-item label="售后方式" required>
          <el-radio-group v-model="form.way">
            <el-radio :value="10">仅退款</el-radio>
            <el-radio :value="20">退货退款</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="退款金额">
          <span class="price">{{ formatPrice(form.refundPrice) }}</span>
        </el-form-item>
        <el-form-item label="申请原因" required>
          <el-select v-model="form.applyReason" placeholder="请选择" style="width: 100%">
            <el-option v-for="r in reasons" :key="r" :label="r" :value="r" />
          </el-select>
        </el-form-item>
        <el-form-item label="问题描述">
          <el-input v-model="form.applyDescription" type="textarea" :rows="3" maxlength="200" />
        </el-form-item>
        <el-form-item label="凭证图片">
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
        <el-form-item>
          <el-button type="primary" :loading="submitting" @click="submit">提交申请</el-button>
          <el-button @click="$router.back()">返回</el-button>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, type UploadRequestOptions, type UploadUserFile } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { OrderApi, type TradeOrderItem } from '@/api/trade/order'
import { AfterSaleApi } from '@/api/trade/afterSale'
import { FileApi } from '@/api/infra/file'
import { formatPrice } from '@/utils/price'

const route = useRoute()
const router = useRouter()
const loading = ref(false)
const submitting = ref(false)
const item = ref<TradeOrderItem | null>(null)
const fileList = ref<UploadUserFile[]>([])
const picUrls = ref<string[]>([])

const reasons = ['质量问题', '商品描述不符', '少件/漏发', '包装破损', '不想要了', '其他']

const form = reactive({
  way: 10,
  refundPrice: 0,
  applyReason: '',
  applyDescription: ''
})

async function load() {
  const orderItemId = Number(route.query.orderItemId)
  const orderId = Number(route.query.orderId)
  if (!orderItemId) {
    ElMessage.error('缺少订单项')
    router.back()
    return
  }
  loading.value = true
  try {
    // 若带了 orderId 直接拉详情；否则尝试用 orderItem 关联（部分接口有 item/get）
    if (orderId) {
      const res = await OrderApi.getOrderDetail(orderId)
      item.value = res.data?.items?.find((i) => i.id === orderItemId) || null
    }
    if (!item.value) {
      // 回退：从最近订单页不够，提示从订单详情进入
      ElMessage.error('请从订单详情进入申请售后')
      router.back()
      return
    }
    form.refundPrice = item.value.payPrice || item.value.price * item.value.count
  } finally {
    loading.value = false
  }
}

async function uploadPic(options: UploadRequestOptions) {
  const res = await FileApi.upload(options.file as File, 'aftersale')
  picUrls.value.push(res.data)
  fileList.value.push({
    name: (options.file as File).name,
    url: res.data
  })
}

function onRemove(file: UploadUserFile) {
  picUrls.value = picUrls.value.filter((u) => u !== file.url)
  fileList.value = fileList.value.filter((f) => f.url !== file.url)
}

async function submit() {
  if (!item.value || !form.applyReason) {
    ElMessage.warning('请选择申请原因')
    return
  }
  submitting.value = true
  try {
    const id = await AfterSaleApi.createAfterSale({
      orderItemId: item.value.id,
      way: form.way,
      refundPrice: form.refundPrice,
      applyReason: form.applyReason,
      applyDescription: form.applyDescription || undefined,
      applyPicUrls: picUrls.value
    })
    ElMessage.success('售后申请已提交')
    router.replace(`/order/aftersale/${id.data}`)
  } finally {
    submitting.value = false
  }
}

onMounted(load)
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

.goods {
  display: flex;
  gap: 12px;
  align-items: center;
}

.goods img {
  width: 72px;
  height: 72px;
  object-fit: cover;
  border-radius: 8px;
  background: #f5f5f4;
}

.muted {
  color: var(--mall-muted);
  font-size: 13px;
  margin-top: 4px;
}
</style>
