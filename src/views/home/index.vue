<template>
  <div class="page-container home">
    <section class="portal">
      <aside class="cate-side">
        <div class="cate-title">分类</div>
        <router-link
          v-for="cat in rootCategories"
          :key="cat.id"
          class="cate-item"
          :to="{ path: '/category', query: { categoryId: cat.id } }"
        >
          <el-icon class="cate-icon" :size="16">
            <component :is="iconForCategory(cat.name)" />
          </el-icon>
          <span class="cate-copy">
            <span class="cate-name">{{ cat.name }}</span>
            <span class="cate-sub">
              {{ childrenOf(cat.id)
                .slice(0, 3)
                .map((c) => c.name)
                .join(' / ') }}
            </span>
          </span>
        </router-link>
        <router-link to="/category" class="cate-more">全部商品 →</router-link>
      </aside>

      <div class="portal-main">
        <el-carousel
          v-if="banners.length"
          height="340px"
          class="banner"
          :interval="4500"
          arrow="hover"
        >
          <el-carousel-item v-for="b in banners" :key="b.id">
            <a class="banner-link" href="javascript:void(0)" @click.prevent="onBanner(b)">
              <img :src="b.picUrl" :alt="b.title || 'banner'" />
            </a>
          </el-carousel-item>
        </el-carousel>
        <div v-else class="banner-fallback">
          <div class="fallback-copy">
            <h1>SHOP</h1>
            <p>搜索好物，或从左侧分类开始逛</p>
            <el-button type="primary" @click="$router.push('/category')">浏览全部商品</el-button>
          </div>
        </div>
      </div>

      <aside class="side-panel">
        <router-link
          v-for="card in promoCards"
          :key="card.to"
          :to="card.to"
          class="promo-card"
          :style="{ background: card.bg }"
        >
          <div class="promo-text">
            <div class="promo-title">{{ card.title }}</div>
            <div class="promo-desc">{{ card.desc }}</div>
          </div>
        </router-link>
      </aside>
    </section>

    <section class="feed">
      <div class="feed-head">
        <h2><span class="feed-mark" />为你推荐</h2>
        <router-link to="/category">更多商品</router-link>
      </div>
      <el-skeleton v-if="loading" :rows="5" animated />
      <div v-else class="product-grid">
        <ProductCard v-for="item in list" :key="item.id" :spu="item" />
      </div>
      <el-empty v-if="!loading && !list.length" description="暂无商品" />
    </section>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref, type Component } from 'vue'
import { useRouter } from 'vue-router'
import {
  Bowl,
  Box,
  Cellphone,
  CoffeeCup,
  FirstAidKit,
  Goods,
  Grape,
  Headset,
  House,
  Iphone,
  MagicStick,
  Menu,
  Monitor,
  Orange,
  Present,
  ShoppingBag,
  Soccer,
  Van
} from '@element-plus/icons-vue'
import { CategoryApi, SpuApi, type ProductCategory, type ProductSpu } from '@/api/product'
import { BannerApi, type Banner } from '@/api/promotion/banner'
import ProductCard from '@/components/ProductCard.vue'

const router = useRouter()

const loading = ref(false)
const list = ref<ProductSpu[]>([])
const banners = ref<Banner[]>([])
const categories = ref<ProductCategory[]>([])

const promoCards = [
  { to: '/coupon', title: '领券中心', desc: '优惠好券天天领', bg: 'linear-gradient(135deg, #ecfdf5, #d1fae5)' },
  { to: '/activity/seckill', title: '限时秒杀', desc: '爆款低价抢先购', bg: 'linear-gradient(135deg, #f5f3ff, #ede9fe)' },
  { to: '/activity/combination', title: '超值拼团', desc: '多人成团更划算', bg: 'linear-gradient(135deg, #eff6ff, #dbeafe)' },
  { to: '/activity/point', title: '积分兑换', desc: '积分抵现更省心', bg: 'linear-gradient(135deg, #fffbeb, #fef3c7)' }
]

const rootCategories = computed(() =>
  categories.value.filter((c) => !c.parentId || c.parentId === 0).slice(0, 12)
)

function childrenOf(parentId: number) {
  return categories.value.filter((c) => c.parentId === parentId)
}

function iconForCategory(name: string): Component {
  const n = name || ''
  if (/电脑|办公|配件|数码/.test(n)) return Monitor
  if (/手机|通信|运营商/.test(n)) return Iphone
  if (/家电|电器/.test(n)) return House
  if (/家具|家装|家居|厨/.test(n)) return CoffeeCup
  if (/女装|男装|内衣|配饰|童装|服/.test(n)) return ShoppingBag
  if (/鞋|运动|户外/.test(n)) return Soccer
  if (/美妆|个护|洗护/.test(n)) return MagicStick
  if (/食品|零食|生鲜|酒|茶/.test(n)) return Grape
  if (/母婴|玩具|宠物/.test(n)) return Present
  if (/汽车|箱包|珠宝/.test(n)) return Van
  if (/健康|医药|保健/.test(n)) return FirstAidKit
  if (/耳机|音响/.test(n)) return Headset
  if (/水果|生鲜/.test(n)) return Orange
  if (/餐|碗/.test(n)) return Bowl
  if (/手机/.test(n)) return Cellphone
  if (/日用|百货/.test(n)) return Box
  if (/商品|好物/.test(n)) return Goods
  return Menu
}

