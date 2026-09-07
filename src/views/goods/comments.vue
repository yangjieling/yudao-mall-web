<template>
  <div class="page-container comments-page" v-loading="loading">
    <div class="head-bar">
      <h1>商品评价</h1>
      <router-link v-if="spuId" :to="`/goods/${spuId}`" class="back">返回商品</router-link>
    </div>

    <div class="summary" v-if="total > 0">
      共 <em>{{ total }}</em> 条评价
    </div>

    <el-empty v-if="!list.length" description="暂无评价" :image-size="80">
      <el-button v-if="spuId" type="primary" @click="$router.push(`/goods/${spuId}`)">
        查看商品
      </el-button>
    </el-empty>

    <div v-for="c in list" :key="c.id" class="comment">
      <div class="avatar">{{ (c.userNickname || '用')[0] }}</div>
      <div class="body">
        <div class="head">
          <span class="name">{{ c.userNickname || '用户' }}</span>
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
        <div class="time">{{ formatDateTime(c.createTime) }}</div>
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
import { computed, onMounted, ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import { CommentApi, type ProductComment } from '@/api/product'
import { formatDateTime } from '@/utils/datetime'

const route = useRoute()
const loading = ref(false)
const list = ref<ProductComment[]>([])
const total = ref(0)
const pageNo = ref(1)
const pageSize = 10

const spuId = computed(() => Number(route.params.id) || 0)

async function load() {
  if (!spuId.value) return
  loading.value = true
  try {
    const res = await CommentApi.getCommentPage(spuId.value, pageNo.value, pageSize, 0)
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
watch(
  () => route.params.id,
  () => {
    pageNo.value = 1
    load()
  }
)
</script>

<style scoped lang="scss">
.comments-page {
  padding-bottom: 40px;
}

.head-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 12px;
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

.back {
  font-size: 13px;
  color: var(--mall-muted);
}

.back:hover {
  color: var(--mall-accent);
}

.summary {
  margin-bottom: 14px;
  color: var(--mall-muted);
  font-size: 13px;
}

.summary em {
  font-style: normal;
  color: var(--mall-accent);
  font-weight: 600;
}

.comment {
  display: flex;
  gap: 12px;
  background: var(--mall-surface);
  border-radius: var(--mall-radius);
  padding: 16px 18px;
  margin-bottom: 12px;
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
}

.avatar {
  flex-shrink: 0;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: #fee2e2;
  color: var(--mall-accent);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: 600;
}

.body {
  flex: 1;
  min-width: 0;
}

.head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  margin-bottom: 8px;
}

.name {
  color: var(--mall-muted);
  font-size: 13px;
}

.body p {
  margin: 0;
  font-size: 14px;
  line-height: 1.6;
}

.pics {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
  margin-top: 10px;
}

.pic {
  width: 72px;
  height: 72px;
  border-radius: 8px;
  overflow: hidden;
}

.time {
  margin-top: 10px;
  color: var(--mall-muted);
  font-size: 12px;
  font-variant-numeric: tabular-nums;
}

.pager {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}
</style>
