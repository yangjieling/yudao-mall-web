USE `ruoyi-vue-pro`;
SET NAMES utf8mb4;
START TRANSACTION;
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
SET @size_s := (SELECT id FROM product_property_value WHERE property_id=2 AND name='S' AND deleted=b'0' AND tenant_id=1 ORDER BY id DESC LIMIT 1);
SET @size_m := (SELECT id FROM product_property_value WHERE property_id=2 AND name='M' AND deleted=b'0' AND tenant_id=1 ORDER BY id DESC LIMIT 1);
SET @size_l := (SELECT id FROM product_property_value WHERE property_id=2 AND name='L' AND deleted=b'0' AND tenant_id=1 ORDER BY id DESC LIMIT 1);
UPDATE product_sku k
JOIN product_spu s ON s.id = k.spu_id
SET k.deleted = b'1', k.updater = 'seed-cat'
WHERE s.creator = 'seed-cat' AND s.deleted = b'0';

UPDATE product_spu
SET deleted = b'1', updater = 'seed-cat'
WHERE creator = 'seed-cat' AND deleted = b'0';
-- product 1: 云锦儿童汉服套装（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '云锦儿童汉服套装（演示）', '汉服 儿童', '轻薄透气，节日出游更有仪式感', '<div><h3>云锦儿童汉服套装（演示）</h3><ul><li>仿古剪裁，活动更自在</li><li>面料亲肤，适合春夏</li><li>含上衣与下裙/裤</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&w=800&q=80" alt="云锦儿童汉服套装（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&w=800&q=80" alt="云锦儿童汉服套装（演示）" style="max-width:100%;height:auto;"/></p></div>',
  19, NULL, 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&w=800&q=80"]',
  10, 1, b'1', 15900, 19900, 7800, 80,
  '1', 1, 15, b'0',
  0, 57, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 5, "valueName": "黑色"}]', 15900, 19900, 7800, CONCAT('SC', @spu_id, '-', 15900), 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&w=800&q=80',
  26, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 1, "valueName": "红色"}]', 16400, 19900, 7800, CONCAT('SC', @spu_id, '-', 16400), 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&w=800&q=80',
  26, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 7, "valueName": "白色"}]', 16900, 19900, 7800, CONCAT('SC', @spu_id, '-', 16900), 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&w=800&q=80',
  26, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=15900, stock=78 WHERE id=@spu_id;
-- product 2: 轻氧儿童纯棉 T 恤（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '轻氧儿童纯棉 T 恤（演示）', 'T恤 纯棉', '柔软纯棉，多色可选', '<div><h3>轻氧儿童纯棉 T 恤（演示）</h3><ul><li>100% 棉感面料</li><li>圆领基础款</li><li>适合日常校园穿搭</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=800&q=80" alt="轻氧儿童纯棉 T 恤（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=800&q=80" alt="轻氧儿童纯棉 T 恤（演示）" style="max-width:100%;height:auto;"/></p></div>',
  28, NULL, 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=800&q=80"]',
  20, 1, b'1', 5900, 7900, 2800, 200,
  '1', 1, 5, b'0',
  0, 64, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, CONCAT('[{"propertyId": 1, "propertyName": "颜色", "valueId": 5, "valueName": "黑色"},{"propertyId":2,"propertyName":"尺寸","valueId":',@size_s,',"valueName":"S"}]'), 5900, 7900, 2800, CONCAT('SC', @spu_id, '-', 5900), 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=800&q=80',
  22, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, CONCAT('[{"propertyId": 1, "propertyName": "颜色", "valueId": 5, "valueName": "黑色"},{"propertyId":2,"propertyName":"尺寸","valueId":',@size_m,',"valueName":"M"}]'), 6100, 7900, 2800, CONCAT('SC', @spu_id, '-', 6100), 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=800&q=80',
  22, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, CONCAT('[{"propertyId": 1, "propertyName": "颜色", "valueId": 5, "valueName": "黑色"},{"propertyId":2,"propertyName":"尺寸","valueId":',@size_l,',"valueName":"L"}]'), 6300, 7900, 2800, CONCAT('SC', @spu_id, '-', 6300), 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=800&q=80',
  22, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, CONCAT('[{"propertyId": 1, "propertyName": "颜色", "valueId": 6, "valueName": "蓝色"},{"propertyId":2,"propertyName":"尺寸","valueId":',@size_s,',"valueName":"S"}]'), 6200, 7900, 2800, CONCAT('SC', @spu_id, '-', 6200), 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=800&q=80',
  22, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, CONCAT('[{"propertyId": 1, "propertyName": "颜色", "valueId": 6, "valueName": "蓝色"},{"propertyId":2,"propertyName":"尺寸","valueId":',@size_m,',"valueName":"M"}]'), 6400, 7900, 2800, CONCAT('SC', @spu_id, '-', 6400), 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=800&q=80',
  22, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, CONCAT('[{"propertyId": 1, "propertyName": "颜色", "valueId": 6, "valueName": "蓝色"},{"propertyId":2,"propertyName":"尺寸","valueId":',@size_l,',"valueName":"L"}]'), 6600, 7900, 2800, CONCAT('SC', @spu_id, '-', 6600), 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=800&q=80',
  22, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, CONCAT('[{"propertyId": 1, "propertyName": "颜色", "valueId": 7, "valueName": "白色"},{"propertyId":2,"propertyName":"尺寸","valueId":',@size_s,',"valueName":"S"}]'), 6500, 7900, 2800, CONCAT('SC', @spu_id, '-', 6500), 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=800&q=80',
  22, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, CONCAT('[{"propertyId": 1, "propertyName": "颜色", "valueId": 7, "valueName": "白色"},{"propertyId":2,"propertyName":"尺寸","valueId":',@size_m,',"valueName":"M"}]'), 6700, 7900, 2800, CONCAT('SC', @spu_id, '-', 6700), 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=800&q=80',
  22, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, CONCAT('[{"propertyId": 1, "propertyName": "颜色", "valueId": 7, "valueName": "白色"},{"propertyId":2,"propertyName":"尺寸","valueId":',@size_l,',"valueName":"L"}]'), 6900, 7900, 2800, CONCAT('SC', @spu_id, '-', 6900), 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=800&q=80',
  22, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=5900, stock=198 WHERE id=@spu_id;
-- product 3: 夏日碎花儿童连衣裙（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '夏日碎花儿童连衣裙（演示）', '裙子 连衣裙', '轻盈裙摆，周末出游好看', '<div><h3>夏日碎花儿童连衣裙（演示）</h3><ul><li>碎花印花</li><li>宽松版型</li><li>可机洗</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=format&fit=crop&w=800&q=80" alt="夏日碎花儿童连衣裙（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=format&fit=crop&w=800&q=80" alt="夏日碎花儿童连衣裙（演示）" style="max-width:100%;height:auto;"/></p></div>',
  29, NULL, 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=format&fit=crop&w=800&q=80"]',
  30, 1, b'1', 8900, 11900, 4200, 120,
  '1', 1, 8, b'0',
  0, 71, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 1, "valueName": "红色"}]', 8900, 11900, 4200, CONCAT('SC', @spu_id, '-', 8900), 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=format&fit=crop&w=800&q=80',
  40, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 6, "valueName": "蓝色"}]', 9400, 11900, 4200, CONCAT('SC', @spu_id, '-', 9400), 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=format&fit=crop&w=800&q=80',
  40, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 24, "valueName": "黄色"}]', 9900, 11900, 4200, CONCAT('SC', @spu_id, '-', 9900), 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=format&fit=crop&w=800&q=80',
  40, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=8900, stock=120 WHERE id=@spu_id;
-- product 4: 舞台亮片演出服（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '舞台亮片演出服（演示）', '演出服', '活动演出亮片装饰', '<div><h3>舞台亮片演出服（演示）</h3><ul><li>亮片点缀</li><li>弹性面料</li><li>适合校园文艺活动</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=800&q=80" alt="舞台亮片演出服（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=800&q=80" alt="舞台亮片演出服（演示）" style="max-width:100%;height:auto;"/></p></div>',
  60, NULL, 'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=800&q=80"]',
  40, 1, b'0', 12900, 16900, 6000, 60,
  '1', 1, 12, b'0',
  0, 78, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 0, "propertyName": "默认", "valueId": 0, "valueName": "默认"}]', 12900, 16900, 6000, CONCAT('SC', @spu_id, '-', 12900), 'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=800&q=80',
  60, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=12900, stock=60 WHERE id=@spu_id;
