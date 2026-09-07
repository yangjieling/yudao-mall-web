-- 修复本地库：积分商城表缺 tenant_id，导致 app-api /promotion/point-activity/page 报 500
-- （多租户插件会往 SQL 注入 tenant_id，列不存在即系统异常）
-- 用法：mysql -uroot -p123456 -D ruoyi_vue_pro --default-character-set=utf8mb4 < scripts/fix-point-activity-tenant.sql

-- promotion_point_activity
SET @col := (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'promotion_point_activity'
    AND COLUMN_NAME = 'tenant_id'
);
SET @sql := IF(
  @col = 0,
  'ALTER TABLE promotion_point_activity ADD COLUMN tenant_id bigint NOT NULL DEFAULT 0 COMMENT ''租户编号''',
  'SELECT ''promotion_point_activity.tenant_id already exists'' AS info'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- promotion_point_product
SET @col := (
  SELECT COUNT(*) FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'promotion_point_product'
    AND COLUMN_NAME = 'tenant_id'
);
SET @sql := IF(
  @col = 0,
  'ALTER TABLE promotion_point_product ADD COLUMN tenant_id bigint NOT NULL DEFAULT 0 COMMENT ''租户编号''',
  'SELECT ''promotion_point_product.tenant_id already exists'' AS info'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SHOW COLUMNS FROM promotion_point_activity LIKE 'tenant%';
SHOW COLUMNS FROM promotion_point_product LIKE 'tenant%';
