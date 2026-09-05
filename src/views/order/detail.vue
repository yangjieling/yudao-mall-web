<template>
  <div class="page-container order-detail" v-loading="loading">
    <template v-if="order">
      <div class="panel">
        <h1>订单详情</h1>
        <div class="meta">
          <div>订单号：{{ order.no }}</div>
          <div>状态：{{ ORDER_STATUS_MAP[order.status] || order.status }}</div>
          <div v-if="order.createTime">下单时间：{{ order.createTime }}</div>
        </div>
      </div>

      <div class="panel">
        <h2>商品</h2>
        <div v-for="item in order.items || []" :key="item.id" class="item-row">
          <img :src="item.picUrl" :alt="item.spuName" />
          <div>
            <div>{{ item.spuName }}</div>
            <div class="muted">x{{ item.count }}</div>
          </div>
          <div class="price">{{ formatPrice(item.price) }}</div>
        </div>
        <div class="pay-line">
          实付 <span class="price">{{ formatPrice(order.payPrice) }}</span>
        </div>
      </div>

      <div class="actions">
        <el-button v-if="order.status === 0 && order.payOrderId" type="primary" @click="goPay">
          去支付
        </el-button>
        <el-button v-if="order.status === 0" @click="cancel">取消订单</el-button>
        <el-button v-if="order.status === 20" type="primary" @click="receive">确认收货</el-button>
        <el-button @click="$router.push('/order')">返回列表</el-button>
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { OrderApi, ORDER_STATUS_MAP, type TradeOrder } from '@/api/trade/order'
import { formatPrice } from '@/utils/price'

const route = useRoute()
const router = useRouter()
const loading = ref(false)
const order = ref<TradeOrder | null>(null)

async function load() {
  const id = Number(route.params.id)
  if (!id) return
  loading.value = true
  try {
    const res = await OrderApi.getOrderDetail(id)
    order.value = res.data
  } finally {
    loading.value = false
  }
}

function goPay() {
  if (order.value?.payOrderId) {
    router.push({ path: '/pay', query: { id: String(order.value.payOrderId) } })
  }
}

async function cancel() {
  if (!order.value) return
  await ElMessageBox.confirm('确认取消该订单？', '提示')
  await OrderApi.cancelOrder(order.value.id)
  ElMessage.success('已取消')
  load()
}

async function receive() {
  if (!order.value) return
  await ElMessageBox.confirm('确认已收到商品？', '提示')
  await OrderApi.receiveOrder(order.value.id)
  ElMessage.success('已确认收货')
  load()
}

onMounted(load)
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
  font-size: 24px;
}

h2 {
  margin: 0 0 12px;
  font-size: 16px;
}

.meta {
  color: var(--mall-muted);
  line-height: 1.8;
  font-size: 14px;
}

.item-row {
  display: grid;
  grid-template-columns: 64px 1fr auto;
  gap: 12px;
  align-items: center;
  padding: 10px 0;
  border-bottom: 1px solid var(--mall-line);
}

.item-row img {
  width: 64px;
  height: 64px;
  object-fit: cover;
  border-radius: 8px;
  background: #f5f5f4;
}

.muted {
  color: var(--mall-muted);
  font-size: 12px;
  margin-top: 4px;
}

.pay-line {
  text-align: right;
  margin-top: 16px;
}

.pay-line .price {
  font-size: 22px;
}

.actions {
  display: flex;
  gap: 10px;
}
</style>
