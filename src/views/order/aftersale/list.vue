<template>
  <div class="aftersale-list" v-loading="loading">
    <h1>退款/售后</h1>

    <el-empty v-if="!list.length" description="暂无售后单" :image-size="80">
      <el-button type="primary" @click="$router.push('/order')">查看订单</el-button>
    </el-empty>

    <div
      v-for="item in list"
      :key="item.id"
      class="card"
      @click="$router.push(`/order/aftersale/${item.id}`)"
    >
      <div class="card-head">
        <span class="no">售后单 {{ item.no || item.id }}</span>
        <span class="status">{{ AFTER_SALE_STATUS_MAP[item.status] || item.status }}</span>
      </div>
      <div class="row">
        <img :src="item.picUrl" :alt="item.spuName" />
        <div class="info">
          <div class="name">{{ item.spuName }}</div>
          <div class="muted">
            {{ AFTER_SALE_WAY_MAP[item.way || 0] }} · 退款 {{ formatPrice(item.refundPrice) }}
          </div>
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
import {
  AfterSaleApi,
  AFTER_SALE_STATUS_MAP,
  AFTER_SALE_WAY_MAP,
  type AfterSale
} from '@/api/trade/afterSale'
import { formatPrice } from '@/utils/price'

const loading = ref(false)
const list = ref<AfterSale[]>([])
const total = ref(0)
const pageNo = ref(1)
const pageSize = 10

async function load() {
  loading.value = true
  try {
    const res = await AfterSaleApi.getAfterSalePage({ pageNo: pageNo.value, pageSize })
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

onMounted(load)
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

.card {
  background: var(--mall-surface);
  border-radius: var(--mall-radius);
  padding: 16px 18px;
  margin-bottom: 12px;
  cursor: pointer;
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
  transition: box-shadow 0.15s;
}

.card:hover {
  box-shadow: 0 4px 12px rgba(239, 68, 68, 0.08);
}

.card-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
  padding-bottom: 12px;
  border-bottom: 1px solid #f3f4f6;
  font-size: 13px;
}

.no {
  color: var(--mall-muted);
}

.status {
  color: var(--mall-accent);
  font-weight: 600;
}

.row {
  display: flex;
  gap: 12px;
  align-items: center;
}

.row img {
  width: 64px;
  height: 64px;
  object-fit: cover;
  border-radius: 8px;
  background: #f3f4f6;
  flex-shrink: 0;
}

.name {
  font-size: 14px;
  line-height: 1.4;
}

.muted {
  color: var(--mall-muted);
  font-size: 12px;
  margin-top: 6px;
}

.pager {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}
</style>
