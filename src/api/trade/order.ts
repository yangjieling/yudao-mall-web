import request from '@/utils/request'
import type { PageParam, PageResult } from '@/types/api'

export interface OrderItemPayload {
  skuId: number
  count: number
  cartId?: number
}

export interface SettlementReq {
  items: OrderItemPayload[]
  couponId?: number
  addressId?: number
  deliveryType?: number
  remark?: string
  pointStatus?: boolean
}

export interface OrderPrice {
  totalPrice: number
  discountPrice?: number
  deliveryPrice?: number
  couponPrice?: number
  pointPrice?: number
  vipPrice?: number
  payPrice: number
}

export interface SettlementCoupon {
  id: number
  name: string
  usePrice?: number
  validStartTime?: string
  validEndTime?: string
  discountType?: number
  discountPercent?: number
  discountPrice?: number
  discountLimitPrice?: number
  match?: boolean
  mismatchReason?: string
}

export interface SettlementResp {
  type?: number
  items: Array<{
    skuId: number
    spuId?: number
    spuName?: string
    skuName?: string
    picUrl?: string
    count: number
    price: number
    properties?: Array<{ propertyName?: string; valueName?: string }>
  }>
  coupons?: SettlementCoupon[]
  price: OrderPrice
  address?: {
    id: number
    name: string
    mobile: string
    areaName?: string
    detailAddress?: string
  }
  usePoint?: number
  totalPoint?: number
}

export interface TradeOrderItem {
  id: number
  orderId?: number
  spuId?: number
  spuName: string
  skuId?: number
  picUrl?: string
  count: number
  price: number
  payPrice?: number
  afterSaleStatus?: number
  commentStatus?: boolean
  properties?: Array<{ propertyName?: string; valueName?: string }>
}

export interface TradeOrder {
  id: number
  no: string
  status: number
  type?: number
  productCount?: number
  payPrice: number
  totalPrice?: number
  discountPrice?: number
  deliveryPrice?: number
  couponPrice?: number
  pointPrice?: number
  vipPrice?: number
  createTime?: string
  payTime?: string
  payChannelName?: string
  payOrderId?: number
  userRemark?: string
  commentStatus?: boolean
  deliveryType?: number
  logisticsId?: number
  logisticsName?: string
  logisticsNo?: string
  deliveryTime?: string
  receiveTime?: string
  receiverName?: string
  receiverMobile?: string
  receiverAreaName?: string
  receiverDetailAddress?: string
  items?: TradeOrderItem[]
}

export interface CreateOrderResp {
  id: number
  payOrderId?: number
}

export interface ExpressTrack {
  time?: string
  content?: string
}

export interface OrderCount {
  allCount?: number
  unpaidCount?: number
  undeliveredCount?: number
  deliveredCount?: number
  uncommentedCount?: number
  afterSaleCount?: number
}

function buildSettlementQuery(data: SettlementReq): string {
  const data2: Record<string, string> = {}
  if (data.couponId && data.couponId > 0) data2.couponId = String(data.couponId)
  if (data.addressId && data.addressId > 0) data2.addressId = String(data.addressId)
  if (data.deliveryType && data.deliveryType > 0) data2.deliveryType = String(data.deliveryType)
  if (data.remark) data2.remark = data.remark
  if (data.pointStatus != null) data2.pointStatus = String(data.pointStatus)

  data.items.forEach((item, i) => {
    data2[`items[${i}].skuId`] = String(item.skuId)
    data2[`items[${i}].count`] = String(item.count)
    if (item.cartId) {
      data2[`items[${i}].cartId`] = String(item.cartId)
    }
  })

  return Object.keys(data2)
    .map((key) => `${encodeURIComponent(key)}=${encodeURIComponent(data2[key])}`)
    .join('&')
}

export const OrderApi = {
  settlementOrder: (data: SettlementReq) =>
    request<SettlementResp>({
      url: `/trade/order/settlement?${buildSettlementQuery(data)}`,
      method: 'GET',
      requireAuth: true
    }),

  createOrder: (data: SettlementReq & { remark?: string }) =>
    request<CreateOrderResp>({
      url: '/trade/order/create',
      method: 'POST',
      data,
      requireAuth: true
    }),

  getOrderDetail: (id: number, sync?: boolean) =>
    request<TradeOrder>({
      url: '/trade/order/get-detail',
      method: 'GET',
      params: { id, sync },
      requireAuth: true
    }),

  getOrderPage: (params: PageParam & { status?: number; commentStatus?: boolean }) =>
    request<PageResult<TradeOrder>>({
      url: '/trade/order/page',
      method: 'GET',
      params,
      requireAuth: true
    }),

  getOrderCount: () =>
    request<OrderCount>({
      url: '/trade/order/get-count',
      method: 'GET',
      requireAuth: true
    }),

  cancelOrder: (id: number) =>
    request<boolean>({
      url: '/trade/order/cancel',
      method: 'DELETE',
      params: { id },
      requireAuth: true
    }),

  receiveOrder: (id: number) =>
    request<boolean>({
      url: '/trade/order/receive',
      method: 'PUT',
      params: { id },
      requireAuth: true
    }),

  deleteOrder: (id: number) =>
    request<boolean>({
      url: '/trade/order/delete',
      method: 'DELETE',
      params: { id },
      requireAuth: true
    }),

  getExpressTrackList: (id: number) =>
    request<ExpressTrack[]>({
      url: '/trade/order/get-express-track-list',
      method: 'GET',
      params: { id },
      requireAuth: true
    }),

  createOrderItemComment: (data: {
    orderItemId: number
    descriptionScores: number
    benefitScores: number
    content: string
    picUrls?: string[]
    anonymous: boolean
  }) =>
    request<number>({
      url: '/trade/order/item/create-comment',
      method: 'POST',
      data,
      requireAuth: true
    })
}

/** 订单状态文案 */
export const ORDER_STATUS_MAP: Record<number, string> = {
  0: '待支付',
  10: '待发货',
  20: '已发货',
  30: '已完成',
  40: '已取消'
}
