import request from '@/utils/request'

export interface PayOrderInfo {
  id: number
  appId?: number
  status: number
  price: number
  channelCode?: string
  merchantOrderId?: string
  expireTime?: string
}

export const PayOrderApi = {
  getOrder: (id?: number, sync?: boolean, no?: string) => {
    const params: Record<string, unknown> = {}
    if (id) params.id = id
    if (no) params.no = no
    if (sync !== undefined) params.sync = sync
    return request<PayOrderInfo>({
      url: '/pay/order/get',
      method: 'GET',
      params,
      requireAuth: true
    })
  },

  submitOrder: (data: { id: number; channelCode: string; channelExtras?: Record<string, unknown>; returnUrl?: string }) =>
    request<{ displayContent?: string; status?: number }>({
      url: '/pay/order/submit',
      method: 'POST',
      data,
      requireAuth: true
    })
}

export const PayChannelApi = {
  getEnableChannelCodeList: (appId: number) =>
    request<string[]>({
      url: '/pay/channel/get-enable-code-list',
      method: 'GET',
      params: { appId },
      requireAuth: true
    })
}
