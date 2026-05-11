CREATE DATABASE IF NOT EXISTS linkhome DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE linkhome;

CREATE TABLE IF NOT EXISTS lh_user (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    username VARCHAR(64) NOT NULL COMMENT '用户名或昵称',
    phone VARCHAR(32) NULL COMMENT '手机号',
    email VARCHAR(128) NULL COMMENT '邮箱',
    password_hash VARCHAR(255) NOT NULL COMMENT 'BCrypt 密码哈希',
    avatar_url VARCHAR(512) NULL COMMENT '头像地址',
    status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE' COMMENT 'ACTIVE/DISABLED',
    last_login_at DATETIME NULL COMMENT '最后登录时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '软删除标记，0未删除，1已删除',
    UNIQUE KEY uk_user_phone (phone),
    UNIQUE KEY uk_user_email (email),
    KEY idx_user_status (status)
) COMMENT='用户表';

CREATE TABLE IF NOT EXISTS lh_family (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '家庭ID',
    name VARCHAR(64) NOT NULL COMMENT '家庭名称',
    owner_user_id BIGINT NOT NULL COMMENT '创建者用户ID',
    address VARCHAR(255) NULL COMMENT '家庭地址',
    city VARCHAR(64) NULL COMMENT '城市',
    timezone VARCHAR(64) NOT NULL DEFAULT 'Asia/Shanghai' COMMENT '家庭所在时区',
    avatar_url VARCHAR(512) NULL COMMENT '家庭头像地址',
    status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE' COMMENT 'ACTIVE/DISSOLVED',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '软删除标记，0未删除，1已删除',
    KEY idx_family_owner (owner_user_id),
    KEY idx_family_status (status)
) COMMENT='家庭表';

CREATE TABLE IF NOT EXISTS lh_family_member (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '家庭成员ID',
    family_id BIGINT NOT NULL COMMENT '家庭ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    role VARCHAR(32) NOT NULL COMMENT 'OWNER/ADMIN/MEMBER/GUEST',
    nickname VARCHAR(64) NULL COMMENT '家庭内昵称',
    status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE' COMMENT 'ACTIVE/REMOVED/PENDING',
    joined_at DATETIME NULL COMMENT '加入时间',
    expire_at DATETIME NULL COMMENT '访客过期时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '软删除标记，0未删除，1已删除',
    UNIQUE KEY uk_family_user (family_id, user_id),
    KEY idx_member_user (user_id),
    KEY idx_member_family_role (family_id, role),
    KEY idx_member_status (status)
) COMMENT='家庭成员表';

CREATE TABLE IF NOT EXISTS lh_family_invite (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '邀请ID',
    family_id BIGINT NOT NULL COMMENT '家庭ID',
    inviter_user_id BIGINT NOT NULL COMMENT '邀请人用户ID',
    invite_code VARCHAR(64) NOT NULL COMMENT '邀请码',
    target_phone VARCHAR(32) NULL COMMENT '被邀请手机号',
    target_email VARCHAR(128) NULL COMMENT '被邀请邮箱',
    role VARCHAR(32) NOT NULL DEFAULT 'MEMBER' COMMENT '邀请加入后的家庭角色',
    max_use_count INT NOT NULL DEFAULT 1 COMMENT '最大可使用次数',
    used_count INT NOT NULL DEFAULT 0 COMMENT '已使用次数',
    expire_at DATETIME NOT NULL COMMENT '过期时间',
    status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE' COMMENT 'ACTIVE/USED/EXPIRED/CANCELLED',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '软删除标记，0未删除，1已删除',
    UNIQUE KEY uk_invite_code (invite_code),
    KEY idx_invite_family (family_id),
    KEY idx_invite_expire (expire_at),
    KEY idx_invite_status (status)
) COMMENT='家庭邀请表';

