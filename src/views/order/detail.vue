<template>
  <div class="page-container order-detail" v-loading="loading">
    <template v-if="order">
      <div class="status-banner" :class="statusClass(order.status)">
        <div class="status-text">
          <div class="label">订单状态</div>
          <div class="value">{{ ORDER_STATUS_MAP[order.status] || order.status }}</div>
        </div>
        <div class="status-meta">
          <div class="meta-item">
            <span class="meta-label">订单号</span>
            <button type="button" class="no-chip" title="点击复制" @click="copyOrderNo(order.no)">
              <span class="no-text">{{ order.no }}</span>
              <el-icon :size="14"><DocumentCopy /></el-icon>
            </button>
          </div>
          <div v-if="order.createTime" class="meta-item">
            <span class="meta-label">下单时间</span>
            <span class="meta-value">{{ formatDateTime(order.createTime) }}</span>
          </div>
        </div>
      </div>

      <div v-if="order.receiverName" class="panel">
        <h2>收货信息</h2>
        <div class="address">
          <div class="receiver">{{ order.receiverName }} {{ order.receiverMobile }}</div>
          <div class="addr">{{ order.receiverAreaName }} {{ order.receiverDetailAddress }}</div>
          <div v-if="order.logisticsName || order.logisticsNo" class="logistics">
            物流：{{ order.logisticsName || '' }} {{ order.logisticsNo || '' }}
            <button type="button" class="link-btn" @click="showExpress = true">查看物流</button>
          </div>
        </div>
      </div>

      <div class="panel">
        <h2>商品信息</h2>
        <div v-for="item in order.items || []" :key="item.id" class="item-row">
          <router-link
            v-if="item.spuId"
            :to="`/goods/${item.spuId}`"
            class="thumb-link"
          >
            <img :src="item.picUrl" :alt="item.spuName" />
          </router-link>
          <img v-else :src="item.picUrl" :alt="item.spuName" />
          <div class="item-body">
            <router-link
              v-if="item.spuId"
              :to="`/goods/${item.spuId}`"
              class="name"
            >
              {{ item.spuName }}
            </router-link>
            <div v-else class="name">{{ item.spuName }}</div>
            <div class="muted">
              <span v-for="(p, i) in item.properties || []" :key="i">
                {{ p.propertyName }}:{{ p.valueName }}
              </span>
              <span>× {{ item.count }}</span>
            </div>
            <div class="item-actions">
              <button
                v-if="canAfterSale(item)"
                type="button"
                class="link-btn"
                @click="$router.push(`/order/aftersale/apply?orderItemId=${item.id}&orderId=${order.id}`)"
              >
                申请售后
              </button>
              <button
                v-if="order.status === 30 && !item.commentStatus"
                type="button"
                class="link-btn"
                @click="$router.push(`/order/comment?orderItemId=${item.id}&orderId=${order.id}`)"
              >
                评价
              </button>
            </div>
          </div>
          <div class="price">{{ formatPrice(item.price) }}</div>
        </div>

        <div class="price-lines">
          <div class="line"><span>商品金额</span><span>{{ formatPrice(order.totalPrice) }}</span></div>
          <div v-if="order.deliveryPrice" class="line">
            <span>运费</span><span>{{ formatPrice(order.deliveryPrice) }}</span>
          </div>
          <div v-if="order.couponPrice" class="line">
            <span>优惠券</span><span>-{{ formatPrice(order.couponPrice) }}</span>
          </div>
          <div v-if="order.discountPrice" class="line">
            <span>优惠</span><span>-{{ formatPrice(order.discountPrice) }}</span>
          </div>
          <div v-if="order.pointPrice" class="line">
            <span>积分抵扣</span><span>-{{ formatPrice(order.pointPrice) }}</span>
          </div>
          <div v-if="order.vipPrice" class="line">
            <span>会员优惠</span><span>-{{ formatPrice(order.vipPrice) }}</span>
          </div>
          <div class="pay-line">
            <span>实付</span>
            <span class="price">{{ formatPrice(order.payPrice) }}</span>
          </div>
        </div>
      </div>

      <div class="panel meta-panel">
        <h2>订单信息</h2>
        <div class="meta-grid">
          <div v-if="order.payChannelName"><em>支付方式</em>{{ order.payChannelName }}</div>
          <div v-if="order.userRemark"><em>备注</em>{{ order.userRemark }}</div>
        </div>
      </div>

      <div class="actions">
        <el-button v-if="order.status === 0" type="primary" @click="goPay">去支付</el-button>
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
import { DocumentCopy } from '@element-plus/icons-vue'
import {
  OrderApi,
  ORDER_STATUS_MAP,
  type ExpressTrack,
  type TradeOrder,
  type TradeOrderItem
} from '@/api/trade/order'
import { PayOrderApi } from '@/api/pay'
import { isPayClosed, isPayRefund, isPaySuccess, isPayWaiting } from '@/utils/pay'
import { formatPrice } from '@/utils/price'
import { formatDateTime } from '@/utils/datetime'

const route = useRoute()
const router = useRouter()
const loading = ref(false)
const order = ref<TradeOrder | null>(null)
const showExpress = ref(false)
const expressLoading = ref(false)
const tracks = ref<ExpressTrack[]>([])

