<template>
  <div class="page-container coupon-center" v-loading="loading">
    <h1>领券中心</h1>
    <el-empty v-if="!list.length" description="暂无可领优惠券" />
    <div class="grid">
      <div v-for="item in list" :key="item.id" class="coupon-card">
        <div class="left">
          <div class="amount" v-if="item.discountType === 1">
            {{ formatPrice(item.discountPrice) }}
          </div>
          <div class="amount" v-else>{{ (item.discountPercent || 0) / 10 }}折</div>
          <div class="cond">满 {{ formatPrice(item.usePrice || 0) }} 可用</div>
        </div>
        <div class="right">
          <div class="name">{{ item.name }}</div>
          <div class="time">
            {{ formatDateTime(item.validStartTime) }} ~ {{ formatDateTime(item.validEndTime) }}
          </div>
          <el-button type="primary" size="small" :disabled="item.canTake === false" @click="take(item.id)">
            立即领取
          </el-button>
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
import { onMounted, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { CouponApi, type CouponTemplate } from '@/api/promotion/coupon'
import { formatPrice } from '@/utils/price'
import { formatDateTime } from '@/utils/datetime'
import { useUserStore } from '@/stores/user'
import { useRouter } from 'vue-router'

const userStore = useUserStore()
const router = useRouter()
const loading = ref(false)
const list = ref<CouponTemplate[]>([])
const total = ref(0)
const pageNo = ref(1)
const pageSize = 12

async function load() {
  loading.value = true
  try {
    const res = await CouponApi.getCouponTemplatePage({
      pageNo: pageNo.value,
      pageSize,
      canTake: true
    })
    list.value = res.data?.list || []
    total.value = res.data?.total || 0
  } finally {
    loading.value = false
  }
}

function onPage(p: number) {
  pageNo.value = p
  load()
}

async function take(templateId: number) {
  if (!userStore.isLogin) {
    router.push({ path: '/login', query: { redirect: '/coupon' } })
    return
  }
  await CouponApi.takeCoupon(templateId)
  ElMessage.success('领取成功')
  load()
}

onMounted(load)
</script>

<style scoped lang="scss">
h1 {
  margin: 0 0 20px;
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

.grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 16px;
}

.coupon-card {
  display: grid;
  grid-template-columns: 140px 1fr;
  background: var(--mall-surface);
  border-radius: var(--mall-radius);
  overflow: hidden;
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
}

.left {
  background: linear-gradient(160deg, #f87171, #ef4444);
  color: #fff;
  padding: 20px 12px;
  text-align: center;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.amount {
  font-size: 22px;
  font-weight: 700;
}

.cond {
  font-size: 12px;
  opacity: 0.9;
  margin-top: 6px;
}

.right {
  padding: 16px;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.name {
  font-weight: 600;
}

.time {
  color: var(--mall-muted);
  font-size: 12px;
  flex: 1;
  font-variant-numeric: tabular-nums;
}

.pager {
  display: flex;
  justify-content: center;
  margin-top: 24px;
}

@media (max-width: 800px) {
  .grid {
    grid-template-columns: 1fr;
  }
}
</style>
