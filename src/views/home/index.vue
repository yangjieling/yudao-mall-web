<template>
  <div class="page-container home">
    <section class="hero-area">
      <el-carousel v-if="banners.length" height="340px" class="banner">
        <el-carousel-item v-for="b in banners" :key="b.id">
          <a :href="b.url || 'javascript:void(0)'" @click.prevent="onBanner(b)">
            <img :src="b.picUrl" :alt="b.title || 'banner'" class="banner-img" />
          </a>
        </el-carousel-item>
      </el-carousel>
      <section v-else class="hero">
        <div class="hero-copy">
          <p class="eyebrow">YUDAO MALL</p>
          <h1>{{ title }}</h1>
          <p class="desc">精选好物，一站购齐。浏览商品、加购下单，与移动端共用同一套商城服务。</p>
          <div class="hero-actions">
            <el-button type="primary" size="large" @click="$router.push('/category')">去逛逛</el-button>
            <el-button size="large" @click="$router.push('/cart')">购物车</el-button>
          </div>
        </div>
        <div class="hero-panel" aria-hidden="true" />
      </section>
    </section>

    <section class="activity-entry">
      <router-link to="/activity/seckill" class="entry">限时秒杀</router-link>
      <router-link to="/activity/combination" class="entry">超值拼团</router-link>
      <router-link to="/activity/point" class="entry">积分商城</router-link>
      <router-link to="/coupon" class="entry">领券中心</router-link>
    </section>

    <section class="section">
      <div class="section-head">
        <h2>精选商品</h2>
        <router-link to="/category">查看全部</router-link>
      </div>
      <el-skeleton v-if="loading" :rows="4" animated />
      <div v-else class="product-grid">
        <ProductCard v-for="item in list" :key="item.id" :spu="item" />
      </div>
      <el-empty v-if="!loading && list.length === 0" description="暂无商品" />
    </section>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { SpuApi, type ProductSpu } from '@/api/product'
import { BannerApi, type Banner } from '@/api/promotion/banner'
import ProductCard from '@/components/ProductCard.vue'

const title = import.meta.env.VITE_APP_TITLE
const router = useRouter()
const loading = ref(false)
const list = ref<ProductSpu[]>([])
const banners = ref<Banner[]>([])

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
    const [spuRes, bannerRes] = await Promise.all([
      SpuApi.getSpuPage({ pageNo: 1, pageSize: 12 }),
      BannerApi.getBannerList(1).catch(() => ({ data: [] as Banner[] }))
    ])
    list.value = spuRes.data?.list || []
    banners.value = bannerRes.data || []
  } finally {
    loading.value = false
  }
})
</script>

<style scoped lang="scss">
.banner {
  margin-bottom: 24px;
  border-radius: 16px;
  overflow: hidden;
}

.banner-img {
  width: 100%;
  height: 340px;
  object-fit: cover;
}

.hero {
  display: grid;
  grid-template-columns: 1.1fr 0.9fr;
  gap: 24px;
  min-height: 320px;
  margin-bottom: 24px;
}

.hero-copy {
  background: linear-gradient(145deg, #fff 0%, #faf6f1 100%);
  border: 1px solid var(--mall-line);
  border-radius: 16px;
  padding: 48px 40px;
}

.eyebrow {
  margin: 0 0 12px;
  letter-spacing: 0.16em;
  color: var(--mall-accent);
  font-size: 12px;
  font-weight: 600;
}

h1 {
  margin: 0 0 14px;
  font-size: 40px;
  line-height: 1.15;
}

.desc {
  margin: 0 0 28px;
  color: var(--mall-muted);
  max-width: 420px;
}

.hero-actions {
  display: flex;
  gap: 12px;
}

.hero-panel {
  border-radius: 16px;
  background:
    radial-gradient(circle at 30% 20%, rgba(255, 255, 255, 0.35), transparent 45%),
    linear-gradient(160deg, #d97845 0%, #8f3d18 100%);
}

.activity-entry {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
  margin-bottom: 28px;
}

.entry {
  background: var(--mall-surface);
  border: 1px solid var(--mall-line);
  border-radius: var(--mall-radius);
  padding: 18px;
  text-align: center;
  font-weight: 600;
}

.entry:hover {
  color: var(--mall-accent);
  border-color: #f0d4c3;
}

.section-head {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  margin-bottom: 18px;
}

.section-head h2 {
  margin: 0;
  font-size: 22px;
}

.section-head a {
  color: var(--mall-muted);
  font-size: 14px;
}

.product-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
}

@media (max-width: 1100px) {
  .hero {
    grid-template-columns: 1fr;
  }
  .hero-panel {
    min-height: 180px;
  }
  .product-grid {
    grid-template-columns: repeat(3, 1fr);
  }
  .activity-entry {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>
