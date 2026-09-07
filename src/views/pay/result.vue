<template>
  <div class="page-container result-page" v-loading="loading">
    <div class="panel" :class="stateClass">
      <template v-if="payOrder">
        <div class="icon-wrap">
          <el-icon :size="48">
            <CircleCheckFilled v-if="success" />
            <CircleCloseFilled v-else-if="failed" />
            <WarningFilled v-else />
          </el-icon>
        </div>
        <h1>{{ titleText }}</h1>
        <p class="sub">{{ subText }}</p>
        <div class="amount price">{{ formatPrice(payOrder.price) }}</div>
        <div class="actions">
          <el-button v-if="!success" type="primary" @click="continuePay">继续支付</el-button>
          <el-button :type="success ? 'primary' : 'default'" @click="$router.push('/order')">
            查看订单
          </el-button>
          <el-button @click="$router.push('/')">返回首页</el-button>
          <el-button v-if="!success && !failed" @click="refresh">刷新状态</el-button>
        </div>
      </template>
      <template v-else-if="!loading">
        <div class="icon-wrap warn">
          <el-icon :size="48"><WarningFilled /></el-icon>
        </div>
        <h1>未找到支付单</h1>
        <p class="sub">请从订单中心重新进入支付，或返回首页继续购物</p>
        <div class="actions">
          <el-button type="primary" @click="$router.push('/order')">查看订单</el-button>
          <el-button @click="$router.push('/')">返回首页</el-button>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { CircleCheckFilled, CircleCloseFilled, WarningFilled } from '@element-plus/icons-vue'
import { PayOrderApi, type PayOrderInfo } from '@/api/pay'
import { formatPrice } from '@/utils/price'

const route = useRoute()
const router = useRouter()
const loading = ref(false)
const payOrder = ref<PayOrderInfo | null>(null)
let timer: number | undefined

/** 支付成功状态一般为 10，关闭 20 */
const success = computed(() => payOrder.value?.status === 10)
const failed = computed(() => payOrder.value?.status === 20)
const stateClass = computed(() => {
  if (!payOrder.value) return 'pending'
  if (success.value) return 'ok'
  if (failed.value) return 'fail'
  return 'pending'
})
const titleText = computed(() => {
  if (success.value) return '支付成功'
  if (failed.value) return '支付关闭'
  return '支付处理中'
})
const subText = computed(() => {
  if (success.value) return '感谢您的购买，可在订单中心查看详情'
  if (failed.value) return '支付已关闭，可返回订单重新发起支付'
  return '支付结果确认中，请稍候刷新或继续完成付款'
})

function continuePay() {
  const id = payOrder.value?.id || Number(route.query.id)
  if (!id) {
    router.push('/order')
    return
  }
  router.push({ path: '/pay', query: { id: String(id) } })
}

async function refresh() {
  const id = Number(route.query.id)
  if (!id) {
    payOrder.value = null
    return
  }
  loading.value = true
  try {
    const res = await PayOrderApi.getOrder(id, true)
    payOrder.value = res.data || null
    if (res.data?.status === 10 || res.data?.status === 20) {
      stopPoll()
    }
  } catch {
    payOrder.value = null
  } finally {
    loading.value = false
  }
}

function startPoll() {
  timer = window.setInterval(() => {
    if (!success.value && !failed.value) refresh()
  }, 2500)
}

function stopPoll() {
  if (timer) {
    clearInterval(timer)
    timer = undefined
  }
}

onMounted(async () => {
  await refresh()
  if (payOrder.value && !success.value && !failed.value) startPoll()
})
onUnmounted(stopPoll)
</script>

<style scoped lang="scss">
.result-page {
  padding-bottom: 48px;
}

.panel {
  max-width: 520px;
  margin: 32px auto 0;
  background: var(--mall-surface);
  border-radius: var(--mall-radius);
  padding: 40px 28px 32px;
  text-align: center;
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
  border: 1px solid transparent;
}

.panel.ok {
  border-color: #bbf7d0;
  background: linear-gradient(180deg, #f0fdf4 0%, #fff 42%);
}

.panel.fail {
  border-color: var(--mall-accent-border);
  background: linear-gradient(180deg, #fff5f5 0%, #fff 42%);
}

.panel.pending {
  border-color: #fde68a;
  background: linear-gradient(180deg, #fffbeb 0%, #fff 42%);
}

.icon-wrap {
  display: inline-flex;
  margin-bottom: 12px;
}

.panel.ok .icon-wrap {
  color: #16a34a;
}

.panel.fail .icon-wrap {
  color: var(--mall-accent);
}

.panel.pending .icon-wrap,
.icon-wrap.warn {
  color: #d97706;
}

h1 {
  margin: 0 0 8px;
  font-size: 24px;
}

.sub {
  margin: 0;
  color: var(--mall-muted);
  font-size: 14px;
}

.amount {
  font-size: 32px;
  margin: 20px 0 28px;
}

.actions {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  justify-content: center;
}
</style>