-- product 5: 防风儿童连帽外套（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '防风儿童连帽外套（演示）', '外套 防风', '春秋防风，轻便好穿', '<div><h3>防风儿童连帽外套（演示）</h3><ul><li>连帽设计</li><li>防泼水面料</li><li>两侧口袋</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1544022613-e87ca75a784a?auto=format&fit=crop&w=800&q=80" alt="防风儿童连帽外套（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1544022613-e87ca75a784a?auto=format&fit=crop&w=800&q=80" alt="防风儿童连帽外套（演示）" style="max-width:100%;height:auto;"/></p></div>',
  61, NULL, 'https://images.unsplash.com/photo-1544022613-e87ca75a784a?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1544022613-e87ca75a784a?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1544022613-e87ca75a784a?auto=format&fit=crop&w=800&q=80"]',
  50, 1, b'1', 13900, 17900, 6500, 90,
  '1', 1, 13, b'0',
  0, 85, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 5, "valueName": "黑色"}]', 13900, 17900, 6500, CONCAT('SC', @spu_id, '-', 13900), 'https://images.unsplash.com/photo-1544022613-e87ca75a784a?auto=format&fit=crop&w=800&q=80',
  45, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 6, "valueName": "蓝色"}]', 14400, 17900, 6500, CONCAT('SC', @spu_id, '-', 14400), 'https://images.unsplash.com/photo-1544022613-e87ca75a784a?auto=format&fit=crop&w=800&q=80',
  45, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=13900, stock=90 WHERE id=@spu_id;
-- product 6: 弹力儿童运动裤（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '弹力儿童运动裤（演示）', '裤子 运动', '松紧腰头，跑跳更自在', '<div><h3>弹力儿童运动裤（演示）</h3><ul><li>弹力面料</li><li>抽绳腰头</li><li>日常运动皆可</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?auto=format&fit=crop&w=800&q=80" alt="弹力儿童运动裤（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?auto=format&fit=crop&w=800&q=80" alt="弹力儿童运动裤（演示）" style="max-width:100%;height:auto;"/></p></div>',
  62, NULL, 'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?auto=format&fit=crop&w=800&q=80"]',
  60, 1, b'1', 6900, 8900, 3200, 150,
  '1', 1, 6, b'0',
  0, 92, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, CONCAT('[{"propertyId": 1, "propertyName": "颜色", "valueId": 5, "valueName": "黑色"},{"propertyId":2,"propertyName":"尺寸","valueId":',@size_s,',"valueName":"S"}]'), 6900, 8900, 3200, CONCAT('SC', @spu_id, '-', 6900), 'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?auto=format&fit=crop&w=800&q=80',
  25, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, CONCAT('[{"propertyId": 1, "propertyName": "颜色", "valueId": 5, "valueName": "黑色"},{"propertyId":2,"propertyName":"尺寸","valueId":',@size_m,',"valueName":"M"}]'), 7100, 8900, 3200, CONCAT('SC', @spu_id, '-', 7100), 'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?auto=format&fit=crop&w=800&q=80',
  25, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, CONCAT('[{"propertyId": 1, "propertyName": "颜色", "valueId": 5, "valueName": "黑色"},{"propertyId":2,"propertyName":"尺寸","valueId":',@size_l,',"valueName":"L"}]'), 7300, 8900, 3200, CONCAT('SC', @spu_id, '-', 7300), 'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?auto=format&fit=crop&w=800&q=80',
  25, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, CONCAT('[{"propertyId": 1, "propertyName": "颜色", "valueId": 6, "valueName": "蓝色"},{"propertyId":2,"propertyName":"尺寸","valueId":',@size_s,',"valueName":"S"}]'), 7200, 8900, 3200, CONCAT('SC', @spu_id, '-', 7200), 'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?auto=format&fit=crop&w=800&q=80',
  25, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, CONCAT('[{"propertyId": 1, "propertyName": "颜色", "valueId": 6, "valueName": "蓝色"},{"propertyId":2,"propertyName":"尺寸","valueId":',@size_m,',"valueName":"M"}]'), 7400, 8900, 3200, CONCAT('SC', @spu_id, '-', 7400), 'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?auto=format&fit=crop&w=800&q=80',
  25, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, CONCAT('[{"propertyId": 1, "propertyName": "颜色", "valueId": 6, "valueName": "蓝色"},{"propertyId":2,"propertyName":"尺寸","valueId":',@size_l,',"valueName":"L"}]'), 7600, 8900, 3200, CONCAT('SC', @spu_id, '-', 7600), 'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?auto=format&fit=crop&w=800&q=80',
  25, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=6900, stock=150 WHERE id=@spu_id;
-- product 7: 软底儿童凉鞋（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '软底儿童凉鞋（演示）', '凉鞋', '夏季透气软底', '<div><h3>软底儿童凉鞋（演示）</h3><ul><li>透气鞋面</li><li>防滑鞋底</li><li>魔术贴调节</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1603487742131-4160ec999306?auto=format&fit=crop&w=800&q=80" alt="软底儿童凉鞋（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1603487742131-4160ec999306?auto=format&fit=crop&w=800&q=80" alt="软底儿童凉鞋（演示）" style="max-width:100%;height:auto;"/></p></div>',
  63, NULL, 'https://images.unsplash.com/photo-1603487742131-4160ec999306?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1603487742131-4160ec999306?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1603487742131-4160ec999306?auto=format&fit=crop&w=800&q=80"]',
  70, 1, b'1', 7900, 9900, 3600, 100,
  '1', 1, 7, b'0',
  0, 99, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 6, "valueName": "蓝色"}]', 7900, 9900, 3600, CONCAT('SC', @spu_id, '-', 7900), 'https://images.unsplash.com/photo-1603487742131-4160ec999306?auto=format&fit=crop&w=800&q=80',
  33, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 24, "valueName": "黄色"}]', 8400, 9900, 3600, CONCAT('SC', @spu_id, '-', 8400), 'https://images.unsplash.com/photo-1603487742131-4160ec999306?auto=format&fit=crop&w=800&q=80',
  33, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 7, "valueName": "白色"}]', 8900, 9900, 3600, CONCAT('SC', @spu_id, '-', 8900), 'https://images.unsplash.com/photo-1603487742131-4160ec999306?auto=format&fit=crop&w=800&q=80',
  33, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=7900, stock=99 WHERE id=@spu_id;
-- product 8: 经典儿童皮鞋（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '经典儿童皮鞋（演示）', '皮鞋', '开学季正装小皮鞋', '<div><h3>经典儿童皮鞋（演示）</h3><ul><li>仿皮鞋面</li><li>橡胶底防滑</li><li>适合校园活动</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1533867617858-e7b97e060509?auto=format&fit=crop&w=800&q=80" alt="经典儿童皮鞋（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1533867617858-e7b97e060509?auto=format&fit=crop&w=800&q=80" alt="经典儿童皮鞋（演示）" style="max-width:100%;height:auto;"/></p></div>',
  64, NULL, 'https://images.unsplash.com/photo-1533867617858-e7b97e060509?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1533867617858-e7b97e060509?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1533867617858-e7b97e060509?auto=format&fit=crop&w=800&q=80"]',
  80, 1, b'0', 9900, 12900, 4800, 70,
  '1', 1, 9, b'0',
  0, 106, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 0, "propertyName": "默认", "valueId": 0, "valueName": "默认"}]', 9900, 12900, 4800, CONCAT('SC', @spu_id, '-', 9900), 'https://images.unsplash.com/photo-1533867617858-e7b97e060509?auto=format&fit=crop&w=800&q=80',
  70, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=9900, stock=70 WHERE id=@spu_id;
-- product 9: 轻跑儿童运动鞋（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '轻跑儿童运动鞋（演示）', '运动鞋', '缓震鞋底，多色可选', '<div><h3>轻跑儿童运动鞋（演示）</h3><ul><li>缓震中底</li><li>透气网面</li><li>耐磨外底</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=80" alt="轻跑儿童运动鞋（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=80" alt="轻跑儿童运动鞋（演示）" style="max-width:100%;height:auto;"/></p></div>',
  65, NULL, 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=80"]',
  90, 1, b'1', 12900, 16900, 6200, 160,
  '1', 1, 12, b'0',
  0, 113, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 5, "valueName": "黑色"}]', 12900, 16900, 6200, CONCAT('SC', @spu_id, '-', 12900), 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=80',
  53, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 7, "valueName": "白色"}]', 13400, 16900, 6200, CONCAT('SC', @spu_id, '-', 13400), 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=80',
  53, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 1, "valueName": "红色"}]', 13900, 16900, 6200, CONCAT('SC', @spu_id, '-', 13900), 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=80',
  53, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=12900, stock=159 WHERE id=@spu_id;
