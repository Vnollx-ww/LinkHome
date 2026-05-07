# 能耗统计与消息中心模块 SQL

## 1. 能耗采样表

```sql
CREATE TABLE lh_energy_sample (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    family_id BIGINT NOT NULL,
    device_id BIGINT NOT NULL,
    power_watt DECIMAL(10,2) NOT NULL COMMENT '当前功率W',
    energy_kwh DECIMAL(12,6) NOT NULL COMMENT '本采样周期估算电量',
    sample_interval_seconds INT NOT NULL DEFAULT 60,
    sampled_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_energy_sample_device_time (device_id, sampled_at),
    KEY idx_energy_sample_family_time (family_id, sampled_at)
) COMMENT='能耗采样表';
```

## 2. 能耗聚合表

```sql
CREATE TABLE lh_energy_aggregate (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    family_id BIGINT NOT NULL,
    device_id BIGINT NULL COMMENT '为空表示家庭总计',
    aggregate_type VARCHAR(32) NOT NULL COMMENT 'HOUR/DAY/MONTH',
    aggregate_time DATETIME NOT NULL COMMENT '聚合周期开始时间',
    energy_kwh DECIMAL(12,6) NOT NULL DEFAULT 0,
    estimated_cost DECIMAL(10,2) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_energy_aggregate (family_id, device_id, aggregate_type, aggregate_time),
    KEY idx_energy_aggregate_family_time (family_id, aggregate_type, aggregate_time)
) COMMENT='能耗聚合表';
```

## 3. 消息表

```sql
CREATE TABLE lh_message (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    family_id BIGINT NULL,
    user_id BIGINT NOT NULL COMMENT '消息接收人',
    message_type VARCHAR(32) NOT NULL COMMENT 'ALERT/DEVICE/SCENE/SYSTEM/ENERGY',
    level VARCHAR(32) NOT NULL DEFAULT 'INFO' COMMENT 'INFO/WARNING/CRITICAL',
    title VARCHAR(128) NOT NULL,
    content VARCHAR(512) NOT NULL,
    target_type VARCHAR(64) NULL COMMENT 'DEVICE/ALERT/SCENE/FAMILY',
    target_id BIGINT NULL,
    read_status TINYINT NOT NULL DEFAULT 0 COMMENT '0未读 1已读',
    read_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_message_user_time (user_id, created_at),
    KEY idx_message_user_read (user_id, read_status),
    KEY idx_message_family_time (family_id, created_at),
    KEY idx_message_type (message_type)
) COMMENT='消息表';
```

## 4. 通知偏好表

```sql
CREATE TABLE lh_notification_preference (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    family_id BIGINT NULL,
    message_type VARCHAR(32) NOT NULL,
    app_push_enabled TINYINT NOT NULL DEFAULT 1,
    in_app_enabled TINYINT NOT NULL DEFAULT 1,
    quiet_start_time TIME NULL,
    quiet_end_time TIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_notify_pref (user_id, family_id, message_type),
    KEY idx_notify_user (user_id)
) COMMENT='通知偏好表';
```
