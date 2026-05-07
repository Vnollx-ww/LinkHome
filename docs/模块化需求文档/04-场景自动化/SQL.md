# 场景自动化模块 SQL

## 1. 场景表

```sql
CREATE TABLE lh_scene (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    family_id BIGINT NOT NULL,
    name VARCHAR(64) NOT NULL,
    icon VARCHAR(64) NULL,
    color VARCHAR(32) NULL,
    scene_type VARCHAR(32) NOT NULL COMMENT 'TAP_TO_RUN/AUTOMATION',
    enabled TINYINT NOT NULL DEFAULT 1,
    sort_order INT NOT NULL DEFAULT 0,
    created_by BIGINT NOT NULL,
    updated_by BIGINT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted TINYINT NOT NULL DEFAULT 0,
    KEY idx_scene_family_type (family_id, scene_type),
    KEY idx_scene_enabled (enabled)
) COMMENT='场景表';
```

## 2. 自动化规则表

```sql
CREATE TABLE lh_automation_rule (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    scene_id BIGINT NOT NULL,
    family_id BIGINT NOT NULL,
    trigger_json JSON NOT NULL COMMENT '触发器配置',
    condition_json JSON NULL COMMENT '条件配置',
    cooldown_seconds INT NOT NULL DEFAULT 60,
    last_triggered_at DATETIME NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'NORMAL' COMMENT 'NORMAL/INVALID/DISABLED',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_rule_family (family_id),
    KEY idx_rule_scene (scene_id),
    KEY idx_rule_status (status)
) COMMENT='自动化规则表';
```

## 3. 场景动作表

```sql
CREATE TABLE lh_scene_action (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    scene_id BIGINT NOT NULL,
    family_id BIGINT NOT NULL,
    action_type VARCHAR(32) NOT NULL COMMENT 'DEVICE_CONTROL/NOTIFY/DELAY/EXECUTE_SCENE',
    target_id BIGINT NULL COMMENT '目标设备或场景ID',
    action_json JSON NOT NULL COMMENT '动作配置',
    sort_order INT NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted TINYINT NOT NULL DEFAULT 0,
    KEY idx_action_scene_sort (scene_id, sort_order),
    KEY idx_action_family (family_id)
) COMMENT='场景动作表';
```

## 4. 场景执行日志表

```sql
CREATE TABLE lh_scene_execution_log (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    family_id BIGINT NOT NULL,
    scene_id BIGINT NOT NULL,
    trigger_type VARCHAR(32) NOT NULL COMMENT 'MANUAL/TIME/DEVICE_EVENT/SYSTEM',
    trigger_user_id BIGINT NULL,
    status VARCHAR(32) NOT NULL COMMENT 'RUNNING/SUCCESS/PARTIAL_FAILED/FAILED',
    result_json JSON NULL,
    started_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    finished_at DATETIME NULL,
    KEY idx_scene_log_scene_time (scene_id, started_at),
    KEY idx_scene_log_family_time (family_id, started_at),
    KEY idx_scene_log_status (status)
) COMMENT='场景执行日志表';
```
