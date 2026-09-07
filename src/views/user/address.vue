<template>
  <div class="address-page" v-loading="loading">
    <div class="head">
      <h1>收货地址</h1>
      <el-button type="primary" @click="openDialog()">新增地址</el-button>
    </div>

    <el-empty v-if="!list.length" description="暂无收货地址" :image-size="80">
      <el-button type="primary" @click="openDialog()">添加地址</el-button>
    </el-empty>

    <div v-for="item in list" :key="item.id" class="addr-card" :class="{ default: item.defaultStatus }">
      <div class="main">
        <div class="top">
          <strong>{{ item.name }}</strong>
          <span class="mobile">{{ item.mobile }}</span>
          <span v-if="item.defaultStatus" class="default-tag">默认</span>
        </div>
        <div class="detail">{{ item.areaName }} {{ item.detailAddress }}</div>
      </div>
      <div class="ops">
        <button type="button" class="link" @click="openDialog(item)">编辑</button>
        <button type="button" class="link danger" @click="remove(item.id)">删除</button>
      </div>
    </div>

    <el-dialog v-model="visible" :title="editingId ? '编辑地址' : '新增地址'" width="480px" destroy-on-close>
      <el-form label-width="80px">
        <el-form-item label="收货人" required>
          <el-input v-model="form.name" maxlength="20" />
        </el-form-item>
        <el-form-item label="手机号" required>
          <el-input v-model="form.mobile" maxlength="11" />
        </el-form-item>
        <el-form-item label="所在地区" required>
          <el-cascader
            v-model="form.areaPath"
            :options="areaOptions"
            :props="{ value: 'id', label: 'name', children: 'children' }"
            clearable
            filterable
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="详细地址" required>
          <el-input v-model="form.detailAddress" type="textarea" :rows="2" maxlength="100" />
        </el-form-item>
        <el-form-item label="默认地址">
          <el-switch v-model="form.defaultStatus" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="visible = false">取消</el-button>
        <el-button type="primary" :loading="saving" @click="save">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { onMounted, reactive, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { AddressApi, type MemberAddress } from '@/api/member/address'
import { AreaApi, type AreaNode } from '@/api/system/area'

const loading = ref(false)
const list = ref<MemberAddress[]>([])
const visible = ref(false)
const saving = ref(false)
const editingId = ref<number>()
const areaOptions = ref<AreaNode[]>([])

const form = reactive({
  name: '',
  mobile: '',
  areaPath: [] as number[],
  detailAddress: '',
  defaultStatus: false
})

function findPath(nodes: AreaNode[], targetId: number, path: number[] = []): number[] | null {
  for (const n of nodes) {
    const next = [...path, n.id]
    if (n.id === targetId) return next
    if (n.children?.length) {
      const found = findPath(n.children, targetId, next)
      if (found) return found
    }
  }
  return null
}

async function load() {
  loading.value = true
  try {
    const res = await AddressApi.getAddressList()
    list.value = res.data || []
  } finally {
    loading.value = false
  }
}

async function ensureAreas() {
  if (areaOptions.value.length) return
  const res = await AreaApi.getAreaTree()
  areaOptions.value = res.data || []
}

async function openDialog(item?: MemberAddress) {
  await ensureAreas()
  editingId.value = item?.id
  form.name = item?.name || ''
  form.mobile = item?.mobile || ''
  form.detailAddress = item?.detailAddress || ''
  form.defaultStatus = item?.defaultStatus ?? list.value.length === 0
  form.areaPath = item?.areaId ? findPath(areaOptions.value, item.areaId) || [] : []
  visible.value = true
}

async function save() {
  const areaId = form.areaPath[form.areaPath.length - 1]
  if (!form.name || !form.mobile || !areaId || !form.detailAddress) {
    ElMessage.warning('请完整填写收货信息')
    return
  }
  saving.value = true
  try {
    const payload = {
      name: form.name,
      mobile: form.mobile,
      areaId,
      detailAddress: form.detailAddress,
      defaultStatus: form.defaultStatus
    }
    if (editingId.value) {
      await AddressApi.updateAddress({ id: editingId.value, ...payload })
    } else {
      await AddressApi.createAddress(payload)
    }
    ElMessage.success('已保存')
    visible.value = false
    await load()
  } finally {
    saving.value = false
  }
}

async function remove(id: number) {
  await ElMessageBox.confirm('确认删除该地址？', '提示')
  await AddressApi.deleteAddress(id)
  ElMessage.success('已删除')
  load()
}

onMounted(load)
</script>

<style scoped lang="scss">
.head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  gap: 12px;
}

h1 {
  margin: 0;
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

.addr-card {
  display: flex;
  justify-content: space-between;
  gap: 16px;
  background: var(--mall-surface);
  border-radius: var(--mall-radius);
  padding: 18px 20px;
  margin-bottom: 12px;
  box-shadow: 0 1px 2px rgba(15, 23, 42, 0.04);
  border: 1px solid transparent;
}

.addr-card.default {
  border-color: var(--mall-accent-border);
  background: linear-gradient(90deg, #fffafa 0%, #fff 60%);
}

.top {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 8px 10px;
}

.top strong {
  font-size: 15px;
}

.mobile {
  color: var(--mall-muted);
  font-size: 14px;
}

.default-tag {
  padding: 1px 8px;
  border-radius: 999px;
  background: var(--mall-accent);
  color: #fff;
  font-size: 12px;
  line-height: 18px;
  font-weight: 600;
}

.detail {
  margin-top: 8px;
  color: var(--mall-muted);
  font-size: 13px;
  line-height: 1.5;
}

.ops {
  flex-shrink: 0;
  display: flex;
  align-items: flex-start;
  gap: 12px;
}

.link {
  border: 0;
  background: transparent;
  color: var(--mall-accent);
  cursor: pointer;
  font-size: 13px;
  padding: 0;
}

.link:hover {
  color: var(--mall-accent-dark);
}

.link.danger {
  color: var(--mall-muted);
}

.link.danger:hover {
  color: var(--mall-accent);
}

@media (max-width: 640px) {
  .addr-card {
    flex-direction: column;
  }
}
</style>
