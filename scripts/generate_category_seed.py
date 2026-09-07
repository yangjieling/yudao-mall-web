#!/usr/bin/env python3
"""Generate complete demo products for every leaf category (fictional data)."""

from __future__ import annotations

import json
import subprocess
from textwrap import dedent

TENANT = 1
CREATOR = "seed-cat"
DELIVERY_TEMPLATE = 1

# Unsplash images (Unsplash License) — themed to look like the product type
IMG = {
    "hanfu": "https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&w=800&q=80",
    "tshirt": "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=800&q=80",
    "dress": "https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=format&fit=crop&w=800&q=80",
    "costume": "https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=800&q=80",
    "coat": "https://images.unsplash.com/photo-1544022613-e87ca75a784a?auto=format&fit=crop&w=800&q=80",
    "pants": "https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?auto=format&fit=crop&w=800&q=80",
    "sandal": "https://images.unsplash.com/photo-1603487742131-4160ec999306?auto=format&fit=crop&w=800&q=80",
    "leather": "https://images.unsplash.com/photo-1614252235646-0b9b8c0c0c0c?auto=format&fit=crop&w=800&q=80",
    "sneaker": "https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=80",
    "tv": "https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?auto=format&fit=crop&w=800&q=80",
    "washer": "https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?auto=format&fit=crop&w=800&q=80",
    "fridge": "https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?auto=format&fit=crop&w=800&q=80",
    "ricecooker": "https://images.unsplash.com/photo-1585515320310-259814833e71?auto=format&fit=crop&w=800&q=80",
    "kettle": "https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5?auto=format&fit=crop&w=800&q=80",
    "vacuum": "https://images.unsplash.com/photo-1558317374-067fb5f30001?auto=format&fit=crop&w=800&q=80",
    "blender": "https://images.unsplash.com/photo-1570222094114-d054a817e56b?auto=format&fit=crop&w=800&q=80",
    "mite": "https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&w=800&q=80",
    "heater": "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?auto=format&fit=crop&w=800&q=80",
    "camera": "https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=800&q=80",
    "laptop": "https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&w=800&q=80",
    "tablet": "https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?auto=format&fit=crop&w=800&q=80",
    "headphone": "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=800&q=80",
    "speaker": "https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?auto=format&fit=crop&w=800&q=80",
    "mic": "https://images.unsplash.com/photo-1590602847861-f357a9332bbc?auto=format&fit=crop&w=800&q=80",
    "game": "https://images.unsplash.com/photo-1606144042614-b2417e99c4e3?auto=format&fit=crop&w=800&q=80",
    "projector": "https://images.unsplash.com/photo-1478720568477-152d9b164e26?auto=format&fit=crop&w=800&q=80",
    "drone": "https://images.unsplash.com/photo-1473968512647-3e447244af8f?auto=format&fit=crop&w=800&q=80",
    "skincare": "https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80",
    "cleanser": "https://images.unsplash.com/photo-1556228578-0d85b1a4d571?auto=format&fit=crop&w=800&q=80",
    "perfume": "https://images.unsplash.com/photo-1541643600914-78b084683601?auto=format&fit=crop&w=800&q=80",
    "makeup": "https://images.unsplash.com/photo-1512496015851-a90fb38ba796?auto=format&fit=crop&w=800&q=80",
    "foundation": "https://images.unsplash.com/photo-1631214524020-7e18db9a8f92?auto=format&fit=crop&w=800&q=80",
    "primer": "https://images.unsplash.com/photo-1596462502278-27bfdc403348?auto=format&fit=crop&w=800&q=80",
    "shampoo": "https://images.unsplash.com/photo-1535585209827-a15fcdbc4c2d?auto=format&fit=crop&w=800&q=80",
    "bodywash": "https://images.unsplash.com/photo-1556228453-efd6c1ff04f6?auto=format&fit=crop&w=800&q=80",
    "oral": "https://images.unsplash.com/photo-1607613009820-a29f7bb81c04?auto=format&fit=crop&w=800&q=80",
    "babywear": "https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?auto=format&fit=crop&w=800&q=80",
    "earlyedu": "https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?auto=format&fit=crop&w=800&q=80",
    "doll": "https://images.unsplash.com/photo-1558060370-d644479cb6f7?auto=format&fit=crop&w=800&q=80",
    "plush": "https://images.unsplash.com/photo-1530325553241-4f6e7690ac58?auto=format&fit=crop&w=800&q=80",
    "bath": "https://images.unsplash.com/photo-1584622650111-993a426fbf0a?auto=format&fit=crop&w=800&q=80",
    "babycare": "https://images.unsplash.com/photo-1519689680058-324335c77eba?auto=format&fit=crop&w=800&q=80",
    "tableware": "https://images.unsplash.com/photo-1603199506016-b9a694b53600?auto=format&fit=crop&w=800&q=80",
    "cup": "https://images.unsplash.com/photo-1602143407151-7111542de6e8?auto=format&fit=crop&w=800&q=80",
    "stroller": "https://images.unsplash.com/photo-1596464115822-d0c0c0c0c0c0?auto=format&fit=crop&w=800&q=80",
}

