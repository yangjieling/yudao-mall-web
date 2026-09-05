import request from '@/utils/request'

export interface CartItem {
  id: number
  selected: boolean
  count: number
  spu: {
    id: number
    name: string
    picUrl?: string
  }
  sku: {
    id: number
    price: number
    stock?: number
    picUrl?: string
    properties?: Array<{ propertyName?: string; valueName?: string }>
  }
}

export interface CartListResp {
  validList: CartItem[]
  invalidList: CartItem[]
}

export const CartApi = {
  addCart: (data: { skuId: number; count: number }) =>
    request<number>({
      url: '/trade/cart/add',
      method: 'POST',
      data,
      requireAuth: true
    }),

  updateCartCount: (data: { id: number; count: number }) =>
    request<boolean>({
      url: '/trade/cart/update-count',
      method: 'PUT',
      data,
      requireAuth: true
    }),

  updateCartSelected: (data: { ids: number[]; selected: boolean }) =>
    request<boolean>({
      url: '/trade/cart/update-selected',
      method: 'PUT',
      data,
      requireAuth: true
    }),

  deleteCart: (ids: string | number) =>
    request<boolean>({
      url: '/trade/cart/delete',
      method: 'DELETE',
      params: { ids },
      requireAuth: true
    }),

  getCartList: () =>
    request<CartListResp>({
      url: '/trade/cart/list',
      method: 'GET',
      requireAuth: true
    })
}