-- product 10: 清画 55 吋智能电视（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '清画 55 吋智能电视（演示）', '电视 智能', '4K 画质，语音遥控', '<div><h3>清画 55 吋智能电视（演示）</h3><ul><li>4K 分辨率</li><li>内置语音助手</li><li>HDMI/USB 接口齐全</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?auto=format&fit=crop&w=800&q=80" alt="清画 55 吋智能电视（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?auto=format&fit=crop&w=800&q=80" alt="清画 55 吋智能电视（演示）" style="max-width:100%;height:auto;"/></p></div>',
  31, NULL, 'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?auto=format&fit=crop&w=800&q=80"]',
  100, 1, b'0', 229900, 269900, 180000, 40,
  '1', 1, 229, b'0',
  0, 120, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 0, "propertyName": "默认", "valueId": 0, "valueName": "默认"}]', 229900, 269900, 180000, CONCAT('SC', @spu_id, '-', 229900), 'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?auto=format&fit=crop&w=800&q=80',
  40, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=229900, stock=40 WHERE id=@spu_id;
-- product 11: 净滚筒 10kg 洗衣机（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '净滚筒 10kg 洗衣机（演示）', '洗衣机', '大容量滚筒，静音洗涤', '<div><h3>净滚筒 10kg 洗衣机（演示）</h3><ul><li>10kg 容量</li><li>多档洗涤程序</li><li>节能静音</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?auto=format&fit=crop&w=800&q=80" alt="净滚筒 10kg 洗衣机（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?auto=format&fit=crop&w=800&q=80" alt="净滚筒 10kg 洗衣机（演示）" style="max-width:100%;height:auto;"/></p></div>',
  32, NULL, 'https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?auto=format&fit=crop&w=800&q=80"]',
  110, 1, b'0', 189900, 219900, 150000, 35,
  '1', 1, 189, b'0',
  0, 127, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 0, "propertyName": "默认", "valueId": 0, "valueName": "默认"}]', 189900, 219900, 150000, CONCAT('SC', @spu_id, '-', 189900), 'https://images.unsplash.com/photo-1626806787461-102c1bfaaea1?auto=format&fit=crop&w=800&q=80',
  35, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=189900, stock=35 WHERE id=@spu_id;
-- product 12: 双门节能冰箱（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '双门节能冰箱（演示）', '冰箱', '冷藏冷冻分区，家用刚刚好', '<div><h3>双门节能冰箱（演示）</h3><ul><li>风冷无霜</li><li>独立温控</li><li>节能等级友好</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?auto=format&fit=crop&w=800&q=80" alt="双门节能冰箱（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?auto=format&fit=crop&w=800&q=80" alt="双门节能冰箱（演示）" style="max-width:100%;height:auto;"/></p></div>',
  34, NULL, 'https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?auto=format&fit=crop&w=800&q=80"]',
  120, 1, b'0', 259900, 299900, 200000, 28,
  '1', 1, 259, b'0',
  0, 134, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 0, "propertyName": "默认", "valueId": 0, "valueName": "默认"}]', 259900, 299900, 200000, CONCAT('SC', @spu_id, '-', 259900), 'https://images.unsplash.com/photo-1571175443880-49e1d25b2bc5?auto=format&fit=crop&w=800&q=80',
  28, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=259900, stock=28 WHERE id=@spu_id;
-- product 13: 厚釜电饭煲 4L（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '厚釜电饭煲 4L（演示）', '电饭煲', '厚釜加热，米饭更香', '<div><h3>厚釜电饭煲 4L（演示）</h3><ul><li>4L 容量</li><li>预约煮饭</li><li>易洁内胆</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1585515320310-259814833e71?auto=format&fit=crop&w=800&q=80" alt="厚釜电饭煲 4L（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1585515320310-259814833e71?auto=format&fit=crop&w=800&q=80" alt="厚釜电饭煲 4L（演示）" style="max-width:100%;height:auto;"/></p></div>',
  35, NULL, 'https://images.unsplash.com/photo-1585515320310-259814833e71?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1585515320310-259814833e71?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1585515320310-259814833e71?auto=format&fit=crop&w=800&q=80"]',
  130, 1, b'0', 29900, 39900, 16000, 90,
  '1', 1, 29, b'0',
  0, 141, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 0, "propertyName": "默认", "valueId": 0, "valueName": "默认"}]', 29900, 39900, 16000, CONCAT('SC', @spu_id, '-', 29900), 'https://images.unsplash.com/photo-1585515320310-259814833e71?auto=format&fit=crop&w=800&q=80',
  90, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=29900, stock=90 WHERE id=@spu_id;
-- product 14: 恒温养生壶 1.5L（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '恒温养生壶 1.5L（演示）', '养生壶', '多段温控，煮茶煮粥', '<div><h3>恒温养生壶 1.5L（演示）</h3><ul><li>1.5L 玻璃壶身</li><li>多功能菜单</li><li>防干烧保护</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5?auto=format&fit=crop&w=800&q=80" alt="恒温养生壶 1.5L（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5?auto=format&fit=crop&w=800&q=80" alt="恒温养生壶 1.5L（演示）" style="max-width:100%;height:auto;"/></p></div>',
  36, NULL, 'https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5?auto=format&fit=crop&w=800&q=80"]',
  140, 1, b'0', 15900, 19900, 8000, 110,
  '1', 1, 15, b'0',
  0, 148, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 0, "propertyName": "默认", "valueId": 0, "valueName": "默认"}]', 15900, 19900, 8000, CONCAT('SC', @spu_id, '-', 15900), 'https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5?auto=format&fit=crop&w=800&q=80',
  110, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=15900, stock=110 WHERE id=@spu_id;
-- product 15: 无线手持吸尘器（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '无线手持吸尘器（演示）', '吸尘器', '轻便无线，一键清空尘杯', '<div><h3>无线手持吸尘器（演示）</h3><ul><li>无线续航约 40 分钟</li><li>多吸头组合</li><li>HEPA 滤芯</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1558317374-067fb5f30001?auto=format&fit=crop&w=800&q=80" alt="无线手持吸尘器（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1558317374-067fb5f30001?auto=format&fit=crop&w=800&q=80" alt="无线手持吸尘器（演示）" style="max-width:100%;height:auto;"/></p></div>',
  37, NULL, 'https://images.unsplash.com/photo-1558317374-067fb5f30001?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1558317374-067fb5f30001?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1558317374-067fb5f30001?auto=format&fit=crop&w=800&q=80"]',
  150, 1, b'1', 69900, 89900, 42000, 55,
  '1', 1, 69, b'0',
  0, 155, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 5, "valueName": "黑色"}]', 69900, 89900, 42000, CONCAT('SC', @spu_id, '-', 69900), 'https://images.unsplash.com/photo-1558317374-067fb5f30001?auto=format&fit=crop&w=800&q=80',
  27, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 7, "valueName": "白色"}]', 70400, 89900, 42000, CONCAT('SC', @spu_id, '-', 70400), 'https://images.unsplash.com/photo-1558317374-067fb5f30001?auto=format&fit=crop&w=800&q=80',
  27, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=69900, stock=54 WHERE id=@spu_id;
-- product 16: 静音破壁机（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '静音破壁机（演示）', '破壁机', '家用破壁，豆浆果汁一次搞定', '<div><h3>静音破壁机（演示）</h3><ul><li>高速破壁刀头</li><li>预约保温</li><li>易清洗杯体</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1570222094114-d054a817e56b?auto=format&fit=crop&w=800&q=80" alt="静音破壁机（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1570222094114-d054a817e56b?auto=format&fit=crop&w=800&q=80" alt="静音破壁机（演示）" style="max-width:100%;height:auto;"/></p></div>',
  66, NULL, 'https://images.unsplash.com/photo-1570222094114-d054a817e56b?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1570222094114-d054a817e56b?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1570222094114-d054a817e56b?auto=format&fit=crop&w=800&q=80"]',
  160, 1, b'0', 49900, 69900, 28000, 70,
  '1', 1, 49, b'0',
  0, 162, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 0, "propertyName": "默认", "valueId": 0, "valueName": "默认"}]', 49900, 69900, 28000, CONCAT('SC', @spu_id, '-', 49900), 'https://images.unsplash.com/photo-1570222094114-d054a817e56b?auto=format&fit=crop&w=800&q=80',
  70, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=49900, stock=70 WHERE id=@spu_id;
