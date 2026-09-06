import request from '@/utils/request'
import type { PageParam, PageResult } from '@/types/api'
import type { ProductSpu } from '@/api/product'

export interface FavoriteItem {
  id: number
  spuId: number
  spu?: ProductSpu
  createTime?: string
}

export const FavoriteApi = {
  getFavoritePage: (params: PageParam) =>
    request<PageResult<FavoriteItem>>({
      url: '/product/favorite/page',
      method: 'GET',
      params,
      requireAuth: true
    }),

  isFavoriteExists: (spuId: number) =>
    request<boolean>({
      url: '/product/favorite/exits',
      method: 'GET',
      params: { spuId },
      requireAuth: true,
      showError: false
    }),

  createFavorite: (spuId: number) =>
    request<number>({
      url: '/product/favorite/create',
      method: 'POST',
      data: { spuId },
      requireAuth: true
    }),

  deleteFavorite: (spuId: number) =>
    request<boolean>({
      url: '/product/favorite/delete',
      method: 'DELETE',
      data: { spuId },
      requireAuth: true
    })
}