function onBanner(b: Banner) {
  BannerApi.addBrowseCount(b.id).catch(() => undefined)
  if (!b.url) return
  if (b.url.startsWith('http')) {
    window.open(b.url, '_blank')
  } else {
    router.push(b.url)
  }
}

onMounted(async () => {
  loading.value = true
  try {
    const [spuRes, bannerRes, catRes] = await Promise.all([
      SpuApi.getSpuPage({ pageNo: 1, pageSize: 20 }),
      BannerApi.getBannerList(1).catch(() => ({ data: [] as Banner[] })),
      CategoryApi.getCategoryList().catch(() => ({ data: [] as ProductCategory[] }))
    ])
    list.value = spuRes.data?.list || []
    banners.value = bannerRes.data || []
    categories.value = catRes.data || []
  } finally {
    loading.value = false
  }
})
</script>

<style scoped lang="scss">
.portal {
  display: grid;
  grid-template-columns: 220px 1fr 200px;
  gap: 12px;
  margin-bottom: 28px;
  min-height: 340px;
  background: var(--mall-surface);
  border-radius: var(--mall-radius);
  padding: 12px;
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
}

.cate-side {
  background: #fff;
  border-radius: 8px;
  overflow: auto;
  max-height: 340px;
  border-right: 1px solid var(--mall-line);
  padding-right: 4px;
}

.cate-title {
  padding: 6px 10px 10px;
  font-size: 14px;
  font-weight: 700;
  color: var(--mall-ink);
}

.cate-item {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  padding: 8px 10px;
  line-height: 1.35;
  border-radius: 6px;
}

.cate-item:hover {
  background: var(--mall-accent-soft);
}

.cate-icon {
  margin-top: 2px;
  color: #9ca3af;
  flex-shrink: 0;
}

.cate-item:hover .cate-icon {
  color: var(--mall-accent);
}

.cate-copy {
  min-width: 0;
  flex: 1;
}

.cate-name {
  display: block;
  font-size: 13px;
  font-weight: 600;
  color: var(--mall-ink);
}

.cate-sub {
  display: block;
  margin-top: 2px;
  font-size: 12px;
  color: var(--mall-muted);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.cate-more {
  display: block;
  margin-top: 4px;
  padding: 10px;
  font-size: 13px;
  color: var(--mall-accent);
  border-top: 1px solid var(--mall-line);
}

.portal-main {
  min-width: 0;
  border-radius: 8px;
  overflow: hidden;
  background: #f8fafc;
}

.banner-link,
.banner-link img {
  display: block;
  width: 100%;
  height: 340px;
  object-fit: cover;
}

.banner-fallback {
  height: 340px;
  display: grid;
  place-items: center;
  background: linear-gradient(145deg, #fff 0%, #fef2f2 55%, #fecaca 100%);
}

.fallback-copy {
  text-align: center;
  padding: 24px;
}

.fallback-copy h1 {
  margin: 0 0 8px;
  font-size: 28px;
}

.fallback-copy p {
  margin: 0 0 16px;
  color: var(--mall-muted);
}

.side-panel {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.promo-card {
  flex: 1;
  min-height: 72px;
  border-radius: 8px;
  padding: 14px 12px;
  display: flex;
  align-items: center;
  transition: transform 0.15s ease;
}

.promo-card:hover {
  transform: translateY(-1px);
}

.promo-title {
  font-size: 14px;
  font-weight: 700;
  color: var(--mall-ink);
}

.promo-desc {
  margin-top: 4px;
  font-size: 12px;
  color: var(--mall-muted);
}

.feed-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 14px;
}

.feed-head h2 {
  margin: 0;
  font-size: 20px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.feed-mark {
  width: 4px;
  height: 18px;
  border-radius: 2px;
  background: var(--mall-accent);
  display: inline-block;
}

.feed-head a {
  color: var(--mall-muted);
  font-size: 13px;
}

.feed-head a:hover {
  color: var(--mall-accent);
}

.product-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 12px;
}

@media (max-width: 1100px) {
  .portal {
    grid-template-columns: 200px 1fr;
  }

  .side-panel {
    display: none;
  }

  .product-grid {
    grid-template-columns: repeat(3, 1fr);
  }
}

@media (max-width: 760px) {
  .portal {
    grid-template-columns: 1fr;
    padding: 8px;
  }

  .cate-side {
    max-height: 200px;
    border-right: 0;
    border-bottom: 1px solid var(--mall-line);
    padding-right: 0;
    padding-bottom: 8px;
  }

  .product-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>
