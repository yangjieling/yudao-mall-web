<template>
  <div class="page-container activity-page" v-loading="loading">
    <h1>限时秒杀</h1>
    <el-tabs v-if="configs.length" v-model="configId" @tab-change="loadList">
      <el-tab-pane
        v-for="c in configs"
        :key="c.id"
        :label="c.name || `${c.startTime}-${c.endTime}`"
        :name="String(c.id)"
      />
    </el-tabs>
    <el-empty v-if="!list.length" description="暂无秒杀活动" />
    <div class="grid">
      <div v-for="item in list" :key="item.id" class="card">
        <img :src="item.picUrl" :alt="item.name" />
        <div class="name">{{ item.name }}</div>
        <div class="price-row">
          <span class="price">{{ formatPrice(item.seckillPrice) }}</span>
          <span class="market">{{ formatPrice(item.marketPrice) }}</span>
        </div>
        <el-button
          type="primary"
          size="small"
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

onMounted(async () => {
  const res = await SeckillApi.getSeckillConfigList().catch(() => ({ data: [] as SeckillConfig[] }))
  configs.value = res.data || []
  configId.value = configs.value[0] ? String(configs.value[0].id) : ''
  await loadList()
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
  text-decoration: line-through;
  font-size: 12px;
}
</style>
