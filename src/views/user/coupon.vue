<template>
  <div class="my-coupon" v-loading="loading">
    <div class="head">
      <h1>我的优惠券</h1>
      <router-link to="/coupon" class="more">领券中心</router-link>
    </div>

    <div class="status-tabs">
      <button
        v-for="tab in tabs"
        :key="tab.name"
        type="button"
        class="status-tab"
        :class="{ active: status === tab.name }"
        @click="switchTab(tab.name)"
      >
        {{ tab.label }}
      </button>
    </div>

    <el-empty v-if="!list.length" description="暂无优惠券" :image-size="80">
      <el-button type="primary" @click="$router.push('/coupon')">去领券</el-button>
    </el-empty>

    <div v-for="item in list" :key="item.id" class="coupon-card" :class="{ muted: status !== '1' }">
      <div class="left">
        <div class="amount" v-if="item.discountType === 1">{{ formatPrice(item.discountPrice) }}</div>
        <div class="amount" v-else>{{ (item.discountPercent || 0) / 10 }}折</div>
        <div class="cond">优惠券</div>
      </div>
      <div class="right">
        <div class="name">{{ item.name }}</div>
        <div class="meta">
          {{ formatDateTime(item.validStartTime) }} ~ {{ formatDateTime(item.validEndTime) }}
        </div>
        <div class="status-text">{{ COUPON_STATUS_MAP[item.status] || item.status }}</div>
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
import { CouponApi, COUPON_STATUS_MAP, type Coupon } from '@/api/promotion/coupon'
import { formatPrice } from '@/utils/price'
import { formatDateTime } from '@/utils/datetime'

const loading = ref(false)
const list = ref<Coupon[]>([])
const total = ref(0)
const pageNo = ref(1)
const pageSize = 10
const status = ref('1')

const tabs = [
  { name: '1', label: '未使用' },
  { name: '2', label: '已使用' },
  { name: '3', label: '已过期' }
]

async function load() {
  loading.value = true
  try {
    const res = await CouponApi.getCouponPage({
      pageNo: pageNo.value,
      pageSize,
      status: Number(status.value)
    })
    list.value = res.data?.list || []
    total.value = res.data?.total || 0
  } finally {
    loading.value = false
  }
}

function switchTab(name: string) {
  if (status.value === name) return
  status.value = name
  pageNo.value = 1
  load()
}

function onPage(p: number) {
  pageNo.value = p
  load()
}

onMounted(load)
</script>

<style scoped lang="scss">
.head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 14px;
}

h1 {
  margin: 0;
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

.more {
  font-size: 13px;
  color: var(--mall-muted);
}

.more:hover {
  color: var(--mall-accent);
}

.status-tabs {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
  margin-bottom: 14px;
  padding: 6px;
  background: var(--mall-surface);
  border-radius: var(--mall-radius);
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
}

.status-tab {
  border: 0;
  background: transparent;
  padding: 8px 16px;
  border-radius: 8px;
  font-size: 14px;
  color: var(--mall-muted);
  cursor: pointer;
}

.status-tab.active {
  background: var(--mall-accent-soft);
  color: var(--mall-accent);
  font-weight: 600;
}

.coupon-card {
  display: grid;
  grid-template-columns: 120px 1fr;
  margin-bottom: 12px;
  border-radius: var(--mall-radius);
  overflow: hidden;
  background: var(--mall-surface);
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
}

.coupon-card.muted {
  opacity: 0.72;
  filter: grayscale(0.2);
}

.left {
  background: linear-gradient(160deg, #f87171, #ef4444);
  color: #fff;
  padding: 18px 10px;
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
  margin-top: 4px;
  font-size: 12px;
  opacity: 0.9;
}

.right {
  padding: 16px 18px;
  min-width: 0;
}

.name {
  font-weight: 600;
  font-size: 15px;
}

.meta {
  margin-top: 8px;
  color: var(--mall-muted);
  font-size: 12px;
  font-variant-numeric: tabular-nums;
}

.status-text {
  margin-top: 8px;
  font-size: 12px;
  color: var(--mall-accent);
}

.pager {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}
</style>
