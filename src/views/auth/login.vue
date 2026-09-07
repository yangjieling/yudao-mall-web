<template>
  <div class="login-page">
    <div class="login-card">
      <div class="brand">
        <span class="mark">{{ brandMark }}</span>
        <h1>SHOP</h1>
        <p>登录后可购物、下单与查看订单</p>
      </div>

      <el-tabs v-model="tab" class="login-tabs">
        <el-tab-pane label="密码登录" name="password">
          <el-form :model="pwdForm" @submit.prevent="onPasswordLogin">
            <el-form-item>
              <el-input v-model="pwdForm.mobile" placeholder="手机号" maxlength="11" size="large" />
            </el-form-item>
            <el-form-item>
              <el-input
                v-model="pwdForm.password"
                type="password"
                show-password
                placeholder="密码"
                size="large"
              />
            </el-form-item>
            <el-button type="primary" native-type="submit" class="submit" size="large" :loading="loading">
              登录
            </el-button>
          </el-form>
        </el-tab-pane>

        <el-tab-pane label="短信登录" name="sms">
          <el-form :model="smsForm" @submit.prevent="onSmsLogin">
            <el-form-item>
              <el-input v-model="smsForm.mobile" placeholder="手机号" maxlength="11" size="large" />
            </el-form-item>
            <el-form-item>
              <div class="sms-row">
                <el-input v-model="smsForm.code" placeholder="验证码" maxlength="6" size="large" />
                <el-button size="large" :disabled="countdown > 0" @click="sendCode">
                  {{ countdown > 0 ? `${countdown}s` : '获取验证码' }}
                </el-button>
              </div>
            </el-form-item>
            <el-button type="primary" native-type="submit" class="submit" size="large" :loading="loading">
              登录
            </el-button>
          </el-form>
        </el-tab-pane>
      </el-tabs>

      <el-button link class="back" @click="$router.push('/')">返回 OM Shop</el-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { AuthApi } from '@/api/member/auth'
import { useUserStore } from '@/stores/user'
import { useCartStore } from '@/stores/cart'

const title = import.meta.env.VITE_APP_TITLE
const brandMark = computed(() => {
  const t = (title || 'OM').trim()
  if (/^OM\b/i.test(t)) return 'OM'
  return t.slice(0, 1) || 'O'
})
const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const cartStore = useCartStore()

const tab = ref('password')
const loading = ref(false)
const countdown = ref(0)
let timer: number | undefined

const pwdForm = reactive({ mobile: '', password: '' })
const smsForm = reactive({ mobile: '', code: '' })

function afterLogin() {
  ElMessage.success('登录成功')
  cartStore.getList()
  const redirect = (route.query.redirect as string) || '/'
  router.replace(redirect)
}

async function onPasswordLogin() {
  if (!pwdForm.mobile || !pwdForm.password) {
    ElMessage.warning('请输入手机号和密码')
    return
  }
  loading.value = true
  try {
    await userStore.loginByPassword(pwdForm.mobile, pwdForm.password)
    afterLogin()
  } finally {
    loading.value = false
  }
}

async function sendCode() {
  if (!smsForm.mobile) {
    ElMessage.warning('请输入手机号')
    return
  }
  await AuthApi.sendSmsCode(smsForm.mobile, 1)
  ElMessage.success('验证码已发送')
  countdown.value = 60
  timer = window.setInterval(() => {
    countdown.value -= 1
    if (countdown.value <= 0 && timer) {
      clearInterval(timer)
      timer = undefined
    }
  }, 1000)
}

async function onSmsLogin() {
  if (!smsForm.mobile || !smsForm.code) {
    ElMessage.warning('请输入手机号和验证码')
    return
  }
  loading.value = true
  try {
    await userStore.loginBySms(smsForm.mobile, smsForm.code)
    afterLogin()
  } finally {
    loading.value = false
  }
}
</script>

<style scoped lang="scss">
.login-page {
  min-height: 100vh;
  display: grid;
  place-items: center;
  background:
    radial-gradient(circle at 18% 18%, rgba(239, 68, 68, 0.14), transparent 42%),
    radial-gradient(circle at 82% 8%, rgba(248, 113, 113, 0.12), transparent 36%),
    var(--mall-bg);
  padding: 24px;
}

.login-card {
  width: min(100%, 420px);
  background: var(--mall-surface);
  border-radius: 16px;
  padding: 32px 28px 24px;
  box-shadow: 0 8px 28px rgba(15, 23, 42, 0.06);
}

.brand {
  text-align: center;
  margin-bottom: 20px;
}

.mark {
  display: inline-grid;
  place-items: center;
  width: 52px;
  height: 52px;
  border-radius: 12px;
  background: var(--mall-accent);
  color: #fff;
  font-size: 16px;
  font-weight: 700;
  letter-spacing: 0.02em;
  margin-bottom: 12px;
}

.brand h1 {
  margin: 0 0 6px;
  font-size: 26px;
  font-weight: 800;
  color: var(--mall-accent);
}

.brand p {
  margin: 0;
  color: var(--mall-muted);
  font-size: 13px;
}

.login-tabs :deep(.el-tabs__item.is-active) {
  color: var(--mall-accent);
}

.login-tabs :deep(.el-tabs__active-bar) {
  background: var(--mall-accent);
}

.submit {
  width: 100%;
  margin-top: 4px;
}

.sms-row {
  display: flex;
  gap: 8px;
  width: 100%;
}

.back {
  display: block;
  margin: 16px auto 0;
  color: var(--mall-muted);
}

.back:hover {
  color: var(--mall-accent);
}
</style>
