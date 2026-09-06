import request from '@/utils/request'

export interface MemberUserInfo {
  id: number
  nickname: string
  avatar: string
  mobile: string
  sex?: number
  point?: number
  experience?: number
  level?: { id?: number; name?: string; level?: number; icon?: string }
}

export const UserApi = {
  getUserInfo: () =>
    request<MemberUserInfo>({
      url: '/member/user/get',
      method: 'GET',
      requireAuth: true
    }),

  updateUser: (data: { nickname?: string; avatar?: string; sex?: number }) =>
    request<boolean>({
      url: '/member/user/update',
      method: 'PUT',
      data,
      requireAuth: true
    }),

  updatePassword: (data: { password: string; code: string }) =>
    request<boolean>({
      url: '/member/user/update-password',
      method: 'PUT',
      data,
      requireAuth: true
    }),

  updateMobile: (data: { mobile: string; code: string; oldCode?: string }) =>
    request<boolean>({
      url: '/member/user/update-mobile',
      method: 'PUT',
      data,
      requireAuth: true
    }),

  resetPassword: (data: { mobile: string; code: string; password: string }) =>
    request<boolean>({
      url: '/member/user/reset-password',
      method: 'PUT',
      data
    })
}
