import request from '@/utils/request'
import type { PageParam, PageResult } from '@/types/api'

export interface ProductCategory {
  id: number
  parentId: number
  name: string
  picUrl?: string
  status?: number
}

export interface ProductSku {
  id: number
  spuId?: number
  properties?: Array<{ propertyId?: number; propertyName?: string; valueId?: number; valueName?: string }>
  price: number
  marketPrice?: number
  stock: number
  picUrl?: string
}

export interface ProductSpu {
  id: number
  name: string
  introduction?: string
  description?: string
  categoryId?: number
  picUrl: string
  sliderPicUrls?: string[]
  unit?: number
  price: number
  marketPrice?: number
  stock?: number
  salesCount?: number
  skus?: ProductSku[]
}

export interface ProductComment {
  id: number
  userNickname?: string
  userAvatar?: string
  content: string
  scores: number
  picUrls?: string[]
  createTime?: string
}

export const CategoryApi = {
  getCategoryList: () =>
    request<ProductCategory[]>({
      url: '/product/category/list',
      method: 'GET'
    })
}

export const SpuApi = {
  getSpuPage: (params: PageParam & { categoryId?: number; keyword?: string; sortField?: string; sortAsc?: boolean }) =>
    request<PageResult<ProductSpu>>({
      url: '/product/spu/page',
      method: 'GET',
      params
    }),

  getSpuDetail: (id: number) =>
    request<ProductSpu>({
      url: '/product/spu/get-detail',
      method: 'GET',
      params: { id }
    })
}

export const CommentApi = {
  /** type: 0 全部、1 好评、2 中评、3 差评（后端必填） */
  getCommentPage: (spuId: number, pageNo = 1, pageSize = 10, type = 0) =>
    request<PageResult<ProductComment>>({
      url: '/product/comment/page',
      method: 'GET',
      params: { spuId, pageNo, pageSize, type }
    })
}
