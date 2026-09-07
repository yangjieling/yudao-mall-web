<template>
  <div class="page-container order-list" v-loading="loading">
    <h1>我的订单</h1>

    <div class="status-tabs">
      <button
        v-for="tab in tabs"
        :key="tab.name"
        type="button"
        class="status-tab"
        :class="{ active: statusTab === tab.name }"
        @click="switchTab(tab.name)"
      >
        {{ tab.label }}
      </button>
    </div>

    <el-empty v-if="!list.length" description="暂无订单" :image-size="80">
      <el-button type="primary" @click="$router.push('/category')">去选购</el-button>
    </el-empty>

    <div v-for="order in list" :key="order.id" class="order-card">
      <div class="order-head">
        <div class="head-left">
          <span class="no">订单号 {{ order.no }}</span>
          <span v-if="order.createTime" class="time">{{ order.createTime }}</span>
        </div>
        <span class="status" :class="statusClass(order.status)">
          {{ ORDER_STATUS_MAP[order.status] || order.status }}
        </span>
      </div>

      <div v-for="item in order.items || []" :key="item.id" class="item-row">
        <img :src="item.picUrl" :alt="item.spuName" />
        <div class="item-info">
          <div class="name">{{ item.spuName }}</div>
          <div class="muted">x{{ item.count }}</div>
        </div>
        <div class="price">{{ formatPrice(item.price) }}</div>
      </div>

      <div class="order-foot">
        <div class="sum">
          共 {{ order.productCount || order.items?.length || 0 }} 件，实付
          <span class="price">{{ formatPrice(order.payPrice) }}</span>
        </div>
        <div class="actions">
          <el-button v-if="order.status === 0" type="primary" @click="goPay(order)">去支付</el-button>
          <el-button v-if="order.status === 0" @click="cancel(order.id)">取消</el-button>
          <el-button v-if="order.status === 20" type="primary" @click="receive(order.id)">
            确认收货
          </el-button>
          <el-button @click="$router.push(`/order/${order.id}`)">详情</el-button>
        </div>
      </div>
    </div>

    <div v-if="total > pageSize" class="pager">
      <el-pagination
        background
        layout="prev, pager, next"
        :total="total"
        :page-size="pageSize"
        :current-page="pageNo"
        @current-change="onPage"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { OrderApi, ORDER_STATUS_MAP, type TradeOrder } from '@/api/trade/order'
import { formatPrice } from '@/utils/price'

const route = useRoute()
const router = useRouter()
const loading = ref(false)
const list = ref<TradeOrder[]>([])
const total = ref(0)
const pageNo = ref(1)
const pageSize = 10
const statusTab = ref(normalizeStatus(route.query.status))

const tabs = [
  { name: 'all', label: '全部' },
  { name: '0', label: '待支付' },
  { name: '10', label: '待发货' },
  { name: '20', label: '已发货' },
  { name: '30', label: '已完成' },
  { name: '40', label: '已取消' }
]

function normalizeStatus(raw: unknown): string {
  const val = Array.isArray(raw) ? raw[0] : raw
  if (val === undefined || val === null || val === '' || val === 'all') return 'all'
  return String(val)
}

function statusClass(status: number) {
  if (status === 0) return 'warn'
  if (status === 40) return 'muted'
  if (status === 30) return 'ok'
  return ''
}

async function load() {
  loading.value = true
  try {
    const res = await OrderApi.getOrderPage({
      pageNo: pageNo.value,
      pageSize,
      status: statusTab.value === 'all' ? undefined : Number(statusTab.value)
    })
    list.value = res.data?.list || []
    total.value = res.data?.total || 0
  } finally {
    loading.value = false
  }
}

function switchTab(name: string) {
  if (statusTab.value === name) return
  statusTab.value = name
  pageNo.value = 1
  router.replace({
    path: '/order',
    query: name === 'all' ? {} : { status: name }
  })
  load()
}

watch(
  () => route.query.status,
  (val) => {
    const next = normalizeStatus(val)
    if (next !== statusTab.value) {
      statusTab.value = next
      pageNo.value = 1
      load()
    }
  }
)

function onPage(page: number) {
  pageNo.value = page
  load()
}

function goPay(order: TradeOrder) {
  if (order.payOrderId) {
    router.push({ path: '/pay', query: { id: String(order.payOrderId) } })
  } else {
    ElMessage.warning('暂无支付单')
  }
}

async function cancel(id: number) {
  await ElMessageBox.confirm('确认取消该订单？', '提示')
  await OrderApi.cancelOrder(id)
  ElMessage.success('已取消')
  load()
}

async function receive(id: number) {
  await ElMessageBox.confirm('确认已收到商品？', '提示')
  await OrderApi.receiveOrder(id)
  ElMessage.success('已确认收货')
  load()
}

onMounted(load)
</script>

<style scoped lang="scss">
.order-list {
  padding-bottom: 40px;
}

h1 {
  margin: 0 0 16px;
  font-size: 22px;
  display: flex;
  align-items: center;
  gap: 8px;
}

h1::before {
  content: '';
  width: 4px;
  height: 18px;
  border-radius: 2px;
  background: var(--mall-accent);
}

.status-tabs {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
  margin-bottom: 16px;
  padding: 6px;
  background: var(--mall-surface);
  border-radius: var(--mall-radius);
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
}

.status-tab {
  border: 0;
  background: transparent;
  padding: 8px 16px;
  border-radius: 8px;
  font-size: 14px;
  color: var(--mall-muted);
  cursor: pointer;
}

.status-tab:hover {
  color: var(--mall-accent);
}

.status-tab.active {
  background: var(--mall-accent-soft);
  color: var(--mall-accent);
  font-weight: 600;
}

.order-card {
  background: var(--mall-surface);
  border-radius: var(--mall-radius);
  padding: 16px 20px;
  margin-bottom: 12px;
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
}

.order-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
  padding-bottom: 12px;
  border-bottom: 1px solid #f3f4f6;
}

.head-left {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 12px;
  min-width: 0;
  font-size: 13px;
  color: var(--mall-muted);
}

.no {
  color: var(--mall-ink);
  font-weight: 500;
}

.status {
  flex-shrink: 0;
  color: var(--mall-accent);
  font-weight: 600;
  font-size: 13px;
}

.status.warn {
  color: #ea580c;
}

.status.ok {
  color: #16a34a;
}

.status.muted {
  color: var(--mall-muted);
}

.item-row {
  display: grid;
  grid-template-columns: 64px 1fr auto;
  gap: 12px;
  align-items: center;
  padding: 10px 0;
}

.item-row img {
  width: 64px;
  height: 64px;
  object-fit: cover;
  border-radius: 8px;
  background: #f3f4f6;
}

.name {
  font-size: 14px;
  line-height: 1.4;
}

.muted {
  color: var(--mall-muted);
  font-size: 12px;
  margin-top: 4px;
}

.order-foot {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  margin-top: 8px;
  padding-top: 14px;
  border-top: 1px solid #f3f4f6;
}

.sum {
  font-size: 14px;
  color: var(--mall-muted);
}

.sum .price {
  font-size: 18px;
  margin-left: 4px;
}

.actions {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.pager {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}

@media (max-width: 720px) {
  .order-foot {
    flex-direction: column;
    align-items: flex-end;
  }
}
</style>
