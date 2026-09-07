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

      <div class="detail-layout">
        <div class="left-col">
          <div class="gallery-card">
            <div class="gallery">
              <div v-if="pics.length" class="thumbs">
                <button
                  v-for="(pic, idx) in pics"
                  :key="idx"
                  type="button"
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
          </div>

          <div ref="tabsRef" class="detail-tabs">
            <div class="tab-bar">
              <button
                type="button"
                class="tab"
                :class="{ active: activeTab === 'comment' }"
                @click="selectTab('comment')"
              >
                商品评价
              </button>
              <button
                type="button"
                class="tab"
                :class="{ active: activeTab === 'detail' }"
                @click="selectTab('detail')"
              >
                商品详情
              </button>
              <button
                type="button"
                class="tab"
                :class="{ active: activeTab === 'aftersale' }"
                @click="selectTab('aftersale')"
              >
                售后保障
              </button>
            </div>

            <div v-show="activeTab === 'comment'" class="tab-panel">
              <div class="comment-summary">
                <h3>
                  买家评价
                  <span class="total">({{ commentTotalText }})</span>
                </h3>
                <router-link :to="`/goods/${spu.id}/comments`">查看全部评价</router-link>
              </div>
              <el-empty v-if="!comments.length" description="暂无评价" :image-size="64" />
              <div v-for="c in comments" :key="c.id" class="comment">
                <div class="avatar">{{ (c.userNickname || '用')[0] }}</div>
                <div class="comment-body">
                  <div class="comment-head">
                    <span class="name">{{ c.userNickname || '用户' }}</span>
                    <el-rate :model-value="c.scores" disabled />
                  </div>
                  <p>{{ c.content }}</p>
                </div>
              </div>
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

            <div v-show="activeTab === 'aftersale'" class="tab-panel aftersale-panel">
              <ul>
                <li v-for="s in aftersaleTips" :key="s">{{ s }}</li>
              </ul>
            </div>
          </div>
        </div>

        <aside class="right-col">
          <div class="info-card">
            <div class="title-row">
              <div class="title-main">
                <span class="tag-own">OM自营</span>
                <h1>{{ spu.name }}</h1>
              </div>
              <button type="button" class="btn-fav" :class="{ on: favorited }" @click="toggleFavorite">
                <el-icon :size="18"><StarFilled v-if="favorited" /><Star v-else /></el-icon>
                <span>{{ favorited ? '已收藏' : '收藏' }}</span>
              </button>
            </div>
            <p v-if="spu.introduction" class="intro">{{ spu.introduction }}</p>

            <div class="price-strip">
              <div class="price-left">
                <span class="price">{{ formatPrice(selectedSku?.price ?? spu.price) }}</span>
                <span v-if="discountLabel" class="price-tag">{{ discountLabel }}</span>
                <span v-if="showMarket" class="market">
                  {{ formatPrice(selectedSku?.marketPrice ?? spu.marketPrice!) }}
                </span>
              </div>
              <button type="button" class="comment-link" @click="selectTab('comment')">
                累计评价
                <em>{{ commentTotalText }}</em>
              </button>
            </div>

            <div class="info-rows">
              <div class="info-row">
                <span class="row-label">配送</span>
                <div class="row-body">
                  <span>快递发货 · 预计 1–3 天送达</span>
                  <span class="muted">库存 {{ selectedSku?.stock ?? spu.stock ?? 0 }}</span>
                  <span v-if="spu.salesCount != null" class="muted">销量 {{ spu.salesCount }}</span>
                </div>
              </div>

              <div class="info-row">
                <span class="row-label">服务</span>
                <div class="row-body service-body">
                  <span v-for="s in services" :key="s">{{ s }}</span>
                </div>
              </div>

              <div v-for="prop in propertyOptions" :key="prop.name" class="info-row">
                <span class="row-label">{{ prop.name }}</span>
                <div class="row-body sku-values">
                  <button
                    v-for="item in prop.values"
                    :key="item.value"
                    type="button"
                    class="sku-value"
                    :class="{ active: selectedProps[prop.name] === item.value, 'has-pic': !!item.picUrl }"
                    @click="selectedProps[prop.name] = item.value"
                  >
                    <img v-if="item.picUrl" :src="item.picUrl" alt="" class="sku-pic" />
                    <span>{{ item.value }}</span>
                  </button>
                </div>
              </div>
            </div>

            <div class="action-bar">
              <el-input-number
                v-model="count"
                class="qty"
                :min="1"
                :max="Math.max(selectedSku?.stock || 1, 1)"
              />
              <button type="button" class="btn-cart" :disabled="!selectedSku" @click="addToCart">
                加入购物车
              </button>
              <button type="button" class="btn-buy" :disabled="!selectedSku" @click="buyNow">
                立即购买
              </button>
            </div>
          </div>
        </aside>
      </div>

      <section v-if="recommends.length" class="recommend">
        <div class="recommend-head">
          <h2>相关推荐</h2>
          <router-link
            :to="
              spu.categoryId
                ? { path: '/category', query: { categoryId: spu.categoryId } }
                : '/category'
            "
          >
            查看更多
          </router-link>
        </div>
        <div class="recommend-grid">
          <ProductCard v-for="item in recommends" :key="item.id" :spu="item" />
        </div>
      </section>
    </template>
    <el-empty
      v-else-if="!loading"
      description="商品不存在或已下架"
      :image-size="96"
    >
      <el-button type="primary" @click="$router.push('/category')">去逛逛</el-button>
    </el-empty>
  </div>
