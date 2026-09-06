import request from '@/utils/request'
import type { PageParam, PageResult } from '@/types/api'

export interface CouponTemplate {
  id: number
  name: string
  description?: string
  discountType?: number
  discountPrice?: number
  discountPercent?: number
  discountLimitPrice?: number
  usePrice?: number
  takeLimitCount?: number
  totalCount?: number
  takeCount?: number
  validityType?: number
  validStartTime?: string
  validEndTime?: string
  fixedStartTerm?: number
  fixedEndTerm?: number
  productScope?: number
  canTake?: boolean
}

export interface Coupon {
  id: number
  name: string
  status: number
  discountType?: number
  discountPrice?: number
  discountPercent?: number
  discountLimitPrice?: number
  usePrice?: number
  validStartTime?: string
  validEndTime?: string
  productScope?: number
}

export const CouponApi = {
  getCouponTemplatePage: (params: PageParam & { canTake?: boolean }) =>
    request<PageResult<CouponTemplate>>({
      url: '/promotion/coupon-template/page',
      method: 'GET',
      params
    }),

  getCouponTemplateList: (params?: { spuId?: number; productScope?: number; count?: number }) =>
    request<CouponTemplate[]>({
      url: '/promotion/coupon-template/list',
      method: 'GET',
      params
    }),

  takeCoupon: (templateId: number) =>
    request<boolean>({
      url: '/promotion/coupon/take',
      method: 'POST',
      data: { templateId },
      requireAuth: true
    }),

  getCouponPage: (params: PageParam & { status?: number }) =>
    request<PageResult<Coupon>>({
      url: '/promotion/coupon/page',
      method: 'GET',
      params,
      requireAuth: true
    }),

  getUnusedCouponCount: () =>
    request<number>({
      url: '/promotion/coupon/get-unused-count',
      method: 'GET',
      requireAuth: true
    })
}

export const COUPON_STATUS_MAP: Record<number, string> = {
  1: '未使用',
  2: '已使用',
  3: '已过期'
}
