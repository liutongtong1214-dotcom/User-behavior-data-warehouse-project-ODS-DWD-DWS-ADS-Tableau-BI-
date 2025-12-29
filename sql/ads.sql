-- Active: 1766845522661@@127.0.0.1@3306@user_behavior_dw
CREATE TABLE ads_dau_day (
    dt DATE COMMENT '日期',
    dau INT COMMENT '日活用户数'
) COMMENT='日活用户指标表';
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