</template>

<script setup lang="ts">
import { computed, nextTick, onMounted, reactive, ref, watch } from 'vue'
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
import ProductCard from '@/components/ProductCard.vue'
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
const commentTotal = ref(0)
const recommends = ref<ProductSpu[]>([])
const count = ref(1)
const activePic = ref('')
const activeTab = ref<'detail' | 'comment' | 'aftersale'>('comment')
const tabsRef = ref<HTMLElement | null>(null)
const favorited = ref(false)
const selectedProps = reactive<Record<string, string>>({})

const services = ['正品保障', '七天无理由退货', '极速退款']
const aftersaleTips = [
  '支持七天无理由退货（商品完好、不影响二次销售）',
  '质量问题可申请换货或退款，客服将在 24 小时内响应',
  '请保留完整包装与配件，以便售后核验',
  '虚拟商品、定制商品等特殊品类以商品页说明为准'
]

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
  const map = new Map<string, Map<string, string | undefined>>()
  for (const sku of spu.value?.skus || []) {
    for (const p of sku.properties || []) {
      const name = p.propertyName || ''
      const value = p.valueName || ''
      if (!name || !value) continue
      if (!map.has(name)) map.set(name, new Map())
      const values = map.get(name)!
      if (!values.has(value) || (!values.get(value) && sku.picUrl)) {
        values.set(value, sku.picUrl)
      }
    }
  }
  return [...map.entries()].map(([name, values]) => ({
    name,
    values: [...values.entries()].map(([value, picUrl]) => ({ value, picUrl }))
  }))
})

const selectedSku = computed<ProductSku | undefined>(() => {
  const skus = spu.value?.skus || []
  if (!skus.length) return undefined
  if (!propertyOptions.value.length) return skus[0]
  return skus.find((sku) =>
    (sku.properties || []).every((p) => selectedProps[p.propertyName || ''] === p.valueName)
  )
})

const showMarket = computed(() => {
  const market = selectedSku.value?.marketPrice ?? spu.value?.marketPrice
  const price = selectedSku.value?.price ?? spu.value?.price
  return !!market && !!price && market > price
})

const discountLabel = computed(() => (showMarket.value ? '优惠价' : ''))

