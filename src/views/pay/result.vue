<template>
  <div class="page-container result-page" v-loading="loading">
    <div class="panel">
      <template v-if="payOrder">
        <el-result
          :icon="success ? 'success' : failed ? 'error' : 'warning'"
          :title="success ? '支付成功' : failed ? '支付关闭' : '支付处理中'"
          :sub-title="success ? '感谢您的购买' : '可稍后在订单中心查看支付状态'"
        >
          <template #extra>
            <div class="amount price">{{ formatPrice(payOrder.price) }}</div>
            <div class="actions">
              <el-button type="primary" @click="$router.push('/order')">查看订单</el-button>
              <el-button @click="$router.push('/')">返回首页</el-button>
              <el-button v-if="!success && !failed" @click="refresh">刷新状态</el-button>
            </div>
          </template>
        </el-result>
      </template>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref } from 'vue'
import { useRoute } from 'vue-router'
import { PayOrderApi, type PayOrderInfo } from '@/api/pay'
import { formatPrice } from '@/utils/price'

const route = useRoute()
const loading = ref(false)
const payOrder = ref<PayOrderInfo | null>(null)
let timer: number | undefined

/** 支付成功状态一般为 10，关闭 20，与芋道 pay 模块约定一致 */
const success = computed(() => payOrder.value?.status === 10)
const failed = computed(() => payOrder.value?.status === 20)

async function refresh() {
  const id = Number(route.query.id)
  if (!id) return
  loading.value = true
  try {
    const res = await PayOrderApi.getOrder(id, true)
    payOrder.value = res.data
    if (res.data?.status === 10 || res.data?.status === 20) {
      stopPoll()
    }
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
  if (!success.value && !failed.value) startPoll()
})
onUnmounted(stopPoll)
</script>

<style scoped lang="scss">
.panel {
  max-width: 560px;
  margin: 40px auto 0;
  background: var(--mall-surface);
  border: 1px solid var(--mall-line);
  border-radius: var(--mall-radius);
  padding: 24px;
}

.amount {
  font-size: 28px;
  margin-bottom: 20px;
}

.actions {
  display: flex;
  gap: 10px;
  justify-content: center;
}
</style>
