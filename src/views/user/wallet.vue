<template>
  <div class="wallet-page" v-loading="loading">
    <h1>我的钱包</h1>
    <div class="balance-card">
      <div class="label">余额</div>
      <div class="amount price">{{ formatPrice(wallet?.balance) }}</div>
      <el-button type="primary" @click="rechargeVisible = true">充值</el-button>
    </div>

    <h2>交易流水</h2>
    <el-empty v-if="!transactions.length" description="暂无流水" />
    <div v-for="t in transactions" :key="t.id" class="tx-row">
      <div>
        <div>{{ t.title || '钱包变动' }}</div>
        <div class="muted">{{ t.createTime }}</div>
      </div>
      <div :class="['price', t.price >= 0 ? 'plus' : '']">
        {{ t.price >= 0 ? '+' : '' }}{{ formatPrice(t.price) }}
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
}

h2 {
  margin: 24px 0 12px;
  font-size: 16px;
}

.balance-card {
  background: linear-gradient(145deg, #fff, #faf6f1);
  border: 1px solid var(--mall-line);
  border-radius: var(--mall-radius);
  padding: 24px;
}

.label {
  color: var(--mall-muted);
}

.amount {
  font-size: 36px;
  margin: 8px 0 16px;
}

.tx-row {
  display: flex;
  justify-content: space-between;
  padding: 14px 0;
  border-bottom: 1px solid var(--mall-line);
}

.muted {
  color: var(--mall-muted);
  font-size: 12px;
  margin-top: 4px;
}

.plus {
  color: #16a34a;
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
}

.pager {
  display: flex;
  justify-content: center;
  margin-top: 16px;
}
</style>
