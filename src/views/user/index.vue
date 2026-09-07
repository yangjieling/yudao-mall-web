<template>
  <div class="user-home" v-loading="loading">
    <div class="profile-card">
      <el-avatar :size="72" :src="userStore.userInfo?.avatar" class="avatar">
        {{ (userStore.userInfo?.nickname || '会').slice(0, 1) }}
      </el-avatar>
      <div class="profile-main">
        <div class="name-row">
          <h1>{{ userStore.userInfo?.nickname || '会员' }}</h1>
          <span class="level">{{ userStore.userInfo?.level?.name || '普通会员' }}</span>
        </div>
        <div class="meta">
          <span>手机 {{ userStore.userInfo?.mobile || '-' }}</span>
          <span>积分 {{ userStore.userInfo?.point ?? 0 }}</span>
        </div>
      </div>
      <el-button @click="$router.push('/user/profile')">编辑资料</el-button>
    </div>

    <div class="section-head">
      <h2>我的订单</h2>
      <router-link to="/order" class="more">全部订单</router-link>
    </div>
    <div class="stats">
      <router-link to="/order?status=0" class="stat">
        <b>{{ count.unpaidCount || 0 }}</b>
        <span>待付款</span>
      </router-link>
      <router-link to="/order?status=10" class="stat">
        <b>{{ count.undeliveredCount || 0 }}</b>
        <span>待发货</span>
      </router-link>
      <router-link to="/order?status=20" class="stat">
        <b>{{ count.deliveredCount || 0 }}</b>
        <span>待收货</span>
      </router-link>
      <router-link to="/order/aftersale" class="stat">
        <b>{{ count.afterSaleCount || 0 }}</b>
        <span>售后</span>
      </router-link>
      <router-link to="/user/coupon" class="stat">
        <b>{{ couponCount }}</b>
        <span>优惠券</span>
      </router-link>
    </div>

    <div class="section-head">
      <h2>常用服务</h2>
    </div>
    <div class="quick">
      <router-link v-for="item in quickLinks" :key="item.to" :to="item.to" class="quick-item">
        <span class="quick-title">{{ item.title }}</span>
        <span class="quick-desc">{{ item.desc }}</span>
      </router-link>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { OrderApi, type OrderCount } from '@/api/trade/order'
import { CouponApi } from '@/api/promotion/coupon'
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()
const loading = ref(false)
const count = reactive<OrderCount>({})
const couponCount = ref(0)

const quickLinks = [
  { to: '/user/address', title: '收货地址', desc: '管理配送地址' },
  { to: '/user/favorite', title: '我的收藏', desc: '收藏的商品' },
  { to: '/user/history', title: '浏览足迹', desc: '最近看过' },
  { to: '/user/wallet', title: '我的钱包', desc: '余额与流水' },
  { to: '/coupon', title: '领券中心', desc: '领取优惠券' },
  { to: '/user/profile', title: '账号资料', desc: '头像与密码' }
]

onMounted(async () => {
  loading.value = true
  try {
    await userStore.fetchUserInfo()
    const [c, coupon] = await Promise.all([
      OrderApi.getOrderCount(),
      CouponApi.getUnusedCouponCount().catch(() => ({ data: 0 }))
    ])
    Object.assign(count, c.data || {})
    couponCount.value = coupon.data || 0
  } finally {
    loading.value = false
  }
})
</script>

<style scoped lang="scss">
.user-home {
  min-width: 0;
}

.profile-card {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 22px 24px;
  margin-bottom: 16px;
  background: linear-gradient(90deg, #fff5f5 0%, #fff 55%);
  border-radius: var(--mall-radius);
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
  border: 1px solid var(--mall-accent-border);
}

.avatar {
  flex-shrink: 0;
  border: 2px solid #fff;
  box-shadow: 0 0 0 2px var(--mall-accent-border);
  background: var(--mall-accent-soft);
  color: var(--mall-accent);
  font-weight: 700;
}

.profile-main {
  flex: 1;
  min-width: 0;
}

.name-row {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 10px;
}

h1 {
  margin: 0;
  font-size: 22px;
}

.level {
  padding: 2px 10px;
  border-radius: 999px;
  background: #fff;
  border: 1px solid var(--mall-accent-border);
  color: var(--mall-accent);
  font-size: 12px;
  font-weight: 600;
}

.meta {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  margin-top: 8px;
  color: var(--mall-muted);
  font-size: 13px;
}

.section-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin: 4px 0 12px;
}

.section-head h2 {
  margin: 0;
  font-size: 16px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.section-head h2::before {
  content: '';
  width: 3px;
  height: 14px;
  border-radius: 2px;
  background: var(--mall-accent);
}

.more {
  font-size: 13px;
  color: var(--mall-muted);
}

.more:hover {
  color: var(--mall-accent);
}

.stats {
  display: grid;
  grid-template-columns: repeat(5, minmax(0, 1fr));
  gap: 12px;
  margin-bottom: 20px;
}

.stat {
  background: var(--mall-surface);
  border-radius: var(--mall-radius);
  padding: 18px 12px;
  text-align: center;
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
  transition: transform 0.15s, box-shadow 0.15s;
}

.stat:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(239, 68, 68, 0.08);
}

.stat b {
  display: block;
  font-size: 22px;
  color: var(--mall-accent);
  line-height: 1.2;
}

.stat span {
  display: block;
  margin-top: 6px;
  color: var(--mall-muted);
  font-size: 13px;
}

.quick {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 12px;
}

.quick-item {
  display: flex;
  flex-direction: column;
  gap: 6px;
  padding: 18px 16px;
  background: var(--mall-surface);
  border-radius: var(--mall-radius);
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
  transition: border-color 0.15s, box-shadow 0.15s;
  border: 1px solid transparent;
}

.quick-item:hover {
  border-color: var(--mall-accent-border);
  box-shadow: 0 4px 12px rgba(239, 68, 68, 0.08);
}

.quick-title {
  font-size: 15px;
  font-weight: 600;
}

.quick-desc {
  font-size: 12px;
  color: var(--mall-muted);
}

@media (max-width: 900px) {
  .stats {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }

  .quick {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .profile-card {
    flex-wrap: wrap;
  }
}

@media (max-width: 560px) {
  .stats,
  .quick {
    grid-template-columns: 1fr 1fr;
  }
}
</style>
