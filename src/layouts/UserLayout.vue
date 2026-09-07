<template>
  <div class="page-container user-layout">
    <aside class="side">
      <div class="side-user">
        <el-avatar :size="64" :src="userStore.userInfo?.avatar" class="avatar">
          {{ (userStore.userInfo?.nickname || '会').slice(0, 1) }}
        </el-avatar>
        <div class="nick">{{ userStore.userInfo?.nickname || '会员' }}</div>
        <div class="mobile">{{ userStore.userInfo?.mobile || '未绑定手机' }}</div>
        <div class="level">{{ userStore.userInfo?.level?.name || '普通会员' }}</div>
      </div>
      <el-menu :default-active="active" router class="side-menu">
        <el-menu-item index="/user">个人中心</el-menu-item>
        <el-menu-item index="/user/profile">账号资料</el-menu-item>
        <el-menu-item index="/user/address">收货地址</el-menu-item>
        <el-menu-item index="/order">我的订单</el-menu-item>
        <el-menu-item index="/user/coupon">我的优惠券</el-menu-item>
        <el-menu-item index="/order/aftersale">退款/售后</el-menu-item>
        <el-menu-item index="/user/favorite">我的收藏</el-menu-item>
        <el-menu-item index="/user/history">浏览足迹</el-menu-item>
        <el-menu-item index="/user/wallet">我的钱包</el-menu-item>
      </el-menu>
    </aside>
    <section class="content">
      <router-view />
    </section>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { useUserStore } from '@/stores/user'

const route = useRoute()
const userStore = useUserStore()

const active = computed(() => {
  const path = route.path
  if (path.startsWith('/order/aftersale')) return '/order/aftersale'
  if (path.startsWith('/order')) return '/order'
  return path
})
</script>

<style scoped lang="scss">
.user-layout {
  display: grid;
  grid-template-columns: 240px minmax(0, 1fr);
  gap: 16px;
  align-items: start;
  padding-bottom: 40px;
}

.side {
  background: var(--mall-surface);
  border-radius: var(--mall-radius);
  padding: 0 0 12px;
  position: sticky;
  top: 52px;
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
  overflow: hidden;
}

.side-user {
  text-align: center;
  padding: 22px 16px 18px;
  background: linear-gradient(180deg, #fff5f5 0%, #fff 78%);
  border-bottom: 1px solid #f3f4f6;
  margin-bottom: 4px;
}

.avatar {
  border: 2px solid #fff;
  box-shadow: 0 0 0 2px var(--mall-accent-border);
  background: var(--mall-accent-soft);
  color: var(--mall-accent);
  font-weight: 700;
}

.nick {
  margin-top: 12px;
  font-weight: 700;
  font-size: 16px;
}

.mobile {
  color: var(--mall-muted);
  font-size: 13px;
  margin-top: 4px;
}

.level {
  display: inline-block;
  margin-top: 10px;
  padding: 2px 10px;
  border-radius: 999px;
  background: var(--mall-accent-soft);
  color: var(--mall-accent);
  font-size: 12px;
  font-weight: 600;
}

.content {
  min-height: 480px;
  min-width: 0;
}

.side-menu {
  border-right: none !important;
  background: transparent;
}

:deep(.el-menu-item) {
  height: 44px;
  line-height: 44px;
  margin: 2px 8px;
  border-radius: 8px;
}

:deep(.el-menu-item.is-active) {
  background: var(--mall-accent-soft) !important;
  color: var(--mall-accent) !important;
  font-weight: 600;
}

:deep(.el-menu-item:hover) {
  background: #fafafa !important;
}

@media (max-width: 900px) {
  .user-layout {
    grid-template-columns: 1fr;
  }

  .side {
    position: static;
  }
}
</style>