CREATE TABLE IF NOT EXISTS lh_audit_log (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '审计日志ID',
    family_id BIGINT NULL COMMENT '家庭ID',
    operator_user_id BIGINT NOT NULL COMMENT '操作人用户ID',
    action VARCHAR(64) NOT NULL COMMENT '操作类型',
    target_type VARCHAR(64) NOT NULL COMMENT '目标类型',
    target_id BIGINT NULL COMMENT '目标ID',
    detail_json JSON NULL COMMENT '操作详情',
    ip_address VARCHAR(64) NULL COMMENT '客户端IP地址',
    user_agent VARCHAR(512) NULL COMMENT '客户端User-Agent',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    KEY idx_audit_family_time (family_id, created_at),
    KEY idx_audit_operator_time (operator_user_id, created_at),
    KEY idx_audit_action (action)
) COMMENT='审计日志表';

CREATE TABLE IF NOT EXISTS lh_room (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '房间ID',
    family_id BIGINT NOT NULL COMMENT '家庭ID',
    name VARCHAR(64) NOT NULL COMMENT '房间名称',
    icon VARCHAR(64) NULL COMMENT '房间图标',
    sort_order INT NOT NULL DEFAULT 0 COMMENT '排序值，越小越靠前',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '软删除标记，0未删除，1已删除',
    KEY idx_room_family_sort (family_id, sort_order),
    UNIQUE KEY uk_room_family_name (family_id, name, deleted)
) COMMENT='房间表';

CREATE TABLE IF NOT EXISTS lh_device_product (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '设备产品类型ID',
    product_key VARCHAR(64) NOT NULL COMMENT '产品唯一标识',
    name VARCHAR(64) NOT NULL COMMENT '产品名称',
    category VARCHAR(64) NOT NULL COMMENT 'LIGHT/AIR_CONDITIONER/CURTAIN/PLUG/SENSOR/CAMERA',
    icon VARCHAR(64) NULL COMMENT '产品图标',
    protocol VARCHAR(32) NOT NULL DEFAULT 'MOCK' COMMENT 'MOCK/WIFI/ZIGBEE/BLE',
    property_schema JSON NOT NULL COMMENT '属性模型定义和默认属性',
    action_schema JSON NULL COMMENT '动作模型定义',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '软删除标记，0未删除，1已删除',
    UNIQUE KEY uk_product_key (product_key),
    KEY idx_product_category (category)
) COMMENT='设备产品类型表';

CREATE TABLE IF NOT EXISTS lh_device (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '设备ID',
    family_id BIGINT NOT NULL COMMENT '家庭ID',
    room_id BIGINT NOT NULL COMMENT '房间ID',
    product_id BIGINT NOT NULL COMMENT '产品类型ID',
    device_name VARCHAR(64) NOT NULL COMMENT '设备名称',
    device_code VARCHAR(128) NOT NULL COMMENT '设备唯一编码',
    category VARCHAR(64) NOT NULL COMMENT '设备分类',
    protocol VARCHAR(32) NOT NULL DEFAULT 'MOCK' COMMENT '设备协议',
    icon VARCHAR(64) NULL COMMENT '设备图标',
    online_status VARCHAR(32) NOT NULL DEFAULT 'ONLINE' COMMENT 'ONLINE/OFFLINE/FAULT/PAIRING',
    properties_json JSON NULL COMMENT '当前属性快照（与 lh_device_property 二选一，简化 MVP 直接存放在主表）',
    favorite TINYINT NOT NULL DEFAULT 0 COMMENT '是否收藏，0否，1是',
    firmware_version VARCHAR(64) NULL COMMENT '固件版本',
    last_online_at DATETIME NULL COMMENT '最后上线时间',
    last_offline_at DATETIME NULL COMMENT '最后离线时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '软删除标记，0未删除，1已删除',
    UNIQUE KEY uk_device_code (device_code),
    KEY idx_device_family_room (family_id, room_id),
    KEY idx_device_family_category (family_id, category),
    KEY idx_device_online (online_status)
) COMMENT='设备实例表';

