<template>
  <div class="profile-page" v-loading="loading">
    <h1>账号资料</h1>

    <div class="panel">
      <h2>基本信息</h2>
      <el-form label-width="90px" class="form">
        <el-form-item label="头像">
          <el-upload class="avatar-upload" :show-file-list="false" :http-request="uploadAvatar" accept="image/*">
            <el-avatar :size="72" :src="form.avatar" class="avatar">
              {{ (form.nickname || '会').slice(0, 1) }}
            </el-avatar>
            <span class="upload-tip">点击更换头像</span>
          </el-upload>
        </el-form-item>
        <el-form-item label="昵称">
          <el-input v-model="form.nickname" maxlength="30" placeholder="请输入昵称" />
        </el-form-item>
        <el-form-item label="性别">
          <el-radio-group v-model="form.sex">
            <el-radio :value="1">男</el-radio>
            <el-radio :value="2">女</el-radio>
            <el-radio :value="0">保密</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :loading="saving" @click="saveProfile">保存资料</el-button>
        </el-form-item>
      </el-form>
    </div>

    <div class="panel">
      <h2>修改密码</h2>
      <el-form label-width="90px" class="form">
        <el-form-item label="手机号">
          <el-input :model-value="userStore.userInfo?.mobile" disabled />
        </el-form-item>
        <el-form-item label="验证码">
          <div class="code-row">
            <el-input v-model="pwdForm.code" maxlength="6" placeholder="短信验证码" />
            <el-button :disabled="countdown > 0" @click="sendCode">
              {{ countdown > 0 ? `${countdown}s` : '获取验证码' }}
            </el-button>
          </div>
        </el-form-item>
        <el-form-item label="新密码">
          <el-input
            v-model="pwdForm.password"
            type="password"
            show-password
            maxlength="20"
            placeholder="请输入新密码"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :loading="pwdSaving" @click="savePassword">更新密码</el-button>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { onMounted, onUnmounted, reactive, ref } from 'vue'
import { ElMessage, type UploadRequestOptions } from 'element-plus'
import { AuthApi } from '@/api/member/auth'
import { UserApi } from '@/api/member/user'
import { FileApi } from '@/api/infra/file'
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()
const loading = ref(false)
const saving = ref(false)
const pwdSaving = ref(false)
const countdown = ref(0)
let timer: number | undefined

const form = reactive({
  nickname: '',
  avatar: '',
  sex: 0
})

const pwdForm = reactive({
  code: '',
  password: ''
})

onMounted(async () => {
  loading.value = true
  try {
    await userStore.fetchUserInfo()
    form.nickname = userStore.userInfo?.nickname || ''
    form.avatar = userStore.userInfo?.avatar || ''
    form.sex = userStore.userInfo?.sex ?? 0
  } finally {
    loading.value = false
  }
})

onUnmounted(() => {
  if (timer) clearInterval(timer)
})

async function uploadAvatar(options: UploadRequestOptions) {
  const res = await FileApi.upload(options.file as File, 'avatar')
  form.avatar = res.data
  ElMessage.success('头像已上传，请点击保存')
}

async function saveProfile() {
  saving.value = true
  try {
    await UserApi.updateUser({
      nickname: form.nickname,
      avatar: form.avatar,
      sex: form.sex
    })
    await userStore.fetchUserInfo()
    ElMessage.success('资料已保存')
  } finally {
    saving.value = false
  }
}

async function sendCode() {
  const mobile = userStore.userInfo?.mobile
  if (!mobile) return
  await AuthApi.sendSmsCode(mobile, 3)
  ElMessage.success('验证码已发送')
  countdown.value = 60
  timer = window.setInterval(() => {
    countdown.value -= 1
    if (countdown.value <= 0 && timer) clearInterval(timer)
  }, 1000)
}

async function savePassword() {
  if (!pwdForm.code || !pwdForm.password) {
    ElMessage.warning('请填写验证码和新密码')
    return
  }
  pwdSaving.value = true
  try {
    await UserApi.updatePassword({
      code: pwdForm.code,
      password: pwdForm.password
    })
    ElMessage.success('密码已更新')
    pwdForm.code = ''
    pwdForm.password = ''
  } finally {
    pwdSaving.value = false
  }
}
</script>

<style scoped lang="scss">
h1 {
  margin: 0 0 16px;
  font-size: 22px;
  display: flex;
  align-items: center;
  gap: 8px;
}

h1::before {
  content: '';
  width: 4px;
  height: 18px;
  border-radius: 2px;
  background: var(--mall-accent);
}

.panel {
  background: var(--mall-surface);
  border-radius: var(--mall-radius);
  padding: 22px 24px;
  margin-bottom: 14px;
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
}

h2 {
  margin: 0 0 18px;
  font-size: 16px;
  display: flex;
  align-items: center;
  gap: 8px;
}

h2::before {
  content: '';
  width: 3px;
  height: 14px;
  border-radius: 2px;
  background: var(--mall-accent);
}

.form {
  max-width: 480px;
}

.avatar-upload {
  display: inline-flex;
  align-items: center;
  gap: 14px;
  cursor: pointer;
}

.avatar {
  border: 2px solid #fff;
  box-shadow: 0 0 0 2px var(--mall-accent-border);
  background: var(--mall-accent-soft);
  color: var(--mall-accent);
  font-weight: 700;
}

.upload-tip {
  font-size: 13px;
  color: var(--mall-muted);
}

.avatar-upload:hover .upload-tip {
  color: var(--mall-accent);
}

.code-row {
  display: flex;
  gap: 8px;
  width: 100%;
}
</style>
