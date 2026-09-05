<template>
  <div class="page-container result-page" v-loading="loading">
    <div class="panel">
      <template v-if="payOrder">
        <el-result
          :icon="success ? 'success' : 'warning'"
          :title="success ? '支付成功' : '支付处理中'"
          :sub-title="success ? '感谢您的购买' : '可稍后在订单中心查看支付状态'"
        >
          <template #extra>
            <div class="amount price">{{ formatPrice(payOrder.price) }}</div>
            <div class="actions">
              <el-button type="primary" @click="$router.push('/order')">查看订单</el-button>
              <el-button @click="$router.push('/')">返回首页</el-button>
              <el-button v-if="!success" @click="refresh">刷新状态</el-button>
            </div>
          </template>
        </el-result>
      </template>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useRoute } from 'vue-router'
import { PayOrderApi, type PayOrderInfo } from '@/api/pay'
import { formatPrice } from '@/utils/price'

const route = useRoute()
const loading = ref(false)
const payOrder = ref<PayOrderInfo | null>(null)

/** 支付成功状态一般为 10，与芋道 pay 模块约定一致 */
const success = computed(() => payOrder.value?.status === 10)

async function refresh() {
  const id = Number(route.query.id)
  if (!id) return
  loading.value = true
  try {
    const res = await PayOrderApi.getOrder(id, true)
    payOrder.value = res.data
  } finally {
    loading.value = false
  }
}

onMounted(refresh)
</script>

<style scoped lang="scss">
.panel {
  max-width: 560px;
  margin: 40px auto 0;
  background: var(--mall-surface);
  border: 1px solid var(--mall-line);
  border-radius: var(--mall-radius);
  padding: 24px;
}

.amount {
  font-size: 28px;
  margin-bottom: 20px;
}

.actions {
  display: flex;
  gap: 10px;
  justify-content: center;
}
</style>
