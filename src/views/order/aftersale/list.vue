<template>
  <div class="aftersale-list" v-loading="loading">
    <h1>退款/售后</h1>
    <el-empty v-if="!list.length" description="暂无售后单" />
    <div v-for="item in list" :key="item.id" class="card" @click="$router.push(`/order/aftersale/${item.id}`)">
      <div class="head">
        <span>售后单 {{ item.no || item.id }}</span>
        <span class="status">{{ AFTER_SALE_STATUS_MAP[item.status] || item.status }}</span>
      </div>
      <div class="row">
        <img :src="item.picUrl" :alt="item.spuName" />
        <div>
          <div>{{ item.spuName }}</div>
          <div class="muted">{{ AFTER_SALE_WAY_MAP[item.way || 0] }} · 退款 {{ formatPrice(item.refundPrice) }}</div>
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
}

.card {
  background: var(--mall-surface);
  border: 1px solid var(--mall-line);
  border-radius: var(--mall-radius);
  padding: 16px;
  margin-bottom: 12px;
  cursor: pointer;
}

.head {
  display: flex;
  justify-content: space-between;
  color: var(--mall-muted);
  font-size: 13px;
  margin-bottom: 12px;
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
  width: 56px;
  height: 56px;
  object-fit: cover;
  border-radius: 6px;
  background: #f5f5f4;
}

.muted {
  color: var(--mall-muted);
  font-size: 12px;
  margin-top: 4px;
}

.pager {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}
</style>
