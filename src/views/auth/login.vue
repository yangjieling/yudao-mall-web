<template>
  <div class="login-page">
    <div class="login-card">
      <div class="brand">
        <span class="mark">芋</span>
        <h1>{{ title }}</h1>
        <p>登录后可购物、下单与查看订单</p>
      </div>

      <el-tabs v-model="tab">
        <el-tab-pane label="密码登录" name="password">
          <el-form :model="pwdForm" @submit.prevent="onPasswordLogin">
            <el-form-item>
              <el-input v-model="pwdForm.mobile" placeholder="手机号" maxlength="11" />
            </el-form-item>
            <el-form-item>
              <el-input
                v-model="pwdForm.password"
                type="password"
                show-password
                placeholder="密码"
              />
            </el-form-item>
            <el-button type="primary" native-type="submit" class="submit" :loading="loading">
              登录
            </el-button>
          </el-form>
        </el-tab-pane>

        <el-tab-pane label="短信登录" name="sms">
          <el-form :model="smsForm" @submit.prevent="onSmsLogin">
            <el-form-item>
              <el-input v-model="smsForm.mobile" placeholder="手机号" maxlength="11" />
            </el-form-item>
            <el-form-item>
              <div class="sms-row">
                <el-input v-model="smsForm.code" placeholder="验证码" maxlength="6" />
                <el-button :disabled="countdown > 0" @click="sendCode">
                  {{ countdown > 0 ? `${countdown}s` : '获取验证码' }}
                </el-button>
              </div>
            </el-form-item>
            <el-button type="primary" native-type="submit" class="submit" :loading="loading">
              登录
            </el-button>
          </el-form>
        </el-tab-pane>
      </el-tabs>

      <el-button link class="back" @click="$router.push('/')">返回商城</el-button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { AuthApi } from '@/api/member/auth'
import { useUserStore } from '@/stores/user'
import { useCartStore } from '@/stores/cart'

const title = import.meta.env.VITE_APP_TITLE
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
    radial-gradient(circle at 20% 20%, rgba(196, 92, 38, 0.12), transparent 40%),
    radial-gradient(circle at 80% 0%, rgba(143, 61, 24, 0.1), transparent 35%),
    var(--mall-bg);
  padding: 24px;
}

.login-card {
  width: min(100%, 420px);
  background: var(--mall-surface);
  border: 1px solid var(--mall-line);
  border-radius: 16px;
  padding: 32px 28px 24px;
}

.brand {
  text-align: center;
  margin-bottom: 20px;
}

.mark {
  display: inline-grid;
  place-items: center;
  width: 48px;
  height: 48px;
  border-radius: 12px;
  background: var(--mall-accent);
  color: #fff;
  font-size: 22px;
  font-weight: 700;
  margin-bottom: 12px;
}

.brand h1 {
  margin: 0 0 6px;
  font-size: 24px;
}

.brand p {
  margin: 0;
  color: var(--mall-muted);
  font-size: 13px;
}

.submit {
  width: 100%;
}

.sms-row {
  display: flex;
  gap: 8px;
  width: 100%;
}

.back {
  display: block;
  margin: 16px auto 0;
}
</style>
