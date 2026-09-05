import axios, {
  type AxiosInstance,
  type AxiosRequestConfig,
  type InternalAxiosRequestConfig
} from 'axios'
import { ElMessage } from 'element-plus'
import type { ApiResult } from '@/types/api'
import {
  clearToken,
  getAccessToken,
  getRefreshToken,
  getTenantId,
  setToken
} from '@/utils/auth'
import router from '@/router'

type RequestConfig = AxiosRequestConfig & {
  /** 是否需要登录（勿用 auth，会与 Axios Basic Auth 冲突） */
  requireAuth?: boolean
  /** 是否携带 token，默认 true */
  isToken?: boolean
  /** 是否展示错误 toast，默认 true */
  showError?: boolean
}

const service: AxiosInstance = axios.create({
  baseURL: import.meta.env.VITE_API_PATH || '/app-api',
  timeout: 15000,
  headers: {
    'Content-Type': 'application/json;charset=UTF-8',
    Accept: '*/*',
    platform: 'PC'
  }
})

service.interceptors.request.use((config: InternalAxiosRequestConfig) => {
  const custom = (config as RequestConfig) || {}
  if (custom.requireAuth && !getAccessToken()) {
    router.push({ path: '/login', query: { redirect: router.currentRoute.value.fullPath } })
    return Promise.reject(new Error('请先登录'))
  }

  const isToken = custom.isToken !== false
  const token = isToken ? getAccessToken() : ''
  if (token) {
    config.headers.Authorization = token
  }
  config.headers.terminal = import.meta.env.VITE_TERMINAL || '20'
  config.headers['tenant-id'] = getTenantId()
  config.headers.platform = 'PC'
  return config
})

let isRefreshToken = false
let requestList: Array<() => void> = []

async function refreshTokenAndRetry(config: InternalAxiosRequestConfig) {
  if (config.url?.includes('/member/auth/refresh-token')) {
    return Promise.reject(new Error('刷新令牌失败'))
  }

  if (!isRefreshToken) {
    isRefreshToken = true
    const refreshToken = getRefreshToken()
    if (!refreshToken) {
      return handleAuthorized()
    }
    try {
      const res = await axios.post<ApiResult<{ accessToken: string; refreshToken: string }>>(
        `${import.meta.env.VITE_API_PATH || '/app-api'}/member/auth/refresh-token`,
        null,
        {
          params: { refreshToken },
          headers: {
            'tenant-id': getTenantId(),
            terminal: import.meta.env.VITE_TERMINAL || '20',
            platform: 'PC'
          }
        }
      )
      if (res.data.code !== 0) {
        throw new Error(res.data.msg || '刷新令牌失败')
      }
      setToken(res.data.data.accessToken, res.data.data.refreshToken)
      requestList.forEach((cb) => cb())
      requestList = []
      config.headers.Authorization = getAccessToken()
      return service.request(config)
    } catch {
      requestList.forEach((cb) => cb())
      requestList = []
      return handleAuthorized()
    } finally {
      isRefreshToken = false
    }
  }

  return new Promise((resolve) => {
    requestList.push(() => {
      config.headers.Authorization = getAccessToken()
      resolve(service.request(config))
    })
  })
}

function handleAuthorized() {
  clearToken()
  const current = router.currentRoute.value.fullPath
  if (!current.startsWith('/login')) {
    router.push({ path: '/login', query: { redirect: current } })
  }
  return Promise.reject({ code: 401, msg: '请先登录' })
}

service.interceptors.response.use(
  async (response) => {
    const config = response.config as RequestConfig
    const res = response.data as ApiResult

    if (
      response.config.url?.includes('/member/auth/') &&
      res?.data &&
      typeof res.data === 'object' &&
      'accessToken' in (res.data as object)
    ) {
      const data = res.data as { accessToken: string; refreshToken: string }
      setToken(data.accessToken, data.refreshToken)
    }

    if (res.code === 401) {
      return refreshTokenAndRetry(response.config)
    }

    if (res.code !== 0) {
      if (config.showError !== false) {
        ElMessage.error(res.msg || '请求失败')
      }
      return Promise.reject(res)
    }

    return res as any
  },
  (error) => {
    const config = error.config as RequestConfig | undefined
    if (config?.showError !== false) {
      ElMessage.error(error.message || '网络异常')
    }
    return Promise.reject(error)
  }
)

export function request<T = unknown>(config: RequestConfig): Promise<ApiResult<T>> {
  return service.request(config) as Promise<ApiResult<T>>
}

export default request
