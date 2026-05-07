# 安防监控与告警模块 SQL

## 1. 告警规则表

```sql
CREATE TABLE lh_alert_rule (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    family_id BIGINT NOT NULL,
    device_id BIGINT NULL COMMENT '为空表示同类型设备通用规则',
    alert_type VARCHAR(64) NOT NULL,
    level VARCHAR(32) NOT NULL COMMENT 'INFO/WARNING/CRITICAL',
    rule_json JSON NOT NULL COMMENT '触发条件',
    enabled TINYINT NOT NULL DEFAULT 1,
    cooldown_seconds INT NOT NULL DEFAULT 300,
    last_triggered_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted TINYINT NOT NULL DEFAULT 0,
    KEY idx_alert_rule_family (family_id),
    KEY idx_alert_rule_device (device_id),
    KEY idx_alert_rule_type (alert_type)
) COMMENT='告警规则表';
```

## 2. 告警事件表

```sql
CREATE TABLE lh_alert_event (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    family_id BIGINT NOT NULL,
    device_id BIGINT NULL,
    device_name_snapshot VARCHAR(64) NULL,
    room_name_snapshot VARCHAR(64) NULL,
    alert_type VARCHAR(64) NOT NULL,
    level VARCHAR(32) NOT NULL,
    title VARCHAR(128) NOT NULL,
    content VARCHAR(512) NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'NEW' COMMENT 'NEW/NOTIFIED/ACKNOWLEDGED/RESOLVED/IGNORED',
    trigger_data JSON NULL,
    trigger_count INT NOT NULL DEFAULT 1,
    first_triggered_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_triggered_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    acknowledged_by BIGINT NULL,
    acknowledged_at DATETIME NULL,
    resolved_by BIGINT NULL,
    resolved_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_alert_family_time (family_id, created_at),
    KEY idx_alert_device_time (device_id, created_at),
    KEY idx_alert_status (status),
    KEY idx_alert_level (level)
) COMMENT='告警事件表';
```

## 3. 摄像头媒体记录表

```sql
CREATE TABLE lh_camera_media_record (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    family_id BIGINT NOT NULL,
    device_id BIGINT NOT NULL,
    media_type VARCHAR(32) NOT NULL COMMENT 'SNAPSHOT/RECORDING',
    media_url VARCHAR(512) NULL,
    duration_seconds INT NULL,
    created_by BIGINT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_camera_media_device_time (device_id, created_at),
    KEY idx_camera_media_family_time (family_id, created_at)
) COMMENT='摄像头媒体记录表';
```
