import request from '@/utils/request'

export interface MemberUserInfo {
  id: number
  nickname: string
  avatar: string
  mobile: string
  sex?: number
  point?: number
  experience?: number
}

export const UserApi = {
  getUserInfo: () =>
    request<MemberUserInfo>({
      url: '/member/user/get',
      method: 'GET',
      requireAuth: true
    })
}
