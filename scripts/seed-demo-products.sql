-- 虚构演示商品 x10（非真实品牌/店铺数据）
-- DB: ruoyi-vue-pro | tenant_id=1 | status=1 上架 | 单规格

USE `ruoyi-vue-pro`;

START TRANSACTION;

INSERT INTO `product_spu` (
  `name`, `keyword`, `introduction`, `description`,
  `category_id`, `brand_id`, `pic_url`, `slider_pic_urls`,
  `sort`, `status`, `spec_type`, `price`, `market_price`, `cost_price`, `stock`,
  `delivery_types`, `delivery_template_id`, `give_integral`, `sub_commission_type`,
  `sales_count`, `virtual_sales_count`, `browse_count`,
  `creator`, `updater`, `deleted`, `tenant_id`
) VALUES
('云杉原木砧板（演示）', '砧板 厨房', '整木开料，日常切菜更稳妥',
 '<p>演示商品：云杉原木砧板，适合家庭日常备菜。仅供本地联调展示。</p>',
 35, NULL, 'https://picsum.photos/seed/mall-board/600/600',
 '["https://picsum.photos/seed/mall-board/600/600","https://picsum.photos/seed/mall-board-2/600/600"]',
 10, 1, b'0', 8900, 12900, 4500, 120,
 '1', 1, 10, b'0', 0, 86, 0, 'demo', 'demo', b'0', 1),

('晨光白瓷马克杯两件套（演示）', '马克杯 杯子', '哑光白瓷，早餐咖啡刚好',
 '<p>演示商品：白瓷马克杯两件套，容量约 350ml。</p>',
 36, NULL, 'https://picsum.photos/seed/mall-mug/600/600',
 '["https://picsum.photos/seed/mall-mug/600/600"]',
 20, 1, b'0', 4900, 6900, 2200, 200,
 '1', 1, 5, b'0', 0, 152, 0, 'demo', 'demo', b'0', 1),

('轻氧速干运动 T 恤（演示）', 'T恤 运动', '轻薄速干，通勤跑步都合适',
 '<p>演示商品：速干运动 T 恤，单规格默认色。</p>',
 28, NULL, 'https://picsum.photos/seed/mall-tee/600/600',
 '["https://picsum.photos/seed/mall-tee/600/600","https://picsum.photos/seed/mall-tee-2/600/600"]',
 30, 1, b'0', 7900, 9900, 3800, 300,
 '1', 1, 8, b'0', 0, 421, 0, 'demo', 'demo', b'0', 1),

('静夜大豆蜡香薰蜡烛（演示）', '香薰 蜡烛', '低烟大豆蜡，卧室氛围灯伴侣',
 '<p>演示商品：大豆蜡香薰蜡烛，燃烧约 25 小时。</p>',
 42, NULL, 'https://picsum.photos/seed/mall-candle/600/600',
 '["https://picsum.photos/seed/mall-candle/600/600"]',
 40, 1, b'0', 5900, 7900, 2600, 180,
 '1', 1, 6, b'0', 0, 97, 0, 'demo', 'demo', b'0', 1),

('折叠布艺收纳箱三件套（演示）', '收纳 整理', '可折叠收纳，换季衣物更整齐',
 '<p>演示商品：三件套收纳箱，含大中小尺寸。</p>',
 37, NULL, 'https://picsum.photos/seed/mall-box/600/600',
 '["https://picsum.photos/seed/mall-box/600/600"]',
 50, 1, b'0', 6900, 9900, 3000, 150,
 '1', 1, 7, b'0', 0, 203, 0, 'demo', 'demo', b'0', 1),

('北欧简约护眼台灯（演示）', '台灯 护眼', '三段调光，书桌阅读更柔和',
 '<p>演示商品：简约护眼台灯，支持三段亮度。</p>',
 69, NULL, 'https://picsum.photos/seed/mall-lamp/600/600',
 '["https://picsum.photos/seed/mall-lamp/600/600","https://picsum.photos/seed/mall-lamp-2/600/600"]',
 60, 1, b'0', 12900, 16900, 6200, 90,
 '1', 1, 12, b'0', 0, 310, 0, 'demo', 'demo', b'0', 1),

