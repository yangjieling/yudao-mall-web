<template>
  <div class="page-container activity-page" v-loading="loading">
    <div class="page-head">
      <h1>限时秒杀</h1>
      <p class="sub">精选好物，限时特惠</p>
    </div>

    <div v-if="configs.length" class="status-tabs">
      <button
        v-for="c in configs"
        :key="c.id"
        type="button"
        class="status-tab"
        :class="{ active: configId === String(c.id) }"
        @click="switchConfig(String(c.id))"
      >
        {{ c.name || `${c.startTime}-${c.endTime}` }}
      </button>
    </div>

    <el-empty v-if="!list.length" description="暂无秒杀活动" :image-size="80">
      <el-button type="primary" @click="$router.push('/category')">去逛商品</el-button>
    </el-empty>

    <div class="grid">
      <div v-for="item in list" :key="item.id" class="card">
        <div class="img-wrap">
          <img :src="item.picUrl" :alt="item.name" />
          <span class="badge">秒杀</span>
        </div>
        <div class="name">{{ item.name }}</div>
        <div class="price-row">
          <span class="price">{{ formatPrice(item.seckillPrice) }}</span>
          <span class="market">{{ formatPrice(item.marketPrice) }}</span>
        </div>
        <el-button
          type="primary"
          class="act-btn"
          :disabled="!item.spuId"
          @click="$router.push(`/goods/${item.spuId}`)"
        >
          去抢购
        </el-button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { SeckillApi, type SeckillActivity, type SeckillConfig } from '@/api/promotion/activity'
import { formatPrice } from '@/utils/price'

const loading = ref(false)
const configs = ref<SeckillConfig[]>([])
const configId = ref('')
const list = ref<SeckillActivity[]>([])

async function loadList() {
  loading.value = true
  try {
    const res = await SeckillApi.getSeckillActivityPage({
      pageNo: 1,
      pageSize: 20,
      configId: configId.value ? Number(configId.value) : undefined
    })
    list.value = res.data?.list || []
  } finally {
    loading.value = false
  }
}

function switchConfig(id: string) {
  if (configId.value === id) return
  configId.value = id
  loadList()
}

onMounted(async () => {
  const res = await SeckillApi.getSeckillConfigList().catch(() => ({ data: [] as SeckillConfig[] }))
  configs.value = res.data || []
  configId.value = configs.value[0] ? String(configs.value[0].id) : ''
  await loadList()
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

.status-tabs {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
  margin-bottom: 16px;
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
