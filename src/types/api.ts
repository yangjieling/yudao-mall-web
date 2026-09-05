/** 通用 API 响应 */
export interface ApiResult<T = unknown> {
  code: number
  data: T
  msg: string
}

/** 分页结果 */
export interface PageResult<T> {
  list: T[]
  total: number
}

export interface PageParam {
  pageNo?: number
  pageSize?: number
}
