<template>
  <div class="page-container category-page">
    <aside class="sidebar">
      <div class="side-title">分类</div>
      <button
        class="cat-item"
        :class="{ active: !activeCategoryId }"
        @click="selectCategory(undefined)"
      >
        <el-icon class="cat-icon" :size="16"><Menu /></el-icon>
        <span>全部</span>
      </button>
      <div v-for="cat in rootCategories" :key="cat.id" class="cat-group">
        <button
          class="cat-item"
          :class="{ active: activeCategoryId === cat.id }"
          @click="selectCategory(cat.id)"
        >
          <el-icon class="cat-icon" :size="16">
            <component :is="iconForCategory(cat.name)" />
          </el-icon>
          <span>{{ cat.name }}</span>
        </button>
        <button
          v-for="child in childrenOf(cat.id)"
          :key="child.id"
          class="cat-item child"
          :class="{ active: activeCategoryId === child.id }"
          @click="selectCategory(child.id)"
        >
          <span class="child-dot" />
          <span>{{ child.name }}</span>
        </button>
      </div>
    </aside>

    <section class="content">
      <div class="toolbar">
        <div class="toolbar-left">
          <h2>{{ currentTitle }}</h2>
          <span class="muted">共 {{ total }} 件</span>
        </div>
        <div class="sorts">
          <el-radio-group v-model="sortKey" size="small" @change="onSortChange">
            <el-radio-button value="default">综合</el-radio-button>
            <el-radio-button value="salesCount">销量</el-radio-button>
            <el-radio-button value="priceAsc">价格升</el-radio-button>
            <el-radio-button value="priceDesc">价格降</el-radio-button>
          </el-radio-group>
        </div>
      </div>

      <el-skeleton v-if="loading" :rows="6" animated />
      <div v-else class="product-grid">
        <ProductCard v-for="item in list" :key="item.id" :spu="item" />
      </div>
      <el-empty v-if="!loading && list.length === 0" :description="emptyDescription">
        <el-button v-if="keyword" @click="clearSearch">清除搜索</el-button>
        <el-button type="primary" @click="goAllGoods">全部商品</el-button>
      </el-empty>

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
import { Menu } from '@element-plus/icons-vue'
import { CategoryApi, SpuApi, type ProductCategory, type ProductSpu } from '@/api/product'
import ProductCard from '@/components/ProductCard.vue'
import { iconForCategory } from '@/utils/categoryIcon'

const route = useRoute()
const router = useRouter()

const allCategories = ref<ProductCategory[]>([])
const list = ref<ProductSpu[]>([])
const loading = ref(false)
const total = ref(0)
const pageNo = ref(1)
const pageSize = 12
const sortKey = ref('default')

const activeCategoryId = computed(() => {
  const id = route.query.categoryId
  return id ? Number(id) : undefined
})

const keyword = computed(() => (route.query.keyword as string) || '')

const rootCategories = computed(() =>
  allCategories.value.filter((c) => !c.parentId || c.parentId === 0)
)

function childrenOf(parentId: number) {
  return allCategories.value.filter((c) => c.parentId === parentId)
}

const currentTitle = computed(() => {
  if (keyword.value) return `搜索：${keyword.value}`
  const cat = allCategories.value.find((c) => c.id === activeCategoryId.value)
  return cat?.name || '全部商品'
})

const emptyDescription = computed(() => {
  if (keyword.value) return `未找到与「${keyword.value}」相关的商品`
  if (activeCategoryId.value) return '该分类暂无商品'
  return '暂无商品'
})

const appTitle = import.meta.env.VITE_APP_TITLE || 'OM Shop'

watch(
  currentTitle,
  (title) => {
    document.title = `${title} - ${appTitle}`
  },
  { immediate: true }
)

