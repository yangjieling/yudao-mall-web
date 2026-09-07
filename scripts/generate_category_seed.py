#!/usr/bin/env python3
"""Generate complete demo products for every leaf category (fictional data)."""

from __future__ import annotations

import json
import subprocess
from textwrap import dedent

TENANT = 1
CREATOR = "seed-cat"
DELIVERY_TEMPLATE = 1

# Unsplash images (Unsplash License) — 每个品类 4 张，便于详情页多图展示
U = "https://images.unsplash.com"
Q = "auto=format&fit=crop&w=800&q=80"


def u(photo: str) -> str:
    return f"{U}/{photo}?{Q}"


IMG_SETS: dict[str, list[str]] = {
    "hanfu": [
        u("photo-1594938298603-c8148c4dae35"),
        u("photo-1585487000160-6ebcfceb0d03"),
        u("photo-1558171813-4c088753381f"),
        u("photo-1490481651871-ab68de25d43d"),
        u("photo-1483985988355-763728e1935b"),
    ],
    "tshirt": [
        u("photo-1521572163474-6864f9cf17ab"),
        u("photo-1583743814966-8936f5b7be1a"),
        u("photo-1576566588028-4147f3842f27"),
        u("photo-1562157873-818bc0726f68"),
        u("photo-1503341504253-dff4815485f1"),
    ],
    "dress": [
        u("photo-1595777457583-95e059d581b8"),
        u("photo-1515372039744-b8f02a3ae446"),
        u("photo-1496747611176-843222e1e57c"),
        u("photo-1572804013309-59a48b1fa61b"),
        u("photo-1539008835657-9e8e9680c956"),
    ],
    "costume": [
        u("photo-1509631179647-0177331693ae"),
        u("photo-1469334031218-e382a71b716b"),
        u("photo-1483985988355-763728e1935b"),
        u("photo-1539008835657-9e8e9680c956"),
        u("photo-1490481651871-ab68de25d43d"),
    ],
    "coat": [
        u("photo-1544022613-e87ca75a784a"),
        u("photo-1551028719-00167b16eac5"),
        u("photo-1591043037720-404d7a5a0c0a"),
        u("photo-1539533018447-63fcce2678e3"),
        u("photo-1487222477894-8943e31ef7b2"),
    ],
    "pants": [
        u("photo-1624378439575-d8705ad7ae80"),
        u("photo-1542272604-787c3835535d"),
        u("photo-1473966968600-fa801b869a1a"),
        u("photo-1506629082955-511b1aa782c0"),
        u("photo-1541099649105-f69ad21f3246"),
    ],
    "sandal": [
        u("photo-1603487742131-4160ec999306"),
        u("photo-1603808033192-082d59583536"),
        u("photo-1562273138-f46be4ebdf33"),
        u("photo-1535041730312-aa899ff441ce"),
        u("photo-1560769629-975ec94e6a86"),
    ],
    "leather": [
        u("photo-1533867617858-e7b97e060509"),
        u("photo-1449505278894-297fdb3edbc1"),
        u("photo-1614252363701-ba4300ce60d6"),
        u("photo-1460353581641-37baddab0fa2"),
        u("photo-1549298916-b41d501d3772"),
    ],
    "sneaker": [
        u("photo-1542291026-7eec264c27ff"),
        u("photo-1606107557195-0e29a4b5b4aa"),
        u("photo-1595950653106-6c9ebd614d3a"),
        u("photo-1460353581641-37baddab0fa2"),
        u("photo-1551107696-a4b0c5a0d9a2"),
    ],
    "tv": [
        u("photo-1593359677879-a4bb92f829d1"),
        u("photo-1593784991095-a205069470b6"),
        u("photo-1461151304267-38535e780c79"),
        u("photo-1571415060716-baff5f717c37"),
        u("photo-1593359677879-a4bb92f829d1"),
    ],
    "washer": [
        u("photo-1626806787461-102c1bfaaea1"),
        u("photo-1610557892470-55d9e80c0bce"),
        u("photo-1604335399105-a0c585fd81a1"),
        u("photo-1582735689369-4fe89db7114c"),
        u("photo-1626806787461-102c1bfaaea1"),
    ],
    "fridge": [
        u("photo-1571175443880-49e1d25b2bc5"),
        u("photo-1584568694244-14fbdf83bd30"),
        u("photo-1506617420156-8e453697f0c9"),
        u("photo-1571175443880-49e1d25b2bc5"),
    ],
    "ricecooker": [
        u("photo-1585515320310-259814833e71"),
        u("photo-1556911220-bff31c812dba"),
        u("photo-1556909114-f6e7ad7d3136"),
        u("photo-1586190848861-99aa4a171e90"),
    ],
    "kettle": [
        u("photo-1594212699903-ec8a3eca50f5"),
        u("photo-1565193566173-7a0ee3dbe261"),
        u("photo-1571934811356-5cc061b6821f"),
        u("photo-1514228742587-6b1558fcca3d"),
    ],
    "vacuum": [
        u("photo-1558317374-067fb5f30001"),
        u("photo-1581578731548-c64695cc6952"),
        u("photo-1527515637462-cff94eecc1ac"),
        u("photo-1558317374-067fb5f30001"),
    ],
    "blender": [
        u("photo-1570222094114-d054a817e56b"),
        u("photo-1574482620811-1aa16ffe3c82"),
        u("photo-1625948515291-69613efd103f"),
        u("photo-1556911220-bff31c812dba"),
    ],
    "mite": [
        u("photo-1581578731548-c64695cc6952"),
        u("photo-1558317374-067fb5f30001"),
        u("photo-1527515637462-cff94eecc1ac"),
        u("photo-1584622650111-993a426fbf0a"),
    ],
    "heater": [
        u("photo-1584622781564-1d987f7333c1"),
        u("photo-1507652313519-d4e9174996dd"),
        u("photo-1584622650111-993a426fbf0a"),
        u("photo-1584622781564-1d987f7333c1"),
    ],
    "camera": [
        u("photo-1516035069371-29a1b244cc32"),
        u("photo-1502920917128-1aa500764cbd"),
        u("photo-1606983340126-99ab4feaa64a"),
        u("photo-1495707902641-75cac588d2e9"),
    ],
    "laptop": [
        u("photo-1496181133206-80ce9b88a853"),
        u("photo-1517336714731-489689fd1ca8"),
        u("photo-1525547719571-a2d4ac882e4d"),
        u("photo-1588872657578-7efd1f1555ed"),
    ],
    "tablet": [
        u("photo-1544244015-0df4b3ffc6b0"),
        u("photo-1561154464-82e9adf32764"),
        u("photo-1542751371-adc38448a05e"),
        u("photo-1585790050230-5dd28404ccb9"),
    ],
    "headphone": [
        u("photo-1505740420928-5e560c06d30e"),
        u("photo-1484704849700-f032a568e944"),
        u("photo-1546435770-a3e426bf472b"),
        u("photo-1618366712010-f4ae9c647dcb"),
    ],
    "speaker": [
        u("photo-1608043152269-423dbba4e7e1"),
        u("photo-1545454675-3531b543be5d"),
        u("photo-1493225457124-a3eb161ffa5f"),
        u("photo-1608043152269-423dbba4e7e1"),
    ],
    "mic": [
        u("photo-1590602847861-f357a9332bbc"),
        u("photo-1478737270239-2f02b77fc618"),
        u("photo-1511379938547-c1f69419868d"),
        u("photo-1590602847861-f357a9332bbc"),
    ],
    "game": [
        u("photo-1606144042614-b2417e99c4e3"),
        u("photo-1612287230202-1ff1d85d1bdf"),
        u("photo-1592840496694-26d035b52b48"),
        u("photo-1605901309584-818e259dc5f0"),
    ],
    "projector": [
        u("photo-1478720568477-152d9b164e26"),
        u("photo-1485846234645-a62644f84728"),
        u("photo-1598899134739-24c46f58b8c0"),
        u("photo-1517604931442-7e0c8ed2963c"),
    ],
    "drone": [
        u("photo-1473968512647-3e447244af8f"),
        u("photo-1507582020474-9a35acdabcc4"),
        u("photo-1579829366248-204b4815034c"),
        u("photo-1473968512647-3e447244af8f"),
    ],
    "skincare": [
        u("photo-1556228720-195a672e8a03"),
        u("photo-1570194065650-d99fb4b38b17"),
        u("photo-1611930022073-b7a4ba5fcccd"),
        u("photo-1571781926291-c477ebfd024b"),
    ],
    "cleanser": [
        u("photo-1556228578-0d85b1a4d571"),
        u("photo-1556228720-195a672e8a03"),
        u("photo-1571781926291-c477ebfd024b"),
        u("photo-1611930022073-b7a4ba5fcccd"),
    ],
    "perfume": [
        u("photo-1541643600914-78b084683601"),
        u("photo-1594035910387-fea47794261f"),
        u("photo-1587017539504-67cfbddac569"),
        u("photo-1592945403244-b3fbafd7f539"),
    ],
    "makeup": [
        u("photo-1512496015851-a90fb38ba796"),
        u("photo-1596462502278-27bfdc403348"),
        u("photo-1522335789203-aabd76c50552"),
        u("photo-1631214524020-7e18db9a8f92"),
    ],
    "foundation": [
        u("photo-1631214524020-7e18db9a8f92"),
        u("photo-1596462502278-27bfdc403348"),
        u("photo-1512496015851-a90fb38ba796"),
        u("photo-1522335789203-aabd76c50552"),
    ],
    "primer": [
        u("photo-1596462502278-27bfdc403348"),
        u("photo-1631214524020-7e18db9a8f92"),
        u("photo-1571781926291-c477ebfd024b"),
        u("photo-1556228720-195a672e8a03"),
    ],
    "shampoo": [
        u("photo-1535585209827-a15fcdbc4c2d"),
        u("photo-1556228453-efd6c1ff04f6"),
        u("photo-1571781926291-c477ebfd024b"),
        u("photo-1608571423902-eed4a5ad8108"),
    ],
    "bodywash": [
        u("photo-1556228453-efd6c1ff04f6"),
        u("photo-1535585209827-a15fcdbc4c2d"),
        u("photo-1608571423902-eed4a5ad8108"),
        u("photo-1571781926291-c477ebfd024b"),
    ],
    "oral": [
        u("photo-1607613009820-a29f7bb81c04"),
        u("photo-1556228578-0d85b1a4d571"),
        u("photo-1571781926291-c477ebfd024b"),
        u("photo-1607613009820-a29f7bb81c04"),
    ],
    "babywear": [
        u("photo-1515488042361-ee00e0ddd4e4"),
        u("photo-1522771739844-6a9f6d5f14af"),
        u("photo-1519689680058-324335c77eba"),
        u("photo-1503454537195-1dcabb73ffb9"),
    ],
    "earlyedu": [
        u("photo-1503454537195-1dcabb73ffb9"),
        u("photo-1587654780291-39c9404d745b"),
        u("photo-1515488042361-ee00e0ddd4e4"),
        u("photo-1522771739844-6a9f6d5f14af"),
    ],
    "doll": [
        u("photo-1558060370-d644479cb6f7"),
        u("photo-1566576912321-d58ddd7a6088"),
        u("photo-1596461404969-9ae70f2830c1"),
        u("photo-1515488042361-ee00e0ddd4e4"),
    ],
    "plush": [
        u("photo-1558060370-d644479cb6f7"),
        u("photo-1566576912321-d58ddd7a6088"),
        u("photo-1596461404969-9ae70f2830c1"),
        u("photo-1515488042361-ee00e0ddd4e4"),
    ],
    "bath": [
        u("photo-1584622650111-993a426fbf0a"),
        u("photo-1515488042361-ee00e0ddd4e4"),
        u("photo-1503454537195-1dcabb73ffb9"),
        u("photo-1584622781564-1d987f7333c1"),
    ],
    "babycare": [
        u("photo-1519689680058-324335c77eba"),
        u("photo-1556228578-0d85b1a4d571"),
        u("photo-1571781926291-c477ebfd024b"),
        u("photo-1556228720-195a672e8a03"),
    ],
    "tableware": [
        u("photo-1493770348161-369560ae357d"),
        u("photo-1603199506016-b9a694b53600"),
        u("photo-1578662996442-48f60103fc96"),
        u("photo-1584622650111-993a426fbf0a"),
    ],
    "cup": [
        u("photo-1602143407151-7111542de6e8"),
        u("photo-1571934811356-5cc061b6821f"),
        u("photo-1523362628745-0c100150b504"),
        u("photo-1514228742587-6b1558fcca3d"),
    ],
    "stroller": [
        u("photo-1544367567-0f2fcb009e0b"),
        u("photo-1515488042361-ee00e0ddd4e4"),
        u("photo-1503454537195-1dcabb73ffb9"),
        u("photo-1522771739844-6a9f6d5f14af"),
    ],
}

