<template>
  <div class="page-container order-detail" v-loading="loading">
    <template v-if="order">
      <div class="panel">
        <h1>订单详情</h1>
        <div class="meta">
          <div>订单号：{{ order.no }}</div>
          <div>状态：{{ ORDER_STATUS_MAP[order.status] || order.status }}</div>
          <div v-if="order.createTime">下单时间：{{ order.createTime }}</div>
          <div v-if="order.payChannelName">支付方式：{{ order.payChannelName }}</div>
          <div v-if="order.userRemark">备注：{{ order.userRemark }}</div>
        </div>
      </div>

      <div v-if="order.receiverName" class="panel">
        <h2>收货信息</h2>
        <div class="meta">
          <div>{{ order.receiverName }} {{ order.receiverMobile }}</div>
          <div>{{ order.receiverAreaName }} {{ order.receiverDetailAddress }}</div>
          <div v-if="order.logisticsName || order.logisticsNo">
            物流：{{ order.logisticsName || '' }} {{ order.logisticsNo || '' }}
            <el-button link type="primary" @click="showExpress = true">查看物流</el-button>
          </div>
        </div>
      </div>

      <div class="panel">
        <h2>商品</h2>
        <div v-for="item in order.items || []" :key="item.id" class="item-row">
          <img :src="item.picUrl" :alt="item.spuName" />
          <div>
            <div>{{ item.spuName }}</div>
            <div class="muted">
              <span v-for="(p, i) in item.properties || []" :key="i">
                {{ p.propertyName }}:{{ p.valueName }}
              </span>
              × {{ item.count }}
            </div>
            <div class="item-actions">
              <el-button
                v-if="canAfterSale(item)"
                link
                type="primary"
                @click="$router.push(`/order/aftersale/apply?orderItemId=${item.id}&orderId=${order.id}`)"
              >
                申请售后
              </el-button>
              <el-button
                v-if="order.status === 30 && !item.commentStatus"
                link
                type="primary"
                @click="$router.push(`/order/comment?orderItemId=${item.id}&orderId=${order.id}`)"
              >
                评价
              </el-button>
            </div>
          </div>
          <div class="price">{{ formatPrice(item.price) }}</div>
        </div>
        <div class="price-lines">
          <div>商品金额：{{ formatPrice(order.totalPrice) }}</div>
          <div v-if="order.deliveryPrice">运费：{{ formatPrice(order.deliveryPrice) }}</div>
          <div v-if="order.couponPrice">优惠券：-{{ formatPrice(order.couponPrice) }}</div>
          <div v-if="order.discountPrice">优惠：-{{ formatPrice(order.discountPrice) }}</div>
          <div v-if="order.pointPrice">积分抵扣：-{{ formatPrice(order.pointPrice) }}</div>
          <div v-if="order.vipPrice">会员优惠：-{{ formatPrice(order.vipPrice) }}</div>
          <div class="pay-line">
            实付 <span class="price">{{ formatPrice(order.payPrice) }}</span>
          </div>
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

    <el-drawer v-model="showExpress" title="物流轨迹" size="420px">
      <div v-loading="expressLoading">
        <el-timeline v-if="tracks.length">
          <el-timeline-item v-for="(t, i) in tracks" :key="i" :timestamp="t.time">
            {{ t.content }}
          </el-timeline-item>
        </el-timeline>
        <el-empty v-else description="暂无物流信息" />
      </div>
    </el-drawer>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  OrderApi,
  ORDER_STATUS_MAP,
  type ExpressTrack,
  type TradeOrder,
  type TradeOrderItem
} from '@/api/trade/order'
import { formatPrice } from '@/utils/price'

const route = useRoute()
const router = useRouter()
const loading = ref(false)
const order = ref<TradeOrder | null>(null)
const showExpress = ref(false)
const expressLoading = ref(false)
const tracks = ref<ExpressTrack[]>([])

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

function canAfterSale(item: TradeOrderItem) {
  if (!order.value) return false
  // 已支付且未完成售后：状态 10/20/30，afterSaleStatus 0 可申请
  return [10, 20, 30].includes(order.value.status) && (item.afterSaleStatus === 0 || item.afterSaleStatus == null)
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

watch(showExpress, async (val) => {
  if (!val || !order.value) return
  expressLoading.value = true
  try {
    const res = await OrderApi.getExpressTrackList(order.value.id)
    tracks.value = res.data || []
  } catch {
    tracks.value = []
  } finally {
    expressLoading.value = false
  }
})

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
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.item-actions {
  margin-top: 6px;
}

.price-lines {
  margin-top: 16px;
  text-align: right;
  color: var(--mall-muted);
  line-height: 1.8;
  font-size: 14px;
}

.pay-line {
  margin-top: 8px;
  color: var(--mall-ink);
}

.pay-line .price {
  font-size: 22px;
}

.actions {
  display: flex;
  gap: 10px;
}
</style>
