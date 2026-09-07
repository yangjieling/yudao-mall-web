import type { Component } from 'vue'
import {
  Brush,
  Camera,
  Cellphone,
  CoffeeCup,
  Cpu,
  FirstAidKit,
  Goods,
  Handbag,
  Headset,
  HotWater,
  Iphone,
  MagicStick,
  Menu,
  Mic,
  Monitor,
  Present,
  ShoppingBag,
  Soccer,
  Van,
  VideoCamera
} from '@element-plus/icons-vue'

/** 按真实类目名（含本地种子：童装童鞋 / 家用电器 / 电子数码 / 美妆个护 / 母婴用品）映射图标 */
export function iconForCategory(name: string): Component {
  const n = (name || '').trim()

  // 一级类目精确匹配
  const exact: Record<string, Component> = {
    童装童鞋: ShoppingBag,
    家用电器: HotWater,
    电子数码: Cpu,
    美妆个护: Brush,
    母婴用品: Present
  }
  if (exact[n]) return exact[n]

  // 童装童鞋
  if (/童装|汉服|裙子|T\s*恤|演出服|外套|裤子|婴儿装/.test(n)) return ShoppingBag
  if (/凉鞋|皮鞋|运动鞋|童鞋|鞋/.test(n)) return Soccer

  // 家用电器
  if (/电视|投影仪/.test(n)) return Monitor
  if (/洗衣机|吸尘器|除螨|热水器/.test(n)) return HotWater
  if (/冰箱|电饭煲|养生壶|破壁|厨房/.test(n)) return CoffeeCup

  // 电子数码
  if (/手机/.test(n)) return Iphone
  if (/平板|笔记|电脑/.test(n)) return Monitor
  if (/相机/.test(n)) return Camera
  if (/耳机|耳麦|音箱/.test(n)) return Headset
  if (/麦克/.test(n)) return Mic
  if (/游戏|无人机/.test(n)) return VideoCamera
  if (/数码|电子/.test(n)) return Cpu
  if (/通信|运营商/.test(n)) return Cellphone

  // 美妆个护
  if (/护肤|洁面|香水|彩妆|粉底|隔离|洗发|沐浴|口腔|美妆|个护/.test(n)) return Brush
  if (/化妆/.test(n)) return MagicStick

  // 母婴用品
  if (/早教|洋娃娃|毛绒|玩具|洗澡|宝宝|儿童餐|水杯|推车|母婴/.test(n)) return Present

  // 通用兜底
  if (/箱包|珠宝|汽车/.test(n)) return Van
  if (/健康|医药|保健/.test(n)) return FirstAidKit
  if (/食品|零食|生鲜/.test(n)) return Goods
  if (/包|袋/.test(n)) return Handbag

  return Menu
}
