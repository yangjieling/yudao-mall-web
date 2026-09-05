<template>
  <div class="page-container pay-page" v-loading="loading">
    <div class="panel">
      <h1>收银台</h1>
      <div class="amount price">{{ formatPrice(payOrder?.price) }}</div>
      <p class="tip">请选择支付方式完成付款</p>

      <el-radio-group v-model="channelCode" class="channels">
        <el-radio
          v-for="code in channels"
          :key="code"
          :value="code"
          border
          class="channel"
        >
          {{ channelLabel(code) }}
        </el-radio>
      </el-radio-group>

      <el-empty v-if="!channels.length && !loading" description="暂无可用支付渠道" />

      <el-button
        type="primary"
        size="large"
        :disabled="!channelCode || !payOrder"
        :loading="submitting"
        @click="submit"
      >
        立即支付
      </el-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { PayChannelApi, PayOrderApi, type PayOrderInfo } from '@/api/pay'
import { formatPrice } from '@/utils/price'

const route = useRoute()
const router = useRouter()
const loading = ref(false)
const submitting = ref(false)
const payOrder = ref<PayOrderInfo | null>(null)
const channels = ref<string[]>([])
const channelCode = ref('')

const LABEL_MAP: Record<string, string> = {
  wallet: '钱包余额',
  alipay_pc: '支付宝',
  wx_native: '微信扫码',
  mock: '模拟支付'
}

function channelLabel(code: string) {
  return LABEL_MAP[code] || code
}

async function load() {
  const id = Number(route.query.id)
  if (!id) {
    ElMessage.error('缺少支付单')
    router.replace('/order')
    return
  }
  loading.value = true
  try {
    const orderRes = await PayOrderApi.getOrder(id, true)
    payOrder.value = orderRes.data
    const appId = orderRes.data?.appId
    if (appId) {
      const channelRes = await PayChannelApi.getEnableChannelCodeList(appId)
      channels.value = channelRes.data || []
      // 优先钱包 / mock，便于本地联调
      channelCode.value =
        channels.value.find((c) => c === 'wallet' || c === 'mock') || channels.value[0] || ''
    } else {
      channels.value = []
    }
  } finally {
    loading.value = false
  }
}

async function submit() {
  if (!payOrder.value || !channelCode.value) return
  submitting.value = true
  try {
    await PayOrderApi.submitOrder({
      id: payOrder.value.id,
      channelCode: channelCode.value,
      returnUrl: `${window.location.origin}/pay/result?id=${payOrder.value.id}`
    })
    router.replace({ path: '/pay/result', query: { id: String(payOrder.value.id) } })
  } finally {
    submitting.value = false
  }
}

onMounted(load)
</script>

<style scoped lang="scss">
.panel {
  max-width: 520px;
  margin: 0 auto;
  background: var(--mall-surface);
  border: 1px solid var(--mall-line);
  border-radius: var(--mall-radius);
  padding: 32px;
  text-align: center;
}

h1 {
  margin: 0 0 12px;
  font-size: 22px;
}

.amount {
  font-size: 40px;
  margin: 16px 0;
}

.tip {
  color: var(--mall-muted);
  margin-bottom: 24px;
}

.channels {
  display: flex;
  flex-direction: column;
  gap: 10px;
  width: 100%;
  margin-bottom: 28px;
}

.channel {
  width: 100%;
  margin: 0 !important;
  height: 48px !important;
}
</style>
