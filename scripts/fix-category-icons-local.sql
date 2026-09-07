-- 分类图标改为本地扁平电商风格 SVG（uniapp /static/category/{id}.svg）
USE `ruoyi-vue-pro`;

UPDATE product_category
SET pic_url = CONCAT('/static/category/', id, '.svg'),
    updater = 'fix-cat-icon',
    update_time = NOW()
WHERE deleted = b'0'
  AND id IN (
    15,30,38,41,47,
    19,28,29,60,61,62,63,64,65,
    31,32,34,35,36,37,66,67,68,
    39,40,69,70,71,72,73,74,75,
    42,43,44,45,46,76,77,78,79,
    48,49,50,51,52,80,81,82,83
  );

SELECT id, parent_id, name, pic_url FROM product_category WHERE deleted=b'0' ORDER BY parent_id, id;
