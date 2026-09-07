<template>
  <div class="wallet-page" v-loading="loading">
    <h1>我的钱包</h1>

    <div class="balance-card">
      <div class="label">可用余额</div>
      <div class="amount price">{{ formatPrice(wallet?.balance) }}</div>
      <el-button type="primary" @click="rechargeVisible = true">充值</el-button>
    </div>

    <div class="section-head">
      <h2>交易流水</h2>
    </div>

    <div class="tx-panel">
      <el-empty v-if="!transactions.length" description="暂无流水" :image-size="64" />
      <div v-for="t in transactions" :key="t.id" class="tx-row">
        <div class="tx-main">
          <div class="title">{{ t.title || '钱包变动' }}</div>
          <div class="muted">{{ formatDateTime(t.createTime) }}</div>
        </div>
        <div :class="['price', t.price >= 0 ? 'plus' : 'minus']">
          {{ t.price >= 0 ? '+' : '' }}{{ formatPrice(t.price) }}
        </div>
      </div>
    </div>

    <div v-if="txTotal > pageSize" class="pager">
      <el-pagination
        background
        layout="prev, pager, next"
        :total="txTotal"
        :page-size="pageSize"
        :current-page="pageNo"
        @current-change="onPage"
      />
    </div>

    <el-dialog v-model="rechargeVisible" title="钱包充值" width="420px">
      <el-radio-group v-model="packageId" class="pkg-list">
        <el-radio v-for="p in packages" :key="p.id" :value="p.id" border class="pkg">
          {{ p.name }} · 支付 {{ formatPrice(p.payPrice) }}
          <span v-if="p.bonusPrice">（赠 {{ formatPrice(p.bonusPrice) }}）</span>
        </el-radio>
      </el-radio-group>
      <template #footer>
        <el-button @click="rechargeVisible = false">取消</el-button>
        <el-button type="primary" :loading="recharging" :disabled="!packageId" @click="doRecharge">
          去支付
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import {
  WalletApi,
  type PayWallet,
  type RechargePackage,
  type WalletTransaction
} from '@/api/pay/wallet'
import { formatPrice } from '@/utils/price'
import { formatDateTime } from '@/utils/datetime'

const router = useRouter()
const loading = ref(false)
const wallet = ref<PayWallet | null>(null)
const transactions = ref<WalletTransaction[]>([])
const txTotal = ref(0)
const pageNo = ref(1)
const pageSize = 10
const rechargeVisible = ref(false)
const recharging = ref(false)
const packages = ref<RechargePackage[]>([])
const packageId = ref<number>()

async function loadWallet() {
  const res = await WalletApi.getWallet()
  wallet.value = res.data
}

async function loadTx() {
  const res = await WalletApi.getTransactionPage({ pageNo: pageNo.value, pageSize })
  transactions.value = res.data?.list || []
  txTotal.value = res.data?.total || 0
}

async function loadPackages() {
  const res = await WalletApi.getRechargePackageList()
  packages.value = res.data || []
  packageId.value = packages.value[0]?.id
}

function onPage(p: number) {
  pageNo.value = p
  loadTx()
}

async function doRecharge() {
  if (!packageId.value) return
  recharging.value = true
  try {
    const res = await WalletApi.createRecharge({ packageId: packageId.value })
    rechargeVisible.value = false
    if (res.data?.payOrderId) {
      router.push({ path: '/pay', query: { id: String(res.data.payOrderId) } })
    } else {
      ElMessage.success('充值已创建')
      loadWallet()
      loadTx()
    }
  } finally {
    recharging.value = false
  }
}

onMounted(async () => {
  loading.value = true
  try {
    await Promise.all([loadWallet(), loadTx(), loadPackages()])
  } finally {
    loading.value = false
  }
})
</script>

<style scoped lang="scss">
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

.balance-card {
  background: linear-gradient(135deg, #fff5f5 0%, #fff 55%);
  border: 1px solid var(--mall-accent-border);
  border-radius: var(--mall-radius);
  padding: 24px;
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
}

.label {
  color: var(--mall-muted);
  font-size: 13px;
}

.amount {
  font-size: 36px;
  margin: 8px 0 16px;
  letter-spacing: -0.02em;
}

.section-head {
  margin: 22px 0 12px;
}

.section-head h2 {
  margin: 0;
  font-size: 16px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.section-head h2::before {
  content: '';
  width: 3px;
  height: 14px;
  border-radius: 2px;
  background: var(--mall-accent);
}

.tx-panel {
  background: var(--mall-surface);
  border-radius: var(--mall-radius);
  padding: 4px 20px;
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
}

.tx-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
  padding: 16px 0;
  border-bottom: 1px solid #f3f4f6;
}

.tx-row:last-child {
  border-bottom: 0;
}

.title {
  font-size: 14px;
}

.muted {
  color: var(--mall-muted);
  font-size: 12px;
  margin-top: 4px;
  font-variant-numeric: tabular-nums;
}

.plus {
  color: #16a34a;
}

.minus {
  color: var(--mall-accent);
}

.pkg-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
  width: 100%;
}

.pkg {
  width: 100%;
  margin: 0 !important;
  height: auto !important;
  padding: 12px !important;
  border-radius: 8px !important;
}

.pager {
  display: flex;
  justify-content: center;
  margin-top: 16px;
}
</style>
