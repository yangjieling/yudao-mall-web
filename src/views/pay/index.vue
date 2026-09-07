<template>
  <div class="page-container pay-page" v-loading="loading">
    <div class="panel">
      <h1>收银台</h1>
      <div class="amount price">{{ formatPrice(payOrder?.price) }}</div>
      <p class="tip">请选择支付方式完成付款</p>

      <el-radio-group v-if="!qrDataUrl && !waitingRedirect" v-model="channelCode" class="channels">
        <el-radio
          v-for="code in channels"
          :key="code"
          :value="code"
          border
          class="channel"
        >
          <span class="channel-body">
            <img class="channel-icon" :src="channelIcon(code)" :alt="channelLabel(code)" />
            <span class="channel-text">
              <span class="channel-name">{{ channelLabel(code) }}</span>
              <span class="channel-desc">{{ channelDesc(code) }}</span>
            </span>
          </span>
        </el-radio>
      </el-radio-group>

      <el-empty v-if="!channels.length && !loading && !qrDataUrl" description="暂无可用支付渠道" />

      <div v-if="qrDataUrl" class="qr-box">
        <img :src="qrDataUrl" alt="支付二维码" class="qr" />
        <p>请使用手机扫码完成支付</p>
        <el-button @click="refreshStatus">我已完成支付</el-button>
      </div>

      <el-button
        v-if="!qrDataUrl && !waitingRedirect"
        type="primary"
        size="large"
        class="pay-btn"
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
import { onMounted, onUnmounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import QRCode from 'qrcode'
import { PayChannelApi, PayOrderApi, type PayOrderInfo } from '@/api/pay'
import {
  channelIcon,
  channelLabel,
  filterPcChannels,
  isPayWaiting,
  isQrPayChannel,
  isRedirectPayContent
} from '@/utils/pay'
import { formatPrice } from '@/utils/price'

function channelDesc(code: string): string {
  if (code === 'wallet') return '使用账户余额付款'
  if (code === 'mock') return '演示环境模拟付款'
  if (code === 'wx_native') return '打开微信扫一扫完成支付'
  if (code === 'alipay_pc') return '跳转支付宝电脑网站付款'
  if (code === 'alipay_qr') return '打开支付宝扫一扫完成支付'
  if (code.startsWith('wx_')) return '使用微信支付'
  if (code.startsWith('alipay_')) return '使用支付宝付款'
  return '安全快捷支付'
}

const route = useRoute()
const router = useRouter()
const loading = ref(false)
const submitting = ref(false)
const payOrder = ref<PayOrderInfo | null>(null)
const channels = ref<string[]>([])
const channelCode = ref('')
const qrDataUrl = ref('')
const waitingRedirect = ref(false)
let pollTimer: number | undefined

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
    payOrder.value = orderRes.data || null
    if (!payOrder.value) {
      ElMessage.error('未找到支付单')
      router.replace('/order')
      return
    }
    if (!isPayWaiting(payOrder.value.status)) {
      router.replace({ path: '/pay/result', query: { id: String(id) } })
      return
    }
    const appId = payOrder.value.appId
    if (appId) {
      const channelRes = await PayChannelApi.getEnableChannelCodeList(appId)
      channels.value = filterPcChannels(channelRes.data || [])
      channelCode.value =
        channels.value.find((c) => c === 'wallet' || c === 'mock') || channels.value[0] || ''
    } else {
      channels.value = []
    }
  } catch {
    payOrder.value = null
    channels.value = []
    ElMessage.error('无法打开收银台')
    router.replace('/order')
  } finally {
    loading.value = false
  }
}

function startPoll() {
  stopPoll()
  pollTimer = window.setInterval(async () => {
    if (!payOrder.value) return
    try {
      const res = await PayOrderApi.getOrder(payOrder.value.id, true)
      if (!isPayWaiting(res.data?.status)) {
        stopPoll()
        router.replace({ path: '/pay/result', query: { id: String(payOrder.value.id) } })
      }
    } catch {
      // ignore
    }
  }, 2500)
}

function stopPoll() {
  if (pollTimer) {
    clearInterval(pollTimer)
    pollTimer = undefined
  }
}

async function refreshStatus() {
  if (!payOrder.value) return
  const res = await PayOrderApi.getOrder(payOrder.value.id, true)
  if (!isPayWaiting(res.data?.status)) {
    router.replace({ path: '/pay/result', query: { id: String(payOrder.value.id) } })
  } else {
    ElMessage.info('尚未检测到支付成功，请稍后再试')
  }
}