-- product 17: 紫外除螨仪（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '紫外除螨仪（演示）', '除螨仪', '床褥除螨，吸尘+紫外', '<div><h3>紫外除螨仪（演示）</h3><ul><li>紫外灯辅助</li><li>大吸力尘杯</li><li>适合床垫沙发</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&w=800&q=80" alt="紫外除螨仪（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&w=800&q=80" alt="紫外除螨仪（演示）" style="max-width:100%;height:auto;"/></p></div>',
  67, NULL, 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&w=800&q=80"]',
  170, 1, b'0', 24900, 32900, 13000, 85,
  '1', 1, 24, b'0',
  0, 169, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 0, "propertyName": "默认", "valueId": 0, "valueName": "默认"}]', 24900, 32900, 13000, CONCAT('SC', @spu_id, '-', 24900), 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&w=800&q=80',
  85, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=24900, stock=85 WHERE id=@spu_id;
-- product 18: 速热电热水器 60L（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '速热电热水器 60L（演示）', '电热水器', '家用储水式，洗澡更从容', '<div><h3>速热电热水器 60L（演示）</h3><ul><li>60L 容量</li><li>防电墙设计</li><li>数显温控</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1584622781564-1d987f7333c1?auto=format&fit=crop&w=800&q=80" alt="速热电热水器 60L（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1584622781564-1d987f7333c1?auto=format&fit=crop&w=800&q=80" alt="速热电热水器 60L（演示）" style="max-width:100%;height:auto;"/></p></div>',
  68, NULL, 'https://images.unsplash.com/photo-1584622781564-1d987f7333c1?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1584622781564-1d987f7333c1?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1584622781564-1d987f7333c1?auto=format&fit=crop&w=800&q=80"]',
  180, 1, b'0', 129900, 159900, 95000, 30,
  '1', 1, 129, b'0',
  0, 176, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 0, "propertyName": "默认", "valueId": 0, "valueName": "默认"}]', 129900, 159900, 95000, CONCAT('SC', @spu_id, '-', 129900), 'https://images.unsplash.com/photo-1584622781564-1d987f7333c1?auto=format&fit=crop&w=800&q=80',
  30, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=129900, stock=30 WHERE id=@spu_id;
-- product 19: 旅行微单数码相机（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '旅行微单数码相机（演示）', '相机 微单', '轻便机身，旅行记录更轻松', '<div><h3>旅行微单数码相机（演示）</h3><ul><li>约 2400 万像素</li><li>4K 视频</li><li>可换镜头卡口</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=800&q=80" alt="旅行微单数码相机（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=800&q=80" alt="旅行微单数码相机（演示）" style="max-width:100%;height:auto;"/></p></div>',
  39, NULL, 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=800&q=80"]',
  190, 1, b'1', 399900, 459900, 320000, 25,
  '1', 1, 399, b'0',
  0, 183, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 5, "valueName": "黑色"}]', 399900, 459900, 320000, CONCAT('SC', @spu_id, '-', 399900), 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=800&q=80',
  12, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 7, "valueName": "白色"}]', 400400, 459900, 320000, CONCAT('SC', @spu_id, '-', 400400), 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=800&q=80',
  12, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=399900, stock=24 WHERE id=@spu_id;
-- product 20: 轻薄办公笔记本电脑（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '轻薄办公笔记本电脑（演示）', '笔记本', '办公学习主力，多内存规格', '<div><h3>轻薄办公笔记本电脑（演示）</h3><ul><li>14 吋高清屏</li><li>全尺寸键盘</li><li>全天续航表现</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&w=800&q=80" alt="轻薄办公笔记本电脑（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&w=800&q=80" alt="轻薄办公笔记本电脑（演示）" style="max-width:100%;height:auto;"/></p></div>',
  40, NULL, 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&w=800&q=80"]',
  200, 1, b'1', 449900, 499900, 360000, 40,
  '1', 1, 449, b'0',
  0, 190, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 14, "propertyName": "内存", "valueId": 34, "valueName": "128G"}]', 449900, 499900, 360000, CONCAT('SC', @spu_id, '-', 449900), 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&w=800&q=80',
  20, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 14, "propertyName": "内存", "valueId": 35, "valueName": "256G"}]', 479900, 529900, 380000, CONCAT('SC', @spu_id, '-', 479900), 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&w=800&q=80',
  20, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=449900, stock=40 WHERE id=@spu_id;
-- product 21: 学习娱乐平板电脑（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '学习娱乐平板电脑（演示）', '平板', '影音阅读，分内存可选', '<div><h3>学习娱乐平板电脑（演示）</h3><ul><li>10.9 吋屏幕</li><li>四扬声器</li><li>支持手写笔（选配）</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?auto=format&fit=crop&w=800&q=80" alt="学习娱乐平板电脑（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?auto=format&fit=crop&w=800&q=80" alt="学习娱乐平板电脑（演示）" style="max-width:100%;height:auto;"/></p></div>',
  69, NULL, 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?auto=format&fit=crop&w=800&q=80"]',
  210, 1, b'1', 189900, 219900, 150000, 60,
  '1', 1, 189, b'0',
  0, 197, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 14, "propertyName": "内存", "valueId": 33, "valueName": "64G"}]', 189900, 219900, 150000, CONCAT('SC', @spu_id, '-', 189900), 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?auto=format&fit=crop&w=800&q=80',
  20, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 14, "propertyName": "内存", "valueId": 34, "valueName": "128G"}]', 219900, 249900, 170000, CONCAT('SC', @spu_id, '-', 219900), 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?auto=format&fit=crop&w=800&q=80',
  20, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 14, "propertyName": "内存", "valueId": 35, "valueName": "256G"}]', 249900, 279900, 190000, CONCAT('SC', @spu_id, '-', 249900), 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?auto=format&fit=crop&w=800&q=80',
  20, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=189900, stock=60 WHERE id=@spu_id;
-- product 22: 降噪头戴耳机（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '降噪头戴耳机（演示）', '耳机', '主动降噪，多色可选', '<div><h3>降噪头戴耳机（演示）</h3><ul><li>主动降噪</li><li>长续航</li><li>触控操作</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=800&q=80" alt="降噪头戴耳机（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=800&q=80" alt="降噪头戴耳机（演示）" style="max-width:100%;height:auto;"/></p></div>',
  70, NULL, 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=800&q=80"]',
  220, 1, b'1', 89900, 109900, 52000, 100,
  '1', 1, 89, b'0',
  0, 204, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 5, "valueName": "黑色"}]', 89900, 109900, 52000, CONCAT('SC', @spu_id, '-', 89900), 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=800&q=80',
  33, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 6, "valueName": "蓝色"}]', 90400, 109900, 52000, CONCAT('SC', @spu_id, '-', 90400), 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=800&q=80',
  33, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 7, "valueName": "白色"}]', 90900, 109900, 52000, CONCAT('SC', @spu_id, '-', 90900), 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=800&q=80',
  33, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=89900, stock=99 WHERE id=@spu_id;
-- product 23: 桌面蓝牙音箱（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '桌面蓝牙音箱（演示）', '音箱', '桌面音质升级', '<div><h3>桌面蓝牙音箱（演示）</h3><ul><li>蓝牙 5.1</li><li>低音增强</li><li>Type-C 充电</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?auto=format&fit=crop&w=800&q=80" alt="桌面蓝牙音箱（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?auto=format&fit=crop&w=800&q=80" alt="桌面蓝牙音箱（演示）" style="max-width:100%;height:auto;"/></p></div>',
  71, NULL, 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?auto=format&fit=crop&w=800&q=80"]',
  230, 1, b'1', 29900, 39900, 15000, 90,
  '1', 1, 29, b'0',
  0, 211, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 5, "valueName": "黑色"}]', 29900, 39900, 15000, CONCAT('SC', @spu_id, '-', 29900), 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?auto=format&fit=crop&w=800&q=80',
  45, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 7, "valueName": "白色"}]', 30400, 39900, 15000, CONCAT('SC', @spu_id, '-', 30400), 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?auto=format&fit=crop&w=800&q=80',
  45, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=29900, stock=90 WHERE id=@spu_id;
