-- 首页轮播 Banner（position=1），可重复执行：先软删同批再插入
-- 用法：mysql -uroot -p123456 --default-character-set=utf8mb4 ruoyi-vue-pro < scripts/seed-home-banners.sql

USE `ruoyi-vue-pro`;

UPDATE promotion_banner
SET deleted = b'1', updater = 'seed-banner'
WHERE creator = 'seed-banner' AND deleted = b'0';

INSERT INTO promotion_banner
  (title, pic_url, url, status, sort, position, memo, browse_count, creator, updater, deleted, tenant_id)
VALUES
('数码好物季', 'https://images.unsplash.com/photo-1498049794561-7780e7231661?auto=format&fit=crop&w=1400&q=80', '/category?categoryId=38', 0, 1, 1, '首页轮播-电子数码', 0, 'seed-banner', 'seed-banner', b'0', 1),
('家电焕新', 'https://images.unsplash.com/photo-1556911220-bff31c812dba?auto=format&fit=crop&w=1400&q=80', '/category?categoryId=30', 0, 2, 1, '首页轮播-家用电器', 0, 'seed-banner', 'seed-banner', b'0', 1),
('童装上新', 'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?auto=format&fit=crop&w=1400&q=80', '/category?categoryId=15', 0, 3, 1, '首页轮播-童装童鞋', 0, 'seed-banner', 'seed-banner', b'0', 1),
('美妆护肤', 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?auto=format&fit=crop&w=1400&q=80', '/category?categoryId=41', 0, 4, 1, '首页轮播-美妆个护', 0, 'seed-banner', 'seed-banner', b'0', 1),
('母婴精选', 'https://images.unsplash.com/photo-1515488042361-ee00e0ddd4e4?auto=format&fit=crop&w=1400&q=80', '/category?categoryId=47', 0, 5, 1, '首页轮播-母婴用品', 0, 'seed-banner', 'seed-banner', b'0', 1);
