<template>
  <router-link :to="`/goods/${spu.id}`" class="product-card">
    <div class="cover">
      <img :src="spu.picUrl" :alt="spu.name" loading="lazy" />
    </div>
    <div class="body">
      <h3 class="name">{{ spu.name }}</h3>
      <div class="meta">
        <span class="price">{{ formatPrice(spu.price) }}</span>
        <span v-if="spu.salesCount != null" class="sales">已售 {{ spu.salesCount }}</span>
      </div>
    </div>
  </router-link>
</template>

<script setup lang="ts">
import type { ProductSpu } from '@/api/product'
import { formatPrice } from '@/utils/price'

defineProps<{
  spu: ProductSpu
}>()
</script>

<style scoped lang="scss">
.product-card {
  display: flex;
  flex-direction: column;
  background: var(--mall-surface);
  border-radius: var(--mall-radius);
  overflow: hidden;
  border: 1px solid transparent;
  transition: border-color 0.2s, transform 0.2s;
}

.product-card:hover {
  border-color: #f0d9cc;
  transform: translateY(-2px);
}

.cover {
  aspect-ratio: 1;
  background: #f5f5f4;
  overflow: hidden;
}

.cover img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.body {
  padding: 14px 14px 16px;
}

.name {
  margin: 0 0 10px;
  font-size: 14px;
  font-weight: 500;
  line-height: 1.4;
  height: 2.8em;
  overflow: hidden;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
}

.meta {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 8px;
}

.price {
  font-size: 18px;
}

.sales {
  color: var(--mall-muted);
  font-size: 12px;
}
</style>
