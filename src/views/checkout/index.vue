<template>
  <div class="page-container checkout-page" v-loading="loading">
    <h1>确认订单</h1>

    <section class="panel">
      <div class="panel-head">
        <h2>收货地址</h2>
        <div>
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
          <div class="muted">{{ item.skuName }} × {{ item.count }}</div>
        </div>
        <div class="price">{{ formatPrice(item.price) }}</div>
      </div>
    </section>

    <section class="panel">
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
        <div class="pay">
          应付：<span class="price">{{ formatPrice(settlement?.price?.payPrice) }}</span>
        </div>
      </div>
      <el-button type="primary" size="large" :disabled="!canSubmit" :loading="submitting" @click="submit">
        提交订单
      </el-button>
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
import {
  OrderApi,
  type OrderItemPayload,
  type SettlementResp
} from '@/api/trade/order'
import { useCartStore } from '@/stores/cart'
import { formatPrice } from '@/utils/price'

const route = useRoute()
const router = useRouter()
const cartStore = useCartStore()

const loading = ref(false)
const submitting = ref(false)
const addresses = ref<MemberAddress[]>([])
const addressId = ref<number>()
const remark = ref('')
const settlement = ref<SettlementResp | null>(null)
const items = ref<OrderItemPayload[]>([])

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

function parseItemsFromQuery(): OrderItemPayload[] {
  // 购物车：items=skuId:count:cartId,skuId:count:cartId
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
  // 立即购买：skuId + count
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
      deliveryType: 1
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
      remark: remark.value || undefined
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

onMounted(async () => {
  items.value = parseItemsFromQuery()
  if (!items.value.length) {
    ElMessage.warning('没有可结算的商品')
    router.replace('/cart')
    return
  }
  await loadAddresses()
  await calcSettlement()
})
</script>

<style scoped lang="scss">
h1 {
  margin: 0 0 20px;
  font-size: 24px;
}

.panel {
  background: var(--mall-surface);
  border: 1px solid var(--mall-line);
  border-radius: var(--mall-radius);
  padding: 20px;
  margin-bottom: 16px;
}

.panel-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.panel h2 {
  margin: 0 0 16px;
  font-size: 16px;
}

.address-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
  width: 100%;
}

.address-item {
  height: auto !important;
  margin: 0 !important;
  padding: 12px 16px !important;
  width: 100%;
  align-items: flex-start;
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

.goods-row {
  display: grid;
  grid-template-columns: 64px 1fr auto;
  gap: 12px;
  align-items: center;
  padding: 10px 0;
  border-bottom: 1px solid var(--mall-line);
}

.goods-row img {
  width: 64px;
  height: 64px;
  object-fit: cover;
  border-radius: 8px;
  background: #f5f5f4;
}

.muted {
  color: var(--mall-muted);
  font-size: 13px;
  margin-top: 4px;
}

.summary {
  margin: 16px 0;
  text-align: right;
  line-height: 1.8;
  color: var(--mall-muted);
}

.pay {
  margin-top: 8px;
  color: var(--mall-ink);
}

.pay .price {
  font-size: 24px;
}
</style>
