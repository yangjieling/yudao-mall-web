import request from '@/utils/request'
import type { PageParam, PageResult } from '@/types/api'

export interface SeckillConfig {
  id: number
  name?: string
  startTime?: string
  endTime?: string
  sliderPicUrls?: string[]
  status?: number
}

export interface SeckillActivity {
  id: number
  name?: string
  spuId?: number
  picUrl?: string
  marketPrice?: number
  seckillPrice?: number
  stock?: number
  totalStock?: number
  status?: number
}

export interface CombinationActivity {
  id: number
  name?: string
  spuId?: number
  picUrl?: string
  spuName?: string
  marketPrice?: number
  combinationPrice?: number
  userSize?: number
  status?: number
}

export interface PointActivity {
  id: number
  spuId?: number
  spuName?: string
  picUrl?: string
  point?: number
  price?: number
  marketPrice?: number
  stock?: number
  status?: number
}

export const SeckillApi = {
  getSeckillConfigList: () =>
    request<SeckillConfig[]>({
      url: '/promotion/seckill-config/list',
      method: 'GET'
    }),

  getSeckillActivityPage: (params: PageParam & { configId?: number }) =>
    request<PageResult<SeckillActivity>>({
      url: '/promotion/seckill-activity/page',
      method: 'GET',
      params
    }),

  getSeckillActivity: (id: number) =>
    request<SeckillActivity>({
      url: '/promotion/seckill-activity/get-detail',
      method: 'GET',
      params: { id }
    })
}

export const CombinationApi = {
  getCombinationActivityPage: (params: PageParam) =>
    request<PageResult<CombinationActivity>>({
      url: '/promotion/combination-activity/page',
      method: 'GET',
      params
    }),

  getCombinationActivity: (id: number) =>
    request<CombinationActivity>({
      url: '/promotion/combination-activity/get-detail',
      method: 'GET',
      params: { id }
    })
}

export const PointActivityApi = {
  getPointActivityPage: (params: PageParam) =>
    request<PageResult<PointActivity>>({
      url: '/promotion/point-activity/page',
      method: 'GET',
      params
    }),

  getPointActivity: (id: number) =>
    request<PointActivity>({
      url: '/promotion/point-activity/get-detail',
      method: 'GET',
      params: { id }
    })
}
