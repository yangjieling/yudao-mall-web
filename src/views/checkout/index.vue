<template>
  <div class="page-container checkout-page" v-loading="loading">
    <h1>确认订单</h1>

    <section class="panel">
      <div class="panel-head">
        <h2>收货地址</h2>
        <div>
          <el-button link type="primary" @click="$router.push('/user/address')">管理地址</el-button>
          <el-button link type="primary" @click="openAddressDialog">新增地址</el-button>
          <el-button link type="primary" @click="loadAddresses">刷新</el-button>
        </div>
      </div>
      <el-radio-group v-if="addresses.length" v-model="addressId" class="address-list">
        <el-radio
          v-for="addr in addresses"
          :key="addr.id"
          :value="addr.id"
          class="address-item"
          border
        >
          <div>
            <strong>{{ addr.name }}</strong>
            <span class="mobile">{{ addr.mobile }}</span>
            <div class="detail">{{ addr.areaName }} {{ addr.detailAddress }}</div>
          </div>
        </el-radio>
      </el-radio-group>
      <el-empty v-else description="暂无收货地址，请先新增" :image-size="80" />
    </section>

    <section class="panel">
      <h2>商品信息</h2>
      <div v-for="(item, idx) in settlement?.items || []" :key="idx" class="goods-row">
        <img :src="item.picUrl" :alt="item.spuName" />
        <div class="goods-info">
          <div>{{ item.spuName }}</div>
          <div class="muted">
            <span v-for="(p, i) in item.properties || []" :key="i">
              {{ p.propertyName }}:{{ p.valueName }}
            </span>
            × {{ item.count }}
          </div>
        </div>
        <div class="price">{{ formatPrice(item.price) }}</div>
      </div>
    </section>

    <section class="panel">
      <h2>优惠券</h2>
      <el-radio-group v-model="couponId" class="coupon-list" @change="calcSettlement">
        <el-radio :value="0" border class="coupon-item">不使用优惠券</el-radio>
        <el-radio
          v-for="c in availableCoupons"
          :key="c.id"
          :value="c.id"
          border
          class="coupon-item"
        >
          {{ c.name }}
          <span class="muted">
            （
            <template v-if="c.discountType === 1">减{{ formatPrice(c.discountPrice) }}</template>
            <template v-else>{{ (c.discountPercent || 0) / 10 }}折</template>
            ）
          </span>
        </el-radio>
      </el-radio-group>
      <div v-if="unavailableCoupons.length" class="muted tip">
        {{ unavailableCoupons.length }} 张优惠券暂不可用
      </div>
    </section>

    <section class="panel">
      <el-form-item label="积分抵扣" v-if="(settlement?.totalPoint || 0) > 0">
        <el-switch v-model="pointStatus" @change="calcSettlement" />
        <span class="muted">可用积分 {{ settlement?.totalPoint }}</span>
      </el-form-item>
      <el-input
        v-model="remark"
        type="textarea"
        :rows="2"
        maxlength="100"
        show-word-limit
        placeholder="订单备注（选填）"
      />
      <div class="summary">
        <div>商品合计：{{ formatPrice(settlement?.price?.totalPrice) }}</div>
        <div v-if="settlement?.price?.deliveryPrice">
          运费：{{ formatPrice(settlement.price.deliveryPrice) }}
        </div>
        <div v-if="settlement?.price?.couponPrice">
          优惠券：-{{ formatPrice(settlement.price.couponPrice) }}
        </div>
        <div v-if="settlement?.price?.discountPrice">
          活动优惠：-{{ formatPrice(settlement.price.discountPrice) }}
        </div>
        <div v-if="settlement?.price?.pointPrice">
          积分抵扣：-{{ formatPrice(settlement.price.pointPrice) }}
        </div>
        <div v-if="settlement?.price?.vipPrice">
          会员优惠：-{{ formatPrice(settlement.price.vipPrice) }}
        </div>
        <div class="pay">
          应付：<span class="price">{{ formatPrice(settlement?.price?.payPrice) }}</span>
        </div>
      </div>
      <el-button type="primary" size="large" :disabled="!canSubmit" :loading="submitting" @click="submit">
        提交订单
      </el-button>
    </section>

    <section v-if="recommends.length" class="recommend">
      <div class="recommend-head">
        <h2>猜你喜欢</h2>
        <router-link to="/category">更多商品</router-link>
      </div>
      <div class="recommend-grid">
        <ProductCard v-for="item in recommends" :key="item.id" :spu="item" />
      </div>
    </section>

    <el-dialog v-model="addressDialogVisible" title="新增收货地址" width="480px" destroy-on-close>
      <el-form label-width="80px">
        <el-form-item label="收货人" required>
          <el-input v-model="addressForm.name" maxlength="20" />
        </el-form-item>
        <el-form-item label="手机号" required>
          <el-input v-model="addressForm.mobile" maxlength="11" />
        </el-form-item>
        <el-form-item label="所在地区" required>
          <el-cascader
            v-model="addressForm.areaPath"
            :options="areaOptions"
            :props="{ value: 'id', label: 'name', children: 'children' }"
            clearable
            filterable
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="详细地址" required>
          <el-input v-model="addressForm.detailAddress" type="textarea" :rows="2" maxlength="100" />
        </el-form-item>
        <el-form-item label="默认地址">
          <el-switch v-model="addressForm.defaultStatus" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="addressDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="addressSaving" @click="saveAddress">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { AddressApi, type MemberAddress } from '@/api/member/address'