-- product 24: 直播电容麦克风（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '直播电容麦克风（演示）', '麦克风', '直播录音清晰收音', '<div><h3>直播电容麦克风（演示）</h3><ul><li>心形指向</li><li>即插即用</li><li>带防喷罩</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1590602847861-f357a9332bbc?auto=format&fit=crop&w=800&q=80" alt="直播电容麦克风（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1590602847861-f357a9332bbc?auto=format&fit=crop&w=800&q=80" alt="直播电容麦克风（演示）" style="max-width:100%;height:auto;"/></p></div>',
  72, NULL, 'https://images.unsplash.com/photo-1590602847861-f357a9332bbc?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1590602847861-f357a9332bbc?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1590602847861-f357a9332bbc?auto=format&fit=crop&w=800&q=80"]',
  240, 1, b'0', 25900, 32900, 12000, 75,
  '1', 1, 25, b'0',
  0, 218, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 0, "propertyName": "默认", "valueId": 0, "valueName": "默认"}]', 25900, 32900, 12000, CONCAT('SC', @spu_id, '-', 25900), 'https://images.unsplash.com/photo-1590602847861-f357a9332bbc?auto=format&fit=crop&w=800&q=80',
  75, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=25900, stock=75 WHERE id=@spu_id;
-- product 25: 次世代游戏主机套装（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '次世代游戏主机套装（演示）', '游戏机', '主机+手柄演示套装', '<div><h3>次世代游戏主机套装（演示）</h3><ul><li>4K 游戏输出</li><li>无线手柄</li><li>高速固态存储</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1606144042614-b2417e99c4e3?auto=format&fit=crop&w=800&q=80" alt="次世代游戏主机套装（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1606144042614-b2417e99c4e3?auto=format&fit=crop&w=800&q=80" alt="次世代游戏主机套装（演示）" style="max-width:100%;height:auto;"/></p></div>',
  73, NULL, 'https://images.unsplash.com/photo-1606144042614-b2417e99c4e3?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1606144042614-b2417e99c4e3?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1606144042614-b2417e99c4e3?auto=format&fit=crop&w=800&q=80"]',
  250, 1, b'0', 299900, 329900, 250000, 20,
  '1', 1, 299, b'0',
  0, 225, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 0, "propertyName": "默认", "valueId": 0, "valueName": "默认"}]', 299900, 329900, 250000, CONCAT('SC', @spu_id, '-', 299900), 'https://images.unsplash.com/photo-1606144042614-b2417e99c4e3?auto=format&fit=crop&w=800&q=80',
  20, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=299900, stock=20 WHERE id=@spu_id;
-- product 26: 家用智能投影仪（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '家用智能投影仪（演示）', '投影仪', '客厅影院入门选择', '<div><h3>家用智能投影仪（演示）</h3><ul><li>自动对焦</li><li>内置系统</li><li>低噪音风扇</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1478720568477-152d9b164e26?auto=format&fit=crop&w=800&q=80" alt="家用智能投影仪（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1478720568477-152d9b164e26?auto=format&fit=crop&w=800&q=80" alt="家用智能投影仪（演示）" style="max-width:100%;height:auto;"/></p></div>',
  74, NULL, 'https://images.unsplash.com/photo-1478720568477-152d9b164e26?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1478720568477-152d9b164e26?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1478720568477-152d9b164e26?auto=format&fit=crop&w=800&q=80"]',
  260, 1, b'0', 199900, 239900, 150000, 35,
  '1', 1, 199, b'0',
  0, 232, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 0, "propertyName": "默认", "valueId": 0, "valueName": "默认"}]', 199900, 239900, 150000, CONCAT('SC', @spu_id, '-', 199900), 'https://images.unsplash.com/photo-1478720568477-152d9b164e26?auto=format&fit=crop&w=800&q=80',
  35, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=199900, stock=35 WHERE id=@spu_id;
-- product 27: 航拍入门无人机（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '航拍入门无人机（演示）', '无人机', '折叠机身，新手友好', '<div><h3>航拍入门无人机（演示）</h3><ul><li>折叠便携</li><li>一键返航</li><li>高清图传</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1473968512647-3e447244af8f?auto=format&fit=crop&w=800&q=80" alt="航拍入门无人机（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1473968512647-3e447244af8f?auto=format&fit=crop&w=800&q=80" alt="航拍入门无人机（演示）" style="max-width:100%;height:auto;"/></p></div>',
  75, NULL, 'https://images.unsplash.com/photo-1473968512647-3e447244af8f?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1473968512647-3e447244af8f?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1473968512647-3e447244af8f?auto=format&fit=crop&w=800&q=80"]',
  270, 1, b'0', 249900, 289900, 190000, 22,
  '1', 1, 249, b'0',
  0, 239, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 0, "propertyName": "默认", "valueId": 0, "valueName": "默认"}]', 249900, 289900, 190000, CONCAT('SC', @spu_id, '-', 249900), 'https://images.unsplash.com/photo-1473968512647-3e447244af8f?auto=format&fit=crop&w=800&q=80',
  22, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=249900, stock=22 WHERE id=@spu_id;
-- product 28: 水感护肤三件套（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '水感护肤三件套（演示）', '护肤套装', '洁面+水+乳基础套组', '<div><h3>水感护肤三件套（演示）</h3><ul><li>基础护肤流程</li><li>清爽质地</li><li>适合日常维稳</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80" alt="水感护肤三件套（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80" alt="水感护肤三件套（演示）" style="max-width:100%;height:auto;"/></p></div>',
  42, NULL, 'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80"]',
  280, 1, b'0', 19900, 26900, 9000, 130,
  '1', 1, 19, b'0',
  0, 246, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 0, "propertyName": "默认", "valueId": 0, "valueName": "默认"}]', 19900, 26900, 9000, CONCAT('SC', @spu_id, '-', 19900), 'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80',
  130, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=19900, stock=130 WHERE id=@spu_id;
-- product 29: 氨基酸温和洁面乳（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '氨基酸温和洁面乳（演示）', '洁面', '温和清洁不紧绷', '<div><h3>氨基酸温和洁面乳（演示）</h3><ul><li>氨基酸表活</li><li>泡沫细腻</li><li>晨晚可用</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1556228578-0d85b1a4d571?auto=format&fit=crop&w=800&q=80" alt="氨基酸温和洁面乳（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1556228578-0d85b1a4d571?auto=format&fit=crop&w=800&q=80" alt="氨基酸温和洁面乳（演示）" style="max-width:100%;height:auto;"/></p></div>',
  43, NULL, 'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1556228578-0d85b1a4d571?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1556228578-0d85b1a4d571?auto=format&fit=crop&w=800&q=80"]',
  290, 1, b'0', 6900, 8900, 3000, 180,
  '1', 1, 6, b'0',
  0, 253, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 0, "propertyName": "默认", "valueId": 0, "valueName": "默认"}]', 6900, 8900, 3000, CONCAT('SC', @spu_id, '-', 6900), 'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?auto=format&fit=crop&w=800&q=80',
  180, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=6900, stock=180 WHERE id=@spu_id;
-- product 30: 晨露淡香水 50ml（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '晨露淡香水 50ml（演示）', '香水', '清新花果调', '<div><h3>晨露淡香水 50ml（演示）</h3><ul><li>50ml 正装</li><li>持久清香</li><li>便携瓶身</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1541643600914-78b084683601?auto=format&fit=crop&w=800&q=80" alt="晨露淡香水 50ml（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1541643600914-78b084683601?auto=format&fit=crop&w=800&q=80" alt="晨露淡香水 50ml（演示）" style="max-width:100%;height:auto;"/></p></div>',
  44, NULL, 'https://images.unsplash.com/photo-1541643600914-78b084683601?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1541643600914-78b084683601?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1541643600914-78b084683601?auto=format&fit=crop&w=800&q=80"]',
  300, 1, b'0', 15900, 19900, 7000, 95,
  '1', 1, 15, b'0',
  0, 260, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 0, "propertyName": "默认", "valueId": 0, "valueName": "默认"}]', 15900, 19900, 7000, CONCAT('SC', @spu_id, '-', 15900), 'https://images.unsplash.com/photo-1541643600914-78b084683601?auto=format&fit=crop&w=800&q=80',
  95, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=15900, stock=95 WHERE id=@spu_id;
