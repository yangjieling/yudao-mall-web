import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'
import { getAccessToken } from '@/utils/auth'

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    component: () => import('@/layouts/MallLayout.vue'),
    children: [
      {
        path: '',
        name: 'Home',
        component: () => import('@/views/home/index.vue'),
        meta: { title: '首页' }
      },
      {
        path: 'category',
        name: 'Category',
        component: () => import('@/views/category/index.vue'),
        meta: { title: '商品列表' }
      },
      {
        path: 'goods/:id/comments',
        name: 'GoodsComments',
        component: () => import('@/views/goods/comments.vue'),
        meta: { title: '商品评价' }
      },
      {
        path: 'goods/:id',
        name: 'GoodsDetail',
        component: () => import('@/views/goods/detail.vue'),
        meta: { title: '商品详情', dynamicTitle: true }
      },
      {
        path: 'cart',
        name: 'Cart',
        component: () => import('@/views/cart/index.vue'),
        meta: { title: '购物车', auth: true }
      },
      {
        path: 'checkout',
        name: 'Checkout',
        component: () => import('@/views/checkout/index.vue'),
        meta: { title: '确认订单', auth: true }
      },
      {
        path: 'coupon',
        name: 'CouponCenter',
        component: () => import('@/views/coupon/index.vue'),
        meta: { title: '领券中心' }
      },
      {
        path: 'activity/seckill',
        name: 'ActivitySeckill',
        component: () => import('@/views/activity/seckill.vue'),
        meta: { title: '限时秒杀' }
      },
      {
        path: 'activity/combination',
        name: 'ActivityCombination',
        component: () => import('@/views/activity/combination.vue'),
        meta: { title: '超值拼团' }
      },
      {
        path: 'activity/point',
        name: 'ActivityPoint',
        component: () => import('@/views/activity/point.vue'),
        meta: { title: '积分商城' }
      },
      {
        path: 'pay',
        name: 'Pay',
        component: () => import('@/views/pay/index.vue'),
        meta: { title: '收银台', auth: true }
      },
      {
        path: 'pay/result',
        name: 'PayResult',
        component: () => import('@/views/pay/result.vue'),
        meta: { title: '支付结果', auth: true }
      },
      {
        path: 'user',
        component: () => import('@/layouts/UserLayout.vue'),
        meta: { auth: true },
        children: [
          {
            path: '',
            name: 'UserHome',
            component: () => import('@/views/user/index.vue'),
            meta: { title: '个人中心', auth: true }
          },
          {
            path: 'profile',
            name: 'UserProfile',
            component: () => import('@/views/user/profile.vue'),
            meta: { title: '账号资料', auth: true }
          },
          {
            path: 'address',
            name: 'UserAddress',
            component: () => import('@/views/user/address.vue'),
            meta: { title: '收货地址', auth: true }
          },
          {
            path: 'coupon',
            name: 'UserCoupon',
            component: () => import('@/views/user/coupon.vue'),
            meta: { title: '我的优惠券', auth: true }
          },
          {
            path: 'favorite',
            name: 'UserFavorite',
            component: () => import('@/views/user/favorite.vue'),
            meta: { title: '我的收藏', auth: true }
          },
          {
            path: 'history',
            name: 'UserHistory',
            component: () => import('@/views/user/history.vue'),
            meta: { title: '浏览足迹', auth: true }
          },
          {
            path: 'wallet',
            name: 'UserWallet',
            component: () => import('@/views/user/wallet.vue'),
            meta: { title: '我的钱包', auth: true }
          }
        ]
      },
      {
        path: 'order',
        component: () => import('@/layouts/UserLayout.vue'),
        meta: { auth: true },
        children: [
          {
            path: '',
            name: 'OrderList',
            component: () => import('@/views/order/list.vue'),
            meta: { title: '我的订单', auth: true }
          },
          {
            path: 'aftersale',
            name: 'AfterSaleList',
            component: () => import('@/views/order/aftersale/list.vue'),
            meta: { title: '退款/售后', auth: true }
          },
          {
            path: 'aftersale/apply',
            name: 'AfterSaleApply',
            component: () => import('@/views/order/aftersale/apply.vue'),
            meta: { title: '申请售后', auth: true }
          },
          {
            path: 'aftersale/:id',
            name: 'AfterSaleDetail',
            component: () => import('@/views/order/aftersale/detail.vue'),
            meta: { title: '售后详情', auth: true }
          },
          {
            path: 'comment',
            name: 'OrderComment',
            component: () => import('@/views/order/comment.vue'),
            meta: { title: '评价订单', auth: true }
          },
          {
            path: ':id',
            name: 'OrderDetail',
            component: () => import('@/views/order/detail.vue'),
            meta: { title: '订单详情', auth: true }
          }
        ]
      }
    ]
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/auth/login.vue'),
    meta: { title: '登录' }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior() {
    return { top: 0 }
  }
})

router.beforeEach((to, _from, next) => {
  const nearest = [...to.matched].reverse().find((r) => r.meta.title)
  const pageTitle = (nearest?.meta.title as string) || '首页'
  const appTitle = import.meta.env.VITE_APP_TITLE || 'OM Shop'
  if (!to.matched.some((r) => r.meta.dynamicTitle)) {
    document.title = `${pageTitle} - ${appTitle}`
  }

  const needAuth = to.matched.some((r) => r.meta.auth)
  if (needAuth && !getAccessToken()) {
    next({ path: '/login', query: { redirect: to.fullPath } })
    return
  }
  next()
})

export default router