CREATE TABLE IF NOT EXISTS lh_device_property (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '设备属性ID',
    device_id BIGINT NOT NULL COMMENT '设备ID',
    family_id BIGINT NOT NULL COMMENT '家庭ID',
    properties JSON NOT NULL COMMENT '当前设备属性快照',
    version BIGINT NOT NULL DEFAULT 1 COMMENT '属性版本号，用于并发控制',
    reported_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '属性上报时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY uk_property_device (device_id),
    KEY idx_property_family (family_id),
    KEY idx_property_reported (reported_at)
) COMMENT='设备属性表';

-- 阶段 3：设备控制与实时状态

CREATE TABLE IF NOT EXISTS lh_device_command (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '指令ID',
    family_id BIGINT NOT NULL COMMENT '家庭ID',
    device_id BIGINT NOT NULL COMMENT '设备ID',
    operator_user_id BIGINT NULL COMMENT '操作人用户ID，自动化触发时为空',
    action VARCHAR(64) NOT NULL DEFAULT 'SET_PROPERTY' COMMENT '指令动作',
    payload_json JSON NULL COMMENT '指令载荷',
    status VARCHAR(32) NOT NULL DEFAULT 'PENDING' COMMENT 'PENDING/SUCCESS/FAILED',
    error_message VARCHAR(512) NULL COMMENT '失败原因',
    request_id VARCHAR(64) NULL COMMENT '幂等请求 ID',
    before_json JSON NULL COMMENT '执行前属性快照',
    after_json JSON NULL COMMENT '执行后属性快照',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    finished_at DATETIME NULL COMMENT '完成时间',
    KEY idx_command_device_time (device_id, created_at),
    KEY idx_command_family_time (family_id, created_at),
    UNIQUE KEY uk_command_request (family_id, request_id)
) COMMENT='设备控制指令表';

-- 阶段 4：场景与自动化

CREATE TABLE IF NOT EXISTS lh_scene (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '场景ID',
    family_id BIGINT NOT NULL COMMENT '家庭ID',
    name VARCHAR(64) NOT NULL COMMENT '场景名称',
    icon VARCHAR(64) NULL COMMENT '场景图标',
    type VARCHAR(32) NOT NULL DEFAULT 'MANUAL' COMMENT 'MANUAL/AUTOMATION',
    enabled TINYINT NOT NULL DEFAULT 1 COMMENT '是否启用',
    trigger_json JSON NULL COMMENT '触发器配置',
    actions_json JSON NOT NULL COMMENT '动作列表配置',
    cooldown_seconds INT NOT NULL DEFAULT 0 COMMENT '冷却时间，秒',
    last_triggered_at DATETIME NULL COMMENT '上次触发时间',
    last_triggered_minute VARCHAR(32) NULL COMMENT '上次触发的分钟键，用于定时去重',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    deleted TINYINT NOT NULL DEFAULT 0 COMMENT '软删除标记',
    KEY idx_scene_family (family_id),
    KEY idx_scene_type (family_id, type)
) COMMENT='场景与自动化规则表';

CREATE TABLE IF NOT EXISTS lh_scene_execution (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '场景执行ID',
    scene_id BIGINT NOT NULL COMMENT '场景ID',
    family_id BIGINT NOT NULL COMMENT '家庭ID',
    trigger_source VARCHAR(32) NOT NULL COMMENT 'MANUAL/TIME/DEVICE_PROPERTY',
    status VARCHAR(32) NOT NULL COMMENT 'SUCCESS/PARTIAL/FAILED/SKIPPED',
    message VARCHAR(255) NULL COMMENT '执行结果摘要',
    items_json JSON NULL COMMENT '逐设备执行明细',
    started_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '开始时间',
    finished_at DATETIME NULL COMMENT '完成时间',
    KEY idx_execution_scene_time (scene_id, started_at),
    KEY idx_execution_family_time (family_id, started_at)
) COMMENT='场景执行日志表';

