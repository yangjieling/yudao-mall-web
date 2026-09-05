import request from '@/utils/request'

export interface MemberAddress {
  id: number
  name: string
  mobile: string
  areaId: number
  detailAddress: string
  defaultStatus: boolean
  areaName?: string
}

export const AddressApi = {
  getAddressList: () =>
    request<MemberAddress[]>({
      url: '/member/address/list',
      method: 'GET',
      requireAuth: true
    }),

  getAddress: (id: number) =>
    request<MemberAddress>({
      url: '/member/address/get',
      method: 'GET',
      params: { id },
      requireAuth: true
    }),

  createAddress: (data: Partial<MemberAddress>) =>
    request<number>({
      url: '/member/address/create',
      method: 'POST',
      data,
      requireAuth: true
    }),

  updateAddress: (data: Partial<MemberAddress>) =>
    request<boolean>({
      url: '/member/address/update',
      method: 'PUT',
      data,
      requireAuth: true
    }),

  deleteAddress: (id: number) =>
    request<boolean>({
      url: '/member/address/delete',
      method: 'DELETE',
      params: { id },
      requireAuth: true
    })
}