('护颈慢回弹记忆枕（演示）', '枕头 睡眠', '曲线贴合肩颈，午睡也舒服',
 '<p>演示商品：慢回弹记忆枕，含可拆洗外套。</p>',
 51, NULL, 'https://picsum.photos/seed/mall-pillow/600/600',
 '["https://picsum.photos/seed/mall-pillow/600/600"]',
 70, 1, b'0', 9900, 13900, 4800, 160,
 '1', 1, 9, b'0', 0, 188, 0, 'demo', 'demo', b'0', 1),

('MiniWave 便携蓝牙音箱（演示）', '音箱 蓝牙', '口袋音箱，续航约 8 小时',
 '<p>演示商品：便携蓝牙音箱，支持蓝牙 5.0。</p>',
 71, NULL, 'https://picsum.photos/seed/mall-speaker/600/600',
 '["https://picsum.photos/seed/mall-speaker/600/600","https://picsum.photos/seed/mall-speaker-2/600/600"]',
 80, 1, b'0', 15900, 19900, 7800, 110,
 '1', 1, 15, b'0', 0, 266, 0, 'demo', 'demo', b'0', 1),

('积木城堡益智套装（演示）', '积木 玩具', '约 286 片，亲子拼搭更有趣',
 '<p>演示商品：积木城堡套装，建议 6 岁以上。</p>',
 50, NULL, 'https://picsum.photos/seed/mall-blocks/600/600',
 '["https://picsum.photos/seed/mall-blocks/600/600"]',
 90, 1, b'0', 11900, 15900, 5500, 140,
 '1', 1, 11, b'0', 0, 175, 0, 'demo', 'demo', b'0', 1),

('轻便运动水杯 700ml（演示）', '水杯 运动', ' Tritan 材质，锁扣防漏',
 '<p>演示商品：700ml 运动水杯，适合通勤健身。</p>',
 65, NULL, 'https://picsum.photos/seed/mall-bottle/600/600',
 '["https://picsum.photos/seed/mall-bottle/600/600"]',
 100, 1, b'0', 3900, 5900, 1800, 250,
 '1', 1, 4, b'0', 0, 390, 0, 'demo', 'demo', b'0', 1);

-- 为刚插入的 10 个 SPU 各建 1 个默认 SKU
INSERT INTO `product_sku` (
  `spu_id`, `properties`, `price`, `market_price`, `cost_price`, `bar_code`, `pic_url`,
  `stock`, `weight`, `volume`, `first_brokerage_price`, `second_brokerage_price`, `sales_count`,
  `creator`, `updater`, `deleted`, `tenant_id`
)
SELECT
  s.id,
  '[{"propertyId":0,"propertyName":"默认","valueId":0,"valueName":"默认"}]',
  s.price,
  s.market_price,
  s.cost_price,
  CONCAT('DEMO', s.id),
  s.pic_url,
  s.stock,
  0.3,
  0.001,
  0,
  0,
  0,
  'demo',
  'demo',
  b'0',
  1
FROM `product_spu` s
WHERE s.creator = 'demo' AND s.deleted = b'0'
  AND s.name LIKE '%（演示）%'
  AND NOT EXISTS (SELECT 1 FROM `product_sku` k WHERE k.spu_id = s.id AND k.deleted = b'0');

COMMIT;

SELECT s.id, s.name, s.category_id, s.price, s.stock, k.id AS sku_id
FROM product_spu s
LEFT JOIN product_sku k ON k.spu_id = s.id AND k.deleted = b'0'
WHERE s.creator = 'demo' AND s.deleted = b'0' AND s.name LIKE '%（演示）%'
ORDER BY s.id;
