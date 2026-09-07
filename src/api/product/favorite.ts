import request from '@/utils/request'
import type { PageParam, PageResult } from '@/types/api'

/** 与 AppFavoriteRespVO 对齐：商品字段为扁平结构 */
export interface FavoriteItem {
  id: number
  spuId: number
  spuName?: string
  picUrl?: string
  price?: number
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
