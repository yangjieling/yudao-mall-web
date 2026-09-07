<template>
  <div class="page-container activity-page" v-loading="loading">
    <div class="page-head">
      <h1>超值拼团</h1>
      <p class="sub">多人成团，价格更优</p>
    </div>

    <el-empty v-if="!list.length" description="暂无拼团活动" :image-size="80">
      <el-button type="primary" @click="$router.push('/category')">去逛商品</el-button>
    </el-empty>

    <div class="grid">
      <div v-for="item in list" :key="item.id" class="card">
        <div class="img-wrap">
          <img :src="item.picUrl" :alt="item.name || item.spuName" />
          <span class="badge">拼团</span>
        </div>
        <div class="name">{{ item.name || item.spuName }}</div>
        <div class="meta">{{ item.userSize || '-' }} 人团</div>
        <div class="price-row">
          <span class="price">{{ formatPrice(item.combinationPrice) }}</span>
          <span class="market">{{ formatPrice(item.marketPrice) }}</span>
        </div>
        <el-button
          type="primary"
          class="act-btn"
          :disabled="!item.spuId"
          @click="$router.push(`/goods/${item.spuId}`)"
        >
          去参团
        </el-button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { CombinationApi, type CombinationActivity } from '@/api/promotion/activity'
import { formatPrice } from '@/utils/price'

const loading = ref(false)
const list = ref<CombinationActivity[]>([])

onMounted(async () => {
  loading.value = true
  try {
    const res = await CombinationApi.getCombinationActivityPage({ pageNo: 1, pageSize: 20 })
    list.value = res.data?.list || []
  } finally {
    loading.value = false
  }
})
</script>

<style scoped lang="scss">
.activity-page {
  padding-bottom: 40px;
}

.page-head {
  margin-bottom: 16px;
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

.sub {
  margin: 8px 0 0;
  color: var(--mall-muted);
  font-size: 13px;
}

.grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 14px;
}

.card {
  background: var(--mall-surface);
  border-radius: var(--mall-radius);
  padding: 12px;
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
}

.img-wrap {
  position: relative;
}

.card img {
  width: 100%;
  aspect-ratio: 1;
  object-fit: cover;
  border-radius: 8px;
  background: #f3f4f6;
}

.badge {
  position: absolute;
  left: 8px;
  top: 8px;
  padding: 2px 8px;
  border-radius: 999px;
  background: rgba(239, 68, 68, 0.92);
  color: #fff;
  font-size: 12px;
  font-weight: 600;
}

.name {
  margin: 10px 0 4px;
  height: 2.8em;
  overflow: hidden;
  font-size: 14px;
  line-height: 1.4;
}

.meta {
  color: var(--mall-muted);
  font-size: 12px;
  margin-bottom: 8px;
}

.price-row {
  display: flex;
  gap: 8px;
  align-items: baseline;
  margin-bottom: 12px;
}

.market {
  color: var(--mall-muted);
  text-decoration: line-through;
  font-size: 12px;
}

.act-btn {
  width: 100%;
}

@media (max-width: 1100px) {
  .grid {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }
}

@media (max-width: 800px) {
  .grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}
</style>
