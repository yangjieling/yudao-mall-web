<template>
  <div class="my-coupon" v-loading="loading">
    <h1>我的优惠券</h1>
    <el-tabs v-model="status" @tab-change="onTab">
      <el-tab-pane label="未使用" name="1" />
      <el-tab-pane label="已使用" name="2" />
      <el-tab-pane label="已过期" name="3" />
    </el-tabs>
    <el-empty v-if="!list.length" description="暂无优惠券">
      <el-button type="primary" @click="$router.push('/coupon')">去领券</el-button>
    </el-empty>
    <div v-for="item in list" :key="item.id" class="coupon-row">
      <div>
        <div class="name">{{ item.name }}</div>
        <div class="meta">
          {{ item.validStartTime }} ~ {{ item.validEndTime }} ·
          {{ COUPON_STATUS_MAP[item.status] || item.status }}
        </div>
      </div>
      <div class="price">
        <template v-if="item.discountType === 1">{{ formatPrice(item.discountPrice) }}</template>
        <template v-else>{{ (item.discountPercent || 0) / 10 }}折</template>
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

const loading = ref(false)
const list = ref<Coupon[]>([])
const total = ref(0)
const pageNo = ref(1)
const pageSize = 10
const status = ref('1')

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

function onTab() {
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
h1 {
  margin: 0 0 12px;
  font-size: 22px;
}

.coupon-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: var(--mall-surface);
  border: 1px solid var(--mall-line);
  border-radius: var(--mall-radius);
  padding: 16px 20px;
  margin-bottom: 10px;
}

.name {
  font-weight: 600;
}

.meta {
  margin-top: 6px;
  color: var(--mall-muted);
  font-size: 12px;
}

.pager {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}
</style>
