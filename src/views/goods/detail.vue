<template>
  <div class="page-container goods-detail" v-loading="loading">
    <template v-if="spu">
      <nav class="breadcrumb" aria-label="面包屑">
        <router-link to="/">首页</router-link>
        <span class="sep">/</span>
        <template v-for="item in breadcrumbCats" :key="item.id">
          <router-link :to="{ path: '/category', query: { categoryId: item.id } }">
            {{ item.name }}
          </router-link>
          <span class="sep">/</span>
        </template>
        <span class="current">{{ spu.name }}</span>
      </nav>

      <div class="buy-panel">
        <div class="gallery">
          <div v-if="pics.length" class="thumbs">
            <button
              v-for="(pic, idx) in pics"
              :key="idx"
              class="thumb"
              :class="{ active: activePic === pic }"
              @click="activePic = pic"
            >
              <img :src="pic" alt="" />
            </button>
          </div>
          <div class="main-wrap">
            <img :src="activePic" :alt="spu.name" class="main-pic" />
          </div>
        </div>

        <div class="info">
          <h1>{{ spu.name }}</h1>
          <p v-if="spu.introduction" class="intro">{{ spu.introduction }}</p>

          <div class="price-box">
            <div class="price-row">
              <span class="price-label">价格</span>
              <span class="price">{{ formatPrice(selectedSku?.price ?? spu.price) }}</span>
              <span v-if="selectedSku?.marketPrice || spu.marketPrice" class="market">
                {{ formatPrice(selectedSku?.marketPrice ?? spu.marketPrice!) }}
              </span>
            </div>
            <div class="meta-row">
              <span>库存 {{ selectedSku?.stock ?? spu.stock ?? 0 }}</span>
              <span v-if="spu.salesCount != null">销量 {{ spu.salesCount }}</span>
            </div>
          </div>

          <div class="service-row">
            <span class="label">服务</span>
            <div class="service-list">
              <span v-for="s in services" :key="s">{{ s }}</span>
            </div>
          </div>

          <div v-if="propertyOptions.length" class="sku-block">
            <div v-for="prop in propertyOptions" :key="prop.name" class="sku-row">
              <span class="label">{{ prop.name }}</span>
              <div class="values">
                <button
                  v-for="val in prop.values"
                  :key="val"
                  class="sku-value"
                  :class="{ active: selectedProps[prop.name] === val }"
                  @click="selectedProps[prop.name] = val"
                >
                  {{ val }}
                </button>
              </div>
            </div>
          </div>

          <div class="count-row">
            <span class="label">数量</span>
            <el-input-number v-model="count" :min="1" :max="Math.max(selectedSku?.stock || 1, 1)" />
          </div>

          <div class="actions">
            <el-button type="primary" size="large" class="btn-cart" :disabled="!selectedSku" @click="addToCart">
              加入购物车
            </el-button>
            <el-button size="large" class="btn-buy" :disabled="!selectedSku" @click="buyNow">
              立即购买
            </el-button>
            <button type="button" class="btn-fav" :class="{ on: favorited }" @click="toggleFavorite">
              <el-icon><StarFilled v-if="favorited" /><Star v-else /></el-icon>
              {{ favorited ? '已收藏' : '收藏' }}
            </button>
          </div>
        </div>
      </div>

      <div class="detail-tabs">
        <div class="tab-bar">
          <button
            type="button"
            class="tab"
            :class="{ active: activeTab === 'detail' }"
            @click="activeTab = 'detail'"
          >
            商品详情
          </button>
          <button
            type="button"
            class="tab"
            :class="{ active: activeTab === 'comment' }"
            @click="activeTab = 'comment'"
          >
            商品评价
            <span v-if="comments.length" class="tab-count">{{ comments.length }}+</span>
          </button>
          <router-link
            v-if="activeTab === 'comment'"
            class="more-link"
            :to="`/goods/${spu.id}/comments`"
          >
            查看全部评价
          </router-link>
        </div>

        <div v-show="activeTab === 'detail'" class="tab-panel">
          <div v-if="specRows.length" class="spec-block">
            <h3>规格参数</h3>
            <dl class="spec-table">
              <template v-for="row in specRows" :key="row.name">
                <dt>{{ row.name }}</dt>
                <dd>{{ row.value }}</dd>
              </template>
            </dl>
          </div>
          <div class="rich" v-html="spu.description || '暂无详情'" />
        </div>

        <div v-show="activeTab === 'comment'" class="tab-panel">
          <el-empty v-if="!comments.length" description="暂无评价" :image-size="64" />
          <div v-for="c in comments" :key="c.id" class="comment">
            <div class="comment-head">
              <span>{{ c.userNickname || '用户' }}</span>
              <el-rate :model-value="c.scores" disabled />
            </div>
            <p>{{ c.content }}</p>
          </div>
        </div>
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { Star, StarFilled } from '@element-plus/icons-vue'
import {
  CategoryApi,
  CommentApi,
  SpuApi,
  type ProductCategory,
  type ProductComment,
  type ProductSku,
  type ProductSpu
} from '@/api/product'
import { FavoriteApi } from '@/api/product/favorite'
import { useCartStore } from '@/stores/cart'
import { useUserStore } from '@/stores/user'
import { formatPrice } from '@/utils/price'

