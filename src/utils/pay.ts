/** PC 端可用的支付渠道 */
export const PC_PAY_CHANNELS = ['wallet', 'mock', 'wx_native', 'alipay_pc', 'alipay_qr'] as const

export const PAY_CHANNEL_LABELS: Record<string, string> = {
  wallet: '钱包余额',
  mock: '模拟支付',
  wx_native: '微信扫码',
  alipay_pc: '支付宝电脑网站',
  alipay_qr: '支付宝扫码'
}

export function filterPcChannels(codes: string[]): string[] {
  return codes.filter((c) => (PC_PAY_CHANNELS as readonly string[]).includes(c))
}

export function channelLabel(code: string): string {
  return PAY_CHANNEL_LABELS[code] || code
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
