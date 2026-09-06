<template>
  <div class="page-container order-list" v-loading="loading">
    <h1>我的订单</h1>

    <el-tabs v-model="statusTab" @tab-change="onTabChange">
      <el-tab-pane label="全部" name="all" />
      <el-tab-pane label="待支付" name="0" />
      <el-tab-pane label="待发货" name="10" />
      <el-tab-pane label="已发货" name="20" />
      <el-tab-pane label="已完成" name="30" />
      <el-tab-pane label="已取消" name="40" />
    </el-tabs>

    <el-empty v-if="!list.length" description="暂无订单" />

    <div v-for="order in list" :key="order.id" class="order-card">
      <div class="order-head">
        <span>订单号 {{ order.no }}</span>
        <span class="status">{{ ORDER_STATUS_MAP[order.status] || order.status }}</span>
      </div>
      <div v-for="item in order.items || []" :key="item.id" class="item-row">
        <img :src="item.picUrl" :alt="item.spuName" />
        <div class="item-info">
          <div>{{ item.spuName }}</div>
          <div class="muted">x{{ item.count }}</div>
        </div>
        <div class="price">{{ formatPrice(item.price) }}</div>
      </div>
      <div class="order-foot">
        <div>
          共 {{ order.productCount || order.items?.length || 0 }} 件，实付
          <span class="price">{{ formatPrice(order.payPrice) }}</span>
        </div>
        <div class="actions">
          <el-button v-if="order.status === 0" @click="goPay(order)">去支付</el-button>
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

function normalizeStatus(raw: unknown): string {
  const val = Array.isArray(raw) ? raw[0] : raw
  if (val === undefined || val === null || val === '' || val === 'all') return 'all'
  return String(val)
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

function onTabChange() {
  pageNo.value = 1
  router.replace({
    path: '/order',
    query: statusTab.value === 'all' ? {} : { status: statusTab.value }
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
h1 {
  margin: 0 0 12px;
  font-size: 24px;
}

.order-card {
  background: var(--mall-surface);
  border: 1px solid var(--mall-line);
  border-radius: var(--mall-radius);
  padding: 16px 20px;
  margin-bottom: 12px;
}

.order-head {
  display: flex;
  justify-content: space-between;
  color: var(--mall-muted);
  font-size: 13px;
  margin-bottom: 12px;
}

.status {
  color: var(--mall-accent);
  font-weight: 600;
}

.item-row {
  display: grid;
  grid-template-columns: 56px 1fr auto;
  gap: 12px;
  align-items: center;
  padding: 8px 0;
}

.item-row img {
  width: 56px;
  height: 56px;
  object-fit: cover;
  border-radius: 6px;
  background: #f5f5f4;
}

.muted {
  color: var(--mall-muted);
  font-size: 12px;
  margin-top: 4px;
}

.order-foot {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px solid var(--mall-line);
}

.actions {
  display: flex;
  gap: 8px;
}

.pager {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}
</style>