function sortParams(): { sortField?: string; sortAsc?: boolean } {
  if (sortKey.value === 'salesCount') return { sortField: 'salesCount', sortAsc: false }
  if (sortKey.value === 'priceAsc') return { sortField: 'price', sortAsc: true }
  if (sortKey.value === 'priceDesc') return { sortField: 'price', sortAsc: false }
  return {}
}

async function loadCategories() {
  const res = await CategoryApi.getCategoryList()
  allCategories.value = res.data || []
}

async function loadProducts() {
  loading.value = true
  try {
    const res = await SpuApi.getSpuPage({
      pageNo: pageNo.value,
      pageSize,
      categoryId: activeCategoryId.value,
      keyword: keyword.value || undefined,
      ...sortParams()
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

function onSortChange() {
  pageNo.value = 1
  loadProducts()
}

function clearSearch() {
  router.push({
    path: '/category',
    query: { categoryId: activeCategoryId.value || undefined }
  })
}

function goAllGoods() {
  router.push({ path: '/category' })
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
  grid-template-columns: 220px 1fr;
  gap: 16px;
  align-items: start;
}

.sidebar {
  background: var(--mall-surface);
  border-radius: var(--mall-radius);
  padding: 12px 10px;
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
  position: sticky;
  top: 96px;
  max-height: calc(100vh - 120px);
  overflow: auto;
}

.side-title {
  padding: 4px 10px 12px;
  font-size: 14px;
  font-weight: 700;
}

.cat-group + .cat-group {
  margin-top: 4px;
  padding-top: 4px;
  border-top: 1px dashed var(--mall-line);
}

.cat-item {
  display: flex;
  align-items: center;
  gap: 8px;
  width: 100%;
  text-align: left;
  border: 0;
  background: transparent;
  padding: 9px 10px;
  border-radius: 8px;
  cursor: pointer;
  color: var(--mall-ink);
  font-size: 14px;
}

.cat-item.child {
  padding-left: 34px;
  font-size: 13px;
  color: var(--mall-muted);
}

.cat-icon {
  color: #6b7280;
  flex-shrink: 0;
}

.child-dot {
  width: 4px;
  height: 4px;
  border-radius: 50%;
  background: #d1d5db;
  flex-shrink: 0;
  margin-left: 6px;
}

.cat-item:hover,
.cat-item.active {
  background: var(--mall-accent-soft);
  color: var(--mall-accent);
  font-weight: 600;
}

.cat-item:hover .cat-icon,
.cat-item.active .cat-icon {
  color: var(--mall-accent);
}

.cat-item.active .child-dot,
.cat-item:hover .child-dot {
  background: var(--mall-accent);
}

.content {
  min-height: 400px;
  background: var(--mall-surface);
  border-radius: var(--mall-radius);
  padding: 16px 18px 24px;
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
}

.toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 16px;
  flex-wrap: wrap;
  padding-bottom: 14px;
  border-bottom: 1px solid var(--mall-line);
}

.toolbar-left {
  display: flex;
  align-items: baseline;
  gap: 10px;
}

.toolbar h2 {
  margin: 0;
  font-size: 20px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.toolbar h2::before {
  content: '';
  width: 4px;
  height: 16px;
  border-radius: 2px;
  background: var(--mall-accent);
  display: inline-block;
}

.muted {
  color: var(--mall-muted);
  font-size: 13px;
}

.sorts :deep(.el-radio-button__original-radio:checked + .el-radio-button__inner) {
  background: var(--mall-accent);
  border-color: var(--mall-accent);
  box-shadow: -1px 0 0 0 var(--mall-accent);
}

.product-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 14px;
}

.pager {
  display: flex;
  justify-content: center;
  margin-top: 28px;
}

@media (max-width: 1100px) {
  .product-grid {
    grid-template-columns: repeat(3, 1fr);
  }
}

@media (max-width: 760px) {
  .category-page {
    grid-template-columns: 1fr;
  }

  .sidebar {
    position: static;
    max-height: 220px;
  }

  .product-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>
