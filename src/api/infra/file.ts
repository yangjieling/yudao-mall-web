import request from '@/utils/request'

export const FileApi = {
  upload: (file: File, directory?: string) => {
    const formData = new FormData()
    formData.append('file', file)
    if (directory) formData.append('directory', directory)
    return request<string>({
      url: '/infra/file/upload',
      method: 'POST',
      data: formData,
      headers: { 'Content-Type': 'multipart/form-data' },
      requireAuth: true
    })
  }
}