const commentTotalText = computed(() => {
  const n = commentTotal.value
  if (n <= 0) return '0'
  if (n >= 10000) return `${(n / 10000).toFixed(n >= 100000 ? 0 : 1)}万+`
  return String(n)
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

function selectTab(tab: 'detail' | 'comment' | 'aftersale') {
  activeTab.value = tab
  nextTick(() => {
    tabsRef.value?.scrollIntoView({ behavior: 'smooth', block: 'start' })
  })
}

async function loadCategories() {
  try {
    const res = await CategoryApi.getCategoryList()
    categories.value = res.data || []
  } catch {
    categories.value = []
  }
}

async function loadRecommends(detail: ProductSpu) {
  try {
    const collected: ProductSpu[] = []
    if (detail.categoryId) {
      const res = await SpuApi.getSpuPage({
        pageNo: 1,
        pageSize: 12,
        categoryId: detail.categoryId,
        sortField: 'salesCount',
        sortAsc: false
      })
      collected.push(...(res.data?.list || []))
    }
    if (collected.length < 8) {
      const res = await SpuApi.getSpuPage({
        pageNo: 1,
        pageSize: 12,
        sortField: 'salesCount',
        sortAsc: false
      })
      collected.push(...(res.data?.list || []))
    }
    const seen = new Set<number>([detail.id])
    recommends.value = collected
      .filter((item) => {
        if (seen.has(item.id)) return false
        seen.add(item.id)
        return true
      })
      .slice(0, 8)
  } catch {
    recommends.value = []
  }
}

async function loadDetail() {
  const id = Number(route.params.id)
  if (!id) {
    spu.value = null
    return
  }
  loading.value = true
  activeTab.value = 'comment'
  recommends.value = []
  try {
    const detailRes = await SpuApi.getSpuDetail(id)
    spu.value = detailRes.data || null
    if (!spu.value) return
    activePic.value = pics.value[0] || ''
    Object.keys(selectedProps).forEach((k) => delete selectedProps[k])
    const first = spu.value.skus?.[0]
    for (const p of first?.properties || []) {
      if (p.propertyName && p.valueName) {
        selectedProps[p.propertyName] = p.valueName
      }
    }
    loadRecommends(spu.value)
    try {
      const commentRes = await CommentApi.getCommentPage(id, 1, 8, 0)
      comments.value = commentRes.data?.list || []
      commentTotal.value = commentRes.data?.total ?? comments.value.length
    } catch {
      comments.value = []
      commentTotal.value = 0
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
  } catch {
    spu.value = null
    comments.value = []
    commentTotal.value = 0
    favorited.value = false
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
    ElMessage.info('请先登录后再操作')
    router.push({ path: '/login', query: { redirect: route.fullPath } })
    return false
  }
  return true
}

async function addToCart() {
  if (!ensureLogin()) return
  if (!selectedSku.value) {
    ElMessage.warning('请选择完整规格')
    return
  }
  try {
    await cartStore.add(selectedSku.value.id, count.value)
    ElMessage.success('已加入购物车')
  } catch {
    // request 拦截器已提示错误
  }
}

async function buyNow() {
  if (!ensureLogin()) return
  if (!selectedSku.value) {
    ElMessage.warning('请选择完整规格')
    return
  }
  router.push({
    path: '/checkout',
    query: {
      skuId: String(selectedSku.value.id),
      count: String(count.value)
    }
  })
}

const appTitle = import.meta.env.VITE_APP_TITLE || 'OM Shop'
watch(
  () => spu.value?.name,
  (name) => {
    document.title = name ? `${name} - ${appTitle}` : `商品详情 - ${appTitle}`
  },
  { immediate: true }
)

onMounted(async () => {
  await Promise.all([loadCategories(), loadDetail()])
})
watch(() => route.params.id, loadDetail)
</script>

<style scoped lang="scss">
.goods-detail {
  /* 详情页比首页更窄，两侧多留白，接近京东/淘宝主内容宽 */
  width: min(100% - 64px, 1180px);
  margin-left: auto;
  margin-right: auto;
  padding-bottom: 40px;
  --gallery-h: min(600px, calc(100vh - 220px));
  /* 右侧购买卡相对视口自适应高度（顶栏/导航预留） */
  --buy-h: calc(100vh - 200px);
}

.recommend {
  margin-top: 16px;
  background: var(--mall-surface);
  border-radius: 12px;
  padding: 18px 20px 20px;
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
}

.recommend-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 14px;
}

.recommend-head h2 {
  margin: 0;
  font-size: 16px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.recommend-head h2::before {
  content: '';
  width: 3px;
  height: 14px;
  border-radius: 2px;
  background: var(--mall-accent);
}

.recommend-head a {
  font-size: 13px;
  color: var(--mall-muted);
}

.recommend-head a:hover {
  color: var(--mall-accent);
}

.recommend-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 14px;
}

@media (max-width: 1100px) {
  .recommend-grid {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }
}

@media (max-width: 800px) {
  .recommend-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

.breadcrumb {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 6px;
  margin: 10px 0 12px;
  font-size: 12px;
  color: var(--mall-muted);
}

.breadcrumb a:hover {
  color: var(--mall-accent);
}

.breadcrumb .sep {
  color: #c4c7cc;
}

.breadcrumb .current {
  color: var(--mall-ink);
  max-width: 360px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.detail-layout {
  display: grid;
  /* 左图略宽，右购买区收窄到约 420–460 */
  grid-template-columns: minmax(0, 1fr) minmax(400px, 460px);
  gap: 16px;
  align-items: start;
}

.left-col {
  display: flex;
  flex-direction: column;
  gap: 12px;
  min-width: 0;
}

.right-col {
  min-width: 0;
  display: flex;
  align-self: start;
}

.gallery-card,
.info-card,
.detail-tabs {
  background: #fff;
  border: 1px solid var(--mall-line);
  border-radius: 12px;
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.03);
}

.gallery-card {
  padding: 12px;
  overflow: hidden;
}

.info-card {
  position: sticky;
  top: 52px;
  flex: 1;
  width: 100%;
  padding: 14px 16px 18px;
  /* 不跟图集绑死，按屏幕可视高度自适应撑开 */
  min-height: var(--buy-h);
  max-height: var(--buy-h);
  overflow-y: auto;
}

.gallery {
  display: flex;
  gap: 10px;
  min-width: 0;
  /* 略增高：约占一屏更大比例，仍留出下方 Tab */
  height: var(--gallery-h, 460px);
  align-items: stretch;
}

.thumbs {
  display: flex;
  flex-direction: column;
  gap: 8px;
  height: 100%;
  overflow-y: auto;
  flex-shrink: 0;
  padding: 1px;
}

.thumb {
  width: 56px;
  height: 56px;
  border: 1px solid var(--mall-line);
  border-radius: 2px;
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
  height: 100%;
  border: 1px solid var(--mall-line);
  border-radius: 8px;
  background: #fafafa;
  overflow: hidden;
}

.main-pic {
  width: 100%;
  height: 100%;
  object-fit: contain;
}

.title-row {
  display: flex;
  align-items: flex-start;
  gap: 12px;
}

.title-main {
  flex: 1;
  min-width: 0;
}

.tag-own {
  display: inline-block;
  vertical-align: middle;
  margin-right: 6px;
  padding: 1px 5px;
  border-radius: 2px;
  background: var(--mall-accent);
  color: #fff;
  font-size: 12px;
  line-height: 18px;
  font-weight: 600;
}

.info-card h1 {
  display: inline;
  margin: 0;
  font-size: 16px;
  line-height: 1.5;
  font-weight: 700;
  vertical-align: middle;
}

.btn-fav {
  flex-shrink: 0;
  display: inline-flex;
  flex-direction: column;
  align-items: center;
  gap: 2px;
  border: 0;
  background: transparent;
  color: var(--mall-muted);
  font-size: 12px;
  cursor: pointer;
  padding: 2px 4px;
}

.btn-fav:hover,
.btn-fav.on {
  color: var(--mall-accent);
}

.intro {
  margin: 8px 0 0;
  color: #e11d48;
  font-size: 13px;
  line-height: 1.45;
}

.price-strip {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: 16px;
  margin-top: 12px;
  padding: 12px 14px;
  background: linear-gradient(90deg, #fff5f5, #fafafa);
  border-top: 1px solid #fee2e2;
  border-bottom: 1px solid #fee2e2;
}

.price-left {
  display: flex;
  flex-wrap: wrap;
  align-items: baseline;
  gap: 8px;
}

.price {
  font-size: 28px;
  font-weight: 700;
  line-height: 1;
  color: var(--mall-accent);
}

.price-tag {
  padding: 1px 6px;
  border: 1px solid var(--mall-accent);
  color: var(--mall-accent);
  font-size: 12px;
  border-radius: 2px;
}

.market {
  color: var(--mall-muted);
  text-decoration: line-through;
  font-size: 13px;
}

.comment-link {
  border: 0;
  background: transparent;
  color: var(--mall-muted);
  font-size: 12px;
  cursor: pointer;
  text-align: right;
  line-height: 1.4;
  padding: 0;
}

.comment-link em {
  display: block;
  font-style: normal;
  color: var(--mall-ink);
  font-size: 14px;
  font-weight: 600;
}

.comment-link:hover {
  color: var(--mall-accent);
}

.comment-link:hover em {
  color: var(--mall-accent);
}

.info-rows {
  margin-top: 6px;
}

.info-row {
  display: flex;
  gap: 10px;
  padding: 10px 0;
  border-bottom: 1px solid #f3f4f6;
}

.row-label {
  flex-shrink: 0;
  width: 48px;
  color: var(--mall-muted);
  font-size: 12px;
  line-height: 28px;
}

.row-body {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 8px 14px;
  font-size: 13px;
  line-height: 28px;
}

.row-body .muted {
  color: var(--mall-muted);
  font-size: 12px;
}

.service-body span {
  position: relative;
  padding-left: 12px;
}

.service-body span::before {
  content: '';
  position: absolute;
  left: 0;
  top: 11px;
  width: 5px;
  height: 5px;
  border-radius: 50%;
  background: var(--mall-accent);
}

.sku-values {
  gap: 8px;
  line-height: 1;
}

.sku-value {
  position: relative;
  display: inline-flex;
  align-items: center;
  gap: 6px;
  min-height: 32px;
  border: 1px solid var(--mall-accent-border);
  background: #fff;
  border-radius: 4px;
  padding: 5px 12px;
  cursor: pointer;
  font-size: 13px;
  color: var(--mall-ink);
  transition: border-color 0.15s, color 0.15s, background 0.15s;
}

.sku-value.has-pic {
  padding: 4px 10px 4px 4px;
}

.sku-value:hover {
  border-color: var(--mall-accent);
  color: var(--mall-accent);
  background: var(--mall-accent-soft);
}

.sku-value.active {
  border-color: var(--mall-accent);
  color: var(--mall-accent);
  background: var(--mall-accent-soft);
}

.sku-value.active::after {
  content: '';
  position: absolute;
  right: 0;
  bottom: 0;
  width: 0;
  height: 0;
  border-style: solid;
  border-width: 0 0 12px 12px;
  border-color: transparent transparent var(--mall-accent) transparent;
}

.sku-pic {
  width: 24px;
  height: 24px;
  object-fit: cover;
  border-radius: 1px;
}

.action-bar {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 12px;
  margin-top: 18px;
  padding-top: 4px;
}

.qty {
  width: 120px;
}

.btn-cart,
.btn-buy {
  flex: 1;
  min-width: 0;
  height: 44px;
  border-radius: 2px;
  border: 1px solid var(--mall-accent);
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
}

.btn-cart {
  background: #ffeeee;
  color: var(--mall-accent);
}

.btn-cart:hover:not(:disabled) {
  background: #ffe2e2;
}

.btn-buy {
  background: var(--mall-accent);
  color: #fff;
}

.btn-buy:hover:not(:disabled) {
  background: var(--mall-accent-dark);
}

.btn-cart:disabled,
.btn-buy:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.detail-tabs {
  scroll-margin-top: 48px;
}

.tab-bar {
  position: sticky;
  top: 40px;
  z-index: 4;
  display: flex;
  align-items: stretch;
  gap: 0;
  border-bottom: 1px solid var(--mall-line);
  background: #f7f8fa;
  padding: 0 8px;
  border-radius: 12px 12px 0 0;
}

.tab {
  position: relative;
  border: 0;
  background: transparent;
  padding: 14px 20px;
  font-size: 14px;
  color: var(--mall-ink);
  cursor: pointer;
}

.tab.active {
  color: var(--mall-accent);
  font-weight: 700;
  background: #fff;
}

.tab.active::after {
  content: '';
  position: absolute;
  left: 0;
  right: 0;
  bottom: -1px;
  height: 2px;
  background: var(--mall-accent);
}

.tab-panel {
  padding: 20px 24px;
  min-height: 180px;
}

.comment-summary {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 16px;
}

.comment-summary h3 {
  margin: 0;
  font-size: 16px;
}

.comment-summary .total {
  color: var(--mall-muted);
  font-weight: 400;
  font-size: 14px;
}

.comment-summary a {
  font-size: 13px;
  color: var(--mall-muted);
}

.comment-summary a:hover {
  color: var(--mall-accent);
}

.comment {
  display: flex;
  gap: 12px;
  padding: 16px 0;
  border-bottom: 1px solid #f3f4f6;
}

.comment:last-child {
  border-bottom: 0;
}

.avatar {
  flex-shrink: 0;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: #fee2e2;
  color: var(--mall-accent);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: 600;
}

.comment-body {
  flex: 1;
  min-width: 0;
}

.comment-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 6px;
}

.comment-head .name {
  color: var(--mall-muted);
  font-size: 13px;
}

.comment-body p {
  margin: 0;
  font-size: 14px;
  line-height: 1.6;
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
  margin: 0;
  border: 1px solid var(--mall-line);
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

.aftersale-panel ul {
  margin: 0;
  padding-left: 18px;
  color: var(--mall-ink);
  font-size: 14px;
  line-height: 2;
}

@media (max-width: 1100px) {
  .goods-detail {
    width: min(100% - 32px, 1180px);
  }

  .detail-layout {
    grid-template-columns: 1fr;
  }

  .info-card {
    position: static;
    min-height: 0;
    max-height: none;
  }

  .gallery {
    flex-direction: column-reverse;
    height: auto;
  }

  .thumbs {
    flex-direction: row;
    height: auto;
    max-height: none;
    overflow-x: auto;
    width: 100%;
  }

  .main-wrap {
    height: auto;
    aspect-ratio: 1;
  }

  .main-pic {
    aspect-ratio: 1;
    height: auto;
    object-fit: cover;
  }

  .tab-bar {
    top: 0;
  }

  .action-bar {
    width: 100%;
  }

  .btn-cart,
  .btn-buy {
    flex: 1;
    min-width: 0;
  }

  .breadcrumb .current {
    max-width: 180px;
  }
}
</style>