-- product 31: 日常彩妆入门盘（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '日常彩妆入门盘（演示）', '彩妆', '眼影腮红组合', '<div><h3>日常彩妆入门盘（演示）</h3><ul><li>多色组合</li><li>易上手</li><li>附双头刷</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1512496015851-a90fb38ba796?auto=format&fit=crop&w=800&q=80" alt="日常彩妆入门盘（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1512496015851-a90fb38ba796?auto=format&fit=crop&w=800&q=80" alt="日常彩妆入门盘（演示）" style="max-width:100%;height:auto;"/></p></div>',
  45, NULL, 'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1512496015851-a90fb38ba796?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1512496015851-a90fb38ba796?auto=format&fit=crop&w=800&q=80"]',
  310, 1, b'0', 12900, 16900, 5500, 110,
  '1', 1, 12, b'0',
  0, 267, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 0, "propertyName": "默认", "valueId": 0, "valueName": "默认"}]', 12900, 16900, 5500, CONCAT('SC', @spu_id, '-', 12900), 'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?auto=format&fit=crop&w=800&q=80',
  110, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=12900, stock=110 WHERE id=@spu_id;
-- product 32: 轻薄粉底液（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '轻薄粉底液（演示）', '粉底', '自然妆感，多色号', '<div><h3>轻薄粉底液（演示）</h3><ul><li>轻薄遮瑕</li><li>持妆配方</li><li>泵头设计</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1631214524020-7e18db9a8f92?auto=format&fit=crop&w=800&q=80" alt="轻薄粉底液（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1631214524020-7e18db9a8f92?auto=format&fit=crop&w=800&q=80" alt="轻薄粉底液（演示）" style="max-width:100%;height:auto;"/></p></div>',
  46, NULL, 'https://images.unsplash.com/photo-1631214524020-7e18db9a8f92?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1631214524020-7e18db9a8f92?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1631214524020-7e18db9a8f92?auto=format&fit=crop&w=800&q=80"]',
  320, 1, b'1', 9900, 12900, 4200, 140,
  '1', 1, 9, b'0',
  0, 274, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 7, "valueName": "白色"}]', 9900, 12900, 4200, CONCAT('SC', @spu_id, '-', 9900), 'https://images.unsplash.com/photo-1631214524020-7e18db9a8f92?auto=format&fit=crop&w=800&q=80',
  46, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 24, "valueName": "黄色"}]', 10400, 12900, 4200, CONCAT('SC', @spu_id, '-', 10400), 'https://images.unsplash.com/photo-1631214524020-7e18db9a8f92?auto=format&fit=crop&w=800&q=80',
  46, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 1, "valueName": "红色"}]', 10900, 12900, 4200, CONCAT('SC', @spu_id, '-', 10900), 'https://images.unsplash.com/photo-1631214524020-7e18db9a8f92?auto=format&fit=crop&w=800&q=80',
  46, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=9900, stock=138 WHERE id=@spu_id;
-- product 33: 妆前隔离乳（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '妆前隔离乳（演示）', '隔离', '提亮修色妆前乳', '<div><h3>妆前隔离乳（演示）</h3><ul><li>妆前打底</li><li>轻薄服帖</li><li>多色修色</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1596462502278-27bfdc403348?auto=format&fit=crop&w=800&q=80" alt="妆前隔离乳（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1596462502278-27bfdc403348?auto=format&fit=crop&w=800&q=80" alt="妆前隔离乳（演示）" style="max-width:100%;height:auto;"/></p></div>',
  76, NULL, 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1596462502278-27bfdc403348?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1596462502278-27bfdc403348?auto=format&fit=crop&w=800&q=80"]',
  330, 1, b'1', 7900, 9900, 3500, 120,
  '1', 1, 7, b'0',
  0, 281, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 6, "valueName": "蓝色"}]', 7900, 9900, 3500, CONCAT('SC', @spu_id, '-', 7900), 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?auto=format&fit=crop&w=800&q=80',
  40, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 7, "valueName": "白色"}]', 8400, 9900, 3500, CONCAT('SC', @spu_id, '-', 8400), 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?auto=format&fit=crop&w=800&q=80',
  40, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 24, "valueName": "黄色"}]', 8900, 9900, 3500, CONCAT('SC', @spu_id, '-', 8900), 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?auto=format&fit=crop&w=800&q=80',
  40, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=7900, stock=120 WHERE id=@spu_id;
-- product 34: 柔顺洗发水 500ml（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '柔顺洗发水 500ml（演示）', '洗发水', '清爽去油，柔顺发丝', '<div><h3>柔顺洗发水 500ml（演示）</h3><ul><li>500ml 家庭装</li><li>温和配方</li><li>易冲洗</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1535585209827-a15fcdbc4c2d?auto=format&fit=crop&w=800&q=80" alt="柔顺洗发水 500ml（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1535585209827-a15fcdbc4c2d?auto=format&fit=crop&w=800&q=80" alt="柔顺洗发水 500ml（演示）" style="max-width:100%;height:auto;"/></p></div>',
  77, NULL, 'https://images.unsplash.com/photo-1535585209827-a15fcdbc4c2d?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1535585209827-a15fcdbc4c2d?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1535585209827-a15fcdbc4c2d?auto=format&fit=crop&w=800&q=80"]',
  340, 1, b'0', 5900, 7900, 2500, 200,
  '1', 1, 5, b'0',
  0, 288, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 0, "propertyName": "默认", "valueId": 0, "valueName": "默认"}]', 5900, 7900, 2500, CONCAT('SC', @spu_id, '-', 5900), 'https://images.unsplash.com/photo-1535585209827-a15fcdbc4c2d?auto=format&fit=crop&w=800&q=80',
  200, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=5900, stock=200 WHERE id=@spu_id;
-- product 35: 清香沐浴露 400ml（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '清香沐浴露 400ml（演示）', '沐浴露', '绵密泡沫，洗后清爽', '<div><h3>清香沐浴露 400ml（演示）</h3><ul><li>400ml</li><li>清香调</li><li>温和洁净</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1556228453-efd6c1ff04f6?auto=format&fit=crop&w=800&q=80" alt="清香沐浴露 400ml（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1556228453-efd6c1ff04f6?auto=format&fit=crop&w=800&q=80" alt="清香沐浴露 400ml（演示）" style="max-width:100%;height:auto;"/></p></div>',
  78, NULL, 'https://images.unsplash.com/photo-1556228453-efd6c1ff04f6?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1556228453-efd6c1ff04f6?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1556228453-efd6c1ff04f6?auto=format&fit=crop&w=800&q=80"]',
  350, 1, b'0', 4900, 6900, 2000, 210,
  '1', 1, 4, b'0',
  0, 295, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 0, "propertyName": "默认", "valueId": 0, "valueName": "默认"}]', 4900, 6900, 2000, CONCAT('SC', @spu_id, '-', 4900), 'https://images.unsplash.com/photo-1556228453-efd6c1ff04f6?auto=format&fit=crop&w=800&q=80',
  210, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=4900, stock=210 WHERE id=@spu_id;
-- product 36: 护龈牙膏套装（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '护龈牙膏套装（演示）', '口腔 牙膏', '早晚分护，清新口气', '<div><h3>护龈牙膏套装（演示）</h3><ul><li>两支装</li><li>清新薄荷</li><li>日常护龈</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1607613009820-a29f7bb81c04?auto=format&fit=crop&w=800&q=80" alt="护龈牙膏套装（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1607613009820-a29f7bb81c04?auto=format&fit=crop&w=800&q=80" alt="护龈牙膏套装（演示）" style="max-width:100%;height:auto;"/></p></div>',
  79, NULL, 'https://images.unsplash.com/photo-1607613009820-a29f7bb81c04?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1607613009820-a29f7bb81c04?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1607613009820-a29f7bb81c04?auto=format&fit=crop&w=800&q=80"]',
  360, 1, b'0', 3900, 5900, 1600, 240,
  '1', 1, 3, b'0',
  0, 302, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 0, "propertyName": "默认", "valueId": 0, "valueName": "默认"}]', 3900, 5900, 1600, CONCAT('SC', @spu_id, '-', 3900), 'https://images.unsplash.com/photo-1607613009820-a29f7bb81c04?auto=format&fit=crop&w=800&q=80',
  240, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=3900, stock=240 WHERE id=@spu_id;
