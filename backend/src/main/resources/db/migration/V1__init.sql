-- =====================================================
-- TaskManagement V1 初始化 Schema
-- 兼容：H2 2.x (MySQL MODE) / MySQL 8.0
-- =====================================================

-- 角色表
CREATE TABLE sys_role
(
    id   BIGINT      NOT NULL AUTO_INCREMENT,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(50) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uk_code (code)
);

-- 用户表
CREATE TABLE sys_user
(
    id               BIGINT       NOT NULL AUTO_INCREMENT,
    username         VARCHAR(50)  NOT NULL,
    email            VARCHAR(100) NOT NULL,
    password         VARCHAR(100) NOT NULL,
    status           VARCHAR(10)  NOT NULL DEFAULT 'ACTIVE',
    fail_count       INT          NOT NULL DEFAULT 0,
    lock_until       DATETIME              DEFAULT NULL,
    password_changed TINYINT      NOT NULL DEFAULT 0,
    created_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_username (username),
    UNIQUE KEY uk_email (email)
);

-- 用户角色关联表
CREATE TABLE sys_user_role
(
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    PRIMARY KEY (user_id, role_id),
    CONSTRAINT fk_ur_user FOREIGN KEY (user_id) REFERENCES sys_user (id),
    CONSTRAINT fk_ur_role FOREIGN KEY (role_id) REFERENCES sys_role (id)
);

-- 任务表
CREATE TABLE task
(
    id          BIGINT       NOT NULL AUTO_INCREMENT,
    title       VARCHAR(200) NOT NULL,
    description TEXT                  DEFAULT NULL,
    status      VARCHAR(20)  NOT NULL DEFAULT 'TODO',
    priority    VARCHAR(10)  NOT NULL DEFAULT 'MEDIUM',
    assignee_id BIGINT                DEFAULT NULL,
    due_date    DATE                  DEFAULT NULL,
    creator_id  BIGINT       NOT NULL,
    deleted     TINYINT      NOT NULL DEFAULT 0,
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_task_assignee FOREIGN KEY (assignee_id) REFERENCES sys_user (id),
    CONSTRAINT fk_task_creator FOREIGN KEY (creator_id) REFERENCES sys_user (id)
);

-- 初始化角色数据
INSERT INTO sys_role (code, name) VALUES ('ADMIN', '管理员');
INSERT INTO sys_role (code, name) VALUES ('MEMBER', '普通成员');
