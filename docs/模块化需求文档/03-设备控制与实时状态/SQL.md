# 设备控制与实时状态模块 SQL

## 1. 设备指令表

```sql
CREATE TABLE lh_device_command (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    family_id BIGINT NOT NULL,
    device_id BIGINT NOT NULL,
    operator_user_id BIGINT NOT NULL,
    client_request_id VARCHAR(128) NOT NULL,
    action VARCHAR(64) NOT NULL COMMENT 'setProperty/startRecord/stopRecord 等',
    request_json JSON NOT NULL COMMENT '指令请求内容',
    status VARCHAR(32) NOT NULL DEFAULT 'CREATED' COMMENT 'CREATED/SENT/SUCCESS/FAILED/TIMEOUT/CANCELLED',
    result_json JSON NULL COMMENT '执行结果',
    error_code VARCHAR(64) NULL,
    error_message VARCHAR(255) NULL,
    sent_at DATETIME NULL,
    completed_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_command_client_request (device_id, operator_user_id, client_request_id),
    KEY idx_command_device_time (device_id, created_at),
    KEY idx_command_family_time (family_id, created_at),
    KEY idx_command_status (status)
) COMMENT='设备控制指令表';
```

## 2. 设备属性历史表

```sql
CREATE TABLE lh_device_property_history (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    family_id BIGINT NOT NULL,
    device_id BIGINT NOT NULL,
    source VARCHAR(32) NOT NULL COMMENT 'USER/AUTOMATION/SYSTEM/DEVICE_REPORT',
    source_id BIGINT NULL COMMENT '来源ID，例如 commandId 或 automationId',
    properties JSON NOT NULL COMMENT '属性快照',
    changed_properties JSON NULL COMMENT '本次变化字段',
    reported_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_history_device_time (device_id, reported_at),
    KEY idx_history_family_time (family_id, reported_at)
) COMMENT='设备属性历史表';
```
