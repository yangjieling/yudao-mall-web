import { defineStore } from 'pinia'
import { computed, ref } from 'vue'
import { CartApi, type CartItem } from '@/api/trade/cart'
import { useUserStore } from '@/stores/user'

export const useCartStore = defineStore('cart', () => {
  const validList = ref<CartItem[]>([])
  const invalidList = ref<CartItem[]>([])
  const loading = ref(false)

  const selectedList = computed(() => validList.value.filter((i) => i.selected))
  const totalCount = computed(() => validList.value.reduce((sum, i) => sum + i.count, 0))
  const selectedCount = computed(() => selectedList.value.reduce((sum, i) => sum + i.count, 0))
  const selectedAmount = computed(() =>
    selectedList.value.reduce((sum, i) => sum + i.sku.price * i.count, 0)
  )

  async function getList() {
    const userStore = useUserStore()
    if (!userStore.isLogin) {
      validList.value = []
      invalidList.value = []
      return
    }
    loading.value = true
    try {
      const res = await CartApi.getCartList()
      validList.value = res.data?.validList || []
      invalidList.value = res.data?.invalidList || []
    } finally {
      loading.value = false
    }
  }

  async function add(skuId: number, count = 1) {
    await CartApi.addCart({ skuId, count })
    try {
      await getList()
    } catch {
      // 加购已成功，刷新失败不影响主流程
    }
  }

  async function updateCount(id: number, count: number) {
    await CartApi.updateCartCount({ id, count })
    await getList()
  }

  async function updateSelected(ids: number[], selected: boolean) {
    await CartApi.updateCartSelected({ ids, selected })
    await getList()
  }

  async function remove(ids: number[]) {
    await CartApi.deleteCart(ids.join(','))
    await getList()
  }

  return {
    validList,
    invalidList,
    loading,
    selectedList,
    totalCount,
    selectedCount,
    selectedAmount,
    getList,
    add,
    updateCount,
    updateSelected,
    remove
  }
})
