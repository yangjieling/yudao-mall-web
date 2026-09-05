<template>
  <div class="mall-layout">
    <header class="mall-header">
      <div class="page-container header-inner">
        <router-link to="/" class="brand">
          <span class="brand-mark">芋</span>
          <span class="brand-name">{{ title }}</span>
        </router-link>

        <el-input
          v-model="keyword"
          class="search"
          placeholder="搜索商品"
          clearable
          @keyup.enter="onSearch"
        >
          <template #append>
            <el-button :icon="Search" @click="onSearch" />
          </template>
        </el-input>

        <nav class="nav-actions">
          <router-link to="/category">分类</router-link>
          <router-link to="/order">订单</router-link>
          <router-link to="/cart" class="cart-link">
            购物车
            <el-badge v-if="cartStore.totalCount > 0" :value="cartStore.totalCount" />
          </router-link>
          <template v-if="userStore.isLogin">
            <span class="user-name">{{ userStore.userInfo?.nickname || '会员' }}</span>
            <el-button link type="primary" @click="onLogout">退出</el-button>
          </template>
          <router-link v-else to="/login">登录</router-link>
        </nav>
      </div>
    </header>

    <main class="mall-main">
      <router-view />
    </main>

    <footer class="mall-footer">
      <div class="page-container">芋道商城 PC 端 · 对接 /app-api</div>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { onMounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Search } from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'
import { useCartStore } from '@/stores/cart'

const title = import.meta.env.VITE_APP_TITLE
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const cartStore = useCartStore()
const keyword = ref((route.query.keyword as string) || '')

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

onMounted(() => {
  if (userStore.isLogin) cartStore.getList()
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

.mall-header {
  position: sticky;
  top: 0;
  z-index: 20;
  background: rgba(255, 255, 255, 0.92);
  backdrop-filter: blur(10px);
  border-bottom: 1px solid var(--mall-line);
}

.header-inner {
  height: 72px;
  display: grid;
  grid-template-columns: auto 1fr auto;
  gap: 24px;
  align-items: center;
}

.brand {
  display: flex;
  align-items: center;
  gap: 10px;
}

.brand-mark {
  width: 36px;
  height: 36px;
  border-radius: 10px;
  background: var(--mall-accent);
  color: #fff;
  display: grid;
  place-items: center;
  font-weight: 700;
}

.brand-name {
  font-size: 20px;
  font-weight: 700;
  letter-spacing: 0.02em;
}

.search {
  max-width: 480px;
}

.nav-actions {
  display: flex;
  align-items: center;
  gap: 18px;
  color: var(--mall-muted);
  font-size: 14px;
}

.nav-actions a:hover,
.cart-link {
  color: var(--mall-ink);
}

.user-name {
  color: var(--mall-ink);
  max-width: 100px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.mall-main {
  flex: 1;
  padding: 28px 0 48px;
}

.mall-footer {
  border-top: 1px solid var(--mall-line);
  padding: 20px 0;
  color: var(--mall-muted);
  font-size: 13px;
  text-align: center;
}
</style>
