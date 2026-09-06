import request from '@/utils/request'
import type { PageParam, PageResult } from '@/types/api'

export interface AfterSale {
  id: number
  no?: string
  status: number
  way?: number
  type?: number
  applyReason?: string
  applyDescription?: string
  applyPicUrls?: string[]
  refundPrice?: number
  orderId?: number
  orderNo?: string
  orderItemId?: number
  spuId?: number
  spuName?: string
  skuId?: number
  picUrl?: string
  count?: number
  properties?: Array<{ propertyName?: string; valueName?: string }>
  createTime?: string
  auditReason?: string
  logisticsId?: number
  logisticsNo?: string
}

export interface AfterSaleLog {
  id?: number
  content?: string
  createTime?: string
  userType?: number
}

export const AfterSaleApi = {
  getAfterSalePage: (params: PageParam & { status?: number }) =>
    request<PageResult<AfterSale>>({
      url: '/trade/after-sale/page',
      method: 'GET',
      params,
      requireAuth: true
    }),

  getAfterSale: (id: number) =>
    request<AfterSale>({
      url: '/trade/after-sale/get',
      method: 'GET',
      params: { id },
      requireAuth: true
    }),

  createAfterSale: (data: {
    orderItemId: number
    way: number
    refundPrice: number
    applyReason: string
    applyDescription?: string
    applyPicUrls?: string[]
  }) =>
    request<number>({
      url: '/trade/after-sale/create',
      method: 'POST',
      data,
      requireAuth: true
    }),

  cancelAfterSale: (id: number) =>
    request<boolean>({
      url: '/trade/after-sale/cancel',
      method: 'DELETE',
      params: { id },
      requireAuth: true
    }),

  deliveryAfterSale: (data: { id: number; logisticsId: number; logisticsNo: string }) =>
    request<boolean>({
      url: '/trade/after-sale/delivery',
      method: 'PUT',
      data,
      requireAuth: true
    }),

  getAfterSaleLogList: (afterSaleId: number) =>
    request<AfterSaleLog[]>({
      url: '/trade/after-sale-log/list',
      method: 'GET',
      params: { afterSaleId },
      requireAuth: true
    })
}

export const AFTER_SALE_STATUS_MAP: Record<number, string> = {
  10: '申请中',
  20: '商品待退货',
  30: '商家待收货',
  40: '等待退款',
  50: '退款成功',
  61: '买家取消',
  62: '商家拒绝',
  63: '商家拒收货'
}

export const AFTER_SALE_WAY_MAP: Record<number, string> = {
  10: '仅退款',
  20: '退货退款'
}
