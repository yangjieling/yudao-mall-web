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
          <router-link to="/coupon">领券中心</router-link>
          <router-link to="/activity/seckill">秒杀</router-link>
          <router-link to="/activity/combination">拼团</router-link>
          <router-link to="/activity/point">积分商城</router-link>
        </div>
      </div>
    </div>

    <header class="mall-header">
      <div class="page-container header-inner">
        <router-link to="/" class="brand">
          <span class="brand-mark">芋</span>
          <span class="brand-name">{{ title }}</span>
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
        </div>

        <router-link to="/cart" class="cart-btn">
          <el-badge :value="cartStore.totalCount || undefined" :hidden="!cartStore.totalCount">
            购物车
          </el-badge>
        </router-link>
      </div>
    </header>

    <div class="nav-bar">
      <div class="page-container nav-inner">
        <div
          class="cate-trigger"
          @mouseenter="showCate = true"
          @mouseleave="showCate = false"
        >
          <span class="cate-label">全部商品分类</span>
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
      <div class="page-container">芋道商城 PC 端 · 对接 /app-api</div>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { CategoryApi, type ProductCategory } from '@/api/product'
import { useUserStore } from '@/stores/user'
import { useCartStore } from '@/stores/cart'

const title = import.meta.env.VITE_APP_TITLE
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
  background: #f5f5f4;
  border-bottom: 1px solid var(--mall-line);
  font-size: 12px;
  color: var(--mall-muted);
}

.top-inner {
  height: 32px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.top-left,
.top-right {
  display: flex;
  align-items: center;
  gap: 14px;
}

.top-right a:hover,
.top-left a:hover {
  color: var(--mall-accent);
}

.mall-header {
  background: var(--mall-surface);
  padding: 18px 0 14px;
}

.header-inner {
  display: grid;
  grid-template-columns: 200px 1fr 120px;
  gap: 28px;
  align-items: center;
}

.brand {
  display: flex;
  align-items: center;
  gap: 10px;
}

.brand-mark {
  width: 42px;
  height: 42px;
  border-radius: 10px;
  background: var(--mall-accent);
  color: #fff;
  display: grid;
  place-items: center;
  font-weight: 700;
  font-size: 18px;
}

.brand-name {
  font-size: 22px;
  font-weight: 700;
  letter-spacing: 0.02em;
}

.search-wrap {
  max-width: 640px;
  margin: 0 auto;
  width: 100%;
}

.search :deep(.el-input-group__append) {
  background: var(--mall-accent);
  border-color: var(--mall-accent);
  color: #fff;
  box-shadow: none;
}

.search :deep(.el-input-group__append .el-button) {
  color: #fff;
  background: transparent;
  border: 0;
}

.cart-btn {
  justify-self: end;
  border: 1px solid #f0d4c3;
  background: #fffaf7;
  color: var(--mall-accent);
  padding: 10px 18px;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 600;
}

.cart-btn:hover {
  border-color: var(--mall-accent);
}

.nav-bar {
  position: sticky;
  top: 0;
  z-index: 30;
  background: var(--mall-surface);
  border-bottom: 2px solid var(--mall-accent);
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
  box-shadow: 0 8px 24px rgba(28, 25, 23, 0.08);
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
.nav-links a.router-link-active {
  color: var(--mall-accent);
}

.mall-main {
  flex: 1;
  padding: 20px 0 48px;
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

  .cart-btn {
    justify-self: start;
  }

  .cate-panel {
    width: min(92vw, 720px);
  }
}
</style>
