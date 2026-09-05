const TOKEN_KEY = 'token'
const REFRESH_TOKEN_KEY = 'refresh-token'
const TENANT_KEY = 'tenant-id'

export function getAccessToken(): string {
  return localStorage.getItem(TOKEN_KEY) || ''
}

export function getRefreshToken(): string {
  return localStorage.getItem(REFRESH_TOKEN_KEY) || ''
}

export function setToken(accessToken: string, refreshToken?: string) {
  localStorage.setItem(TOKEN_KEY, accessToken)
  if (refreshToken) {
    localStorage.setItem(REFRESH_TOKEN_KEY, refreshToken)
  }
}

export function clearToken() {
  localStorage.removeItem(TOKEN_KEY)
  localStorage.removeItem(REFRESH_TOKEN_KEY)
}

export function getTenantId(): string {
  return localStorage.getItem(TENANT_KEY) || import.meta.env.VITE_TENANT_ID || '1'
}

export function setTenantId(tenantId: string) {
  localStorage.setItem(TENANT_KEY, tenantId)
}