-- product 37: 纯棉婴儿连体衣（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '纯棉婴儿连体衣（演示）', '婴儿装', '柔软纯棉，爬行更舒服', '<div><h3>纯棉婴儿连体衣（演示）</h3><ul><li>A 类棉感</li><li>按扣换穿方便</li><li>四季打底</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?auto=format&fit=crop&w=800&q=80" alt="纯棉婴儿连体衣（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?auto=format&fit=crop&w=800&q=80" alt="纯棉婴儿连体衣（演示）" style="max-width:100%;height:auto;"/></p></div>',
  48, NULL, 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?auto=format&fit=crop&w=800&q=80"]',
  370, 1, b'1', 6900, 8900, 3000, 160,
  '1', 1, 6, b'0',
  0, 309, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, CONCAT('[{"propertyId": 1, "propertyName": "颜色", "valueId": 7, "valueName": "白色"},{"propertyId":2,"propertyName":"尺寸","valueId":',@size_s,',"valueName":"S"}]'), 6900, 8900, 3000, CONCAT('SC', @spu_id, '-', 6900), 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?auto=format&fit=crop&w=800&q=80',
  17, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, CONCAT('[{"propertyId": 1, "propertyName": "颜色", "valueId": 7, "valueName": "白色"},{"propertyId":2,"propertyName":"尺寸","valueId":',@size_m,',"valueName":"M"}]'), 7100, 8900, 3000, CONCAT('SC', @spu_id, '-', 7100), 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?auto=format&fit=crop&w=800&q=80',
  17, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, CONCAT('[{"propertyId": 1, "propertyName": "颜色", "valueId": 7, "valueName": "白色"},{"propertyId":2,"propertyName":"尺寸","valueId":',@size_l,',"valueName":"L"}]'), 7300, 8900, 3000, CONCAT('SC', @spu_id, '-', 7300), 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?auto=format&fit=crop&w=800&q=80',
  17, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, CONCAT('[{"propertyId": 1, "propertyName": "颜色", "valueId": 24, "valueName": "黄色"},{"propertyId":2,"propertyName":"尺寸","valueId":',@size_s,',"valueName":"S"}]'), 7200, 8900, 3000, CONCAT('SC', @spu_id, '-', 7200), 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?auto=format&fit=crop&w=800&q=80',
  17, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, CONCAT('[{"propertyId": 1, "propertyName": "颜色", "valueId": 24, "valueName": "黄色"},{"propertyId":2,"propertyName":"尺寸","valueId":',@size_m,',"valueName":"M"}]'), 7400, 8900, 3000, CONCAT('SC', @spu_id, '-', 7400), 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?auto=format&fit=crop&w=800&q=80',
  17, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, CONCAT('[{"propertyId": 1, "propertyName": "颜色", "valueId": 24, "valueName": "黄色"},{"propertyId":2,"propertyName":"尺寸","valueId":',@size_l,',"valueName":"L"}]'), 7600, 8900, 3000, CONCAT('SC', @spu_id, '-', 7600), 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?auto=format&fit=crop&w=800&q=80',
  17, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, CONCAT('[{"propertyId": 1, "propertyName": "颜色", "valueId": 6, "valueName": "蓝色"},{"propertyId":2,"propertyName":"尺寸","valueId":',@size_s,',"valueName":"S"}]'), 7500, 8900, 3000, CONCAT('SC', @spu_id, '-', 7500), 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?auto=format&fit=crop&w=800&q=80',
  17, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, CONCAT('[{"propertyId": 1, "propertyName": "颜色", "valueId": 6, "valueName": "蓝色"},{"propertyId":2,"propertyName":"尺寸","valueId":',@size_m,',"valueName":"M"}]'), 7700, 8900, 3000, CONCAT('SC', @spu_id, '-', 7700), 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?auto=format&fit=crop&w=800&q=80',
  17, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, CONCAT('[{"propertyId": 1, "propertyName": "颜色", "valueId": 6, "valueName": "蓝色"},{"propertyId":2,"propertyName":"尺寸","valueId":',@size_l,',"valueName":"L"}]'), 7900, 8900, 3000, CONCAT('SC', @spu_id, '-', 7900), 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?auto=format&fit=crop&w=800&q=80',
  17, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=6900, stock=153 WHERE id=@spu_id;
-- product 38: 触屏早教机（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '触屏早教机（演示）', '早教机', '启蒙绘本与儿歌', '<div><h3>触屏早教机（演示）</h3><ul><li>护眼屏幕</li><li>海量内容卡</li><li>家长管控</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?auto=format&fit=crop&w=800&q=80" alt="触屏早教机（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?auto=format&fit=crop&w=800&q=80" alt="触屏早教机（演示）" style="max-width:100%;height:auto;"/></p></div>',
  49, NULL, 'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?auto=format&fit=crop&w=800&q=80"]',
  380, 1, b'0', 29900, 39900, 15000, 70,
  '1', 1, 29, b'0',
  0, 316, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 0, "propertyName": "默认", "valueId": 0, "valueName": "默认"}]', 29900, 39900, 15000, CONCAT('SC', @spu_id, '-', 29900), 'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?auto=format&fit=crop&w=800&q=80',
  70, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=29900, stock=70 WHERE id=@spu_id;
-- product 39: 柔顺长发洋娃娃（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '柔顺长发洋娃娃（演示）', '洋娃娃', '可梳妆角色扮演', '<div><h3>柔顺长发洋娃娃（演示）</h3><ul><li>可换装</li><li>柔顺假发</li><li>含小配饰</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1558060370-d644479cb6f7?auto=format&fit=crop&w=800&q=80" alt="柔顺长发洋娃娃（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1558060370-d644479cb6f7?auto=format&fit=crop&w=800&q=80" alt="柔顺长发洋娃娃（演示）" style="max-width:100%;height:auto;"/></p></div>',
  50, NULL, 'https://images.unsplash.com/photo-1558060370-d644479cb6f7?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1558060370-d644479cb6f7?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1558060370-d644479cb6f7?auto=format&fit=crop&w=800&q=80"]',
  390, 1, b'0', 8900, 11900, 4000, 100,
  '1', 1, 8, b'0',
  0, 323, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 0, "propertyName": "默认", "valueId": 0, "valueName": "默认"}]', 8900, 11900, 4000, CONCAT('SC', @spu_id, '-', 8900), 'https://images.unsplash.com/photo-1558060370-d644479cb6f7?auto=format&fit=crop&w=800&q=80',
  100, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=8900, stock=100 WHERE id=@spu_id;
-- product 40: 云朵安抚毛绒玩具（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '云朵安抚毛绒玩具（演示）', '毛绒玩具', '柔软安抚，陪伴入睡', '<div><h3>云朵安抚毛绒玩具（演示）</h3><ul><li>短绒面料</li><li>填充均匀</li><li>可手洗</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1558060370-d644479cb6f7?auto=format&fit=crop&w=800&q=80" alt="云朵安抚毛绒玩具（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1558060370-d644479cb6f7?auto=format&fit=crop&w=800&q=80" alt="云朵安抚毛绒玩具（演示）" style="max-width:100%;height:auto;"/></p></div>',
  51, NULL, 'https://images.unsplash.com/photo-1558060370-d644479cb6f7?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1558060370-d644479cb6f7?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1558060370-d644479cb6f7?auto=format&fit=crop&w=800&q=80"]',
  400, 1, b'1', 5900, 7900, 2500, 180,
  '1', 1, 5, b'0',
  0, 330, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 7, "valueName": "白色"}]', 5900, 7900, 2500, CONCAT('SC', @spu_id, '-', 5900), 'https://images.unsplash.com/photo-1558060370-d644479cb6f7?auto=format&fit=crop&w=800&q=80',
  60, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 24, "valueName": "黄色"}]', 6400, 7900, 2500, CONCAT('SC', @spu_id, '-', 6400), 'https://images.unsplash.com/photo-1558060370-d644479cb6f7?auto=format&fit=crop&w=800&q=80',
  60, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 6, "valueName": "蓝色"}]', 6900, 7900, 2500, CONCAT('SC', @spu_id, '-', 6900), 'https://images.unsplash.com/photo-1558060370-d644479cb6f7?auto=format&fit=crop&w=800&q=80',
  60, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=5900, stock=180 WHERE id=@spu_id;
