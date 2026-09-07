<template>
  <div class="page-container activity-page" v-loading="loading">
    <div class="page-head">
      <h1>积分商城</h1>
      <p class="sub">积分兑换精选好物</p>
    </div>

    <el-empty v-if="!list.length" description="暂无积分商品" :image-size="80">
      <el-button type="primary" @click="$router.push('/category')">去逛商品</el-button>
    </el-empty>

    <div class="grid">
      <div v-for="item in list" :key="item.id" class="card">
        <div class="img-wrap">
          <img :src="item.picUrl" :alt="item.spuName" />
          <span class="badge">积分</span>
        </div>
        <div class="name">{{ item.spuName }}</div>
        <div class="price-row">
          <span class="price">{{ item.point || 0 }} 积分</span>
          <span v-if="item.price" class="extra">+ {{ formatPrice(item.price) }}</span>
        </div>
        <el-button
          type="primary"
          class="act-btn"
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
  margin: 10px 0 8px;
  height: 2.8em;
  overflow: hidden;
  font-size: 14px;
  line-height: 1.4;
}

.price-row {
  display: flex;
  gap: 8px;
  align-items: baseline;
  margin-bottom: 12px;
}

.extra {
  color: var(--mall-muted);
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