async function handleDisplayContent(content?: string) {
  if (!content) {
    router.replace({ path: '/pay/result', query: { id: String(payOrder.value!.id) } })
    return
  }
  if (isQrPayChannel(channelCode.value) || (!content.includes('<form') && !content.startsWith('http'))) {
    if (!content.includes('<')) {
      qrDataUrl.value = await QRCode.toDataURL(content, { width: 220, margin: 2 })
      startPoll()
      return
    }
  }
  if (isRedirectPayContent(content)) {
    if (content.includes('<form')) {
      waitingRedirect.value = true
      const wrap = document.createElement('div')
      wrap.innerHTML = content
      document.body.appendChild(wrap)
      const form = wrap.querySelector('form')
      if (form) {
        form.submit()
      } else {
        ElMessage.error('无法打开支付页面')
        waitingRedirect.value = false
      }
      return
    }
    waitingRedirect.value = true
    window.location.href = content
    return
  }
  try {
    qrDataUrl.value = await QRCode.toDataURL(content, { width: 220, margin: 2 })
    startPoll()
  } catch {
    router.replace({ path: '/pay/result', query: { id: String(payOrder.value!.id) } })
  }
}

async function submit() {
  if (!payOrder.value || !channelCode.value) return
  submitting.value = true
  try {
    const res = await PayOrderApi.submitOrder({
      id: payOrder.value.id,
      channelCode: channelCode.value,
      returnUrl: `${window.location.origin}/pay/result?id=${payOrder.value.id}`
    })
    if (channelCode.value === 'wallet' || channelCode.value === 'mock') {
      router.replace({ path: '/pay/result', query: { id: String(payOrder.value.id) } })
      return
    }
    await handleDisplayContent(res.data?.displayContent)
  } finally {
    submitting.value = false
  }
}

onMounted(load)
onUnmounted(stopPoll)
</script>

<style scoped lang="scss">
.pay-page {
  padding-bottom: 40px;
}

.panel {
  max-width: 520px;
  margin: 0 auto;
  background: var(--mall-surface);
  border-radius: var(--mall-radius);
  padding: 32px 28px;
  text-align: center;
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
}

h1 {
  margin: 0 0 8px;
  font-size: 22px;
  display: inline-flex;
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

.amount {
  font-size: 40px;
  margin: 16px 0 8px;
  letter-spacing: -0.02em;
}

.tip {
  color: var(--mall-muted);
  margin: 0 0 24px;
  font-size: 14px;
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
  height: auto !important;
  min-height: 64px;
  border-radius: 8px !important;
  padding: 12px 14px !important;
  align-items: center;
}

.channel.is-checked {
  border-color: var(--mall-accent) !important;
  background: var(--mall-accent-soft);
}

.channel :deep(.el-radio__input.is-checked .el-radio__inner) {
  background-color: var(--mall-accent);
  border-color: var(--mall-accent);
}

.channel :deep(.el-radio__input.is-checked + .el-radio__label) {
  color: var(--mall-ink);
}

.channel :deep(.el-radio__inner:hover) {
  border-color: var(--mall-accent);
}

.channel :deep(.el-radio__label) {
  width: 100%;
  padding-left: 10px;
}

.channel-body {
  display: flex;
  align-items: center;
  gap: 12px;
  text-align: left;
}

.channel-icon {
  width: 36px;
  height: 36px;
  flex-shrink: 0;
  object-fit: contain;
}

.channel-text {
  display: flex;
  flex-direction: column;
  gap: 2px;
  min-width: 0;
}

.channel-name {
  font-size: 15px;
  font-weight: 500;
  color: var(--mall-ink);
  line-height: 1.3;
}

.channel-desc {
  font-size: 12px;
  color: var(--mall-muted);
  line-height: 1.3;
}

.qr-box {
  margin: 12px 0 8px;
}

.qr-box p {
  color: var(--mall-muted);
  font-size: 14px;
}

.qr {
  width: 220px;
  height: 220px;
  margin: 0 auto 12px;
  border: 1px solid var(--mall-line);
  border-radius: 8px;
}

.pay-btn {
  width: 100%;
  height: 44px;
  font-size: 16px;
}
</style>