# Fix bad/placeholder URLs with better known ones
IMG["leather"] = "https://images.unsplash.com/photo-1533867617858-e7b97e060509?auto=format&fit=crop&w=800&q=80"
IMG["stroller"] = "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&w=800&q=80"
IMG["heater"] = "https://images.unsplash.com/photo-1584622781564-1d987f7333c1?auto=format&fit=crop&w=800&q=80"
IMG["sandal"] = "https://images.unsplash.com/photo-1603487742131-4160ec999306?auto=format&fit=crop&w=800&q=80"

# category_id -> product definition
# multi: list of property combos using existing IDs
# color: 1红 5黑 6蓝 7白 24黄
# size will be inserted: S/M/L
# mem: 32=32G 33=64G 34=128G 35=256G

def detail_html(title: str, points: list[str], images: list[str]) -> str:
    lis = "".join(f"<li>{p}</li>" for p in points)
    imgs = "".join(
        f'<p><img src="{u}" alt="{title}" style="max-width:100%;height:auto;"/></p>' for u in images
    )
    return (
        f"<div><h3>{title}</h3><ul>{lis}</ul>"
        f"<p>以上为本地联调演示商品，文案与图片仅用于展示。</p>{imgs}</div>"
    )


# Products: one primary per leaf category. Some multi-spec.
PRODUCTS = [
    # 童装童鞋
    {
        "cat": 19,
        "name": "云锦儿童汉服套装（演示）",
        "kw": "汉服 儿童",
        "intro": "轻薄透气，节日出游更有仪式感",
        "img": "hanfu",
        "price": 15900,
        "market": 19900,
        "cost": 7800,
        "stock": 80,
        "multi": "color",
        "colors": [(5, "黑色"), (1, "红色"), (7, "白色")],
        "points": ["仿古剪裁，活动更自在", "面料亲肤，适合春夏", "含上衣与下裙/裤"],
    },
    {
        "cat": 28,
        "name": "轻氧儿童纯棉 T 恤（演示）",
        "kw": "T恤 纯棉",
        "intro": "柔软纯棉，多色可选",
        "img": "tshirt",
        "price": 5900,
        "market": 7900,
        "cost": 2800,
        "stock": 200,
        "multi": "color_size",
        "colors": [(5, "黑色"), (6, "蓝色"), (7, "白色")],
        "sizes": "SML",
        "points": ["100% 棉感面料", "圆领基础款", "适合日常校园穿搭"],
    },
    {
        "cat": 29,
        "name": "夏日碎花儿童连衣裙（演示）",
        "kw": "裙子 连衣裙",
        "intro": "轻盈裙摆，周末出游好看",
        "img": "dress",
        "price": 8900,
        "market": 11900,
        "cost": 4200,
        "stock": 120,
        "multi": "color",
        "colors": [(1, "红色"), (6, "蓝色"), (24, "黄色")],
        "points": ["碎花印花", "宽松版型", "可机洗"],
    },
    {
        "cat": 60,
        "name": "舞台亮片演出服（演示）",
        "kw": "演出服",
        "intro": "活动演出亮片装饰",
        "img": "costume",
        "price": 12900,
        "market": 16900,
        "cost": 6000,
        "stock": 60,
        "multi": None,
        "points": ["亮片点缀", "弹性面料", "适合校园文艺活动"],
    },
    {
        "cat": 61,
        "name": "防风儿童连帽外套（演示）",
        "kw": "外套 防风",
        "intro": "春秋防风，轻便好穿",
        "img": "coat",
        "price": 13900,
        "market": 17900,
        "cost": 6500,
        "stock": 90,
        "multi": "color",
        "colors": [(5, "黑色"), (6, "蓝色")],
        "points": ["连帽设计", "防泼水面料", "两侧口袋"],
    },
    {
        "cat": 62,
        "name": "弹力儿童运动裤（演示）",
        "kw": "裤子 运动",
        "intro": "松紧腰头，跑跳更自在",
        "img": "pants",
        "price": 6900,
        "market": 8900,
        "cost": 3200,
        "stock": 150,
        "multi": "color_size",
        "colors": [(5, "黑色"), (6, "蓝色")],
        "sizes": "SML",
        "points": ["弹力面料", "抽绳腰头", "日常运动皆可"],
    },
    {
        "cat": 63,
        "name": "软底儿童凉鞋（演示）",
        "kw": "凉鞋",
        "intro": "夏季透气软底",
        "img": "sandal",
        "price": 7900,
        "market": 9900,
        "cost": 3600,
        "stock": 100,
        "multi": "color",
        "colors": [(6, "蓝色"), (24, "黄色"), (7, "白色")],
        "points": ["透气鞋面", "防滑鞋底", "魔术贴调节"],
    },
    {
        "cat": 64,
        "name": "经典儿童皮鞋（演示）",
        "kw": "皮鞋",
        "intro": "开学季正装小皮鞋",
        "img": "leather",
        "price": 9900,
        "market": 12900,
        "cost": 4800,
        "stock": 70,
        "multi": None,
        "points": ["仿皮鞋面", "橡胶底防滑", "适合校园活动"],
    },
    {
        "cat": 65,
        "name": "轻跑儿童运动鞋（演示）",
        "kw": "运动鞋",
        "intro": "缓震鞋底，多色可选",
        "img": "sneaker",
        "price": 12900,
        "market": 16900,
        "cost": 6200,
        "stock": 160,
        "multi": "color",
        "colors": [(5, "黑色"), (7, "白色"), (1, "红色")],
        "points": ["缓震中底", "透气网面", "耐磨外底"],
    },
    # 家用电器
    {
        "cat": 31,
        "name": "清画 55 吋智能电视（演示）",
        "kw": "电视 智能",
        "intro": "4K 画质，语音遥控",
        "img": "tv",
        "price": 229900,
        "market": 269900,
        "cost": 180000,
        "stock": 40,
        "multi": None,
        "points": ["4K 分辨率", "内置语音助手", "HDMI/USB 接口齐全"],
    },
    {
        "cat": 32,
        "name": "净滚筒 10kg 洗衣机（演示）",
        "kw": "洗衣机",
        "intro": "大容量滚筒，静音洗涤",
        "img": "washer",
        "price": 189900,
        "market": 219900,
        "cost": 150000,
        "stock": 35,
        "multi": None,
        "points": ["10kg 容量", "多档洗涤程序", "节能静音"],
    },
    {
        "cat": 34,
        "name": "双门节能冰箱（演示）",
        "kw": "冰箱",
        "intro": "冷藏冷冻分区，家用刚刚好",
        "img": "fridge",
        "price": 259900,
        "market": 299900,
        "cost": 200000,
        "stock": 28,
        "multi": None,
        "points": ["风冷无霜", "独立温控", "节能等级友好"],
    },
    {
        "cat": 35,
        "name": "厚釜电饭煲 4L（演示）",
        "kw": "电饭煲",
        "intro": "厚釜加热，米饭更香",
        "img": "ricecooker",
        "price": 29900,
        "market": 39900,
        "cost": 16000,
        "stock": 90,
        "multi": None,
        "points": ["4L 容量", "预约煮饭", "易洁内胆"],
    },
    {
        "cat": 36,
        "name": "恒温养生壶 1.5L（演示）",
        "kw": "养生壶",
        "intro": "多段温控，煮茶煮粥",
        "img": "kettle",
        "price": 15900,
        "market": 19900,
        "cost": 8000,
        "stock": 110,
        "multi": None,
        "points": ["1.5L 玻璃壶身", "多功能菜单", "防干烧保护"],
    },
    {
        "cat": 37,
        "name": "无线手持吸尘器（演示）",
        "kw": "吸尘器",
        "intro": "轻便无线，一键清空尘杯",
        "img": "vacuum",
        "price": 69900,
        "market": 89900,
        "cost": 42000,
        "stock": 55,
        "multi": "color",
        "colors": [(5, "黑色"), (7, "白色")],
        "points": ["无线续航约 40 分钟", "多吸头组合", "HEPA 滤芯"],
    },
    {
        "cat": 66,
        "name": "静音破壁机（演示）",
        "kw": "破壁机",
        "intro": "家用破壁，豆浆果汁一次搞定",
        "img": "blender",
        "price": 49900,
        "market": 69900,
        "cost": 28000,
        "stock": 70,
        "multi": None,
        "points": ["高速破壁刀头", "预约保温", "易清洗杯体"],
    },
    {
        "cat": 67,
        "name": "紫外除螨仪（演示）",
        "kw": "除螨仪",
        "intro": "床褥除螨，吸尘+紫外",
        "img": "mite",
        "price": 24900,
        "market": 32900,
        "cost": 13000,
        "stock": 85,
        "multi": None,
        "points": ["紫外灯辅助", "大吸力尘杯", "适合床垫沙发"],
    },
    {
        "cat": 68,
        "name": "速热电热水器 60L（演示）",
        "kw": "电热水器",
        "intro": "家用储水式，洗澡更从容",
        "img": "heater",
        "price": 129900,
        "market": 159900,
        "cost": 95000,
        "stock": 30,
        "multi": None,
        "points": ["60L 容量", "防电墙设计", "数显温控"],
    },
    # 电子数码
    {
        "cat": 39,
        "name": "旅行微单数码相机（演示）",
        "kw": "相机 微单",
        "intro": "轻便机身，旅行记录更轻松",
        "img": "camera",
        "price": 399900,
        "market": 459900,
        "cost": 320000,
        "stock": 25,
        "multi": "color",
        "colors": [(5, "黑色"), (7, "白色")],
        "points": ["约 2400 万像素", "4K 视频", "可换镜头卡口"],
    },
    {
        "cat": 40,
        "name": "轻薄办公笔记本电脑（演示）",
        "kw": "笔记本",
        "intro": "办公学习主力，多内存规格",
        "img": "laptop",
        "price": 449900,
        "market": 499900,
        "cost": 360000,
        "stock": 40,
        "multi": "memory",
        "mems": [(34, "128G"), (35, "256G")],
        "points": ["14 吋高清屏", "全尺寸键盘", "全天续航表现"],
    },
    {
        "cat": 69,
        "name": "学习娱乐平板电脑（演示）",
        "kw": "平板",
        "intro": "影音阅读，分内存可选",
        "img": "tablet",
        "price": 189900,
        "market": 219900,
        "cost": 150000,
        "stock": 60,
        "multi": "memory",
        "mems": [(33, "64G"), (34, "128G"), (35, "256G")],
        "points": ["10.9 吋屏幕", "四扬声器", "支持手写笔（选配）"],
    },
    {
        "cat": 70,
        "name": "降噪头戴耳机（演示）",
        "kw": "耳机",
        "intro": "主动降噪，多色可选",
        "img": "headphone",
        "price": 89900,
        "market": 109900,
        "cost": 52000,
        "stock": 100,
        "multi": "color",
        "colors": [(5, "黑色"), (6, "蓝色"), (7, "白色")],
        "points": ["主动降噪", "长续航", "触控操作"],
    },
    {
        "cat": 71,
        "name": "桌面蓝牙音箱（演示）",
        "kw": "音箱",
        "intro": "桌面音质升级",
        "img": "speaker",
        "price": 29900,
        "market": 39900,
        "cost": 15000,
        "stock": 90,
        "multi": "color",
        "colors": [(5, "黑色"), (7, "白色")],
        "points": ["蓝牙 5.1", "低音增强", "Type-C 充电"],
    },
    {
        "cat": 72,
        "name": "直播电容麦克风（演示）",
        "kw": "麦克风",
        "intro": "直播录音清晰收音",
        "img": "mic",
        "price": 25900,
        "market": 32900,
        "cost": 12000,
        "stock": 75,
        "multi": None,
        "points": ["心形指向", "即插即用", "带防喷罩"],
    },
    {
        "cat": 73,
        "name": "次世代游戏主机套装（演示）",
        "kw": "游戏机",
        "intro": "主机+手柄演示套装",
        "img": "game",
        "price": 299900,
        "market": 329900,
        "cost": 250000,
        "stock": 20,
        "multi": None,
        "points": ["4K 游戏输出", "无线手柄", "高速固态存储"],
    },
    {
        "cat": 74,
        "name": "家用智能投影仪（演示）",
        "kw": "投影仪",
        "intro": "客厅影院入门选择",
        "img": "projector",
        "price": 199900,
        "market": 239900,
        "cost": 150000,
        "stock": 35,
        "multi": None,
        "points": ["自动对焦", "内置系统", "低噪音风扇"],
    },
    {
        "cat": 75,
        "name": "航拍入门无人机（演示）",
        "kw": "无人机",
        "intro": "折叠机身，新手友好",
        "img": "drone",
        "price": 249900,
        "market": 289900,
        "cost": 190000,
        "stock": 22,
        "multi": None,
        "points": ["折叠便携", "一键返航", "高清图传"],
    },
    # 美妆个护
    {
        "cat": 42,
        "name": "水感护肤三件套（演示）",
        "kw": "护肤套装",
        "intro": "洁面+水+乳基础套组",
        "img": "skincare",
        "price": 19900,
        "market": 26900,
        "cost": 9000,
        "stock": 130,
        "multi": None,
        "points": ["基础护肤流程", "清爽质地", "适合日常维稳"],
    },
    {
        "cat": 43,
        "name": "氨基酸温和洁面乳（演示）",
        "kw": "洁面",
        "intro": "温和清洁不紧绷",
        "img": "cleanser",
        "price": 6900,
        "market": 8900,
        "cost": 3000,
        "stock": 180,
        "multi": None,
        "points": ["氨基酸表活", "泡沫细腻", "晨晚可用"],
    },
    {
        "cat": 44,
        "name": "晨露淡香水 50ml（演示）",
        "kw": "香水",
        "intro": "清新花果调",
        "img": "perfume",
        "price": 15900,
        "market": 19900,
        "cost": 7000,
        "stock": 95,
        "multi": None,
        "points": ["50ml 正装", "持久清香", "便携瓶身"],
    },
    {
        "cat": 45,
        "name": "日常彩妆入门盘（演示）",
        "kw": "彩妆",
        "intro": "眼影腮红组合",
        "img": "makeup",
        "price": 12900,
        "market": 16900,
        "cost": 5500,
        "stock": 110,
        "multi": None,
        "points": ["多色组合", "易上手", "附双头刷"],
    },
    {
        "cat": 46,
        "name": "轻薄粉底液（演示）",
        "kw": "粉底",
        "intro": "自然妆感，多色号",
        "img": "foundation",
        "price": 9900,
        "market": 12900,
        "cost": 4200,
        "stock": 140,
        "multi": "color",
        "colors": [(7, "白色"), (24, "黄色"), (1, "红色")],
        "points": ["轻薄遮瑕", "持妆配方", "泵头设计"],
    },
    {
        "cat": 76,
        "name": "妆前隔离乳（演示）",
        "kw": "隔离",
        "intro": "提亮修色妆前乳",
        "img": "primer",
        "price": 7900,
        "market": 9900,
        "cost": 3500,
        "stock": 120,
        "multi": "color",
        "colors": [(6, "蓝色"), (7, "白色"), (24, "黄色")],
        "points": ["妆前打底", "轻薄服帖", "多色修色"],
    },
    {
        "cat": 77,
        "name": "柔顺洗发水 500ml（演示）",
        "kw": "洗发水",
        "intro": "清爽去油，柔顺发丝",
        "img": "shampoo",
        "price": 5900,
        "market": 7900,
        "cost": 2500,
        "stock": 200,
        "multi": None,
        "points": ["500ml 家庭装", "温和配方", "易冲洗"],
    },
    {
        "cat": 78,
        "name": "清香沐浴露 400ml（演示）",
        "kw": "沐浴露",
        "intro": "绵密泡沫，洗后清爽",
        "img": "bodywash",
        "price": 4900,
        "market": 6900,
        "cost": 2000,
        "stock": 210,
        "multi": None,
        "points": ["400ml", "清香调", "温和洁净"],
    },
    {
        "cat": 79,
        "name": "护龈牙膏套装（演示）",
        "kw": "口腔 牙膏",
        "intro": "早晚分护，清新口气",
        "img": "oral",
        "price": 3900,
        "market": 5900,
        "cost": 1600,
        "stock": 240,
        "multi": None,
        "points": ["两支装", "清新薄荷", "日常护龈"],
    },
    # 母婴用品
    {
        "cat": 48,
        "name": "纯棉婴儿连体衣（演示）",
        "kw": "婴儿装",
        "intro": "柔软纯棉，爬行更舒服",
        "img": "babywear",
        "price": 6900,
        "market": 8900,
        "cost": 3000,
        "stock": 160,
        "multi": "color_size",
        "colors": [(7, "白色"), (24, "黄色"), (6, "蓝色")],
        "sizes": "SML",
        "points": ["A 类棉感", "按扣换穿方便", "四季打底"],
    },
    {
        "cat": 49,
        "name": "触屏早教机（演示）",
        "kw": "早教机",
        "intro": "启蒙绘本与儿歌",
        "img": "earlyedu",
        "price": 29900,
        "market": 39900,
        "cost": 15000,
        "stock": 70,
        "multi": None,
        "points": ["护眼屏幕", "海量内容卡", "家长管控"],
    },
    {
        "cat": 50,
        "name": "柔顺长发洋娃娃（演示）",
        "kw": "洋娃娃",
        "intro": "可梳妆角色扮演",
        "img": "doll",
        "price": 8900,
        "market": 11900,
        "cost": 4000,
        "stock": 100,
        "multi": None,
        "points": ["可换装", "柔顺假发", "含小配饰"],
    },
    {
        "cat": 51,
        "name": "云朵安抚毛绒玩具（演示）",
        "kw": "毛绒玩具",
        "intro": "柔软安抚，陪伴入睡",
        "img": "plush",
        "price": 5900,
        "market": 7900,
        "cost": 2500,
        "stock": 180,
        "multi": "color",
        "colors": [(7, "白色"), (24, "黄色"), (6, "蓝色")],
        "points": ["短绒面料", "填充均匀", "可手洗"],
    },
    {
        "cat": 52,
        "name": "婴儿洗澡座椅套装（演示）",
        "kw": "洗澡用具",
        "intro": "防滑座椅，洗澡更省心",
        "img": "bath",
        "price": 7900,
        "market": 9900,
        "cost": 3500,
        "stock": 90,
        "multi": None,
        "points": ["防滑底座", "可调节靠背", "易晾干"],
    },
    {
        "cat": 80,
        "name": "宝宝润肤乳 200ml（演示）",
        "kw": "宝宝个护",
        "intro": "温和保湿，日常护理",
        "img": "babycare",
        "price": 6900,
        "market": 8900,
        "cost": 3000,
        "stock": 150,
        "multi": None,
        "points": ["温和配方", "易吸收", "全家可用"],
    },
    {
        "cat": 81,
        "name": "儿童餐具五件套（演示）",
        "kw": "儿童餐具",
        "intro": "碗勺叉盘组合",
        "img": "tableware",
        "price": 5900,
        "market": 7900,
        "cost": 2500,
        "stock": 130,
        "multi": "color",
        "colors": [(6, "蓝色"), (24, "黄色"), (1, "红色")],
        "points": ["食品级材质", "防摔设计", "易清洗"],
    },
    {
        "cat": 82,
        "name": "儿童吸管水杯 400ml（演示）",
        "kw": "儿童水杯",
        "intro": "防漏吸管，出行方便",
        "img": "cup",
        "price": 4900,
        "market": 6900,
        "cost": 2000,
        "stock": 170,
        "multi": "color",
        "colors": [(6, "蓝色"), (1, "红色"), (7, "白色")],
        "points": ["400ml", "一键开合", "耐摔杯身"],
    },
    {
        "cat": 83,
        "name": "轻便可折叠婴儿推车（演示）",
        "kw": "婴儿推车",
        "intro": "单手折叠，城市出行",
        "img": "stroller",
        "price": 69900,
        "market": 89900,
        "cost": 42000,
        "stock": 40,
        "multi": "color",
        "colors": [(5, "黑色"), (6, "蓝色"), (7, "白色")],
        "points": ["一键折叠", "避震轮组", "可坐可躺"],
    },
]


