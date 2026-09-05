/** 分转元，价格字段后端统一为分 */
export function fen2yuan(fen?: number | null): string {
  if (fen == null || Number.isNaN(Number(fen))) return '0.00'
  return (Number(fen) / 100).toFixed(2)
}

/** 展示用价格，¥ 前缀 */
export function formatPrice(fen?: number | null): string {
  return `¥${fen2yuan(fen)}`
}
