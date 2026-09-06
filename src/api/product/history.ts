import request from '@/utils/request'
import type { PageParam, PageResult } from '@/types/api'
import type { ProductSpu } from '@/api/product'

export interface BrowseHistoryItem {
  id: number
  spuId: number
  spu?: ProductSpu
  createTime?: string
}

export const HistoryApi = {
  getBrowseHistoryPage: (params: PageParam) =>
    request<PageResult<BrowseHistoryItem>>({
      url: '/product/browse-history/page',
      method: 'GET',
      params,
      requireAuth: true
    }),

  deleteBrowseHistory: (spuIds: number[]) =>
    request<boolean>({
      url: '/product/browse-history/delete',
      method: 'DELETE',
      data: { spuIds },
      requireAuth: true
    }),

  cleanBrowseHistory: () =>
    request<boolean>({
      url: '/product/browse-history/clean',
      method: 'DELETE',
      requireAuth: true
    })
}
