<template>
  <div class="page-container user-layout">
    <aside class="side">
      <div class="side-user">
        <el-avatar :size="56" :src="userStore.userInfo?.avatar">
          {{ (userStore.userInfo?.nickname || '会').slice(0, 1) }}
        </el-avatar>
        <div class="nick">{{ userStore.userInfo?.nickname || '会员' }}</div>
        <div class="mobile">{{ userStore.userInfo?.mobile }}</div>
      </div>
      <el-menu :default-active="active" router>
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
  grid-template-columns: 240px 1fr;
  gap: 20px;
  align-items: start;
}

.side {
  background: var(--mall-surface);
  border: 1px solid var(--mall-line);
  border-radius: var(--mall-radius);
  padding: 16px 0;
  position: sticky;
  top: 96px;
}

.side-user {
  text-align: center;
  padding: 8px 16px 20px;
  border-bottom: 1px solid var(--mall-line);
  margin-bottom: 8px;
}

.nick {
  margin-top: 10px;
  font-weight: 600;
}

.mobile {
  color: var(--mall-muted);
  font-size: 13px;
  margin-top: 4px;
}

.content {
  min-height: 480px;
}

:deep(.el-menu) {
  border-right: none;
}
</style>
