import { defineStore } from 'pinia'
import { computed, ref } from 'vue'
import { AuthApi } from '@/api/member/auth'
import { UserApi, type MemberUserInfo } from '@/api/member/user'
import { clearToken, getAccessToken, setToken } from '@/utils/auth'

export const useUserStore = defineStore('user', () => {
  const token = ref(getAccessToken())
  const userInfo = ref<MemberUserInfo | null>(null)

  const isLogin = computed(() => !!token.value)

  function syncToken(accessToken: string, refreshToken?: string) {
    setToken(accessToken, refreshToken)
    token.value = accessToken
  }

  async function fetchUserInfo() {
    if (!token.value) {
      userInfo.value = null
      return
    }
    const res = await UserApi.getUserInfo()
    userInfo.value = res.data
  }

  async function loginByPassword(mobile: string, password: string) {
    const res = await AuthApi.login({ mobile, password })
    syncToken(res.data.accessToken, res.data.refreshToken)
    await fetchUserInfo()
  }

  async function loginBySms(mobile: string, code: string) {
    const res = await AuthApi.smsLogin({ mobile, code })
    syncToken(res.data.accessToken, res.data.refreshToken)
    await fetchUserInfo()
  }

  async function logout() {
    try {
      if (token.value) {
        await AuthApi.logout()
      }
    } catch {
      // ignore
    } finally {
      clearToken()
      token.value = ''
      userInfo.value = null
    }
  }

  function initFromStorage() {
    token.value = getAccessToken()
    if (token.value) {
      fetchUserInfo().catch(() => {
        clearToken()
        token.value = ''
      })
    }
  }

  return {
    token,
    userInfo,
    isLogin,
    loginByPassword,
    loginBySms,
    logout,
    fetchUserInfo,
    initFromStorage
  }
})
