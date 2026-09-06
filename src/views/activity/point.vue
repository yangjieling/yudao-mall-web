<template>
  <div class="page-container activity-page" v-loading="loading">
    <h1>积分商城</h1>
    <el-empty v-if="!list.length" description="暂无积分商品" />
    <div class="grid">
      <div v-for="item in list" :key="item.id" class="card">
        <img :src="item.picUrl" :alt="item.spuName" />
        <div class="name">{{ item.spuName }}</div>
        <div class="price-row">
          <span class="price">{{ item.point || 0 }} 积分</span>
          <span v-if="item.price" class="market">+ {{ formatPrice(item.price) }}</span>
        </div>
        <el-button
          type="primary"
          size="small"
          :disabled="!item.spuId"
          @click="$router.push(`/goods/${item.spuId}`)"
        >
          去兑换
        </el-button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { PointActivityApi, type PointActivity } from '@/api/promotion/activity'
import { formatPrice } from '@/utils/price'

const loading = ref(false)
const list = ref<PointActivity[]>([])

onMounted(async () => {
  loading.value = true
  try {
    const res = await PointActivityApi.getPointActivityPage({ pageNo: 1, pageSize: 20 })
    list.value = res.data?.list || []
  } finally {
    loading.value = false
  }
})
</script>

<style scoped lang="scss">
h1 {
  margin: 0 0 16px;
  font-size: 24px;
}

.grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
}

.card {
  background: var(--mall-surface);
  border: 1px solid var(--mall-line);
  border-radius: var(--mall-radius);
  padding: 12px;
}

.card img {
  width: 100%;
  aspect-ratio: 1;
  object-fit: cover;
  border-radius: 8px;
  background: #f5f5f4;
}

.name {
  margin: 8px 0;
  height: 40px;
  overflow: hidden;
  font-size: 14px;
}

.price-row {
  display: flex;
  gap: 8px;
  align-items: baseline;
  margin-bottom: 10px;
}

.market {
  color: var(--mall-muted);
  font-size: 12px;
}
</style>
