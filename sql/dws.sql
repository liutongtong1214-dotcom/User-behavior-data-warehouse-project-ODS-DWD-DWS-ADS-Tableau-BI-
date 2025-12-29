-- Active: 1766845522661@@127.0.0.1@3306@user_behavior_dw
CREATE TABLE dws_user_day (
    user_id BIGINT COMMENT '用户ID',
    dt DATE COMMENT '日期',
    pv_cnt INT COMMENT '浏览次数',
    cart_cnt INT COMMENT '加购次数',
    fav_cnt INT COMMENT '收藏次数',
    buy_cnt INT COMMENT '购买次数'
) COMMENT='用户行为日汇总表（DWS层）';

TRUNCATE TABLE dws_user_day;

INSERT INTO dws_user_day
SELECT
    user_id,
    dt,
    SUM(is_pv)   AS pv_cnt,
    SUM(is_cart) AS cart_cnt,
    SUM(is_fav)  AS fav_cnt,
    SUM(is_buy)  AS buy_cnt
FROM dwd_user_behavior
GROUP BY user_id, dt;

SELECT *
FROM dws_user_day
LIMIT 10;

SELECT
    SUM(pv_cnt),
    SUM(cart_cnt),
    SUM(fav_cnt),
    SUM(buy_cnt)
FROM dws_user_day;


CREATE TABLE ads_dau_day (
    dt DATE COMMENT '日期',
    dau INT COMMENT '日活用户数'
) COMMENT='日活用户指标表';
TRUNCATE TABLE ads_dau_day;
INSERT INTO ads_dau_day
SELECT
    dt,
    COUNT(DISTINCT user_id) AS dau
FROM dws_user_day
WHERE pv_cnt > 0
GROUP BY dt;

CREATE TABLE ads_user_conversion_day (
    dt DATE COMMENT '日期',
    uv INT COMMENT '访问用户数',
    buy_uv INT COMMENT '购买用户数',
    conversion_rate DECIMAL(10,4) COMMENT '转化率'
) COMMENT='用户转化率指标表';
TRUNCATE TABLE ads_user_conversion_day;
INSERT INTO ads_user_conversion_day
SELECT
    dt,
    COUNT(DISTINCT user_id) AS uv,
    COUNT(DISTINCT CASE WHEN buy_cnt > 0 THEN user_id END) AS buy_uv,
    COUNT(DISTINCT CASE WHEN buy_cnt > 0 THEN user_id END)
    / COUNT(DISTINCT user_id) AS conversion_rate
FROM dws_user_day
WHERE pv_cnt > 0
GROUP BY dt;

CREATE TABLE ads_item_top10_day (
    dt DATE COMMENT '日期',
    item_id BIGINT COMMENT '商品ID',
    buy_cnt INT COMMENT '购买次数'
) COMMENT='每日商品购买Top10';

TRUNCATE TABLE ads_item_top10_day;
INSERT INTO ads_item_top10_day
SELECT
    dt,
    item_id,
    SUM(is_buy) AS buy_cnt
FROM dwd_user_behavior
GROUP BY dt, item_id
ORDER BY buy_cnt DESC
LIMIT 10;

SELECT * FROM ads_dau_day ORDER BY dt LIMIT 10;
SELECT * FROM ads_user_conversion_day ORDER BY dt LIMIT 10;
SELECT * FROM ads_item_top10_day ORDER BY dt;





select * from ads_mau_day order by dt limit 10;


CREATE TABLE ads_order_conversion_day (
    dt DATE,
    order_uv BIGINT,
    dau BIGINT,
    order_rate DECIMAL(10,4)
);
INSERT INTO ads_order_conversion_day
SELECT
    a.dt,
    a.order_uv,
    b.dau,
    a.order_uv / b.dau AS order_rate
FROM
(
    SELECT dt, COUNT(DISTINCT user_id) AS order_uv
    FROM dwd_user_behavior
    WHERE behavior = 'buy'
    GROUP BY dt
) a
JOIN ads_dau_day b
ON a.dt = b.dt;


CREATE TABLE dws_user_active_day (
    user_id BIGINT,
    dt DATE
);
INSERT INTO dws_user_active_day
SELECT DISTINCT
    user_id,
    dt
FROM dwd_user_behavior
WHERE behavior = 'pv';

CREATE TABLE ads_retention_1d (
    dt DATE,
    new_uv BIGINT,
    retained_uv BIGINT,
    retention_rate DECIMAL(10,4)
);

INSERT INTO ads_retention_1d
SELECT
    a.dt,
    COUNT(DISTINCT a.user_id) AS new_uv,
    COUNT(DISTINCT b.user_id) AS retained_uv,
    COUNT(DISTINCT b.user_id) / COUNT(DISTINCT a.user_id) AS retention_rate
FROM dws_user_active_day a
LEFT JOIN dws_user_active_day b
ON a.user_id = b.user_id
AND b.dt = DATE_ADD(a.dt, INTERVAL 1 DAY)
GROUP BY a.dt;