const route = useRoute()
const router = useRouter()
const cartStore = useCartStore()
const userStore = useUserStore()

const loading = ref(false)
const spu = ref<ProductSpu | null>(null)
const categories = ref<ProductCategory[]>([])
const comments = ref<ProductComment[]>([])
const count = ref(1)
const activePic = ref('')
const activeTab = ref<'detail' | 'comment'>('detail')
const favorited = ref(false)
const selectedProps = reactive<Record<string, string>>({})

const services = ['正品保障', '七天无理由退货', '极速退款']

const pics = computed(() => {
  if (!spu.value) return []
  const list = [spu.value.picUrl, ...(spu.value.sliderPicUrls || [])].filter(Boolean) as string[]
  return [...new Set(list)]
})

const breadcrumbCats = computed(() => {
  const id = spu.value?.categoryId
  if (!id || !categories.value.length) return [] as ProductCategory[]
  const byId = new Map(categories.value.map((c) => [c.id, c]))
  const chain: ProductCategory[] = []
  let cur = byId.get(id)
  const guard = new Set<number>()
  while (cur && !guard.has(cur.id)) {
    guard.add(cur.id)
    chain.unshift(cur)
    if (!cur.parentId || cur.parentId === 0) break
    cur = byId.get(cur.parentId)
  }
  return chain
})

const propertyOptions = computed(() => {
  const map = new Map<string, Set<string>>()
  for (const sku of spu.value?.skus || []) {
    for (const p of sku.properties || []) {
      const name = p.propertyName || ''
      const value = p.valueName || ''
      if (!name || !value) continue
      if (!map.has(name)) map.set(name, new Set())
      map.get(name)!.add(value)
    }
  }
  return [...map.entries()].map(([name, values]) => ({ name, values: [...values] }))
})

const selectedSku = computed<ProductSku | undefined>(() => {
  const skus = spu.value?.skus || []
  if (!skus.length) return undefined
  if (!propertyOptions.value.length) return skus[0]
  return skus.find((sku) =>
    (sku.properties || []).every((p) => selectedProps[p.propertyName || ''] === p.valueName)
  )
})

const specRows = computed(() => {
  const props = selectedSku.value?.properties || []
  return props
    .filter((p) => p.propertyName && p.valueName)
    .map((p) => ({ name: p.propertyName!, value: p.valueName! }))
})

watch(selectedSku, (sku) => {
  if (sku?.picUrl) activePic.value = sku.picUrl
})

async function loadCategories() {
  try {
    const res = await CategoryApi.getCategoryList()
    categories.value = res.data || []
  } catch {
    categories.value = []
  }
}

async function loadDetail() {
  const id = Number(route.params.id)
  if (!id) return
  loading.value = true
  activeTab.value = 'detail'
  try {
    const detailRes = await SpuApi.getSpuDetail(id)
    spu.value = detailRes.data
    activePic.value = pics.value[0] || ''
    Object.keys(selectedProps).forEach((k) => delete selectedProps[k])
    const first = spu.value?.skus?.[0]
    for (const p of first?.properties || []) {
      if (p.propertyName && p.valueName) {
        selectedProps[p.propertyName] = p.valueName
      }
    }
    try {
      const commentRes = await CommentApi.getCommentPage(id, 1, 5, 0)
      comments.value = commentRes.data?.list || []
    } catch {
      comments.value = []
    }
    if (userStore.isLogin) {
      try {
        const fav = await FavoriteApi.isFavoriteExists(id)
        favorited.value = !!fav.data
      } catch {
        favorited.value = false
      }
    } else {
      favorited.value = false
    }
  } finally {
    loading.value = false
  }
}