import { AreaApi, type AreaNode } from '@/api/system/area'
import { SpuApi, type ProductSpu } from '@/api/product'
import {
  OrderApi,
  type OrderItemPayload,
  type SettlementResp
} from '@/api/trade/order'
import ProductCard from '@/components/ProductCard.vue'
import { useCartStore } from '@/stores/cart'
import { formatPrice } from '@/utils/price'

const route = useRoute()
const router = useRouter()
const cartStore = useCartStore()

const loading = ref(false)
const submitting = ref(false)
const addresses = ref<MemberAddress[]>([])
const addressId = ref<number>()
const couponId = ref(0)
const pointStatus = ref(false)
const remark = ref('')
const settlement = ref<SettlementResp | null>(null)
const items = ref<OrderItemPayload[]>([])
const recommends = ref<ProductSpu[]>([])

const addressDialogVisible = ref(false)
const addressSaving = ref(false)
const areaOptions = ref<AreaNode[]>([])
const addressForm = reactive({
  name: '',
  mobile: '',
  areaPath: [] as number[],
  detailAddress: '',
  defaultStatus: true
})

const canSubmit = computed(() => !!addressId.value && items.value.length > 0 && !!settlement.value)
const availableCoupons = computed(() => (settlement.value?.coupons || []).filter((c) => c.match))
const unavailableCoupons = computed(() => (settlement.value?.coupons || []).filter((c) => !c.match))
const checkoutSpuIds = computed(() => {
  const ids = new Set<number>()
  for (const item of settlement.value?.items || []) {
    if (item.spuId) ids.add(item.spuId)
  }
  return ids
})

async function loadRecommends() {
  try {
    const res = await SpuApi.getSpuPage({
      pageNo: 1,
      pageSize: 12,
      sortField: 'salesCount',
      sortAsc: false
    })
    const exclude = checkoutSpuIds.value
    recommends.value = (res.data?.list || [])
      .filter((item) => !exclude.has(item.id))
      .slice(0, 8)
  } catch {
    recommends.value = []
  }
}

function parseItemsFromQuery(): OrderItemPayload[] {
  if (route.query.items) {
    return String(route.query.items)
      .split(',')
      .map((part) => {
        const [skuId, count, cartId] = part.split(':')
        return {
          skuId: Number(skuId),
          count: Number(count) || 1,
          cartId: cartId ? Number(cartId) : undefined
        }
      })
      .filter((i) => i.skuId)
  }
  if (route.query.skuId) {
    return [
      {
        skuId: Number(route.query.skuId),
        count: Number(route.query.count) || 1
      }
    ]
  }
  return []
}

async function loadAddresses() {
  const res = await AddressApi.getAddressList()
  addresses.value = res.data || []
  const def = addresses.value.find((a) => a.defaultStatus) || addresses.value[0]
  if (def) addressId.value = def.id
}

async function openAddressDialog() {
  if (!areaOptions.value.length) {
    const res = await AreaApi.getAreaTree()
    areaOptions.value = res.data || []
  }
  addressForm.name = ''
  addressForm.mobile = ''
  addressForm.areaPath = []
  addressForm.detailAddress = ''
  addressForm.defaultStatus = addresses.value.length === 0
  addressDialogVisible.value = true
}

async function saveAddress() {
  const areaId = addressForm.areaPath[addressForm.areaPath.length - 1]
  if (!addressForm.name || !addressForm.mobile || !areaId || !addressForm.detailAddress) {
    ElMessage.warning('请完整填写收货信息')
    return
  }
  addressSaving.value = true
  try {
    await AddressApi.createAddress({
      name: addressForm.name,
      mobile: addressForm.mobile,
      areaId,
      detailAddress: addressForm.detailAddress,
      defaultStatus: addressForm.defaultStatus
    })
    ElMessage.success('地址已保存')
    addressDialogVisible.value = false
    await loadAddresses()
    await calcSettlement()
  } finally {
    addressSaving.value = false
  }
}

