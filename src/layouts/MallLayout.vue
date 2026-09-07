<template>
  <div class="mall-layout">
    <div class="top-bar">
      <div class="page-container top-inner">
        <div class="top-left">
          <template v-if="userStore.isLogin">
            <router-link to="/user">{{ userStore.userInfo?.nickname || '会员' }}</router-link>
            <el-button link type="primary" @click="onLogout">退出</el-button>
          </template>
          <router-link v-else to="/login">请登录</router-link>
        </div>
        <div class="top-right">
          <router-link to="/order">我的订单</router-link>
          <router-link to="/user/favorite">收藏夹</router-link>
          <router-link to="/cart" class="top-cart">
            <el-icon class="cart-icon" :size="15"><ShoppingCart /></el-icon>
            购物车
            <em v-if="cartStore.totalCount" class="cart-count">{{ cartStore.totalCount }}</em>
          </router-link>
        </div>
      </div>
    </div>

    <header class="mall-header">
      <div class="page-container header-inner">
        <router-link to="/" class="brand">
          <span class="brand-mark">{{ brandMark }}</span>
          <div class="brand-main">
            <span class="brand-name">SHOP</span>
            <span class="brand-sub">{{ brandUrl }}</span>
          </div>
          <span class="brand-divider" aria-hidden="true" />
          <div class="brand-tag">
            <span>热卖</span>
            <span>好物</span>
          </div>
        </router-link>

        <div class="search-wrap">
          <el-input
            v-model="keyword"
            class="search"
            size="large"
            placeholder="搜索商品名称"
            clearable
            @keyup.enter="onSearch"
          >
            <template #append>
              <el-button type="primary" @click="onSearch">搜索</el-button>
            </template>
          </el-input>
          <div class="hot-words">
            <a
              v-for="word in hotWords"
              :key="word"
              href="javascript:void(0)"
              @click.prevent="onHotWord(word)"
            >
              {{ word }}
            </a>
          </div>
        </div>
      </div>
    </header>

    <div class="nav-bar">
      <div class="page-container nav-inner">
        <div
          class="cate-trigger"
          @mouseenter="showCate = true"
          @mouseleave="showCate = false"
        >
          <span class="cate-label">全部分类</span>
          <div v-show="showCate" class="cate-panel">
            <div v-for="cat in rootCategories" :key="cat.id" class="cate-row">
              <router-link
                class="cate-root"
                :to="{ path: '/category', query: { categoryId: cat.id } }"
                @click="showCate = false"
              >
                {{ cat.name }}
              </router-link>
              <div class="cate-children">
                <router-link
                  v-for="child in childrenOf(cat.id)"
                  :key="child.id"
                  :to="{ path: '/category', query: { categoryId: child.id } }"
                  @click="showCate = false"
                >
                  {{ child.name }}
                </router-link>
              </div>
            </div>
            <el-empty v-if="!rootCategories.length" description="暂无分类" :image-size="64" />
          </div>
        </div>
        <nav class="nav-links">
          <router-link to="/">首页</router-link>
          <router-link to="/category">全部商品</router-link>
          <router-link to="/coupon">优惠券</router-link>
          <router-link to="/activity/seckill">限时秒杀</router-link>
          <router-link to="/activity/combination">超值拼团</router-link>
          <router-link to="/activity/point">积分兑换</router-link>
        </nav>
      </div>
    </div>

    <main class="mall-main">
      <router-view />
    </main>

    <footer class="mall-footer">
      <div class="page-container">OM SHOP · {{ brandUrl }}</div>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ShoppingCart } from '@element-plus/icons-vue'
import { CategoryApi, type ProductCategory } from '@/api/product'
import { useUserStore } from '@/stores/user'
import { useCartStore } from '@/stores/cart'

const title = import.meta.env.VITE_APP_TITLE
const brandUrl = 'om.shop.com'
const brandMark = computed(() => {
  const t = (title || 'OM').trim()
  if (/^OM\b/i.test(t)) return 'OM'
  return t.slice(0, 1) || 'O'
})
const hotWords = ['手机', '零食', '母婴', '家电', '美妆', '运动']
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const cartStore = useCartStore()
const keyword = ref((route.query.keyword as string) || '')
const showCate = ref(false)
const categories = ref<ProductCategory[]>([])

const rootCategories = computed(() =>
  categories.value.filter((c) => !c.parentId || c.parentId === 0)
)

function childrenOf(parentId: number) {
  return categories.value.filter((c) => c.parentId === parentId)
}

watch(
  () => route.query.keyword,
  (val) => {
    keyword.value = (val as string) || ''
  }
)

watch(
  () => userStore.isLogin,
  (login) => {
    if (login) cartStore.getList()
  },
  { immediate: true }
)

onMounted(async () => {
  if (userStore.isLogin) cartStore.getList()
  try {
    const res = await CategoryApi.getCategoryList()
    categories.value = res.data || []
  } catch {
    categories.value = []
  }
})

function onSearch() {
  router.push({ path: '/category', query: { keyword: keyword.value || undefined } })
}

function onHotWord(word: string) {
  keyword.value = word
  router.push({ path: '/category', query: { keyword: word } })
}

async function onLogout() {
  await userStore.logout()
  cartStore.validList = []
  router.push('/')
}
</script>