async function toggleFavorite() {
  if (!ensureLogin() || !spu.value) return
  if (favorited.value) {
    await FavoriteApi.deleteFavorite(spu.value.id)
    favorited.value = false
    ElMessage.success('已取消收藏')
  } else {
    await FavoriteApi.createFavorite(spu.value.id)
    favorited.value = true
    ElMessage.success('收藏成功')
  }
}

function ensureLogin() {
  if (!userStore.isLogin) {
    router.push({ path: '/login', query: { redirect: route.fullPath } })
    return false
  }
  return true
}

async function addToCart() {
  if (!ensureLogin() || !selectedSku.value) return
  await cartStore.add(selectedSku.value.id, count.value)
  ElMessage.success('已加入购物车')
}

async function buyNow() {
  if (!ensureLogin() || !selectedSku.value) return
  router.push({
    path: '/checkout',
    query: {
      skuId: String(selectedSku.value.id),
      count: String(count.value)
    }
  })
}

onMounted(async () => {
  await Promise.all([loadCategories(), loadDetail()])
})
watch(() => route.params.id, loadDetail)
</script>

<style scoped lang="scss">
.goods-detail {
  padding-bottom: 32px;
}

.breadcrumb {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 6px;
  margin: 12px 0 14px;
  font-size: 13px;
  color: var(--mall-muted);
  line-height: 1.4;
}

.breadcrumb a:hover {
  color: var(--mall-accent);
}

.breadcrumb .sep {
  color: #c4c7cc;
}

