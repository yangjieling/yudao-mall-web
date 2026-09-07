<template>
  <div class="favorite-page" v-loading="loading">
    <h1>我的收藏</h1>
    <el-empty v-if="!list.length" description="暂无收藏" />
    <div class="grid">
      <div v-for="item in list" :key="item.id" class="card">
        <router-link :to="`/goods/${item.spuId}`">
          <img :src="item.picUrl" :alt="item.spuName" />
          <div class="name">{{ item.spuName }}</div>
          <div class="price">{{ formatPrice(item.price) }}</div>
        </router-link>
        <el-button link type="danger" @click="remove(item.spuId)">取消收藏</el-button>
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
h1 {
  margin: 0 0 16px;
  font-size: 22px;
}

.grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 14px;
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
  margin-top: 8px;
  font-size: 14px;
  height: 40px;
  overflow: hidden;
}

.pager {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}
</style>
