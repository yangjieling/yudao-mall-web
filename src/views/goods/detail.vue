<template>
  <div class="page-container goods-detail" v-loading="loading">
    <template v-if="spu">
      <div class="buy-panel">
        <div class="gallery">
          <img :src="activePic" :alt="spu.name" class="main-pic" />
          <div v-if="pics.length > 1" class="thumbs">
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
        </div>

        <div class="info">
          <h1>{{ spu.name }}</h1>
          <p v-if="spu.introduction" class="intro">{{ spu.introduction }}</p>
          <div class="price-box">
            <div class="price-row">
              <span class="price-label">价格</span>
              <span class="price">{{ formatPrice(selectedSku?.price ?? spu.price) }}</span>
              <span v-if="selectedSku?.marketPrice" class="market">
                {{ formatPrice(selectedSku.marketPrice) }}
              </span>
            </div>
            <div class="stock">库存 {{ selectedSku?.stock ?? spu.stock ?? 0 }}</div>
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
            <el-button size="large" text class="btn-fav" @click="toggleFavorite">
              {{ favorited ? '已收藏' : '收藏' }}
            </el-button>
          </div>
        </div>
      </div>
    </template>

    <section v-if="spu" class="detail-section">
      <h2><span class="sec-mark" />商品详情</h2>
      <div class="rich" v-html="spu.description || '暂无详情'" />
    </section>

    <section class="detail-section">
      <div class="section-head">
        <h2><span class="sec-mark" />用户评价</h2>
        <router-link v-if="spu" :to="`/goods/${spu.id}/comments`">查看更多</router-link>
      </div>
      <el-empty v-if="!comments.length" description="暂无评价" :image-size="64" />
      <div v-for="c in comments" :key="c.id" class="comment">
        <div class="comment-head">
          <span>{{ c.userNickname || '用户' }}</span>
          <el-rate :model-value="c.scores" disabled />
        </div>
        <p>{{ c.content }}</p>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { CommentApi, SpuApi, type ProductComment, type ProductSku, type ProductSpu } from '@/api/product'
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
const comments = ref<ProductComment[]>([])
const count = ref(1)
const activePic = ref('')
const favorited = ref(false)
const selectedProps = reactive<Record<string, string>>({})

const pics = computed(() => {
  if (!spu.value) return []
  const list = [spu.value.picUrl, ...(spu.value.sliderPicUrls || [])].filter(Boolean) as string[]
  return [...new Set(list)]
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

watch(selectedSku, (sku) => {
  if (sku?.picUrl) activePic.value = sku.picUrl
})

async function loadDetail() {
  const id = Number(route.params.id)
  if (!id) return
  loading.value = true
  try {
    const detailRes = await SpuApi.getSpuDetail(id)
    spu.value = detailRes.data
    activePic.value = pics.value[0] || ''
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

onMounted(loadDetail)
watch(() => route.params.id, loadDetail)
</script>

<style scoped lang="scss">
.buy-panel {
  display: grid;
  grid-template-columns: 420px 1fr;
  gap: 28px;
  background: var(--mall-surface);
  border-radius: var(--mall-radius);
  padding: 20px;
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
}

.gallery {
  min-width: 0;
}

.main-pic {
  width: 100%;
  aspect-ratio: 1;
  object-fit: cover;
  border-radius: 10px;
  background: #f3f4f6;
}

.thumbs {
  display: flex;
  gap: 8px;
  margin-top: 12px;
  flex-wrap: wrap;
}

.thumb {
  width: 64px;
  height: 64px;
  border: 2px solid transparent;
  border-radius: 8px;
  padding: 0;
  overflow: hidden;
  cursor: pointer;
  background: #fff;
}

.thumb.active {
  border-color: var(--mall-accent);
}

.thumb img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.info h1 {
  margin: 0 0 10px;
  font-size: 22px;
  line-height: 1.35;
  font-weight: 700;
}

.intro {
  color: var(--mall-muted);
  margin: 0 0 16px;
  font-size: 14px;
}

.price-box {
  background: linear-gradient(135deg, #fff5f5, #fef2f2);
  border-radius: 10px;
  padding: 14px 16px;
  margin-bottom: 20px;
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
  font-size: 30px;
}

.market {
  color: var(--mall-muted);
  text-decoration: line-through;
  font-size: 14px;
}

.stock {
  color: var(--mall-muted);
  font-size: 13px;
  margin-top: 6px;
}

.sku-block,
.count-row {
  margin-bottom: 18px;
}

.sku-row {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  margin-bottom: 14px;
}

.label {
  flex-shrink: 0;
  width: 48px;
  color: var(--mall-muted);
  font-size: 14px;
  line-height: 32px;
}

.values {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.sku-value {
  border: 1px solid var(--mall-line);
  background: #fff;
  border-radius: 6px;
  padding: 6px 14px;
  cursor: pointer;
  font-size: 13px;
}

.sku-value.active {
  border-color: var(--mall-accent);
  color: var(--mall-accent);
  background: var(--mall-accent-soft);
}

.count-row {
  display: flex;
  align-items: center;
  gap: 12px;
}

.actions {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  margin-top: 24px;
}

.btn-cart {
  min-width: 140px;
}

.btn-buy {
  min-width: 140px;
  border-color: var(--mall-accent);
  color: var(--mall-accent);
}

.btn-buy:hover {
  background: var(--mall-accent-soft);
  border-color: var(--mall-accent);
  color: var(--mall-accent-dark);
}

.btn-fav {
  color: var(--mall-muted);
}

.detail-section {
  margin-top: 16px;
  background: var(--mall-surface);
  border-radius: var(--mall-radius);
  padding: 22px 24px;
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
}

.section-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.detail-section h2 {
  margin: 0 0 16px;
  font-size: 18px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.section-head h2 {
  margin: 0;
}

.sec-mark {
  width: 4px;
  height: 16px;
  border-radius: 2px;
  background: var(--mall-accent);
  display: inline-block;
}

.section-head a {
  color: var(--mall-muted);
  font-size: 14px;
}

.section-head a:hover {
  color: var(--mall-accent);
}

.rich :deep(img) {
  max-width: 100%;
}

.comment {
  padding: 12px 0;
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

@media (max-width: 960px) {
  .buy-panel {
    grid-template-columns: 1fr;
  }
}
</style>