-- 阶段 5：安防监控与告警

CREATE TABLE IF NOT EXISTS lh_alarm_rule (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '告警规则ID',
    family_id BIGINT NOT NULL COMMENT '家庭ID',
    device_id BIGINT NULL COMMENT '指定设备，NULL 表示分类匹配',
    target_category VARCHAR(64) NULL COMMENT '设备分类匹配，如 SENSOR/CAMERA',
    name VARCHAR(64) NOT NULL COMMENT '规则名称',
    level VARCHAR(32) NOT NULL DEFAULT 'WARNING' COMMENT 'INFO/WARNING/CRITICAL',
    property_key VARCHAR(64) NOT NULL COMMENT '触发属性',
    operator VARCHAR(8) NOT NULL DEFAULT 'EQ' COMMENT 'EQ/NEQ/GT/GTE/LT/LTE',
    threshold_value VARCHAR(64) NOT NULL COMMENT '阈值',
    active_start VARCHAR(8) NULL COMMENT '生效开始 HH:mm，NULL 表示全天',
    active_end VARCHAR(8) NULL COMMENT '生效结束 HH:mm，NULL 表示全天',
    cooldown_seconds INT NOT NULL DEFAULT 300 COMMENT '冷却时间，秒',
    enabled TINYINT NOT NULL DEFAULT 1 COMMENT '是否启用',
    last_triggered_at DATETIME NULL COMMENT '上次触发时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted TINYINT NOT NULL DEFAULT 0,
    KEY idx_alarm_rule_family (family_id),
    KEY idx_alarm_rule_device (device_id)
) COMMENT='告警规则表';

CREATE TABLE IF NOT EXISTS lh_alarm_event (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '告警事件ID',
    family_id BIGINT NOT NULL COMMENT '家庭ID',
    rule_id BIGINT NOT NULL COMMENT '触发规则ID',
    rule_name_snapshot VARCHAR(64) NOT NULL COMMENT '触发时规则名称快照',
    device_id BIGINT NULL COMMENT '设备ID',
    device_name_snapshot VARCHAR(64) NOT NULL COMMENT '设备名称快照',
    level VARCHAR(32) NOT NULL COMMENT 'INFO/WARNING/CRITICAL',
    status VARCHAR(32) NOT NULL DEFAULT 'NEW' COMMENT 'NEW/ACKNOWLEDGED/RESOLVED',
    message VARCHAR(255) NOT NULL COMMENT '告警描述',
    property_key VARCHAR(64) NULL COMMENT '触发属性',
    property_value VARCHAR(255) NULL COMMENT '触发时属性值',
    occurred_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发生时间',
    acked_at DATETIME NULL COMMENT '确认时间',
    acked_by BIGINT NULL COMMENT '确认人用户ID',
    resolved_at DATETIME NULL COMMENT '处理完成时间',
    resolved_by BIGINT NULL COMMENT '处理人用户ID',
    KEY idx_alarm_event_family_time (family_id, occurred_at),
    KEY idx_alarm_event_status (family_id, status),
    KEY idx_alarm_event_level (family_id, level)
) COMMENT='告警事件表';

-- 阶段 6：消息中心与能耗

CREATE TABLE IF NOT EXISTS lh_message (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '消息ID',
    family_id BIGINT NOT NULL COMMENT '家庭ID',
    category VARCHAR(32) NOT NULL COMMENT 'ALARM/DEVICE/SCENE/SYSTEM',
    level VARCHAR(32) NOT NULL DEFAULT 'INFO' COMMENT 'INFO/WARNING/CRITICAL',
    title VARCHAR(128) NOT NULL COMMENT '标题',
    body VARCHAR(512) NULL COMMENT '正文',
    ref_type VARCHAR(32) NULL COMMENT '关联类型 ALARM/DEVICE/SCENE',
    ref_id BIGINT NULL COMMENT '关联实体ID',
    read_user_ids JSON NULL COMMENT '已读用户ID集合',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    KEY idx_message_family_time (family_id, created_at),
    KEY idx_message_category (family_id, category)
) COMMENT='消息中心';

