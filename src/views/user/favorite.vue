<template>
  <div class="favorite-page" v-loading="loading">
    <div class="head">
      <h1>我的收藏</h1>
      <router-link to="/category" class="more">去逛逛</router-link>
    </div>

    <el-empty v-if="!list.length" description="暂无收藏" :image-size="80">
      <el-button type="primary" @click="$router.push('/category')">去选购</el-button>
    </el-empty>

    <div class="grid">
      <div v-for="item in list" :key="item.id" class="card">
        <router-link :to="`/goods/${item.spuId}`" class="goods">
          <img :src="item.picUrl" :alt="item.spuName" />
          <div class="name">{{ item.spuName }}</div>
          <div class="price">{{ formatPrice(item.price) }}</div>
        </router-link>
        <button type="button" class="remove" @click="remove(item.spuId)">取消收藏</button>
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
import { FavoriteApi, type FavoriteItem } from '@/api/product/favorite'
import { formatPrice } from '@/utils/price'

const loading = ref(false)
const list = ref<FavoriteItem[]>([])
const total = ref(0)
const pageNo = ref(1)
const pageSize = 12

async function load() {
  loading.value = true
  try {
    const res = await FavoriteApi.getFavoritePage({ pageNo: pageNo.value, pageSize })
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

async function remove(spuId: number) {
  await FavoriteApi.deleteFavorite(spuId)
  ElMessage.success('已取消收藏')
  load()
}

onMounted(load)
</script>

<style scoped lang="scss">
.head {
  display: flex;
  align-items: center;
  justify-content: space-between;
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

.more {
  font-size: 13px;
  color: var(--mall-muted);
}

.more:hover {
  color: var(--mall-accent);
}

.grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 14px;
}

.card {
  background: var(--mall-surface);
  border-radius: var(--mall-radius);
  padding: 12px;
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
}

.goods {
  display: block;
}

.card img {
  width: 100%;
  aspect-ratio: 1;
  object-fit: cover;
  border-radius: 8px;
  background: #f3f4f6;
}

.name {
  margin-top: 10px;
  font-size: 14px;
  line-height: 1.4;
  height: 2.8em;
  overflow: hidden;
}

.price {
  margin-top: 6px;
  font-size: 16px;
}

.remove {
  margin-top: 8px;
  border: 0;
  background: transparent;
  color: var(--mall-muted);
  font-size: 13px;
  cursor: pointer;
  padding: 0;
}

.remove:hover {
  color: var(--mall-accent);
}

.pager {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}

@media (max-width: 900px) {
  .grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}
</style>
