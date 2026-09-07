# OM Shop

> Oh My · 商城 PC 网页端  
> Vue 3 · Vite · TypeScript · Element Plus · 芋道 `/app-api`

[![Vue](https://img.shields.io/badge/Vue-3.5-42b883?style=flat-square&logo=vue.js&logoColor=white)](https://vuejs.org/)
[![Vite](https://img.shields.io/badge/Vite-7-646cff?style=flat-square&logo=vite&logoColor=white)](https://vitejs.dev/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.8-3178c6?style=flat-square&logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![Element Plus](https://img.shields.io/badge/Element%20Plus-2.11-409eff?style=flat-square)](https://element-plus.org/)
[![Pinia](https://img.shields.io/badge/Pinia-3-yellow?style=flat-square)](https://pinia.vuejs.org/)

面向 B2C 场景的桌面端商城前台，对齐淘宝 / 京东门户体验，对接芋道云网关 `/app-api`，覆盖浏览、交易、营销、会员与支付全链路。

---

## ✨ 能力一览

| 模块 | 能力 |
|------|------|
| **门户首页** | 左侧类目、中部 Banner、右侧会员 / 活动入口、下方推荐商品流 |
| **商品** | 顶栏大搜索、类目下拉、列表排序 / 筛选、详情、评价、收藏 / 足迹 |
| **交易** | 购物车（含失效品）、结算（地址 / 优惠券 / 积分）、订单列表 / 详情、物流轨迹 |
| **支付** | 收银台：扫码 / 跳转 / 钱包 / Mock；支付结果页 |
| **售后** | 售后申请、进度查询 |
| **营销** | 领券中心、秒杀、拼团、积分商城 |
| **会员** | 资料、地址簿、优惠券、收藏、足迹、钱包 |
| **登录** | 密码登录、短信登录 |

请求头统一携带：`Authorization` · `tenant-id` · `terminal=20` · `platform=PC`

---

## 🛠 技术栈

```text
Vue 3.5          Composition API + <script setup>
Vite 7           开发服务器 / 生产构建
TypeScript 5.8   全量类型约束
Element Plus     UI 组件与图标
Pinia            状态管理
Vue Router 4     路由
Axios            HTTP 客户端
Sass             样式预处理
qrcode           收银台二维码
```

---

## 📁 目录结构

```text
src/
├── api/          # 接口封装（member / product / trade / pay / promotion）
├── assets/       # 静态资源
├── components/   # 通用组件
├── layouts/      # 布局壳层
├── router/       # 路由表
├── stores/       # Pinia stores
├── styles/       # 全局样式
├── types/        # TS 类型
├── utils/        # 工具与请求封装
└── views/        # 页面
    ├── home/           # 首页
    ├── category/       # 商品列表
    ├── goods/          # 详情 / 评价
    ├── cart/           # 购物车
    ├── checkout/       # 结算
    ├── pay/            # 收银台 / 结果
    ├── order/          # 订单 / 售后
    ├── activity/       # 秒杀 / 拼团 / 积分
    ├── coupon/         # 领券中心
    ├── user/           # 个人中心
    └── auth/           # 登录
```

---

## 🚀 快速开始

### 前置条件

- Node.js 18+
- 已启动芋道网关及 `member` / `product` / `trade` / `pay` / `promotion` 等相关服务
- 正式支付需在管理后台为商城支付应用启用 `wx_native`、`alipay_pc`、`wallet` 等渠道

### 安装与启动

```bash
npm install
npm run dev
```

开发地址：[http://127.0.0.1:5173](http://127.0.0.1:5173)  
接口代理目标为 `.env.development` 中的 `VITE_BASE_URL`（默认 `http://127.0.0.1:48080`）。

### 常用脚本

| 命令 | 说明 |
|------|------|
| `npm run dev` | 启动开发服务器 |
| `npm run build` | 类型检查 + 生产构建 |
| `npm run preview` | 预览构建产物 |

---

## ⚙️ 环境变量

| 变量 | 说明 | 示例 |
|------|------|------|
| `VITE_APP_TITLE` | 站点名称 | `OM Shop` |
| `VITE_BASE_URL` | 后端网关地址（开发代理目标） | `http://127.0.0.1:48080` |
| `VITE_API_PATH` | API 前缀 | `/app-api` |
| `VITE_TENANT_ID` | 租户编号 | `1` |
| `VITE_TERMINAL` | 终端标识（默认 H5） | `20` |

开发 / 生产分别配置于 `.env.development` 与 `.env.production`。

---

## 🏗 架构示意

```text
┌─────────────┐     /app-api      ┌──────────────┐
│  OM Shop PC │ ───────────────► │  芋道网关      │
│  (Vue3 SPA) │                  └──────┬───────┘
└─────────────┘                         │
                    ┌───────────────────┼───────────────────┐
                    ▼                   ▼                   ▼
              member / product    trade / pay         promotion
```

---

## 📄 License

Private · Internal use only