CREATE TABLE IF NOT EXISTS lh_notification_pref (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '通知偏好ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    category VARCHAR(32) NOT NULL COMMENT 'ALARM/DEVICE/SCENE/SYSTEM',
    push_enabled TINYINT NOT NULL DEFAULT 1 COMMENT '是否推送',
    sound_enabled TINYINT NOT NULL DEFAULT 1 COMMENT '是否声音',
    vibrate_enabled TINYINT NOT NULL DEFAULT 1 COMMENT '是否震动',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_pref_user_category (user_id, category)
) COMMENT='通知偏好表';

CREATE TABLE IF NOT EXISTS lh_energy_sample (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '能耗采样ID',
    family_id BIGINT NOT NULL COMMENT '家庭ID',
    device_id BIGINT NOT NULL COMMENT '设备ID',
    watts DOUBLE NOT NULL COMMENT '采样瞬时功率，瓦',
    sampled_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '采样时间',
    KEY idx_energy_sample_device_time (device_id, sampled_at),
    KEY idx_energy_sample_family_time (family_id, sampled_at)
) COMMENT='设备能耗采样表';

CREATE TABLE IF NOT EXISTS lh_device_token (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '推送 Token ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    platform VARCHAR(16) NOT NULL COMMENT 'FCM / APNS / EXPO',
    token VARCHAR(512) NOT NULL COMMENT '推送 Token',
    locale VARCHAR(16) NULL COMMENT '语言区域',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_device_token (user_id, platform, token(255)),
    KEY idx_device_token_user (user_id)
) COMMENT='设备推送 Token 表';

CREATE TABLE IF NOT EXISTS lh_energy_daily (
    id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '能耗日聚合ID',
    family_id BIGINT NOT NULL COMMENT '家庭ID',
    device_id BIGINT NOT NULL COMMENT '设备ID',
    day_key VARCHAR(16) NOT NULL COMMENT '日期键 yyyy-MM-dd',
    kwh DOUBLE NOT NULL DEFAULT 0 COMMENT '当日总用电量',
    sample_count INT NOT NULL DEFAULT 0 COMMENT '采样次数',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_energy_daily (family_id, device_id, day_key),
    KEY idx_energy_daily_day (family_id, day_key)
) COMMENT='设备能耗日聚合表';

