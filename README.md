# OM Shop

> Oh My · 商城 PC 网页端  
> Vue 3 · Vite · TypeScript · Element Plus · `/app-api`

面向 B2C 的桌面端商城前台，软红主题、京东式货架布局，对接云端网关 `/app-api`，覆盖浏览、交易、营销、会员与支付全链路。

仓库：[github.com/yangjieling/yudao-mall-web](https://github.com/yangjieling/yudao-mall-web)

---

## 能力一览

| 模块 | 能力 |
|------|------|
| **门户首页** | 分类入口、Banner、运营卡、为你推荐 |
| **商品** | 顶栏搜索 / 热搜、类目列表排序、详情（多图 / SKU / 评价 / 售后 Tab）、相关推荐、收藏 / 足迹 |
| **交易** | 购物车（猜你喜欢）、结算（地址 / 优惠券 / 积分 / 推荐）、订单列表 / 详情、评价、物流轨迹 |
| **支付** | 收银台（钱包 / Mock / 微信扫码 / 支付宝 PC·扫码，带渠道图标）、支付结果 |
| **售后** | 申请、列表、进度详情 |
| **营销** | 领券中心、秒杀、拼团、积分商城 |
| **会员** | 个人中心、资料、地址、优惠券、收藏、足迹、钱包 |
| **登录** | 密码登录、短信登录（支持登录回跳） |

请求头统一携带：`Authorization` · `tenant-id` · `terminal=20` · `platform=PC`

---

## 技术栈

```text
Vue 3.5          Composition API + <script setup>
Vite 7           开发服务器 / 生产构建
TypeScript 5.8   全量类型约束
Element Plus     UI 组件与图标（中文 locale）
Pinia            状态管理
Vue Router 4     路由（meta.title / 鉴权）
Axios            HTTP 客户端
Sass             全局主题变量
qrcode           收银台二维码
```

---

## 目录结构

```text
src/
├── api/          # 接口封装（member / product / trade / pay / promotion）
├── assets/       # 静态资源（含支付渠道 SVG）
├── components/   # 通用组件
├── layouts/      # MallLayout / UserLayout
├── router/       # 路由表
├── stores/       # Pinia stores
├── styles/       # 全局样式与主题变量
├── types/        # TS 类型
├── utils/        # 请求、价格、支付渠道等
└── views/        # 页面
scripts/          # 演示数据 seed / 修复 SQL
```

---

## 快速开始

### 前置条件

- Node.js 18+
- 已启动后端网关（默认 `48080`）及 `member` / `product` / `trade` / `pay` / `promotion` 等相关服务
- 本地库建议使用 `ruoyi_vue_pro`（与 `scripts/` 中 seed 默认库名一致）

### 安装与启动

```bash
npm install
npm run dev
```

开发地址：<http://127.0.0.1:5173>  
接口代理目标为 `.env.development` 中的 `VITE_BASE_URL`（默认 `http://127.0.0.1:48080`）。

### 常用脚本

| 命令 | 说明 |
|------|------|
| `npm run dev` | 启动开发服务器 |
| `npm run build` | 类型检查 + 生产构建 |
| `npm run preview` | 预览构建产物 |

---

## 演示登录

PC 商城登录的是**会员账号**（`member_user`），不是管理后台 `admin`。

### 推荐：短信登录

本地验证码一般为固定 **`9999`**（后端 `application.yaml` 中 `begin-code` / `end-code`）。

| 项 | 值 |
|----|-----|
| 手机号 | 任意（常用演示号 `15601691300`） |
| 验证码 | `9999` |
| 操作 | 先点「获取验证码」，再登录 |

未注册手机会在短信登录时自动注册。

### 密码登录

若库中已有会员密码，可尝试演示常用密码 `123456`；不通时优先用短信登录。

---

## 演示数据 Seed

可重复执行（会软删旧的 `creator=seed-cat` / `seed-banner` 数据再插入）：

```bash
# 推荐：按叶子类目灌演示商品（每商品约 4～5 张图）+ SKU
mysql -uroot -p123456 --default-character-set=utf8mb4 < scripts/seed-all-categories.sql

# 首页 Banner
mysql -uroot -p123456 --default-character-set=utf8mb4 < scripts/seed-home-banners.sql

# 支付渠道（按需）
mysql -uroot -p123456 --default-character-set=utf8mb4 < scripts/seed-pay-channels.sql
```

重新生成商品 seed SQL：

```bash
python3 scripts/generate_category_seed.py
```

说明：

- `seed-all-categories.sql`：主演示商品（幂等）
- `seed-demo-products.sql`：少量简易商品，与上面功能重叠，一般不必再跑
- `fix-point-activity-tenant.sql`：积分活动表缺 `tenant_id` 时的修复脚本
- **积分商城有货**：需在管理后台「营销管理 → 积分商城」配置活动；仅跑商品 seed 不会自动出现积分 SKU

支付渠道：演示优先启用 `wallet` / `mock`；正式扫码需在管理端为商城支付应用启用 `wx_native`、`alipay_pc`、`alipay_qr` 等。

---

## 环境变量

| 变量 | 说明 | 示例 |
|------|------|------|
| `VITE_APP_TITLE` | 站点名称 | `OM Shop` |
| `VITE_BASE_URL` | 后端网关地址（开发代理目标） | `http://127.0.0.1:48080` |
| `VITE_API_PATH` | API 前缀 | `/app-api` |
| `VITE_TENANT_ID` | 租户编号 | `1` |
| `VITE_TERMINAL` | 终端标识 | `20` |

开发 / 生产分别配置于 `.env.development` 与 `.env.production`。

---

## 架构示意

```text
┌─────────────┐     /app-api      ┌──────────────┐
│  OM Shop PC │ ───────────────► │  API 网关      │
│  (Vue3 SPA) │                  └──────┬───────┘
└─────────────┘                         │
                    ┌───────────────────┼───────────────────┐
                    ▼                   ▼                   ▼
              member / product    trade / pay         promotion
```

联调建议路径：浏览 → 登录 → 加购 → 结算 → 支付（钱包 / Mock）→ 订单 / 评价 / 售后。

---

## License

Private · Internal use only
