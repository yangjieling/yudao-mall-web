<template>
  <div class="page-container aftersale-detail" v-loading="loading">
    <template v-if="detail">
      <div class="status-banner">
        <div class="status-text">
          <div class="label">售后状态</div>
          <div class="value">{{ AFTER_SALE_STATUS_MAP[detail.status] || detail.status }}</div>
        </div>
        <div class="status-meta">
          <div>方式 {{ AFTER_SALE_WAY_MAP[detail.way || 0] }}</div>
          <div>退款 {{ formatPrice(detail.refundPrice) }}</div>
        </div>
      </div>

      <div class="panel">
        <h2>申请信息</h2>
        <div class="meta-grid">
          <div><em>原因</em>{{ detail.applyReason }}</div>
          <div v-if="detail.applyDescription"><em>描述</em>{{ detail.applyDescription }}</div>
          <div v-if="detail.auditReason"><em>审核说明</em>{{ detail.auditReason }}</div>
        </div>
        <div class="goods">
          <img :src="detail.picUrl" :alt="detail.spuName" />
          <div>
            <div class="name">{{ detail.spuName }}</div>
            <div class="muted">× {{ detail.count }}</div>
          </div>
        </div>
      </div>

      <div class="panel" v-if="logs.length">
        <h2>处理进度</h2>
        <el-timeline>
          <el-timeline-item
            v-for="(log, i) in logs"
            :key="i"
            :timestamp="formatDateTime(log.createTime)"
          >
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
import { formatDateTime } from '@/utils/datetime'

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
.aftersale-detail {
  padding-bottom: 40px;
}

.status-banner {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 14px;
  padding: 20px 22px;
  border-radius: var(--mall-radius);
  background: linear-gradient(90deg, #fff5f5, #fff);
  border: 1px solid var(--mall-accent-border);
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
}

.status-text .label {
  font-size: 13px;
  color: var(--mall-muted);
  margin-bottom: 4px;
}

.status-text .value {
  font-size: 22px;
  font-weight: 700;
  color: var(--mall-accent);
}

.status-meta {
  font-size: 13px;
  color: var(--mall-muted);
  line-height: 1.7;
  text-align: right;
}

.panel {
  background: var(--mall-surface);
  border-radius: var(--mall-radius);
  padding: 20px 22px;
  margin-bottom: 14px;
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
}

h2 {
  margin: 0 0 14px;
  font-size: 16px;
  display: flex;
  align-items: center;
  gap: 8px;
}

h2::before {
  content: '';
  width: 3px;
  height: 14px;
  border-radius: 2px;
  background: var(--mall-accent);
}

.meta-grid {
  display: grid;
  gap: 10px;
  margin-bottom: 16px;
  font-size: 14px;
}

.meta-grid em {
  font-style: normal;
  color: var(--mall-muted);
  margin-right: 12px;
  display: inline-block;
  min-width: 64px;
}

.goods {
  display: flex;
  gap: 12px;
  align-items: center;
  padding-top: 16px;
  border-top: 1px solid #f3f4f6;
}

.goods img {
  width: 72px;
  height: 72px;
  object-fit: cover;
  border-radius: 8px;
  background: #f3f4f6;
}

.name {
  font-size: 14px;
}

.muted {
  margin-top: 4px;
  color: var(--mall-muted);
  font-size: 12px;
}

.actions {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

@media (max-width: 720px) {
  .status-meta {
    text-align: left;
  }
}
</style>