-- 测试数据：账号 test_user / 密码 123456
INSERT IGNORE INTO lh_device_product(id, product_key, name, category, icon, protocol, property_schema)
VALUES
    (1, 'mock.light.v1', '智能灯', 'LIGHT', 'lightbulb', 'MOCK', JSON_OBJECT('power', false, 'brightness', 80, 'colorTemp', 4000, 'color', '#FFFFFF')),
    (2, 'mock.ac.v1', '智能空调', 'AIR_CONDITIONER', 'snowflake', 'MOCK', JSON_OBJECT('power', false, 'mode', 'COOL', 'temperature', 26, 'fanSpeed', 'AUTO')),
    (3, 'mock.curtain.v1', '智能窗帘', 'CURTAIN', 'blinds', 'MOCK', JSON_OBJECT('power', true, 'openPercent', 50)),
    (4, 'mock.plug.v1', '智能插座', 'PLUG', 'plug', 'MOCK', JSON_OBJECT('power', false, 'currentPower', 0)),
    (5, 'mock.sensor.v1', '温湿度传感器', 'SENSOR', 'thermometer', 'MOCK', JSON_OBJECT('temperature', 24.5, 'humidity', 55, 'battery', 90)),
    (6, 'mock.camera.v1', '智能摄像头', 'CAMERA', 'camera', 'MOCK', JSON_OBJECT('online', true, 'recording', false, 'streamUrl', 'rtmp://mock.linkhome/stream/living-room', 'hlsUrl', 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8')),
    (7, 'mock.smoke.v1', '烟雾传感器', 'SENSOR', 'fire', 'MOCK', JSON_OBJECT('smoke', false, 'battery', 95));

INSERT IGNORE INTO lh_user(id, username, phone, email, password_hash, status, created_at)
VALUES
    (1001, '测试用户', 'test_user', 'test_user@linkhome.local',
     '$2a$10$9ssl2ZiTycMvbNFifh8kcOlryxAvSG6.ZQ0ecDQUVU9dqXRpWBLA6', 'ACTIVE', NOW());

INSERT IGNORE INTO lh_family(id, name, owner_user_id, address, city, timezone, status, created_at)
VALUES
    (1001, '测试家庭', 1001, 'LinkHome 测试地址', '上海', 'Asia/Shanghai', 'ACTIVE', NOW());

INSERT IGNORE INTO lh_family_member(id, family_id, user_id, role, nickname, status, joined_at, created_at)
VALUES
    (1001, 1001, 1001, 'OWNER', '测试业主', 'ACTIVE', NOW(), NOW());

INSERT IGNORE INTO lh_room(id, family_id, name, icon, sort_order, created_at)
VALUES
    (1001, 1001, '客厅', 'sofa', 1, NOW()),
    (1002, 1001, '卧室', 'bed', 2, NOW());

INSERT IGNORE INTO lh_device(id, family_id, room_id, product_id, device_name, device_code, category, protocol, icon, online_status, properties_json, created_at)
VALUES
    (1001, 1001, 1001, 1, '测试客厅灯', 'TEST-LIGHT-001', 'LIGHT', 'MOCK', 'lightbulb', 'ONLINE',
     JSON_OBJECT('power', false, 'brightness', 80, 'colorTemp', 4000, 'currentPower', 0), NOW()),
    (1002, 1001, 1001, 6, '测试摄像头', 'TEST-CAMERA-001', 'CAMERA', 'MOCK', 'camera', 'ONLINE',
     JSON_OBJECT('online', true, 'recording', false, 'streamUrl', 'rtmp://mock.linkhome/stream/test-camera', 'hlsUrl', 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8'), NOW()),
    (1003, 1001, 1002, 7, '测试烟雾传感器', 'TEST-SMOKE-001', 'SENSOR', 'MOCK', 'fire', 'ONLINE',
     JSON_OBJECT('smoke', false, 'battery', 95), NOW());

INSERT IGNORE INTO lh_message(id, family_id, category, level, title, body, ref_type, ref_id, read_user_ids, created_at)
VALUES
    (1001, 1001, 'SYSTEM', 'INFO', '欢迎使用 LinkHome', '测试家庭已创建，可直接体验设备、监控、消息和能耗功能。', NULL, NULL, JSON_ARRAY(), NOW()),
    (1002, 1001, 'DEVICE', 'INFO', '测试设备已接入', '客厅灯、摄像头和烟雾传感器已准备就绪。', 'DEVICE', 1001, JSON_ARRAY(), NOW());

INSERT IGNORE INTO lh_alarm_event(id, family_id, rule_id, rule_name_snapshot, device_id, device_name_snapshot, level, status, message, property_key, property_value, occurred_at)
VALUES
    (1001, 1001, NULL, '测试烟雾告警', 1003, '测试烟雾传感器', 'WARNING', 'NEW', '测试烟雾传感器触发模拟告警。', 'smoke', 'true', NOW());

INSERT IGNORE INTO lh_notification_pref(id, user_id, category, push_enabled, sound_enabled, vibrate_enabled)
VALUES
    (1001, 1001, 'ALARM', 1, 1, 1),
    (1002, 1001, 'DEVICE', 1, 1, 0),
    (1003, 1001, 'SCENE', 1, 0, 0),
    (1004, 1001, 'SYSTEM', 1, 0, 0);
