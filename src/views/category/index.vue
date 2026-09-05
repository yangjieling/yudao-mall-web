<template>
  <div class="page-container category-page">
    <aside class="sidebar">
      <button
        class="cat-item"
        :class="{ active: !activeCategoryId }"
        @click="selectCategory(undefined)"
      >
        全部
      </button>
      <button
        v-for="cat in categories"
        :key="cat.id"
        class="cat-item"
        :class="{ active: activeCategoryId === cat.id }"
        @click="selectCategory(cat.id)"
      >
        {{ cat.name }}
      </button>
    </aside>

    <section class="content">
      <div class="toolbar">
        <h2>{{ currentTitle }}</h2>
        <span class="muted">共 {{ total }} 件</span>
      </div>

      <el-skeleton v-if="loading" :rows="6" animated />
      <div v-else class="product-grid">
        <ProductCard v-for="item in list" :key="item.id" :spu="item" />
      </div>
      <el-empty v-if="!loading && list.length === 0" description="该分类暂无商品" />

      <div v-if="total > pageSize" class="pager">
        <el-pagination
          background
          layout="prev, pager, next"
          :total="total"
          :page-size="pageSize"
          :current-page="pageNo"
          @current-change="onPageChange"
        />
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { CategoryApi, SpuApi, type ProductCategory, type ProductSpu } from '@/api/product'
import ProductCard from '@/components/ProductCard.vue'

const route = useRoute()
const router = useRouter()

const categories = ref<ProductCategory[]>([])
const list = ref<ProductSpu[]>([])
const loading = ref(false)
const total = ref(0)
const pageNo = ref(1)
const pageSize = 12

const activeCategoryId = computed(() => {
  const id = route.query.categoryId
  return id ? Number(id) : undefined
})

const keyword = computed(() => (route.query.keyword as string) || '')

const currentTitle = computed(() => {
  if (keyword.value) return `搜索：${keyword.value}`
  const cat = categories.value.find((c) => c.id === activeCategoryId.value)
  return cat?.name || '全部商品'
})

async function loadCategories() {
  const res = await CategoryApi.getCategoryList()
  // 只展示一级分类，避免过深
  categories.value = (res.data || []).filter((c) => !c.parentId || c.parentId === 0)
}

async function loadProducts() {
  loading.value = true
  try {
    const res = await SpuApi.getSpuPage({
      pageNo: pageNo.value,
      pageSize,
      categoryId: activeCategoryId.value,
      keyword: keyword.value || undefined
    })
    list.value = res.data?.list || []
    total.value = res.data?.total || 0
  } finally {
    loading.value = false
  }
}

function selectCategory(id?: number) {
  pageNo.value = 1
  router.push({
    path: '/category',
    query: {
      categoryId: id || undefined,
      keyword: keyword.value || undefined
    }
  })
}

function onPageChange(page: number) {
  pageNo.value = page
  loadProducts()
}

watch(
  () => [route.query.categoryId, route.query.keyword],
  () => {
    pageNo.value = 1
    loadProducts()
  }
)

onMounted(async () => {
  await loadCategories()
  await loadProducts()
})
</script>

<style scoped lang="scss">
.category-page {
  display: grid;
  grid-template-columns: 200px 1fr;
  gap: 20px;
  align-items: start;
}

.sidebar {
  background: var(--mall-surface);
  border-radius: var(--mall-radius);
  padding: 12px;
  border: 1px solid var(--mall-line);
  position: sticky;
  top: 96px;
}

.cat-item {
  display: block;
  width: 100%;
  text-align: left;
  border: 0;
  background: transparent;
  padding: 10px 12px;
  border-radius: 8px;
  cursor: pointer;
  color: var(--mall-muted);
  font-size: 14px;
}

.cat-item:hover,
.cat-item.active {
  background: #faf4ef;
  color: var(--mall-accent);
  font-weight: 600;
}

.content {
  min-height: 400px;
}

.toolbar {
  display: flex;
  align-items: baseline;
  gap: 12px;
  margin-bottom: 16px;
}

.toolbar h2 {
  margin: 0;
  font-size: 22px;
}

.muted {
  color: var(--mall-muted);
  font-size: 13px;
}

.product-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
}

.pager {
  display: flex;
  justify-content: center;
  margin-top: 28px;
}
</style>