<style scoped lang="scss">
.mall-layout {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.top-bar {
  background: #f5f6f8;
  border-bottom: 1px solid var(--mall-line);
  font-size: 12px;
  color: var(--mall-muted);
}

.top-inner {
  height: 30px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.top-left,
.top-right {
  display: flex;
  align-items: center;
  gap: 16px;
}

.top-right a:hover,
.top-left a:hover {
  color: var(--mall-accent);
}

.mall-header {
  background: var(--mall-surface);
  padding: 16px 0 10px;
}

.header-inner {
  display: grid;
  grid-template-columns: 280px 1fr;
  gap: 24px;
  align-items: start;
}

.brand {
  display: flex;
  align-items: center;
  gap: 10px;
  padding-top: 2px;
  min-width: 0;
}

.brand-mark {
  width: 52px;
  height: 52px;
  border-radius: 12px;
  background: var(--mall-accent);
  color: #fff;
  display: grid;
  place-items: center;
  font-weight: 700;
  font-size: 16px;
  letter-spacing: 0.04em;
  flex-shrink: 0;
}

.brand-main {
  display: flex;
  flex-direction: column;
  justify-content: center;
  line-height: 1.15;
  min-width: 0;
}

.brand-name {
  font-size: 26px;
  font-weight: 800;
  color: var(--mall-accent);
  letter-spacing: 0.01em;
  white-space: nowrap;
}

.brand-sub {
  margin-top: 3px;
  font-size: 12px;
  color: var(--mall-accent);
  opacity: 0.75;
  font-weight: 500;
  letter-spacing: 0.02em;
  text-transform: lowercase;
}

.brand-divider {
  width: 1px;
  height: 36px;
  background: var(--mall-accent);
  opacity: 0.35;
  flex-shrink: 0;
  margin: 0 2px;
}

.brand-tag {
  display: flex;
  flex-direction: column;
  justify-content: center;
  gap: 2px;
  font-size: 15px;
  font-weight: 700;
  line-height: 1.2;
  color: var(--mall-accent);
  white-space: nowrap;
}

.search-wrap {
  /* 右缘对齐首页轮播（为右侧运营卡 220 + gap 12 留空） */
  width: 100%;
  max-width: calc(100% - 232px);
  margin: 0;
  min-width: 0;
}

.search :deep(.el-input__wrapper) {
  border-radius: 4px 0 0 4px;
  box-shadow: 0 0 0 2px var(--mall-accent) inset;
}

.search :deep(.el-input-group__append) {
  background: var(--mall-accent);
  border-color: var(--mall-accent);
  color: #fff;
  box-shadow: none;
  border-radius: 0 4px 4px 0;
}

.search :deep(.el-input-group__append .el-button) {
  color: #fff;
  background: transparent;
  border: 0;
  font-weight: 600;
  padding: 0 22px;
}

.hot-words {
  display: flex;
  flex-wrap: wrap;
  gap: 4px 14px;
  margin-top: 8px;
  font-size: 12px;
  color: var(--mall-muted);
}

.hot-words a:hover {
  color: var(--mall-accent);
}

.top-cart {
  display: inline-flex;
  align-items: center;
  gap: 4px;
}

.cart-icon {
  color: var(--mall-accent);
}

.cart-count {
  min-width: 16px;
  height: 16px;
  padding: 0 4px;
  border-radius: 999px;
  background: var(--mall-accent);
  color: #fff;
  font-size: 11px;
  font-style: normal;
  line-height: 16px;
  text-align: center;
  font-weight: 600;
}

.nav-bar {
  position: sticky;
  top: 0;
  z-index: 30;
  background: var(--mall-surface);
  border-bottom: 1px solid var(--mall-line);
}

.nav-inner {
  height: 40px;
  display: flex;
  align-items: stretch;
  gap: 0;
}

.cate-trigger {
  position: relative;
  width: 200px;
  flex-shrink: 0;
}

.cate-label {
  display: flex;
  align-items: center;
  height: 100%;
  padding: 0 16px;
  background: var(--mall-accent);
  color: #fff;
  font-weight: 600;
  font-size: 14px;
  cursor: default;
}

.cate-panel {
  position: absolute;
  left: 0;
  top: 100%;
  width: 720px;
  max-height: 420px;
  overflow: auto;
  background: #fff;
  border: 1px solid var(--mall-line);
  border-top: 0;
  box-shadow: 0 8px 24px rgba(15, 23, 42, 0.08);
  padding: 12px 16px;
  z-index: 40;
}

.cate-row {
  display: grid;
  grid-template-columns: 100px 1fr;
  gap: 12px;
  padding: 10px 0;
  border-bottom: 1px dashed var(--mall-line);
}

.cate-row:last-child {
  border-bottom: 0;
}

.cate-root {
  font-weight: 600;
  font-size: 14px;
}

.cate-root:hover {
  color: var(--mall-accent);
}

.cate-children {
  display: flex;
  flex-wrap: wrap;
  gap: 8px 14px;
  align-items: center;
  color: var(--mall-muted);
  font-size: 13px;
}

.cate-children a:hover {
  color: var(--mall-accent);
}

.nav-links {
  display: flex;
  align-items: center;
  gap: 28px;
  padding-left: 24px;
  font-size: 14px;
  font-weight: 500;
}

.nav-links a:hover,
.nav-links a.router-link-exact-active {
  color: var(--mall-accent);
}

.mall-main {
  flex: 1;
  padding: 16px 0 48px;
}

.mall-footer {
  border-top: 1px solid var(--mall-line);
  padding: 20px 0;
  color: var(--mall-muted);
  font-size: 13px;
  text-align: center;
}

@media (max-width: 960px) {
  .header-inner {
    grid-template-columns: 1fr;
    gap: 12px;
  }

  .search-wrap {
    max-width: none;
  }

  .cate-panel {
    width: min(92vw, 720px);
  }
}
</style>
