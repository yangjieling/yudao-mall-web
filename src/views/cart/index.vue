<template>
  <div class="page-container cart-page" v-loading="cartStore.loading">
    <h1>购物车</h1>

    <el-empty v-if="!cartStore.validList.length && !cartStore.invalidList.length" description="购物车是空的">
      <el-button type="primary" @click="$router.push('/category')">去选购</el-button>
    </el-empty>

    <template v-if="cartStore.validList.length">
      <div class="cart-table">
        <div class="head row">
          <el-checkbox
            :model-value="allSelected"
            :indeterminate="indeterminate"
            @change="toggleAll"
          >
            全选
          </el-checkbox>
          <span>商品</span>
          <span>单价</span>
          <span>数量</span>
          <span>小计</span>
          <span>操作</span>
        </div>

        <div v-for="item in cartStore.validList" :key="item.id" class="body row">
          <el-checkbox
            :model-value="item.selected"
            @change="(val: boolean | string | number) => onSelect(item.id, !!val)"
          />
          <div class="goods">
            <img :src="item.sku.picUrl || item.spu.picUrl" :alt="item.spu.name" />
            <div>
              <router-link :to="`/goods/${item.spu.id}`" class="name">{{ item.spu.name }}</router-link>
              <div class="sku-props">
                <span v-for="(p, i) in item.sku.properties || []" :key="i">
                  {{ p.propertyName }}:{{ p.valueName }}
                </span>
              </div>
            </div>
          </div>
          <div class="price">{{ formatPrice(item.sku.price) }}</div>
          <el-input-number
            :model-value="item.count"
            :min="1"
            :max="item.sku.stock || 999"
            @change="(val: number | undefined) => onCount(item.id, val || 1)"
          />
          <div class="price">{{ formatPrice(item.sku.price * item.count) }}</div>
          <el-button link type="danger" @click="onRemove(item.id)">删除</el-button>
        </div>
      </div>

      <div class="footer-bar">
        <div>
          已选 <b>{{ cartStore.selectedCount }}</b> 件，合计
          <span class="price total">{{ formatPrice(cartStore.selectedAmount) }}</span>
        </div>
        <el-button type="primary" size="large" :disabled="!cartStore.selectedCount" @click="checkout">
          去结算
        </el-button>
      </div>
    </template>

    <section v-if="cartStore.invalidList.length" class="invalid-section">
      <div class="invalid-head">
        <h2>失效商品</h2>
        <el-button link type="danger" @click="clearInvalid">清空失效</el-button>
      </div>
      <div class="cart-table invalid">
        <div v-for="item in cartStore.invalidList" :key="item.id" class="body row">
          <span class="invalid-tag">失效</span>
          <div class="goods">
            <img :src="item.sku.picUrl || item.spu.picUrl" :alt="item.spu.name" />
            <div>
              <div class="name muted-name">{{ item.spu.name }}</div>
              <div class="sku-props">商品已下架或库存不足</div>
            </div>
          </div>
          <div class="price">{{ formatPrice(item.sku.price) }}</div>
          <span>{{ item.count }}</span>
          <span>—</span>
          <el-button link type="danger" @click="onRemove(item.id)">删除</el-button>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useCartStore } from '@/stores/cart'
import { formatPrice } from '@/utils/price'

const cartStore = useCartStore()
const router = useRouter()

const allSelected = computed(
  () => cartStore.validList.length > 0 && cartStore.validList.every((i) => i.selected)
)
const indeterminate = computed(
  () => cartStore.selectedList.length > 0 && cartStore.selectedList.length < cartStore.validList.length
)

onMounted(() => cartStore.getList())

async function toggleAll(val: boolean | string | number) {
  const ids = cartStore.validList.map((i) => i.id)
  await cartStore.updateSelected(ids, !!val)
}

async function onSelect(id: number, selected: boolean) {
  await cartStore.updateSelected([id], selected)
}

async function onCount(id: number, count: number) {
  await cartStore.updateCount(id, count)
}

async function onRemove(id: number) {
  await cartStore.remove([id])
}

async function clearInvalid() {
  const ids = cartStore.invalidList.map((i) => i.id)
  if (ids.length) await cartStore.remove(ids)
}

function checkout() {
  const items = cartStore.selectedList
    .map((i) => `${i.sku.id}:${i.count}:${i.id}`)
    .join(',')
  router.push({ path: '/checkout', query: { items } })
}
</script>

<style scoped lang="scss">
h1 {
  margin: 0 0 20px;
  font-size: 24px;
}

.cart-table {
  background: var(--mall-surface);
  border: 1px solid var(--mall-line);
  border-radius: var(--mall-radius);
  overflow: hidden;
}

.row {
  display: grid;
  grid-template-columns: 80px 1fr 120px 140px 120px 80px;
  gap: 12px;
  align-items: center;
  padding: 16px 20px;
}

.head {
  background: #fafaf9;
  color: var(--mall-muted);
  font-size: 13px;
}

.body {
  border-top: 1px solid var(--mall-line);
}

.goods {
  display: flex;
  gap: 12px;
  align-items: center;
}

.goods img {
  width: 72px;
  height: 72px;
  object-fit: cover;
  border-radius: 8px;
  background: #f5f5f4;
}

.name {
  font-weight: 500;
}

.muted-name {
  color: var(--mall-muted);
}

.sku-props {
  margin-top: 4px;
  color: var(--mall-muted);
  font-size: 12px;
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.footer-bar {
  margin-top: 20px;
  background: var(--mall-surface);
  border: 1px solid var(--mall-line);
  border-radius: var(--mall-radius);
  padding: 16px 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.total {
  font-size: 24px;
  margin-left: 8px;
}

.invalid-section {
  margin-top: 28px;
}

.invalid-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.invalid-head h2 {
  margin: 0;
  font-size: 16px;
  color: var(--mall-muted);
}

.invalid .body {
  opacity: 0.75;
}

.invalid-tag {
  color: var(--mall-muted);
  font-size: 12px;
}
</style>