# 兼容旧代码：单图映射取封面
IMG = {k: v[0] for k, v in IMG_SETS.items()}


def gallery_for(key: str) -> list[str]:
    pics = list(IMG_SETS.get(key) or [IMG.get(key, u("photo-1523275335684-37898b6baf30"))])
    uniq: list[str] = []
    for p in pics:
        if p not in uniq:
            uniq.append(p)
    # 详情页至少 4 张；不足时用同组循环补齐（尽量不重复相邻）
    if not uniq:
        uniq = [u("photo-1523275335684-37898b6baf30")]
    base = list(uniq)
    while len(uniq) < 4:
        uniq.append(base[len(uniq) % len(base)])
    return uniq[:5]


def sku_pic_for(gallery: list[str], index: int) -> str:
    return gallery[index % len(gallery)] if gallery else u("photo-1523275335684-37898b6baf30")


# category_id -> product definition
# multi: list of property combos using existing IDs
# color: 1红 5黑 6蓝 7白 24黄
# size will be inserted: S/M/L
# mem: 32=32G 33=64G 34=128G 35=256G

def detail_html(title: str, points: list[str], images: list[str]) -> str:
    lis = "".join(f"<li>{p}</li>" for p in points)
    imgs = "".join(
        f'<p><img src="{src}" alt="{title}" style="max-width:100%;height:auto;"/></p>' for src in images
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
    lines.append("USE `ruoyi_vue_pro`;")
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
        gallery = gallery_for(p["img"])
        cover = gallery[0]
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

        skus: list[tuple] = []
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
                skus.append((props, price, p["market"], p["cost"], stock, sku_pic_for(gallery, idx)))
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
                    skus.append((props_sql, price, p["market"], p["cost"], stock, sku_pic_for(gallery, ci), True))
        elif multi == "memory":
            n = len(p["mems"])
            for idx, (mid, mname) in enumerate(p["mems"]):
                props = json.dumps(
                    [{"propertyId": 14, "propertyName": "内存", "valueId": mid, "valueName": mname}],
                    ensure_ascii=False,
                )
                price = p["price"] + idx * 30000
                stock = max(5, p["stock"] // n)
                skus.append(
                    (
                        props,
                        price,
                        p["market"] + idx * 30000,
                        p["cost"] + idx * 20000,
                        stock,
                        sku_pic_for(gallery, idx),
                    )
                )

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
    out = "/Users/ext.yangjieling3/CursorProjects/yudao/yudao-mall-web/scripts/seed-all-categories.sql"
    with open(out, "w", encoding="utf-8") as f:
        f.write(sql)
    print(f"wrote {out} ({len(PRODUCTS)} products)")

    # Prefer local mysql; fall back to docker mysql8 if present
    db_candidates = ["ruoyi_vue_pro", "ruoyi-vue-pro"]
    attempts = [
        [
            "mysql",
            "-uroot",
            "-p123456",
            "-h127.0.0.1",
            "--default-character-set=utf8mb4",
        ],
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
    ]
    last_err = ""
    for cmd in attempts:
        for db_name in db_candidates:
            payload = sql.replace("USE `ruoyi_vue_pro`;", f"USE `{db_name}`;")
            proc = subprocess.run(cmd, input=payload.encode("utf-8"), capture_output=True)
            err = proc.stderr.decode("utf-8", errors="replace")
            out_txt = proc.stdout.decode("utf-8", errors="replace")
            if proc.returncode == 0:
                print(f"imported into `{db_name}` via {cmd[0]}")
                print(out_txt)
                for line in err.splitlines():
                    if "Warning" not in line and line.strip():
                        print(line)
                return
            last_err = err or out_txt
        print(f"seed via {' '.join(cmd[:2])} failed, try next…")
    print(last_err)
    print("SQL file written; please import manually if DB is offline.")
    raise SystemExit(0)


if __name__ == "__main__":
    main()