def esc(s: str) -> str:
    return s.replace("\\", "\\\\").replace("'", "''")


def main() -> None:
    size_ids = {"S": None, "M": None, "L": None}  # filled after insert query via variables in SQL

    lines: list[str] = []
    lines.append("USE `ruoyi-vue-pro`;")
    lines.append("SET NAMES utf8mb4;")
    lines.append("START TRANSACTION;")
    lines.append(
        dedent(
            """
            -- 补充服装尺码属性值（若不存在）
            INSERT INTO product_property_value (property_id, name, status, remark, creator, updater, tenant_id, deleted)
            SELECT 2, v.name, 0, 'demo size', 'seed-cat', 'seed-cat', 1, b'0'
            FROM (
              SELECT 'S' AS name UNION ALL SELECT 'M' UNION ALL SELECT 'L'
            ) v
            WHERE NOT EXISTS (
              SELECT 1 FROM product_property_value p
              WHERE p.property_id = 2 AND p.name = v.name AND p.deleted = b'0' AND p.tenant_id = 1
            );
            """
        ).strip()
    )

    # Helper SQL vars for size ids
    lines.append("SET @size_s := (SELECT id FROM product_property_value WHERE property_id=2 AND name='S' AND deleted=b'0' AND tenant_id=1 ORDER BY id DESC LIMIT 1);")
    lines.append("SET @size_m := (SELECT id FROM product_property_value WHERE property_id=2 AND name='M' AND deleted=b'0' AND tenant_id=1 ORDER BY id DESC LIMIT 1);")
    lines.append("SET @size_l := (SELECT id FROM product_property_value WHERE property_id=2 AND name='L' AND deleted=b'0' AND tenant_id=1 ORDER BY id DESC LIMIT 1);")

    # Soft-delete previous seed-cat if re-run? Optional - delete old seed-cat products first for idempotent
    lines.append(
        dedent(
            """
            UPDATE product_sku k
            JOIN product_spu s ON s.id = k.spu_id
            SET k.deleted = b'1', k.updater = 'seed-cat'
            WHERE s.creator = 'seed-cat' AND s.deleted = b'0';

            UPDATE product_spu
            SET deleted = b'1', updater = 'seed-cat'
            WHERE creator = 'seed-cat' AND deleted = b'0';
            """
        ).strip()
    )

    for i, p in enumerate(PRODUCTS, start=1):
        cover = IMG[p["img"]]
        gallery = [cover, cover + "&sat=-20"] if "?" in cover else [cover]
        # second image: append another related if same key with -2 not available, reuse cover with crop
        gallery = [cover]
        if p["img"] + "2" in IMG:
            gallery.append(IMG[p["img"] + "2"])
        else:
            # slight variant via different unsplash same category - just duplicate is ok for demo
            gallery.append(cover)

        desc = detail_html(p["name"], p["points"], gallery)
        slider = json.dumps(gallery, ensure_ascii=False)
        multi = p.get("multi")
        spec_type = "b'1'" if multi else "b'0'"

        # base stock/price for spu = min across skus
        lines.append(f"-- product {i}: {p['name']}")
        lines.append(
            f"""INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '{esc(p["name"])}', '{esc(p["kw"])}', '{esc(p["intro"])}', '{esc(desc)}',
  {p["cat"]}, NULL, '{esc(cover)}', '{esc(slider)}',
  {i * 10}, 1, {spec_type}, {p["price"]}, {p["market"]}, {p["cost"]}, {p["stock"]},
  '1', {DELIVERY_TEMPLATE}, {max(1, p["price"] // 1000)}, b'0',
  0, {50 + i * 7}, 0, '{CREATOR}', '{CREATOR}', b'0', {TENANT}
);"""
        )
        lines.append("SET @spu_id := LAST_INSERT_ID();")

        skus: list[tuple[str, int, int, int, int, str]] = []
        # properties_json, price, market, cost, stock, pic
        if multi is None:
            props = json.dumps(
                [{"propertyId": 0, "propertyName": "默认", "valueId": 0, "valueName": "默认"}],
                ensure_ascii=False,
            )
            skus.append((props, p["price"], p["market"], p["cost"], p["stock"], cover))
        elif multi == "color":
            n = len(p["colors"])
            for idx, (cid, cname) in enumerate(p["colors"]):
                props = json.dumps(
                    [{"propertyId": 1, "propertyName": "颜色", "valueId": cid, "valueName": cname}],
                    ensure_ascii=False,
                )
                price = p["price"] + idx * 500
                stock = max(10, p["stock"] // n)
                skus.append((props, price, p["market"], p["cost"], stock, cover))
        elif multi == "color_size":
            sizes = [("S", "@size_s"), ("M", "@size_m"), ("L", "@size_l")]
            n = len(p["colors"]) * 3
            for ci, (cid, cname) in enumerate(p["colors"]):
                for si, (sname, svar) in enumerate(sizes):
                    # properties need numeric valueId - use SQL concat with variables
                    # Build JSON with size id filled by MySQL variable
                    props_sql = (
                        "CONCAT('["
                        + json.dumps(
                            {
                                "propertyId": 1,
                                "propertyName": "颜色",
                                "valueId": cid,
                                "valueName": cname,
                            },
                            ensure_ascii=False,
                        ).replace("'", "''")
                        + ",{\"propertyId\":2,\"propertyName\":\"尺寸\",\"valueId\":',"
                        + svar
                        + ",',\"valueName\":\""
                        + sname
                        + "\"}]')"
                    )
                    price = p["price"] + ci * 300 + si * 200
                    stock = max(8, p["stock"] // n)
                    skus.append((props_sql, price, p["market"], p["cost"], stock, cover, True))
        elif multi == "memory":
            n = len(p["mems"])
            for idx, (mid, mname) in enumerate(p["mems"]):
                props = json.dumps(
                    [{"propertyId": 14, "propertyName": "内存", "valueId": mid, "valueName": mname}],
                    ensure_ascii=False,
                )
                price = p["price"] + idx * 30000
                stock = max(5, p["stock"] // n)
                skus.append((props, price, p["market"] + idx * 30000, p["cost"] + idx * 20000, stock, cover))

        min_price = min(s[1] for s in skus)
        total_stock = sum(s[4] for s in skus)

        for sku in skus:
            if len(sku) == 7:
                props_sql, price, market, cost, stock, pic, _ = sku
                lines.append(
                    f"""INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, {props_sql}, {price}, {market}, {cost}, CONCAT('SC', @spu_id, '-', {price}), '{esc(pic)}',
  {stock}, 0.5, 0.002, 0, 0, 0, '{CREATOR}', '{CREATOR}', b'0', {TENANT}
);"""
                )
            else:
                props, price, market, cost, stock, pic = sku
                lines.append(
                    f"""INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '{esc(props)}', {price}, {market}, {cost}, CONCAT('SC', @spu_id, '-', {price}), '{esc(pic)}',
  {stock}, 0.5, 0.002, 0, 0, 0, '{CREATOR}', '{CREATOR}', b'0', {TENANT}
);"""
                )

        lines.append(
            f"UPDATE product_spu SET price={min_price}, stock={total_stock} WHERE id=@spu_id;"
        )

    lines.append("COMMIT;")
    lines.append(
        dedent(
            """
            SELECT c.name AS category, COUNT(s.id) AS products
            FROM product_category c
            LEFT JOIN product_spu s ON s.category_id = c.id AND s.deleted=b'0' AND s.status=1 AND s.creator='seed-cat'
            WHERE c.deleted=b'0' AND c.status=0 AND c.parent_id<>0
            GROUP BY c.id, c.name
            ORDER BY c.parent_id, c.id;

            SELECT
              (SELECT COUNT(*) FROM product_spu WHERE creator='seed-cat' AND deleted=b'0') AS spus,
              (SELECT COUNT(*) FROM product_sku k JOIN product_spu s ON s.id=k.spu_id WHERE s.creator='seed-cat' AND k.deleted=b'0') AS skus,
              (SELECT COUNT(*) FROM product_spu WHERE deleted=b'0' AND status=1) AS on_sale;
            """
        ).strip()
    )

    sql = "\n".join(lines) + "\n"
    out = "/Users/jielingyang/CursorProjects/yudao/yudao-mall-web/scripts/seed-all-categories.sql"
    with open(out, "w", encoding="utf-8") as f:
        f.write(sql)
    print(f"wrote {out} ({len(PRODUCTS)} products)")

    # execute
    proc = subprocess.run(
        [
            "docker",
            "exec",
            "-i",
            "mysql8",
            "mysql",
            "-uroot",
            "-p123456",
            "--default-character-set=utf8mb4",
        ],
        input=sql.encode("utf-8"),
        capture_output=True,
    )
    err = proc.stderr.decode("utf-8", errors="replace")
    out_txt = proc.stdout.decode("utf-8", errors="replace")
    print(out_txt)
    if proc.returncode != 0:
        print(err)
        raise SystemExit(proc.returncode)
    # filter warning
    for line in err.splitlines():
        if "Warning" not in line and line.strip():
            print(line)


if __name__ == "__main__":
    main()