.breadcrumb .current {
  color: var(--mall-ink);
  max-width: 420px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.buy-panel {
  display: grid;
  grid-template-columns: minmax(400px, 460px) minmax(0, 1fr);
  gap: 28px;
  background: var(--mall-surface);
  border-radius: var(--mall-radius);
  padding: 20px;
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
}

.gallery {
  display: flex;
  gap: 10px;
  min-width: 0;
  align-items: flex-start;
}

.thumbs {
  display: flex;
  flex-direction: column;
  gap: 8px;
  max-height: 420px;
  overflow-y: auto;
  flex-shrink: 0;
  padding: 2px;
}

.thumb {
  width: 54px;
  height: 54px;
  border: 2px solid transparent;
  border-radius: 4px;
  padding: 0;
  overflow: hidden;
  cursor: pointer;
  background: #fff;
  flex-shrink: 0;
}

.thumb.active {
  border-color: var(--mall-accent);
}

.thumb img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.main-wrap {
  flex: 1;
  min-width: 0;
  border: 1px solid var(--mall-line);
  border-radius: 4px;
  overflow: hidden;
  background: #fafafa;
}

.main-pic {
  width: 100%;
  aspect-ratio: 1;
  object-fit: cover;
}

.info {
  min-width: 0;
}

.info h1 {
  margin: 0 0 6px;
  font-size: 18px;
  line-height: 1.45;
  font-weight: 700;
}

.intro {
  color: var(--mall-muted);
  margin: 0 0 12px;
  font-size: 13px;
  line-height: 1.5;
}

.price-box {
  background: linear-gradient(90deg, #fff5f5 0%, #fef2f2 60%, #fff 100%);
  border: 1px solid var(--mall-accent-border);
  border-radius: 6px;
  padding: 12px 14px;
  margin-bottom: 14px;
}

.price-row {
  display: flex;
  align-items: baseline;
  gap: 10px;
}

.price-label {
  color: var(--mall-muted);
  font-size: 13px;
}

.price {
  font-size: 28px;
  letter-spacing: -0.02em;
}

.market {
  color: var(--mall-muted);
  text-decoration: line-through;
  font-size: 13px;
}

.meta-row {
  display: flex;
  gap: 18px;
  color: var(--mall-muted);
  font-size: 12px;
  margin-top: 8px;
  padding-top: 8px;
  border-top: 1px dashed var(--mall-accent-border);
}

.service-row,
.sku-row,
.count-row {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  margin-bottom: 12px;
}

.label {
  flex-shrink: 0;
  width: 42px;
  color: var(--mall-muted);
  font-size: 13px;
  line-height: 28px;
}

.service-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px 14px;
  padding-top: 4px;
}

.service-list span {
  position: relative;
  padding-left: 12px;
  font-size: 13px;
  color: var(--mall-ink);
}

.service-list span::before {
  content: '';
  position: absolute;
  left: 0;
  top: 6px;
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: var(--mall-accent);
}

.sku-block {
  margin-bottom: 4px;
}

.values {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.sku-value {
  border: 1px solid var(--mall-line);
  background: #fff;
  border-radius: 2px;
  padding: 5px 12px;
  cursor: pointer;
  font-size: 13px;
  transition: border-color 0.15s, color 0.15s, background 0.15s;
}

.sku-value:hover {
  border-color: var(--mall-accent);
  color: var(--mall-accent);
}

.sku-value.active {
  border-color: var(--mall-accent);
  color: var(--mall-accent);
  background: var(--mall-accent-soft);
}

.count-row {
  align-items: center;
}

.actions {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 12px;
  margin-top: 18px;
  padding-top: 16px;
  border-top: 1px solid var(--mall-line);
}

.btn-cart {
  min-width: 140px;
  height: 42px;
  font-size: 15px;
}

.btn-buy {
  min-width: 140px;
  height: 42px;
  font-size: 15px;
  border-color: var(--mall-accent);
  color: var(--mall-accent);
  background: #fff;
}

.btn-buy:hover {
  background: var(--mall-accent-soft);
  border-color: var(--mall-accent);
  color: var(--mall-accent-dark);
}

.btn-fav {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  margin-left: 4px;
  border: 0;
  background: transparent;
  color: var(--mall-muted);
  font-size: 13px;
  cursor: pointer;
  padding: 8px 4px;
}

.btn-fav:hover,
.btn-fav.on {
  color: var(--mall-accent);
}

.detail-tabs {
  margin-top: 14px;
  background: var(--mall-surface);
  border-radius: var(--mall-radius);
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
  overflow: hidden;
}

.tab-bar {
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 0 16px;
  border-bottom: 1px solid var(--mall-line);
  background: #fafafa;
}

.tab {
  position: relative;
  border: 0;
  background: transparent;
  padding: 13px 16px;
  font-size: 14px;
  color: var(--mall-muted);
  cursor: pointer;
}

.tab.active {
  color: var(--mall-accent);
  font-weight: 600;
}

.tab.active::after {
  content: '';
  position: absolute;
  left: 16px;
  right: 16px;
  bottom: 0;
  height: 2px;
  background: var(--mall-accent);
  border-radius: 1px;
}

.tab-count {
  margin-left: 4px;
  font-size: 12px;
  font-weight: 400;
}

.more-link {
  margin-left: auto;
  font-size: 13px;
  color: var(--mall-muted);
}

.more-link:hover {
  color: var(--mall-accent);
}

.tab-panel {
  padding: 20px 22px;
  min-height: 160px;
}

.spec-block {
  margin-bottom: 20px;
  padding-bottom: 16px;
  border-bottom: 1px solid var(--mall-line);
}

.spec-block h3 {
  margin: 0 0 12px;
  font-size: 15px;
  font-weight: 600;
}

.spec-table {
  display: grid;
  grid-template-columns: 100px 1fr;
  gap: 0;
  margin: 0;
  border: 1px solid var(--mall-line);
  border-radius: 4px;
  overflow: hidden;
  font-size: 13px;
}

.spec-table dt,
.spec-table dd {
  margin: 0;
  padding: 10px 12px;
  border-bottom: 1px solid var(--mall-line);
}

.spec-table dt {
  background: #fafafa;
  color: var(--mall-muted);
}

.spec-table dd:nth-last-of-type(1),
.spec-table dt:nth-last-of-type(1) {
  border-bottom: 0;
}

.rich :deep(img) {
  max-width: 100%;
}

.comment {
  padding: 14px 0;
  border-bottom: 1px solid var(--mall-line);
}

.comment:last-child {
  border-bottom: 0;
}

.comment-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 6px;
  color: var(--mall-muted);
  font-size: 13px;
}

.comment p {
  margin: 0;
  font-size: 14px;
  line-height: 1.6;
}

@media (max-width: 960px) {
  .buy-panel {
    grid-template-columns: 1fr;
    gap: 16px;
    padding: 14px;
  }

  .gallery {
    flex-direction: column-reverse;
  }

  .thumbs {
    flex-direction: row;
    max-height: none;
    overflow-x: auto;
    width: 100%;
  }

  .breadcrumb .current {
    max-width: 200px;
  }

  .btn-cart,
  .btn-buy {
    flex: 1;
    min-width: 0;
  }
}
</style>
