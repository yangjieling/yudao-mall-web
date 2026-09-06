import request from '@/utils/request'
import type { PageParam, PageResult } from '@/types/api'

export interface PayWallet {
  balance: number
  totalExpense?: number
  totalRecharge?: number
  freezePrice?: number
}

export interface WalletTransaction {
  id: number
  title?: string
  price: number
  balance?: number
  createTime?: string
}

export interface RechargePackage {
  id: number
  name: string
  payPrice: number
  bonusPrice?: number
}

export const WalletApi = {
  getWallet: () =>
    request<PayWallet>({
      url: '/pay/wallet/get',
      method: 'GET',
      requireAuth: true
    }),

  getTransactionPage: (params: PageParam & { type?: number }) =>
    request<PageResult<WalletTransaction>>({
      url: '/pay/wallet-transaction/page',
      method: 'GET',
      params,
      requireAuth: true
    }),

  getRechargePackageList: () =>
    request<RechargePackage[]>({
      url: '/pay/wallet-recharge-package/list',
      method: 'GET',
      requireAuth: true
    }),

  createRecharge: (data: { packageId?: number; payPrice?: number }) =>
    request<{ id: number; payOrderId: number }>({
      url: '/pay/wallet-recharge/create',
      method: 'POST',
      data,
      requireAuth: true
    })
}
