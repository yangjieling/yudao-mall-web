<template>
  <div class="user-home" v-loading="loading">
    <h1>个人中心</h1>
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

    <div class="panel">
      <h2>账户信息</h2>
      <div class="info-grid">
        <div>昵称：{{ userStore.userInfo?.nickname }}</div>
        <div>手机：{{ userStore.userInfo?.mobile }}</div>
        <div>积分：{{ userStore.userInfo?.point ?? 0 }}</div>
        <div>等级：{{ userStore.userInfo?.level?.name || '普通会员' }}</div>
      </div>
      <el-button type="primary" @click="$router.push('/user/profile')">编辑资料</el-button>
    </div>

    <div class="quick">
      <el-button @click="$router.push('/user/address')">收货地址</el-button>
      <el-button @click="$router.push('/user/favorite')">我的收藏</el-button>
      <el-button @click="$router.push('/user/wallet')">我的钱包</el-button>
      <el-button @click="$router.push('/coupon')">领券中心</el-button>
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
h1 {
  margin: 0 0 20px;
  font-size: 22px;
}

.stats {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 12px;
  margin-bottom: 20px;
}

.stat {
  background: var(--mall-surface);
  border: 1px solid var(--mall-line);
  border-radius: var(--mall-radius);
  padding: 18px 12px;
  text-align: center;
}

.stat b {
  display: block;
  font-size: 22px;
  color: var(--mall-accent);
}

.stat span {
  color: var(--mall-muted);
  font-size: 13px;
}

.panel {
  background: var(--mall-surface);
  border: 1px solid var(--mall-line);
  border-radius: var(--mall-radius);
  padding: 20px;
  margin-bottom: 16px;
}

.panel h2 {
  margin: 0 0 12px;
  font-size: 16px;
}

.info-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
  margin-bottom: 16px;
  color: var(--mall-muted);
}

.quick {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}
</style>
