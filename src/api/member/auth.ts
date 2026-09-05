import request from '@/utils/request'

export interface AuthLoginReq {
  mobile: string
  password: string
}

export interface AuthSmsLoginReq {
  mobile: string
  code: string
}

export interface AuthLoginResp {
  accessToken: string
  refreshToken: string
  expiresTime?: number
  userId?: number
}

/** 会员登录相关 */
export const AuthApi = {
  login: (data: AuthLoginReq) =>
    request<AuthLoginResp>({
      url: '/member/auth/login',
      method: 'POST',
      data
    }),

  smsLogin: (data: AuthSmsLoginReq) =>
    request<AuthLoginResp>({
      url: '/member/auth/sms-login',
      method: 'POST',
      data
    }),

  /** scene: 1 = 会员手机号登录 */
  sendSmsCode: (mobile: string, scene = 1) =>
    request<boolean>({
      url: '/member/auth/send-sms-code',
      method: 'POST',
      data: { mobile, scene }
    }),

  logout: () =>
    request<boolean>({
      url: '/member/auth/logout',
      method: 'POST'
    }),

  refreshToken: (refreshToken: string) =>
    request<AuthLoginResp>({
      url: '/member/auth/refresh-token',
      method: 'POST',
      params: { refreshToken },
      showError: false
    })
}