async function copyOrderNo(no?: string) {
  if (!no) return
  try {
    await navigator.clipboard.writeText(no)
    ElMessage.success('订单号已复制')
  } catch {
    ElMessage.error('复制失败')
  }
}

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

function statusClass(status: number) {
  if (status === 0) return 'warn'
  if (status === 40) return 'muted'
  if (status === 30) return 'ok'
  return ''
}

function canAfterSale(item: TradeOrderItem) {
  if (!order.value) return false
  return [10, 20, 30].includes(order.value.status) && (item.afterSaleStatus === 0 || item.afterSaleStatus == null)
}

async function goPay() {
  if (!order.value?.payOrderId) {
    ElMessage.warning('暂无可用支付单，请稍后重试或联系客服')
    return
  }
  const payId = order.value.payOrderId
  try {
    const res = await PayOrderApi.getOrder(payId, true)
    const status = res.data?.status
    if (isPaySuccess(status) || isPayClosed(status) || isPayRefund(status)) {
      router.push({ path: '/pay/result', query: { id: String(payId) } })
      return
    }
    if (!isPayWaiting(status)) {
      ElMessage.warning('当前支付单不可继续支付')
      return
    }
    router.push({ path: '/pay', query: { id: String(payId) } })
  } catch {
    ElMessage.warning('无法打开收银台，请稍后重试')
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
.order-detail {
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

.status-banner.warn {
  background: linear-gradient(90deg, #fff7ed, #fff);
  border-color: #fed7aa;
}

.status-banner.ok {
  background: linear-gradient(90deg, #f0fdf4, #fff);
  border-color: #bbf7d0;
}

.status-banner.muted {
  background: #f9fafb;
  border-color: var(--mall-line);
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

.status-banner.warn .value {
  color: #ea580c;
}

.status-banner.ok .value {
  color: #16a34a;
}

.status-banner.muted .value {
  color: var(--mall-muted);
}

.status-meta {
  display: flex;
  flex-direction: column;
  gap: 10px;
  min-width: 260px;
}

.meta-item {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 10px;
}

.meta-label {
  flex-shrink: 0;
  font-size: 12px;
  color: var(--mall-muted);
  line-height: 1;
}

.meta-value {
  font-size: 13px;
  color: var(--mall-ink);
  font-variant-numeric: tabular-nums;
  letter-spacing: 0.01em;
}

.no-chip {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  max-width: 100%;
  border: 0;
  background: transparent;
  padding: 0;
  cursor: pointer;
  color: var(--mall-ink);
  transition: color 0.15s;
}

.no-chip:hover {
  color: var(--mall-accent);
}

.no-text {
  font-size: 13px;
  font-weight: 600;
  font-variant-numeric: tabular-nums;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
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

.receiver {
  font-size: 15px;
  font-weight: 600;
  margin-bottom: 6px;
}

.addr,
.logistics {
  color: var(--mall-muted);
  font-size: 14px;
  line-height: 1.6;
}

.logistics {
  margin-top: 8px;
}

.link-btn {
  border: 0;
  background: transparent;
  color: var(--mall-accent);
  cursor: pointer;
  font-size: 13px;
  padding: 0 0 0 8px;
}

.link-btn:hover {
  color: var(--mall-accent-dark);
}

.item-row {
  display: grid;
  grid-template-columns: 72px 1fr auto;
  gap: 14px;
  align-items: flex-start;
  padding: 14px 0;
  border-bottom: 1px solid #f3f4f6;
}

.item-row:last-of-type {
  border-bottom: 0;
}

.item-row img {
  width: 72px;
  height: 72px;
  object-fit: cover;
  border-radius: 8px;
  background: #f3f4f6;
}

.thumb-link {
  display: block;
  line-height: 0;
}

.name {
  font-size: 14px;
  line-height: 1.45;
  color: var(--mall-ink);
}

a.name:hover {
  color: var(--mall-accent);
}

.muted {
  color: var(--mall-muted);
  font-size: 12px;
  margin-top: 6px;
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.item-actions {
  margin-top: 8px;
  display: flex;
  gap: 12px;
}

.item-actions .link-btn {
  padding: 0;
}

.price-lines {
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid #f3f4f6;
  max-width: 320px;
  margin-left: auto;
}

.line {
  display: flex;
  justify-content: space-between;
  gap: 24px;
  color: var(--mall-muted);
  font-size: 14px;
  line-height: 1.9;
}

.pay-line {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  margin-top: 8px;
  padding-top: 8px;
  border-top: 1px dashed var(--mall-line);
  font-size: 14px;
}

.pay-line .price {
  font-size: 22px;
}

.meta-grid {
  display: grid;
  gap: 10px;
  font-size: 14px;
  color: var(--mall-ink);
}

.meta-grid em {
  font-style: normal;
  color: var(--mall-muted);
  margin-right: 12px;
  display: inline-block;
  min-width: 64px;
}

.actions {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  padding: 4px 0 8px;
}

@media (max-width: 720px) {
  .status-meta {
    width: 100%;
    min-width: 0;
  }

  .meta-item {
    justify-content: flex-start;
  }

  .item-row {
    grid-template-columns: 64px 1fr;
  }

  .item-row .price {
    grid-column: 2;
  }
}
</style>
