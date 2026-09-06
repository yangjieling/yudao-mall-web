<template>
  <div class="page-container comments-page" v-loading="loading">
    <h1>商品评价</h1>
    <el-empty v-if="!list.length" description="暂无评价" />
    <div v-for="c in list" :key="c.id" class="comment">
      <div class="head">
        <span>{{ c.userNickname || '用户' }}</span>
        <el-rate :model-value="c.scores" disabled />
      </div>
      <p>{{ c.content }}</p>
      <div v-if="c.picUrls?.length" class="pics">
        <el-image
          v-for="(pic, i) in c.picUrls"
          :key="i"
          :src="pic"
          :preview-src-list="c.picUrls"
          fit="cover"
          class="pic"
        />
      </div>
      <div class="time">{{ c.createTime }}</div>
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
import { useRoute } from 'vue-router'
import { CommentApi, type ProductComment } from '@/api/product'

const route = useRoute()
const loading = ref(false)
const list = ref<ProductComment[]>([])
const total = ref(0)
const pageNo = ref(1)
const pageSize = 10

async function load() {
  const spuId = Number(route.params.id)
  if (!spuId) return
  loading.value = true
  try {
    const res = await CommentApi.getCommentPage(spuId, pageNo.value, pageSize)
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

.comment {
  background: var(--mall-surface);
  border: 1px solid var(--mall-line);
  border-radius: var(--mall-radius);
  padding: 16px 20px;
  margin-bottom: 12px;
}

.head {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
  color: var(--mall-muted);
}

.pics {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
  margin-top: 8px;
}

.pic {
  width: 72px;
  height: 72px;
  border-radius: 6px;
}

.time {
  margin-top: 8px;
  color: var(--mall-muted);
  font-size: 12px;
}

.pager {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}
</style>
