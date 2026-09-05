import request from '@/utils/request'

export interface AreaNode {
  id: number
  name: string
  children?: AreaNode[]
}

export const AreaApi = {
  getAreaTree: () =>
    request<AreaNode[]>({
      url: '/system/area/tree',
      method: 'GET'
    })
}
