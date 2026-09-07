import iconAlipayApp from '@/assets/pay/alipay_app.svg'
import iconAlipayBar from '@/assets/pay/alipay_bar.svg'
import iconAlipayPc from '@/assets/pay/alipay_pc.svg'
import iconAlipayQr from '@/assets/pay/alipay_qr.svg'
import iconAlipayWap from '@/assets/pay/alipay_wap.svg'
import iconMock from '@/assets/pay/mock.svg'
import iconWallet from '@/assets/pay/wallet.svg'
import iconWxApp from '@/assets/pay/wx_app.svg'
import iconWxBar from '@/assets/pay/wx_bar.svg'
import iconWxLite from '@/assets/pay/wx_lite.svg'
import iconWxNative from '@/assets/pay/wx_native.svg'
import iconWxPub from '@/assets/pay/wx_pub.svg'

/** PC 端可用的支付渠道 */
export const PC_PAY_CHANNELS = ['wallet', 'mock', 'wx_native', 'alipay_pc', 'alipay_qr'] as const

/** 与后端 PayChannelEnum 对齐的展示名 */
export const PAY_CHANNEL_LABELS: Record<string, string> = {
  wallet: '钱包余额',
  mock: '模拟支付',
  wx_pub: '微信公众号',
  wx_lite: '微信小程序',
  wx_app: '微信 App',
  wx_native: '微信扫码',
  wx_wap: '微信 H5',
  wx_bar: '微信付款码',
  alipay_pc: '支付宝电脑网站',
  alipay_wap: '支付宝手机网站',
  alipay_app: '支付宝 App',
  alipay_qr: '支付宝扫码',
  alipay_bar: '支付宝条码',
  alipay_lite: '支付宝小程序'
}

/** 渠道图标：库表无 icon 字段，前端按 code 映射（素材与管理端收银台一致） */
const PAY_CHANNEL_ICONS: Record<string, string> = {
  wallet: iconWallet,
  mock: iconMock,
  wx_pub: iconWxPub,
  wx_lite: iconWxLite,
  wx_app: iconWxApp,
  wx_native: iconWxNative,
  wx_wap: iconWxNative,
  wx_bar: iconWxBar,
  alipay_pc: iconAlipayPc,
  alipay_wap: iconAlipayWap,
  alipay_app: iconAlipayApp,
  alipay_qr: iconAlipayQr,
  alipay_bar: iconAlipayBar,
  alipay_lite: iconAlipayPc
}

export function filterPcChannels(codes: string[]): string[] {
  return codes.filter((c) => (PC_PAY_CHANNELS as readonly string[]).includes(c))
}

export function channelLabel(code: string): string {
  return PAY_CHANNEL_LABELS[code] || code
}

export function channelIcon(code: string): string {
  if (PAY_CHANNEL_ICONS[code]) return PAY_CHANNEL_ICONS[code]
  if (code.startsWith('wx_')) return iconWxNative
  if (code.startsWith('alipay_')) return iconAlipayPc
  return iconWallet
}

/** 是否需要展示二维码（微信 Native / 支付宝扫码） */
export function isQrPayChannel(code: string): boolean {
  return code === 'wx_native' || code === 'alipay_qr'
}

/** 支付宝 PC 等返回 HTML form / 跳转链接 */
export function isRedirectPayContent(content?: string): boolean {
  if (!content) return false
  return content.includes('<form') || content.startsWith('http://') || content.startsWith('https://')
}
