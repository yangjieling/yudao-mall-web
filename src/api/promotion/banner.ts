import request from '@/utils/request'

export interface Banner {
  id: number
  title?: string
  picUrl: string
  url?: string
  position?: number
}

export const BannerApi = {
  /** position: 1 首页等，与后台配置一致 */
  getBannerList: (position = 1) =>
    request<Banner[]>({
      url: '/promotion/banner/list',
      method: 'GET',
      params: { position }
    }),

  addBrowseCount: (id: number) =>
    request<boolean>({
      url: '/promotion/banner/add-browse-count',
      method: 'PUT',
      params: { id },
      showError: false
    })
}
