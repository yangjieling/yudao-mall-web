<template>
  <div class="page-container home">
    <!-- 淘宝/京东式首屏：左分类 + 中 Banner + 右快捷 -->
    <section class="portal">
      <aside class="cate-side">
        <router-link
          v-for="cat in rootCategories"
          :key="cat.id"
          class="cate-item"
          :to="{ path: '/category', query: { categoryId: cat.id } }"
        >
          <span class="cate-name">{{ cat.name }}</span>
          <span class="cate-sub">
            {{ childrenOf(cat.id)
              .slice(0, 3)
              .map((c) => c.name)
              .join(' / ') }}
          </span>
        </router-link>
        <router-link to="/category" class="cate-more">全部商品 →</router-link>
      </aside>

      <div class="portal-main">
        <el-carousel
          v-if="banners.length"
          height="320px"
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
            <h1>{{ title }}</h1>
            <p>搜索好物，或从左侧分类开始逛</p>
            <el-button type="primary" @click="$router.push('/category')">浏览全部商品</el-button>
          </div>
        </div>
      </div>

      <aside class="side-panel">
        <div class="user-box">
          <template v-if="userStore.isLogin">
            <div class="hello">Hi，{{ userStore.userInfo?.nickname || '会员' }}</div>
            <div class="user-links">
              <router-link to="/order">我的订单</router-link>
              <router-link to="/user/coupon">优惠券</router-link>
              <router-link to="/user/favorite">收藏</router-link>
              <router-link to="/user/history">足迹</router-link>
            </div>
          </template>
          <template v-else>
            <div class="hello">欢迎来到{{ title }}</div>
            <el-button type="primary" class="login-btn" @click="$router.push('/login')">
              登录 / 注册
            </el-button>
          </template>
        </div>
        <div class="promo-grid">
          <router-link to="/coupon" class="promo">领券中心</router-link>
          <router-link to="/activity/seckill" class="promo">限时秒杀</router-link>
          <router-link to="/activity/combination" class="promo">超值拼团</router-link>
          <router-link to="/activity/point" class="promo">积分商城</router-link>
        </div>
      </aside>
    </section>

    <section class="feed">
      <div class="feed-head">
        <h2>为你推荐</h2>
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
import { computed, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { CategoryApi, SpuApi, type ProductCategory, type ProductSpu } from '@/api/product'
import { BannerApi, type Banner } from '@/api/promotion/banner'
import ProductCard from '@/components/ProductCard.vue'
import { useUserStore } from '@/stores/user'

const title = import.meta.env.VITE_APP_TITLE
const router = useRouter()
const userStore = useUserStore()

const loading = ref(false)
const list = ref<ProductSpu[]>([])
const banners = ref<Banner[]>([])
const categories = ref<ProductCategory[]>([])

const rootCategories = computed(() =>
  categories.value.filter((c) => !c.parentId || c.parentId === 0).slice(0, 12)
)

function childrenOf(parentId: number) {
  return categories.value.filter((c) => c.parentId === parentId)
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
  grid-template-columns: 220px 1fr 220px;
  gap: 12px;
  margin-bottom: 28px;
  min-height: 320px;
}

.cate-side {
  background: var(--mall-surface);
  border: 1px solid var(--mall-line);
  border-radius: var(--mall-radius);
  padding: 8px 0;
  overflow: auto;
  max-height: 320px;
}

.cate-item {
  display: block;
  padding: 8px 14px;
  line-height: 1.35;
}

.cate-item:hover {
  background: var(--mall-accent-soft);
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
  padding: 10px 14px;
  font-size: 13px;
  color: var(--mall-accent);
  border-top: 1px dashed var(--mall-line);
}

.portal-main {
  min-width: 0;
  border-radius: var(--mall-radius);
  overflow: hidden;
  background: var(--mall-surface);
  border: 1px solid var(--mall-line);
}

.banner-link,
.banner-link img {
  display: block;
  width: 100%;
  height: 320px;
  object-fit: cover;
}

.banner-fallback {
  height: 320px;
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
  gap: 12px;
}

.user-box {
  background: var(--mall-surface);
  border: 1px solid var(--mall-line);
  border-radius: var(--mall-radius);
  padding: 16px;
  flex: 1;
}

.hello {
  font-weight: 600;
  margin-bottom: 12px;
}

.user-links {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
  font-size: 13px;
  color: var(--mall-muted);
}

.user-links a:hover {
  color: var(--mall-accent);
}

.login-btn {
  width: 100%;
}

.promo-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px;
}

.promo {
  background: var(--mall-accent-soft);
  border: 1px solid var(--mall-accent-border);
  border-radius: 8px;
  padding: 14px 8px;
  text-align: center;
  font-size: 13px;
  font-weight: 600;
  color: var(--mall-accent);
}

.promo:hover {
  background: #fee2e2;
}

.feed-head {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  margin-bottom: 14px;
}

.feed-head h2 {
  margin: 0;
  font-size: 20px;
}

.feed-head a {
  color: var(--mall-muted);
  font-size: 13px;
}

.product-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 12px;
}

@media (max-width: 1100px) {
  .portal {
    grid-template-columns: 180px 1fr;
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
  }

  .cate-side {
    max-height: 180px;
  }

  .product-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>
