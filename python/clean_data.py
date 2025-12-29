import pandas as pd
import pymysql
from datetime import datetime

# 1. 读取 CSV
df = pd.read_csv(
    "D:\UserBehavior.csv",
    names=["user_id", "item_id", "category_id", "behavior", "ts"]
)

# 2. 时间戳转日期
# ts 转为数值，非法的变成 NaN
df["ts"] = pd.to_numeric(df["ts"], errors="coerce")

# 过滤 ts 为空的行
df = df.dropna(subset=["ts"])

# 转 int
df["ts"] = df["ts"].astype(int)

# 时间戳转日期
df["dt"] = df["ts"].apply(
    lambda x: datetime.fromtimestamp(x).strftime("%Y-%m-%d")
)
# 3. 连接 MySQL
conn = pymysql.connect(
    host="localhost",
    user="root",
    password="wuyuzi10",
    database="user_behavior_dw",
    charset="utf8mb4"
)

cursor = conn.cursor()

# 4. 插入数据（示例：先插前 10 万行，避免卡死）
insert_sql = """
INSERT INTO ods_user_behavior
(user_id, item_id, category_id, behavior, ts, dt)
VALUES (%s, %s, %s, %s, %s, %s)
"""

data = df.head(100000).values.tolist()
cursor.executemany(insert_sql, data)

conn.commit()
cursor.close()
conn.close()

print("ODS 数据导入完成")
