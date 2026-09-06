<template>
  <div class="page-container aftersale-detail" v-loading="loading">
    <template v-if="detail">
      <div class="panel">
        <h1>售后详情</h1>
        <div class="meta">
          <div>状态：{{ AFTER_SALE_STATUS_MAP[detail.status] || detail.status }}</div>
          <div>方式：{{ AFTER_SALE_WAY_MAP[detail.way || 0] }}</div>
          <div>退款金额：{{ formatPrice(detail.refundPrice) }}</div>
          <div>原因：{{ detail.applyReason }}</div>
          <div v-if="detail.applyDescription">描述：{{ detail.applyDescription }}</div>
          <div v-if="detail.auditReason">审核说明：{{ detail.auditReason }}</div>
        </div>
        <div class="goods">
          <img :src="detail.picUrl" :alt="detail.spuName" />
          <div>{{ detail.spuName }} × {{ detail.count }}</div>
        </div>
      </div>

      <div class="panel" v-if="logs.length">
        <h2>处理进度</h2>
        <el-timeline>
          <el-timeline-item v-for="(log, i) in logs" :key="i" :timestamp="log.createTime">
            {{ log.content }}
          </el-timeline-item>
        </el-timeline>
      </div>

      <div class="actions">
        <el-button v-if="detail.status === 10" @click="cancel">取消售后</el-button>
        <el-button v-if="detail.status === 20" type="primary" @click="deliveryVisible = true">
          填写退货物流
        </el-button>
        <el-button @click="$router.push('/order/aftersale')">返回列表</el-button>
      </div>
    </template>

    <el-dialog v-model="deliveryVisible" title="退货物流" width="420px">
      <el-form label-width="90px">
        <el-form-item label="快递公司" required>
          <el-select v-model="deliveryForm.logisticsId" filterable style="width: 100%">
            <el-option v-for="e in expresses" :key="e.id" :label="e.name" :value="e.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="快递单号" required>
          <el-input v-model="deliveryForm.logisticsNo" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="deliveryVisible = false">取消</el-button>
        <el-button type="primary" :loading="delivering" @click="submitDelivery">提交</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  AfterSaleApi,
  AFTER_SALE_STATUS_MAP,
  AFTER_SALE_WAY_MAP,
  type AfterSale,
  type AfterSaleLog
} from '@/api/trade/afterSale'
import { DeliveryApi, type ExpressCompany } from '@/api/trade/delivery'
import { formatPrice } from '@/utils/price'

const route = useRoute()
const loading = ref(false)
const detail = ref<AfterSale | null>(null)
const logs = ref<AfterSaleLog[]>([])
const deliveryVisible = ref(false)
const delivering = ref(false)
const expresses = ref<ExpressCompany[]>([])
const deliveryForm = reactive({
  logisticsId: undefined as number | undefined,
  logisticsNo: ''
})

async function load() {
  const id = Number(route.params.id)
  if (!id) return
  loading.value = true
  try {
    const [d, l] = await Promise.all([
      AfterSaleApi.getAfterSale(id),
      AfterSaleApi.getAfterSaleLogList(id)
    ])
    detail.value = d.data
    logs.value = l.data || []
  } finally {
    loading.value = false
  }
}

async function cancel() {
  if (!detail.value) return
  await ElMessageBox.confirm('确认取消该售后申请？', '提示')
  await AfterSaleApi.cancelAfterSale(detail.value.id)
  ElMessage.success('已取消')
  load()
}

async function submitDelivery() {
  if (!detail.value || !deliveryForm.logisticsId || !deliveryForm.logisticsNo) {
    ElMessage.warning('请填写完整物流信息')
    return
  }
  delivering.value = true
  try {
    await AfterSaleApi.deliveryAfterSale({
      id: detail.value.id,
      logisticsId: deliveryForm.logisticsId,
      logisticsNo: deliveryForm.logisticsNo
    })
    ElMessage.success('已提交退货物流')
    deliveryVisible.value = false
    load()
  } finally {
    delivering.value = false
  }
}

onMounted(async () => {
  const res = await DeliveryApi.getExpressList()
  expresses.value = res.data || []
  await load()
})
</script>

<style scoped lang="scss">
.panel {
  background: var(--mall-surface);
  border: 1px solid var(--mall-line);
  border-radius: var(--mall-radius);
  padding: 20px;
  margin-bottom: 16px;
}

h1 {
  margin: 0 0 12px;
  font-size: 22px;
}

h2 {
  margin: 0 0 12px;
  font-size: 16px;
}

.meta {
  color: var(--mall-muted);
  line-height: 1.8;
  margin-bottom: 16px;
}

.goods {
  display: flex;
  gap: 12px;
  align-items: center;
}

.goods img {
  width: 64px;
  height: 64px;
  object-fit: cover;
  border-radius: 8px;
  background: #f5f5f4;
}

.actions {
  display: flex;
  gap: 10px;
}
</style>
