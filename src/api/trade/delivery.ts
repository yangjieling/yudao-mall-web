import request from '@/utils/request'

export interface ExpressCompany {
  id: number
  code?: string
  name: string
}

export const DeliveryApi = {
  getExpressList: () =>
    request<ExpressCompany[]>({
      url: '/trade/delivery/express/list',
      method: 'GET'
    })
}
