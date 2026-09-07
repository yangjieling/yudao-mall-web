import request from '@/utils/request'
import type { PageParam, PageResult } from '@/types/api'

/** 与 AppProductBrowseHistoryRespVO 对齐：商品字段为扁平结构 */
export interface BrowseHistoryItem {
  id: number
  spuId: number
  spuName?: string
  picUrl?: string
  price?: number
  salesCount?: number
  stock?: number
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