async function calcSettlement() {
  if (!items.value.length) return
  loading.value = true
  try {
    const res = await OrderApi.settlementOrder({
      items: items.value,
      addressId: addressId.value,
      deliveryType: 1,
      couponId: couponId.value || undefined,
      pointStatus: pointStatus.value
    })
    settlement.value = res.data
    if (res.data.address?.id) {
      addressId.value = res.data.address.id
    }
  } finally {
    loading.value = false
  }
}

async function submit() {
  if (!canSubmit.value) {
    ElMessage.warning('请选择收货地址')
    return
  }
  submitting.value = true
  try {
    const res = await OrderApi.createOrder({
      items: items.value,
      addressId: addressId.value,
      deliveryType: 1,
      remark: remark.value || undefined,
      couponId: couponId.value || undefined,
      pointStatus: pointStatus.value
    })
    if (items.value.some((i) => i.cartId)) {
      await cartStore.getList()
    }
    if (res.data.payOrderId) {
      router.replace({ path: '/pay', query: { id: String(res.data.payOrderId) } })
    } else {
      router.replace({ path: `/order/${res.data.id}` })
    }
  } finally {
    submitting.value = false
  }
}

watch(addressId, () => {
  if (items.value.length) calcSettlement()
})

watch(checkoutSpuIds, () => {
  loadRecommends()
})

onMounted(async () => {
  items.value = parseItemsFromQuery()
  if (!items.value.length) {
    ElMessage.warning('没有可结算的商品')
    router.replace('/cart')
    return
  }
  await loadAddresses()
  await calcSettlement()
  await loadRecommends()
})
</script>

<style scoped lang="scss">
h1 {
  margin: 0 0 18px;
  font-size: 22px;
  display: flex;
  align-items: center;
  gap: 8px;
}

h1::before {
  content: '';
  width: 4px;
  height: 18px;
  border-radius: 2px;
  background: var(--mall-accent);
}

.panel {
  background: var(--mall-surface);
  border-radius: var(--mall-radius);
  padding: 20px;
  margin-bottom: 14px;
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
}

.panel-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.panel h2 {
  margin: 0 0 16px;
  font-size: 16px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.panel h2::before {
  content: '';
  width: 3px;
  height: 14px;
  border-radius: 2px;
  background: var(--mall-accent);
}

.panel-head h2 {
  margin: 0;
}

.address-list,
.coupon-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
  width: 100%;
}

.address-item,
.coupon-item {
  height: auto !important;
  margin: 0 !important;
  padding: 12px 16px !important;
  width: 100%;
  align-items: flex-start;
}

.address-item.is-checked,
.coupon-item.is-checked {
  border-color: var(--mall-accent) !important;
  background: var(--mall-accent-soft);
}

.mobile {
  margin-left: 12px;
  color: var(--mall-muted);
}

.detail {
  margin-top: 4px;
  color: var(--mall-muted);
  font-size: 13px;
  white-space: normal;
}

.tip {
  margin-top: 8px;
  font-size: 13px;
}

.goods-row {
  display: grid;
  grid-template-columns: 64px 1fr auto;
  gap: 12px;
  align-items: center;
  padding: 12px 0;
  border-bottom: 1px solid var(--mall-line);
}

.goods-row:last-child {
  border-bottom: 0;
}

.goods-row img {
  width: 64px;
  height: 64px;
  object-fit: cover;
  border-radius: 8px;
  background: #f3f4f6;
}

.muted {
  color: var(--mall-muted);
  font-size: 13px;
  margin-top: 4px;
}

.summary {
  margin: 16px 0;
  padding: 14px 16px;
  border-radius: 10px;
  background: linear-gradient(135deg, #fff5f5, #fef2f2);
  text-align: right;
  line-height: 1.8;
  color: var(--mall-muted);
}

.pay {
  margin-top: 8px;
  color: var(--mall-ink);
}

.pay .price {
  font-size: 26px;
}

.recommend {
  margin-top: 4px;
  margin-bottom: 14px;
  background: var(--mall-surface);
  border-radius: var(--mall-radius);
  padding: 18px 20px 20px;
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
}

.recommend-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 14px;
}

.recommend-head h2 {
  margin: 0;
  font-size: 16px;
  display: flex;
  align-items: center;
  gap: 8px;
  color: var(--mall-ink);
}

.recommend-head h2::before {
  content: '';
  width: 3px;
  height: 14px;
  border-radius: 2px;
  background: var(--mall-accent);
}

.recommend-head a {
  font-size: 13px;
  color: var(--mall-muted);
}

.recommend-head a:hover {
  color: var(--mall-accent);
}

.recommend-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 14px;
}

@media (max-width: 1100px) {
  .recommend-grid {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }
}

@media (max-width: 800px) {
  .recommend-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}
</style>
