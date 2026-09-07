-- 为商城应用 (pay_app.id=1, app_key=mall) 补齐本地联调支付渠道
-- 幂等：仅当同一 app_id + code 且 creator=seed-pay 不存在时插入
-- 用法：mysql -uroot -p123456 -D ruoyi_vue_pro --default-character-set=utf8mb4 < scripts/seed-pay-channels.sql

INSERT INTO pay_channel (
  code, status, remark, fee_rate, app_id, config,
  creator, create_time, updater, update_time, deleted, tenant_id
)
SELECT
  'mock', 0, '本地联调模拟支付', 0, 1,
  JSON_OBJECT(
    '@class', 'cn.iocoder.yudao.module.pay.framework.pay.core.client.impl.NonePayClientConfig',
    'name', 'mock-conf'
  ),
  'seed-pay', NOW(), 'seed-pay', NOW(), b'0', 1
FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM pay_channel
  WHERE app_id = 1 AND code = 'mock' AND deleted = b'0'
);

INSERT INTO pay_channel (
  code, status, remark, fee_rate, app_id, config,
  creator, create_time, updater, update_time, deleted, tenant_id
)
SELECT
  'wallet', 0, '本地联调钱包支付', 0, 1,
  JSON_OBJECT(
    '@class', 'cn.iocoder.yudao.module.pay.framework.pay.core.client.impl.NonePayClientConfig',
    'name', 'wallet-conf'
  ),
  'seed-pay', NOW(), 'seed-pay', NOW(), b'0', 1
FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM pay_channel
  WHERE app_id = 1 AND code = 'wallet' AND deleted = b'0'
);

-- 已存在但缺 @class 时补齐（避免渠道列表接口 500）
UPDATE pay_channel
SET config = JSON_OBJECT(
  '@class', 'cn.iocoder.yudao.module.pay.framework.pay.core.client.impl.NonePayClientConfig',
  'name', 'mock-conf'
)
WHERE app_id = 1 AND code = 'mock' AND deleted = b'0'
  AND (JSON_EXTRACT(config, '$."@class"') IS NULL OR JSON_UNQUOTE(JSON_EXTRACT(config, '$."@class"')) = '');

UPDATE pay_channel
SET config = JSON_OBJECT(
  '@class', 'cn.iocoder.yudao.module.pay.framework.pay.core.client.impl.NonePayClientConfig',
  'name', 'wallet-conf'
)
WHERE app_id = 1 AND code = 'wallet' AND deleted = b'0'
  AND (JSON_EXTRACT(config, '$."@class"') IS NULL OR JSON_UNQUOTE(JSON_EXTRACT(config, '$."@class"')) = '');

SELECT id, app_id, code, status, config FROM pay_channel WHERE app_id = 1 AND deleted = b'0';
