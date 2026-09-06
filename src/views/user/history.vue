<template>
  <div class="history-page" v-loading="loading">
    <div class="head">
      <h1>浏览足迹</h1>
      <el-button link type="danger" @click="clean">清空</el-button>
    </div>
    <el-empty v-if="!list.length" description="暂无足迹" />
    <div class="grid">
      <div v-for="item in list" :key="item.id" class="card">
        <router-link :to="`/goods/${item.spuId}`">
          <img :src="item.spu?.picUrl" :alt="item.spu?.name" />
          <div class="name">{{ item.spu?.name }}</div>
          <div class="price">{{ formatPrice(item.spu?.price) }}</div>
        </router-link>
        <el-button link type="danger" @click="remove(item.spuId)">删除</el-button>
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
import { ElMessage, ElMessageBox } from 'element-plus'
import { HistoryApi, type BrowseHistoryItem } from '@/api/product/history'
import { formatPrice } from '@/utils/price'

const loading = ref(false)
const list = ref<BrowseHistoryItem[]>([])
const total = ref(0)
const pageNo = ref(1)
const pageSize = 12

async function load() {
  loading.value = true
  try {
    const res = await HistoryApi.getBrowseHistoryPage({ pageNo: pageNo.value, pageSize })
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
  await HistoryApi.deleteBrowseHistory([spuId])
  ElMessage.success('已删除')
  load()
}

async function clean() {
  await ElMessageBox.confirm('确认清空浏览足迹？', '提示')
  await HistoryApi.cleanBrowseHistory()
  ElMessage.success('已清空')
  load()
}

onMounted(load)
</script>

<style scoped lang="scss">
.head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

h1 {
  margin: 0;
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
