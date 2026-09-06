# mall-web

商城 PC 网页端（Vue3 + Vite + TypeScript），对接后端网关的 `/app-api`。

## 功能范围

- PC 首页（对齐淘宝/京东门户）：左侧分类、中部 Banner、右侧会员/活动快捷入口，下方推荐商品流
- 顶栏大搜索 + 分类下拉；`/category` 商品列表（排序 / 关键词 / 类目）
- 商品详情与评价、收藏 / 足迹
- 购物车（含失效商品）、结算（地址 / 优惠券 / 积分）、收银台（扫码 / 跳转 / 钱包 / mock）
- 订单列表 / 详情、物流轨迹、评价、售后申请与进度
- 个人中心：资料、地址簿、优惠券、收藏、足迹、钱包
- 领券中心；秒杀 / 拼团 / 积分商城
- 密码登录、短信登录

请求头携带 `Authorization`、`tenant-id`、`terminal=20`、`platform=PC`。

## 本地启动

```bash
npm install
npm run dev
```

默认开发地址：http://127.0.0.1:5173  
接口代理到 `.env.development` 中的 `VITE_BASE_URL`（默认 `http://127.0.0.1:48080`）。

请先启动网关及 member / product / trade / pay / promotion 等相关服务。  
正式支付请在管理后台为商城支付应用启用 `wx_native`、`alipay_pc`、`wallet` 等渠道。

## 环境变量

| 变量 | 说明 |
|------|------|
| `VITE_APP_TITLE` | 站点名称 |
| `VITE_BASE_URL` | 后端网关地址（开发代理目标） |
| `VITE_API_PATH` | API 前缀，默认 `/app-api` |
| `VITE_TENANT_ID` | 租户编号 |
| `VITE_TERMINAL` | 终端，默认 `20`（H5） |

## 脚本

```bash
npm run dev      # 开发
npm run build    # 类型检查 + 生产构建
npm run preview  # 预览构建产物
```
