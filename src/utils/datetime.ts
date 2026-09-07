/** 将时间戳或日期字符串格式化为可读时间 */
export function formatDateTime(input?: string | number | null): string {
  if (input == null || input === '') return ''

  let date: Date
  if (typeof input === 'number' || /^\d+$/.test(String(input).trim())) {
    const n = Number(input)
    // 10 位按秒，13 位按毫秒
    date = new Date(n < 1e12 ? n * 1000 : n)
  } else {
    date = new Date(input)
  }

  if (Number.isNaN(date.getTime())) return String(input)

  const pad = (v: number) => String(v).padStart(2, '0')
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())} ${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())}`
}
