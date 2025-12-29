CREATE TABLE ods_user_behavior (
    user_id BIGINT COMMENT '用户ID',
    item_id BIGINT COMMENT '商品ID',
    category_id BIGINT COMMENT '商品类目ID',
    behavior VARCHAR(10) COMMENT '行为类型',
    ts BIGINT COMMENT '行为时间戳(秒)',
    dt DATE COMMENT '行为日期'
) COMMENT='用户行为原始表';


SELECT behavior, COUNT(*) 
FROM ods_user_behavior
GROUP BY behavior;