-- product 41: 婴儿洗澡座椅套装（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '婴儿洗澡座椅套装（演示）', '洗澡用具', '防滑座椅，洗澡更省心', '<div><h3>婴儿洗澡座椅套装（演示）</h3><ul><li>防滑底座</li><li>可调节靠背</li><li>易晾干</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1584622650111-993a426fbf0a?auto=format&fit=crop&w=800&q=80" alt="婴儿洗澡座椅套装（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1584622650111-993a426fbf0a?auto=format&fit=crop&w=800&q=80" alt="婴儿洗澡座椅套装（演示）" style="max-width:100%;height:auto;"/></p></div>',
  52, NULL, 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1584622650111-993a426fbf0a?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1584622650111-993a426fbf0a?auto=format&fit=crop&w=800&q=80"]',
  410, 1, b'0', 7900, 9900, 3500, 90,
  '1', 1, 7, b'0',
  0, 337, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 0, "propertyName": "默认", "valueId": 0, "valueName": "默认"}]', 7900, 9900, 3500, CONCAT('SC', @spu_id, '-', 7900), 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?auto=format&fit=crop&w=800&q=80',
  90, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=7900, stock=90 WHERE id=@spu_id;
-- product 42: 宝宝润肤乳 200ml（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '宝宝润肤乳 200ml（演示）', '宝宝个护', '温和保湿，日常护理', '<div><h3>宝宝润肤乳 200ml（演示）</h3><ul><li>温和配方</li><li>易吸收</li><li>全家可用</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1519689680058-324335c77eba?auto=format&fit=crop&w=800&q=80" alt="宝宝润肤乳 200ml（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1519689680058-324335c77eba?auto=format&fit=crop&w=800&q=80" alt="宝宝润肤乳 200ml（演示）" style="max-width:100%;height:auto;"/></p></div>',
  80, NULL, 'https://images.unsplash.com/photo-1519689680058-324335c77eba?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1519689680058-324335c77eba?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1519689680058-324335c77eba?auto=format&fit=crop&w=800&q=80"]',
  420, 1, b'0', 6900, 8900, 3000, 150,
  '1', 1, 6, b'0',
  0, 344, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 0, "propertyName": "默认", "valueId": 0, "valueName": "默认"}]', 6900, 8900, 3000, CONCAT('SC', @spu_id, '-', 6900), 'https://images.unsplash.com/photo-1519689680058-324335c77eba?auto=format&fit=crop&w=800&q=80',
  150, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=6900, stock=150 WHERE id=@spu_id;
-- product 43: 儿童餐具五件套（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '儿童餐具五件套（演示）', '儿童餐具', '碗勺叉盘组合', '<div><h3>儿童餐具五件套（演示）</h3><ul><li>食品级材质</li><li>防摔设计</li><li>易清洗</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1493770348161-369560ae357d?auto=format&fit=crop&w=800&q=80" alt="儿童餐具五件套（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1493770348161-369560ae357d?auto=format&fit=crop&w=800&q=80" alt="儿童餐具五件套（演示）" style="max-width:100%;height:auto;"/></p></div>',
  81, NULL, 'https://images.unsplash.com/photo-1493770348161-369560ae357d?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1493770348161-369560ae357d?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1493770348161-369560ae357d?auto=format&fit=crop&w=800&q=80"]',
  430, 1, b'1', 5900, 7900, 2500, 130,
  '1', 1, 5, b'0',
  0, 351, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 6, "valueName": "蓝色"}]', 5900, 7900, 2500, CONCAT('SC', @spu_id, '-', 5900), 'https://images.unsplash.com/photo-1493770348161-369560ae357d?auto=format&fit=crop&w=800&q=80',
  43, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 24, "valueName": "黄色"}]', 6400, 7900, 2500, CONCAT('SC', @spu_id, '-', 6400), 'https://images.unsplash.com/photo-1493770348161-369560ae357d?auto=format&fit=crop&w=800&q=80',
  43, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 1, "valueName": "红色"}]', 6900, 7900, 2500, CONCAT('SC', @spu_id, '-', 6900), 'https://images.unsplash.com/photo-1493770348161-369560ae357d?auto=format&fit=crop&w=800&q=80',
  43, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=5900, stock=129 WHERE id=@spu_id;
-- product 44: 儿童吸管水杯 400ml（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '儿童吸管水杯 400ml（演示）', '儿童水杯', '防漏吸管，出行方便', '<div><h3>儿童吸管水杯 400ml（演示）</h3><ul><li>400ml</li><li>一键开合</li><li>耐摔杯身</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1602143407151-7111542de6e8?auto=format&fit=crop&w=800&q=80" alt="儿童吸管水杯 400ml（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1602143407151-7111542de6e8?auto=format&fit=crop&w=800&q=80" alt="儿童吸管水杯 400ml（演示）" style="max-width:100%;height:auto;"/></p></div>',
  82, NULL, 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1602143407151-7111542de6e8?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1602143407151-7111542de6e8?auto=format&fit=crop&w=800&q=80"]',
  440, 1, b'1', 4900, 6900, 2000, 170,
  '1', 1, 4, b'0',
  0, 358, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 6, "valueName": "蓝色"}]', 4900, 6900, 2000, CONCAT('SC', @spu_id, '-', 4900), 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?auto=format&fit=crop&w=800&q=80',
  56, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 1, "valueName": "红色"}]', 5400, 6900, 2000, CONCAT('SC', @spu_id, '-', 5400), 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?auto=format&fit=crop&w=800&q=80',
  56, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 7, "valueName": "白色"}]', 5900, 6900, 2000, CONCAT('SC', @spu_id, '-', 5900), 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?auto=format&fit=crop&w=800&q=80',
  56, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=4900, stock=168 WHERE id=@spu_id;
-- product 45: 轻便可折叠婴儿推车（演示）
INSERT INTO product_spu (
  name, keyword, introduction, description, category_id, brand_id, pic_url, slider_pic_urls,
  sort, status, spec_type, price, market_price, cost_price, stock,
  delivery_types, delivery_template_id, give_integral, sub_commission_type,
  sales_count, virtual_sales_count, browse_count, creator, updater, deleted, tenant_id
) VALUES (
  '轻便可折叠婴儿推车（演示）', '婴儿推车', '单手折叠，城市出行', '<div><h3>轻便可折叠婴儿推车（演示）</h3><ul><li>一键折叠</li><li>避震轮组</li><li>可坐可躺</li></ul><p>以上为本地联调演示商品，文案与图片仅用于展示。</p><p><img src="https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&w=800&q=80" alt="轻便可折叠婴儿推车（演示）" style="max-width:100%;height:auto;"/></p><p><img src="https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&w=800&q=80" alt="轻便可折叠婴儿推车（演示）" style="max-width:100%;height:auto;"/></p></div>',
  83, NULL, 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&w=800&q=80', '["https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&w=800&q=80", "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&w=800&q=80"]',
  450, 1, b'1', 69900, 89900, 42000, 40,
  '1', 1, 69, b'0',
  0, 365, 0, 'seed-cat', 'seed-cat', b'0', 1
);
SET @spu_id := LAST_INSERT_ID();
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 5, "valueName": "黑色"}]', 69900, 89900, 42000, CONCAT('SC', @spu_id, '-', 69900), 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&w=800&q=80',
  13, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 6, "valueName": "蓝色"}]', 70400, 89900, 42000, CONCAT('SC', @spu_id, '-', 70400), 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&w=800&q=80',
  13, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
INSERT INTO product_sku (
  spu_id, properties, price, market_price, cost_price, bar_code, pic_url, stock, weight, volume,
  first_brokerage_price, second_brokerage_price, sales_count, creator, updater, deleted, tenant_id
) VALUES (
  @spu_id, '[{"propertyId": 1, "propertyName": "颜色", "valueId": 7, "valueName": "白色"}]', 70900, 89900, 42000, CONCAT('SC', @spu_id, '-', 70900), 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&w=800&q=80',
  13, 0.5, 0.002, 0, 0, 0, 'seed-cat', 'seed-cat', b'0', 1
);
UPDATE product_spu SET price=69900, stock=39 WHERE id=@spu_id;
COMMIT;
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
