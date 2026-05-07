# 用户与家庭权限模块 SQL

## 1. 表设计说明

本模块包含用户、家庭、家庭成员、邀请、审计日志五类核心表。所有业务表建议统一包含 `created_at`、`updated_at`、`deleted` 字段，便于审计和软删除。

## 2. 用户表

```sql
CREATE TABLE lh_user (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(64) NOT NULL COMMENT '用户名或昵称',
    phone VARCHAR(32) NULL COMMENT '手机号',
    email VARCHAR(128) NULL COMMENT '邮箱',
    password_hash VARCHAR(255) NOT NULL COMMENT 'BCrypt 密码哈希',
    avatar_url VARCHAR(512) NULL COMMENT '头像地址',
    status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE' COMMENT 'ACTIVE/DISABLED',
    last_login_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted TINYINT NOT NULL DEFAULT 0,
    UNIQUE KEY uk_user_phone (phone),
    UNIQUE KEY uk_user_email (email),
    KEY idx_user_status (status)
) COMMENT='用户表';
```

## 3. 家庭表

```sql
CREATE TABLE lh_family (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(64) NOT NULL COMMENT '家庭名称',
    owner_user_id BIGINT NOT NULL COMMENT '创建者用户ID',
    address VARCHAR(255) NULL COMMENT '家庭地址',
    city VARCHAR(64) NULL COMMENT '城市',
    timezone VARCHAR(64) NOT NULL DEFAULT 'Asia/Shanghai',
    avatar_url VARCHAR(512) NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE' COMMENT 'ACTIVE/DISSOLVED',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted TINYINT NOT NULL DEFAULT 0,
    KEY idx_family_owner (owner_user_id),
    KEY idx_family_status (status)
) COMMENT='家庭表';
```

## 4. 家庭成员表

```sql
CREATE TABLE lh_family_member (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    family_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    role VARCHAR(32) NOT NULL COMMENT 'OWNER/ADMIN/MEMBER/GUEST',
    nickname VARCHAR(64) NULL COMMENT '家庭内昵称',
    status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE' COMMENT 'ACTIVE/REMOVED/PENDING',
    joined_at DATETIME NULL,
    expire_at DATETIME NULL COMMENT '访客过期时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted TINYINT NOT NULL DEFAULT 0,
    UNIQUE KEY uk_family_user (family_id, user_id),
    KEY idx_member_user (user_id),
    KEY idx_member_family_role (family_id, role),
    KEY idx_member_status (status)
) COMMENT='家庭成员表';
```

## 5. 家庭邀请表

```sql
CREATE TABLE lh_family_invite (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    family_id BIGINT NOT NULL,
    inviter_user_id BIGINT NOT NULL,
    invite_code VARCHAR(64) NOT NULL,
    target_phone VARCHAR(32) NULL,
    target_email VARCHAR(128) NULL,
    role VARCHAR(32) NOT NULL DEFAULT 'MEMBER',
    max_use_count INT NOT NULL DEFAULT 1,
    used_count INT NOT NULL DEFAULT 0,
    expire_at DATETIME NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE' COMMENT 'ACTIVE/USED/EXPIRED/CANCELLED',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted TINYINT NOT NULL DEFAULT 0,
    UNIQUE KEY uk_invite_code (invite_code),
    KEY idx_invite_family (family_id),
    KEY idx_invite_expire (expire_at),
    KEY idx_invite_status (status)
) COMMENT='家庭邀请表';
```

## 6. 审计日志表

```sql
CREATE TABLE lh_audit_log (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    family_id BIGINT NULL,
    operator_user_id BIGINT NOT NULL,
    action VARCHAR(64) NOT NULL COMMENT '操作类型',
    target_type VARCHAR(64) NOT NULL COMMENT '目标类型',
    target_id BIGINT NULL COMMENT '目标ID',
    detail_json JSON NULL COMMENT '操作详情',
    ip_address VARCHAR(64) NULL,
    user_agent VARCHAR(512) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_audit_family_time (family_id, created_at),
    KEY idx_audit_operator_time (operator_user_id, created_at),
    KEY idx_audit_action (action)
) COMMENT='审计日志表';
```

## 7. 初始化数据建议

```sql
INSERT INTO lh_user (username, phone, password_hash)
VALUES ('Demo 用户', '18800000000', '$2a$10$replace_with_bcrypt_hash');
```
