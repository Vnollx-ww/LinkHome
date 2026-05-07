# 设备管理模块 SQL

## 1. 房间表

```sql
CREATE TABLE lh_room (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    family_id BIGINT NOT NULL,
    name VARCHAR(64) NOT NULL,
    icon VARCHAR(64) NULL,
    sort_order INT NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted TINYINT NOT NULL DEFAULT 0,
    KEY idx_room_family_sort (family_id, sort_order),
    UNIQUE KEY uk_room_family_name (family_id, name, deleted)
) COMMENT='房间表';
```

## 2. 设备产品类型表

```sql
CREATE TABLE lh_device_product (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    product_key VARCHAR(64) NOT NULL,
    name VARCHAR(64) NOT NULL,
    category VARCHAR(64) NOT NULL COMMENT 'LIGHT/AIR_CONDITIONER/CURTAIN/PLUG/SENSOR/CAMERA',
    icon VARCHAR(64) NULL,
    protocol VARCHAR(32) NOT NULL DEFAULT 'MOCK' COMMENT 'MOCK/WIFI/ZIGBEE/BLE',
    property_schema JSON NOT NULL COMMENT '属性模型定义',
    action_schema JSON NULL COMMENT '动作模型定义',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted TINYINT NOT NULL DEFAULT 0,
    UNIQUE KEY uk_product_key (product_key),
    KEY idx_product_category (category)
) COMMENT='设备产品类型表';
```

## 3. 设备实例表

```sql
CREATE TABLE lh_device (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    family_id BIGINT NOT NULL,
    room_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    device_name VARCHAR(64) NOT NULL,
    device_code VARCHAR(128) NOT NULL,
    category VARCHAR(64) NOT NULL,
    protocol VARCHAR(32) NOT NULL DEFAULT 'MOCK',
    icon VARCHAR(64) NULL,
    online_status VARCHAR(32) NOT NULL DEFAULT 'ONLINE' COMMENT 'ONLINE/OFFLINE/FAULT/PAIRING',
    favorite TINYINT NOT NULL DEFAULT 0,
    firmware_version VARCHAR(64) NULL,
    last_online_at DATETIME NULL,
    last_offline_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted TINYINT NOT NULL DEFAULT 0,
    UNIQUE KEY uk_device_code (device_code),
    KEY idx_device_family_room (family_id, room_id),
    KEY idx_device_family_category (family_id, category),
    KEY idx_device_online (online_status)
) COMMENT='设备实例表';
```

## 4. 设备属性表

```sql
CREATE TABLE lh_device_property (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    device_id BIGINT NOT NULL,
    family_id BIGINT NOT NULL,
    properties JSON NOT NULL COMMENT '当前设备属性快照',
    version BIGINT NOT NULL DEFAULT 1 COMMENT '属性版本号，用于并发控制',
    reported_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_property_device (device_id),
    KEY idx_property_family (family_id),
    KEY idx_property_reported (reported_at)
) COMMENT='设备属性表';
```

## 5. 初始化产品类型

```sql
INSERT INTO lh_device_product (product_key, name, category, icon, protocol, property_schema, action_schema)
VALUES
('mock.light.v1', '智能灯', 'LIGHT', 'lightbulb', 'MOCK',
 JSON_OBJECT('power', false, 'brightness', 80, 'colorTemp', 4000, 'color', '#FFFFFF'),
 JSON_ARRAY('setPower', 'setBrightness', 'setColorTemp', 'setColor')),
('mock.ac.v1', '智能空调', 'AIR_CONDITIONER', 'snowflake', 'MOCK',
 JSON_OBJECT('power', false, 'mode', 'COOL', 'temperature', 26, 'fanSpeed', 'AUTO'),
 JSON_ARRAY('setPower', 'setMode', 'setTemperature', 'setFanSpeed')),
('mock.curtain.v1', '智能窗帘', 'CURTAIN', 'blinds', 'MOCK',
 JSON_OBJECT('power', true, 'openPercent', 50),
 JSON_ARRAY('setPower', 'setOpenPercent')),
('mock.plug.v1', '智能插座', 'PLUG', 'plug', 'MOCK',
 JSON_OBJECT('power', false, 'currentPower', 0, 'voltage', 220),
 JSON_ARRAY('setPower')),
('mock.temp_humidity.v1', '温湿度传感器', 'SENSOR', 'thermometer', 'MOCK',
 JSON_OBJECT('temperature', 25.5, 'humidity', 60, 'battery', 90),
 JSON_ARRAY()),
('mock.camera.v1', '智能摄像头', 'CAMERA', 'camera', 'MOCK',
 JSON_OBJECT('online', true, 'recording', false, 'streamUrl', ''),
 JSON_ARRAY('startRecord', 'stopRecord'));
```
