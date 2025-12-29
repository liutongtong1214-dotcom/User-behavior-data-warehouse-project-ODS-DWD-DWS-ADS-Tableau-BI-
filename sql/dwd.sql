-- Active: 1766845522661@@127.0.0.1@3306
CREATE TABLE dwd_user_behavior (
    user_id BIGINT COMMENT '用户ID',
    item_id BIGINT COMMENT '商品ID',
    category_id BIGINT COMMENT '商品类目ID',
    behavior VARCHAR(10) COMMENT '行为类型',
    is_pv TINYINT COMMENT '是否浏览',
    is_cart TINYINT COMMENT '是否加购',
    is_fav TINYINT COMMENT '是否收藏',
    is_buy TINYINT COMMENT '是否购买',
    ts BIGINT COMMENT '行为时间戳',
    dt DATE COMMENT '行为日期'
) COMMENT='用户行为明细表（DWD层）';
SELECT DATABASE();
INSERT INTO dwd_user_behavior
SELECT
    user_id,
    item_id,
    category_id,
    behavior,

    CASE WHEN behavior = 'pv'   THEN 1 ELSE 0 END AS is_pv,
    CASE WHEN behavior = 'cart' THEN 1 ELSE 0 END AS is_cart,
    CASE WHEN behavior = 'fav'  THEN 1 ELSE 0 END AS is_fav,
    CASE WHEN behavior = 'buy'  THEN 1 ELSE 0 END AS is_buy,

    ts,
    dt
FROM (
    SELECT DISTINCT
        user_id,
        item_id,
        category_id,
        behavior,
        ts,
        dt
    FROM ods_user_behavior
    WHERE behavior IN ('pv', 'cart', 'fav', 'buy')
) t;
SELECT behavior, COUNT(*) 
FROM dwd_user_behavior
GROUP BY behavior;
SELECT
    SUM(is_pv),
    SUM(is_cart),
    SUM(is_fav),
    SUM(is_buy)
FROM dwd_user_behavior;

SELECT *
FROM dws_user_day
LIMIT 100;

SELECT
    SUM(pv_cnt),
    SUM(cart_cnt),
    SUM(fav_cnt),
    SUM(buy_cnt)
FROM dws_user_day;

SELECT
    SUM(is_pv),
    SUM(is_cart),
    SUM(is_fav),
    SUM(is_buy)
FROM dwd_user_behavior;
