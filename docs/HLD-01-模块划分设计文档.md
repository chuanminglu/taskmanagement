# 任务管理系统模块划分设计文档（HLD-01）

> **文档编号**: HLD-01  
> **文档版本**: v1.0  
> **编写日期**: 2026-04-25  
> **编写人**: AI辅助设计  
> **关联文档**: Epic描述文档-任务管理系统.md | SAD-任务管理系统软件架构文档.md | ADR-001-技术栈选型决策.md  
> **审核状态**: 待评审  

---

## 第1章：模块划分概览

**项目名称**: 团队任务管理系统（Task Management System）  
**架构风格**: 单体分层架构（Monolith Layered Architecture）  
**模块数量**: 9个（7个业务模块 + 2个技术模块）

### 1.1 模块划分原则

1. **按业务领域划分**：以Epic中定义的6个功能模块为基础，映射为对应的后端业务模块（DDD限界上下文）
2. **按技术层次划分**：前端（Vue SPA）独立为一个模块，后端按分层架构拆分业务职责
3. **按团队规模划分**（康威定律）：5人小团队，采用单体架构，避免微服务带来的分布式复杂度；前端2人负责前端模块，后端2人分担后端业务模块，测试1人
4. **横切关注点独立**：公共基础模块（异常处理、审计日志、权限拦截）独立封装，避免重复代码

### 1.2 Story覆盖统计

- **总Story数**: 21个（INVEST优化版 v2.0）
- **已分配到模块**: 21个（100%）✅
- **未分配Story**: 0个

| 功能分组 | Story数量 | 主要负责模块 |
|---------|---------|------------|
| 用户与权限管理 | 5个（US001-US004, US025） | MOD-BE-001, MOD-BE-002 |
| 任务管理核心 | 7个（US005-US011） | MOD-BE-003 |
| 多视图展示 | 3个（US012, US013A, US014） | MOD-BE-004, MOD-FE-001 |
| 搜索与筛选 | 2个（US015, US016） | MOD-BE-005 |
| 协作与通知 | 2个（US018, US020） | MOD-BE-006 |
| Sprint管理 | 3个（US022-US024） | MOD-BE-007 |

---

## 第2章：模块清单

| 模块编号 | 模块名称 | 模块类型 | 业务职责摘要 | 技术栈 | 覆盖Story | 优先级 | 负责团队 | 预估SP |
|---------|---------|---------|------------|--------|---------|--------|---------|--------|
| MOD-FE-001 | 前端应用层 | 业务模块（前端） | Vue SPA，所有页面与交互 | Vue 3 + TypeScript + Element Plus + Pinia | 全部21个Story（UI层） | P0 | 前端（2人） | 45 SP |
| MOD-BE-001 | 用户认证与权限模块 | 业务模块（后端） | 登录、JWT Token管理、权限拦截、账号锁定 | Spring Boot + Spring Security + JWT + MySQL | US001, US003 | P0 | 后端A | 10 SP |
| MOD-BE-002 | 用户管理模块 | 业务模块（后端） | 用户账号CRUD、密码管理 | Spring Boot + MyBatis-Plus + MySQL | US002, US004, US025 | P0 | 后端A | 12 SP |
| MOD-BE-003 | 任务管理核心模块 | 业务模块（后端） | 任务CRUD、状态流转、历史记录 | Spring Boot + MyBatis-Plus + MySQL | US005-US011 | P0 | 后端B | 20 SP |
| MOD-BE-004 | 任务视图模块 | 业务模块（后端） | 列表视图、看板视图数据接口 | Spring Boot + MyBatis-Plus + MySQL | US012, US013A, US014 | P0 | 后端B | 10 SP |
| MOD-BE-005 | 搜索与筛选模块 | 业务模块（后端） | 关键词搜索、多维度筛选、偏好保存 | Spring Boot + MyBatis-Plus + MySQL | US015, US016 | P1 | 后端A | 8 SP |
| MOD-BE-006 | 协作与通知模块 | 业务模块（后端） | 任务评论、@提及、系统通知中心 | Spring Boot + MyBatis-Plus + MySQL（HTTP轮询） | US018, US020 | P1 | 后端B | 10 SP |
| MOD-BE-007 | Sprint管理模块 | 业务模块（后端） | Sprint创建、任务分配、进度统计 | Spring Boot + MyBatis-Plus + MySQL | US022-US024 | P1 | 后端B | 8 SP |
| MOD-TECH-001 | 公共基础模块 | 技术模块 | 全局异常处理、审计日志、参数校验、工具类 | Spring Boot + AOP + @Async + Lombok | 横切关注点（US001,US002,US005等） | P0 | 后端A+B | 5 SP |

**总计**：128 SP

> **优先级说明**：P0（MVP必须，Sprint 1-2完成）、P1（重要功能，Sprint 3-4完成）、P2（增强功能，v2.0规划）

---

## 第3章：模块详细设计

---

### MOD-FE-001：前端应用层

#### 3.1.1 模块职责

**核心职责**（追溯SAD §2.1，ADR-001前端选型）：
- 提供所有用户界面：登录页、用户管理、任务列表、看板视图、Sprint管理、通知中心
- 前端状态管理（Pinia）：全局用户信息、JWT Token、筛选偏好
- 前端路由（Vue Router）：权限路由守卫，未登录跳转登录页
- HTTP请求封装（Axios）：统一携带JWT Token，统一错误响应处理

**非职责**（明确边界）：
- ❌ 不负责业务逻辑计算（由后端Service层负责）
- ❌ 不负责数据持久化（由后端数据库负责）
- ❌ 不负责权限鉴定（后端API强制校验，前端仅控制UI显示）

#### 3.1.2 覆盖Story

| Story编号 | Story名称 | 前端实现说明 |
|----------|----------|------------|
| US001 | 用户登录系统 | 登录页面、表单校验、Token存储、路由守卫 |
| US002 | 管理团队成员账号 | 用户管理列表页、新建/编辑用户模态框 |
| US003 | 分配用户角色权限 | 角色分配对话框、权限展示 |
| US004 | 修改个人密码 | 个人中心-修改密码表单 |
| US005 | 创建新任务 | 新建任务表单（抽屉/对话框） |
| US006 | 编辑任务信息 | 任务详情页-编辑表单 |
| US007 | 分配任务负责人 | 任务详情-负责人下拉选择器 |
| US008 | 更新任务状态 | 任务状态下拉 + 看板拖拽 |
| US009 | 查看任务详情 | 任务详情抽屉/页面 |
| US010 | 删除任务 | 删除确认对话框 |
| US011 | 记录任务操作历史 | 任务详情-历史记录时间轴 |
| US012 | 查看任务列表视图 | 任务列表表格（分页、排序） |
| US013A | 基础看板视图展示 | 三列看板（待办/进行中/完成） |
| US014 | 看板拖拽更新状态 | Element Plus 拖拽组件 |
| US015 | 搜索任务 | 搜索框（实时搜索/防抖） |
| US016 | 多维度筛选任务 | 筛选面板，偏好持久化localStorage |
| US018 | 任务内评论讨论 | 评论列表 + 评论输入框（@提及） |
| US020 | 系统通知与通知中心 | 顶部消息铃铛 + 通知中心抽屉 |
| US022 | 创建Sprint迭代 | Sprint创建表单 |
| US023 | 分配任务到Sprint | 任务详情-Sprint关联选择器 |
| US024 | 查看Sprint进度统计 | Sprint详情-统计卡片 |
| US025 | 查看操作审计日志 | 审计日志列表页（仅管理员可见） |

#### 3.1.3 技术栈

| 技术 | 版本 | 用途 |
|-----|-----|-----|
| Vue 3 | 3.3.x | 核心框架（Composition API + `<script setup>`） |
| TypeScript | 5.x | 类型安全 |
| Element Plus | 2.x | UI组件库（表格、表单、对话框、看板） |
| Pinia | 2.x | 状态管理（用户信息、Token、通知） |
| Vue Router | 4.x | 路由管理 + 权限守卫 |
| Axios | 1.x | HTTP请求封装 |
| Vite | 4.x | 构建工具 |

#### 3.1.4 数据存储

- **浏览器localStorage**：JWT Token（30分钟过期）、筛选偏好（本地持久化）
- **Pinia Store**：当前登录用户信息、未读通知数量（运行时状态）

#### 3.1.5 接口依赖

前端调用以下后端模块提供的REST API：

- MOD-BE-001：`POST /api/v1/auth/login`、`POST /api/v1/auth/logout`
- MOD-BE-002：`/api/v1/users/**`
- MOD-BE-003：`/api/v1/tasks/**`
- MOD-BE-004：`/api/v1/tasks/board`、`/api/v1/tasks/list`
- MOD-BE-005：`/api/v1/tasks/search`、`/api/v1/filter-preferences/**`
- MOD-BE-006：`/api/v1/comments/**`、`/api/v1/notifications/**`
- MOD-BE-007：`/api/v1/sprints/**`

#### 3.1.6 非功能需求

| 需求 | 目标值 | 实现方案 |
|-----|-------|---------|
| 性能 | 首屏加载 < 3秒（追溯Epic §5） | Vite代码分割、路由懒加载、图片懒加载 |
| 响应式 | 320px-1920px自适应 | Element Plus响应式栅格 |
| 兼容性 | Chrome/Edge/Firefox最新版 | 无特殊处理，Vite默认构建 |

---

### MOD-BE-001：用户认证与权限模块

#### 3.2.1 模块职责

**核心职责**（追溯ADR-001 §安全标准，US001, US003）：
- 账号密码登录认证（BCrypt密码对比）
- JWT Token生成与校验（30分钟有效期）
- 登录失败锁定机制（5次失败锁定30分钟）
- 请求权限拦截（PermissionInterceptor，所有API端点强制JWT校验）
- 基于RBAC的角色权限控制（管理员/成员）

**非职责**（明确边界）：
- ❌ 不负责用户账号CRUD（由MOD-BE-002负责）
- ❌ 不负责审计日志写入（由MOD-TECH-001负责）

#### 3.2.2 覆盖Story

| Story编号 | Story名称 | 实现说明 |
|----------|----------|---------|
| US001 | 用户登录系统 | `POST /api/v1/auth/login`，BCrypt校验，返回JWT Token；5次失败锁定 |
| US003 | 分配用户角色权限 | `PUT /api/v1/users/{id}/roles`，角色枚举：ADMIN / MEMBER |

#### 3.2.3 技术栈

| 技术 | 版本 | 用途 |
|-----|-----|-----|
| Spring Security | 6.x | 认证框架 |
| JJWT | 0.11.x | JWT生成与解析 |
| BCrypt | Spring内置 | 密码哈希加密存储 |
| Spring Boot | 3.1.x | 容器框架 |
| MySQL | 8.0 | 用户数据存储 |

#### 3.2.4 数据存储

**数据库表**（概要）：
- `t_user`：用户基本信息（id, username, email, password_hash, status, login_fail_count, lock_expire_time, created_at）
- `t_role`：角色表（ADMIN, MEMBER）
- `t_user_role`：用户角色关联表

#### 3.2.5 接口清单（概要）

| 接口 | 方法 | 说明 |
|-----|-----|-----|
| `/api/v1/auth/login` | POST | 登录，返回JWT Token |
| `/api/v1/auth/logout` | POST | 登出（客户端删除Token） |
| `/api/v1/auth/refresh` | POST | Token续期（预留） |

**内部拦截器**：
- `JwtAuthenticationFilter`：所有`/api/**`接口强制校验Token
- `PermissionInterceptor`：ADMIN角色方可访问`/api/v1/admin/**`

#### 3.2.6 依赖关系

**上游依赖**：无（基础认证模块）  
**下游依赖**：
- MOD-BE-002（用户管理）：查询用户信息、更新锁定状态
- MOD-TECH-001（公共基础）：写入登录操作审计日志

#### 3.2.7 非功能需求

| 需求 | 目标值 | 实现方案 |
|-----|-------|---------|
| 性能 | 登录 P95 < 200ms | 数据库username/email索引，BCrypt强度设置为10 |
| 安全 | 防暴力破解 | 登录失败5次锁定30分钟（追溯ADR-001 §安全标准） |
| 安全 | SQL注入防护 | MyBatis-Plus参数化查询（追溯GCTReporter规范） |

#### 3.2.8 部署规格

- **实例数**：与Spring Boot后端同进程（单体架构，追溯ADR-001）
- **服务器**：4核CPU，8GB内存（追溯SAD §2.2）

---

### MOD-BE-002：用户管理模块

#### 3.3.1 模块职责

**核心职责**（追溯US002, US004, US025）：
- 用户账号CRUD（创建、查询、编辑、禁用/启用）
- 密码管理（管理员重置密码、用户修改个人密码）
- 审计日志查询（管理员专用）

**非职责**：
- ❌ 不负责登录认证（由MOD-BE-001负责）
- ❌ 不负责任务管理（由MOD-BE-003负责）

#### 3.3.2 覆盖Story

| Story编号 | Story名称 | 实现说明 |
|----------|----------|---------|
| US002 | 管理团队成员账号 | 用户列表分页查询、创建用户（初始密码）、禁用/启用账号 |
| US004 | 修改个人密码 | `PUT /api/v1/users/me/password`，旧密码验证 + 新密码BCrypt存储 |
| US025 | 查看操作审计日志 | `GET /api/v1/admin/audit-logs`，分页+时间范围查询（管理员专用） |

#### 3.3.3 接口清单（概要）

| 接口 | 方法 | 说明 | 权限 |
|-----|-----|-----|-----|
| `/api/v1/users` | GET | 用户列表（分页+搜索） | ADMIN |
| `/api/v1/users` | POST | 创建用户 | ADMIN |
| `/api/v1/users/{id}` | PUT | 编辑用户信息 | ADMIN |
| `/api/v1/users/{id}/status` | PATCH | 禁用/启用账号 | ADMIN |
| `/api/v1/users/me/password` | PUT | 修改个人密码 | ANY |
| `/api/v1/admin/audit-logs` | GET | 查询审计日志 | ADMIN |

#### 3.3.4 依赖关系

**上游依赖**：
- MOD-BE-001（认证）：验证请求JWT Token

**下游依赖**：
- MOD-TECH-001（公共基础）：写入用户操作审计日志（@Async异步）

---

### MOD-BE-003：任务管理核心模块

#### 3.4.1 模块职责

**核心职责**（追溯US005-US011，Epic §3 功能模块2）：
- 任务CRUD：创建、读取、更新、删除
- 任务属性管理：标题、描述、负责人、截止时间、优先级、状态、标签
- 任务状态流转：待办（TODO）→ 进行中（IN_PROGRESS）→ 完成（DONE），支持重新打开
- 任务操作历史记录：状态变更、属性修改、分配变更（Phase 1：仅记录，Phase 2：差异对比）
- 任务权限控制：创建者和负责人可编辑，其他用户只读

**非职责**：
- ❌ 不负责任务视图渲染（由MOD-BE-004 + MOD-FE-001负责）
- ❌ 不负责评论（由MOD-BE-006负责）

#### 3.4.2 覆盖Story

| Story编号 | Story名称 | 实现说明 |
|----------|----------|---------|
| US005 | 创建新任务 | `POST /api/v1/tasks`，支持完整任务属性 |
| US006 | 编辑任务信息 | `PUT /api/v1/tasks/{id}`，部分更新（PATCH语义） |
| US007 | 分配任务负责人 | `PATCH /api/v1/tasks/{id}/assignee`，触发通知 |
| US008 | 更新任务状态 | `PATCH /api/v1/tasks/{id}/status`，状态机校验 |
| US009 | 查看任务详情 | `GET /api/v1/tasks/{id}`，包含历史记录摘要 |
| US010 | 删除任务 | `DELETE /api/v1/tasks/{id}`，仅创建者/PM可操作 |
| US011 | 记录任务操作历史 | 拦截写操作，异步写入`t_task_history`表 |

#### 3.4.3 数据存储

**数据库表**（概要，详细设计见HLD-03）：
- `t_task`：任务主表（id, title, description, status, priority, assignee_id, creator_id, sprint_id, due_date, tags, created_at, updated_at）
- `t_task_history`：任务历史记录（id, task_id, operator_id, action_type, field_name, old_value, new_value, operated_at）
- `t_task_tag`：任务标签关联表

**核心状态机**：
```
TODO ──────────────────────> IN_PROGRESS ──────────────> DONE
       [开始处理]                             [完成]
  ↑                                                  ↓
  └──────────────── [重新打开] ──────────────────────┘
```

#### 3.4.4 接口清单（概要）

| 接口 | 方法 | 说明 | 权限 |
|-----|-----|-----|-----|
| `/api/v1/tasks` | POST | 创建任务 | ANY |
| `/api/v1/tasks/{id}` | GET | 查看任务详情 | ANY |
| `/api/v1/tasks/{id}` | PUT | 编辑任务 | 创建者/负责人/ADMIN |
| `/api/v1/tasks/{id}` | DELETE | 删除任务 | 创建者/ADMIN |
| `/api/v1/tasks/{id}/status` | PATCH | 更新状态 | 负责人/ADMIN |
| `/api/v1/tasks/{id}/assignee` | PATCH | 分配负责人 | ADMIN/PM |
| `/api/v1/tasks/{id}/history` | GET | 查看历史记录 | ANY |

#### 3.4.5 依赖关系

**上游依赖**：
- MOD-BE-001（认证）：JWT权限校验

**下游依赖**：
- MOD-BE-006（通知）：任务分配/状态变更时触发通知事件
- MOD-TECH-001（公共基础）：历史记录异步写入、异常处理

#### 3.4.6 非功能需求

| 需求 | 目标值 | 实现方案 |
|-----|-------|---------|
| 性能 | 任务操作 < 500ms（追溯Epic §5） | 任务主键索引、assignee_id/status复合索引 |
| 安全 | SQL注入防护 | MyBatis-Plus参数化查询 |
| 事务 | 创建任务+记录历史原子性 | `@Transactional(rollbackFor = Exception.class)` |

---

### MOD-BE-004：任务视图模块

#### 3.5.1 模块职责

**核心职责**（追溯US012, US013A, US014，Epic §3 功能模块3）：
- 列表视图数据接口：分页、排序、分组查询
- 看板视图数据接口：按状态分列，返回结构化看板数据
- 拖拽排序支持：看板拖拽后更新任务状态（对接MOD-BE-003）

**非职责**：
- ❌ 不负责任务数据的增删改（由MOD-BE-003负责）
- ❌ 不负责搜索筛选（由MOD-BE-005负责）

#### 3.5.2 覆盖Story

| Story编号 | Story名称 | 实现说明 |
|----------|----------|---------|
| US012 | 查看任务列表视图 | `GET /api/v1/tasks/list`，支持分页（page/size）、排序（sort）、分组 |
| US013A | 基础看板视图展示 | `GET /api/v1/tasks/board`，返回三列结构 `{todo:[], inProgress:[], done:[]}` |
| US014 | 看板拖拽更新状态 | 拖拽触发 `PATCH /api/v1/tasks/{id}/status`（复用MOD-BE-003接口） |

#### 3.5.3 接口清单（概要）

| 接口 | 方法 | 说明 |
|-----|-----|-----|
| `/api/v1/tasks/list` | GET | 列表视图（分页+排序） |
| `/api/v1/tasks/board` | GET | 看板视图（按状态分列） |

---

### MOD-BE-005：搜索与筛选模块

#### 3.6.1 模块职责

**核心职责**（追溯US015, US016，Epic §3 功能模块4）：
- 关键词搜索（搜索任务标题和描述，MyBatis-Plus LIKE查询）
- 快捷筛选器：我的任务、今日到期、本周任务、已完成
- 高级筛选：状态、负责人、优先级、标签多条件组合查询
- 筛选偏好持久化：保存用户筛选条件到数据库（`t_filter_preference`表）

**非职责**：
- ❌ 不负责任务数据修改（由MOD-BE-003负责）
- ❌ 不负责全文索引（MVP阶段用LIKE，二期引入Elasticsearch）

#### 3.6.2 覆盖Story

| Story编号 | Story名称 | 实现说明 |
|----------|----------|---------|
| US015 | 搜索任务 | `GET /api/v1/tasks/search?keyword=xxx`，LIKE搜索title+description |
| US016 | 多维度筛选任务（含偏好保存） | `GET /api/v1/tasks/filter`，多条件组合；`POST /api/v1/filter-preferences`保存偏好 |

#### 3.6.3 数据存储

- `t_filter_preference`：筛选偏好（user_id, preference_name, filter_config_json, created_at）

#### 3.6.4 非功能需求

| 需求 | 目标值 | 实现方案 |
|-----|-------|---------|
| 性能 | 搜索 < 1秒（追溯Epic §5） | title/description添加全文索引（MySQL FULLTEXT），status/assignee_id联合索引 |

---

### MOD-BE-006：协作与通知模块

#### 3.7.1 模块职责

**核心职责**（追溯US018, US020，Epic §3 功能模块5）：
- 任务内评论：发布、编辑、删除评论（支持Markdown格式）
- @提及功能：解析评论中的@用户名，触发系统通知
- 系统通知写入：任务分配、状态变更、评论回复等场景生成通知
- 通知中心：查询通知列表、标记已读、批量清除
- 通知推送：MVP阶段采用前端HTTP轮询（5秒间隔），预留WebSocket扩展点

**非职责**：
- ❌ 不负责邮件通知（MVP范围外，追溯Epic §3 功能边界）
- ❌ 不负责任务状态变更（由MOD-BE-003负责）

#### 3.7.2 覆盖Story

| Story编号 | Story名称 | 实现说明 |
|----------|----------|---------|
| US018 | 任务内评论讨论（含@提及） | `POST /api/v1/tasks/{id}/comments`，解析@提及并写通知 |
| US020 | 系统通知与通知中心 | `GET /api/v1/notifications`，`PATCH /api/v1/notifications/{id}/read` |

#### 3.7.3 数据存储

- `t_task_comment`：评论表（id, task_id, author_id, content, is_deleted, created_at）
- `t_notification`：通知表（id, recipient_id, type, title, content, is_read, related_task_id, created_at）

#### 3.7.4 依赖关系

**上游依赖**：
- MOD-BE-003（任务管理）：任务分配/状态变更时触发通知事件（通过Spring ApplicationEvent解耦）

**循环依赖处理**（追溯SAD §2.1依赖说明）：
- 评论 ↔ 通知：**通过Spring事件机制解耦**，评论服务发布`MentionEvent`，通知服务异步消费，消除直接循环调用

---

### MOD-BE-007：Sprint管理模块

#### 3.8.1 模块职责

**核心职责**（追溯US022-US024，Epic §3 功能模块6）：
- Sprint创建与管理：名称、开始/结束时间、目标描述
- 任务分配到Sprint：更新task表的sprint_id字段
- Sprint看板：按Sprint过滤任务，返回看板数据
- Sprint进度统计：已完成/进行中/待办任务数量统计

**非职责**：
- ❌ 不负责甘特图和燃尽图（MVP范围外，追溯Epic §3 功能边界）
- ❌ 不负责任务数据修改（由MOD-BE-003负责）

#### 3.8.2 覆盖Story

| Story编号 | Story名称 | 实现说明 |
|----------|----------|---------|
| US022 | 创建Sprint迭代 | `POST /api/v1/sprints`，设置名称/时间/目标 |
| US023 | 分配任务到Sprint | `PATCH /api/v1/tasks/{id}/sprint`，更新sprint_id |
| US024 | 查看Sprint进度统计 | `GET /api/v1/sprints/{id}/progress`，返回统计数据 |

#### 3.8.3 数据存储

- `t_sprint`：Sprint表（id, name, goal, start_date, end_date, status, created_by, created_at）

---

### MOD-TECH-001：公共基础模块

#### 3.9.1 模块职责

**核心职责**（追溯SAD §2.1 关键设计决策，横切关注点）：
- **全局异常处理**：`@ControllerAdvice` + `GlobalExceptionHandler`，统一捕获业务异常/DB异常/参数校验异常，返回标准JSON响应
- **审计日志**：AOP切面拦截关键操作，`@Async`异步写入`t_audit_log`表，与主业务事务隔离
- **参数校验**：`@Valid` + Bean Validation注解，统一校验失败处理
- **工具类**：日期工具、字符串工具、加密工具

**非职责**：
- ❌ 不负责任何业务逻辑

#### 3.9.2 关键组件

| 组件 | 类型 | 说明 |
|-----|-----|-----|
| `GlobalExceptionHandler` | @ControllerAdvice | 统一异常响应，返回`{code, message, timestamp}` |
| `AuditLogAspect` | @Aspect | 拦截`@AuditLog`注解方法，异步写入审计日志 |
| `AuditLogService` | @Service + @Async | 异步写审计日志，不阻塞主业务 |
| `Result<T>` | POJO | 统一API响应包装器 |
| `BusinessException` | Exception | 业务异常基类（code + message） |

#### 3.9.3 数据存储

- `t_audit_log`：审计日志（id, operator_id, action_type, resource_type, resource_id, request_ip, detail_json, operated_at）
- **保留策略**：保留最近180天（追溯Epic §5 安全标准 "保留30天" → SAD文档修正为180天）

---

## 第4章：模块架构图

```
┌────────────────────────────────────────────────────────────────────────┐
│                           企业内网环境                                  │
│                                                                        │
│  ┌─────────────────────────────────────────────────────────────┐      │
│  │                 用户浏览器                                    │      │
│  └─────────────────────────┬───────────────────────────────────┘      │
│                             │ HTTPS (TLS 1.2+)                         │
│  ┌──────────────────────────▼──────────────────────────────────┐      │
│  │               Nginx反向代理（端口80/443）                    │      │
│  │         /api/* → 后端8081     /  → 前端8080                 │      │
│  └──────────────┬──────────────────────┬────────────────────────┘      │
│                 │                      │                                │
│  ┌──────────────▼──────────┐  ┌───────▼────────────────────────┐      │
│  │   MOD-FE-001            │  │   Spring Boot后端（端口8081）   │      │
│  │   Vue 3 前端应用        │  │                                │      │
│  │   - Element Plus UI     │  │  ┌─────────────────────────┐  │      │
│  │   - Pinia状态管理       │  │  │ Controller层（路由分发）  │  │      │
│  │   - Vue Router守卫      │  │  └────────────┬────────────┘  │      │
│  │   - Axios HTTP封装      │  │               │               │      │
│  └─────────────────────────┘  │  ┌────────────▼────────────┐  │      │
│                                │  │    Service层（业务逻辑）  │  │      │
│                                │  │                         │  │      │
│                                │  │  ┌─────────┐ ┌───────┐ │  │      │
│                                │  │  │MOD-BE-01│ │BE-002 │ │  │      │
│                                │  │  │认证&权限│ │用户管理│ │  │      │
│                                │  │  └────┬────┘ └───┬───┘ │  │      │
│                                │  │       │          │      │  │      │
│                                │  │  ┌────▼──────────▼───┐ │  │      │
│                                │  │  │    MOD-TECH-001   │ │  │      │
│                                │  │  │  公共基础模块      │ │  │      │
│                                │  │  │  (异常/日志/校验)  │ │  │      │
│                                │  │  └────────────────────┘ │  │      │
│                                │  │                          │  │      │
│                                │  │  ┌─────────┐ ┌───────┐  │  │      │
│                                │  │  │MOD-BE-03│ │BE-004 │  │  │      │
│                                │  │  │任务管理  │ │任务视图│  │  │      │
│                                │  │  └─────────┘ └───────┘  │  │      │
│                                │  │                          │  │      │
│                                │  │  ┌─────────┐ ┌───────┐  │  │      │
│                                │  │  │MOD-BE-05│ │BE-006 │  │  │      │
│                                │  │  │搜索筛选  │ │协作通知│  │  │      │
│                                │  │  └─────────┘ └───────┘  │  │      │
│                                │  │                          │  │      │
│                                │  │  ┌─────────┐             │  │      │
│                                │  │  │MOD-BE-07│             │  │      │
│                                │  │  │Sprint管理│             │  │      │
│                                │  │  └─────────┘             │  │      │
│                                │  │                          │  │      │
│                                │  │  ┌────────────────────┐  │  │      │
│                                │  │  │   MyBatis-Plus     │  │  │      │
│                                │  │  │   Mapper/Repository │  │  │      │
│                                │  │  └──────────┬─────────┘  │  │      │
│                                │  └─────────────┼────────────┘  │      │
│                                └─────────────────┼───────────────┘      │
│                                                  │ JDBC                  │
│                         ┌────────────────────────▼────────────────┐     │
│                         │  MySQL 8.0 数据库（端口3306）            │     │
│                         │  t_user / t_task / t_sprint / ...        │     │
│                         └─────────────────────────────────────────┘     │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 第5章：模块依赖关系图

### 5.1 依赖拓扑图（有向无环图）

```
MOD-FE-001（前端）
    │
    │ REST API（HTTP/HTTPS）
    ↓
┌───────────────────────────────────────────────────┐
│  Spring Boot 后端（统一进程）                      │
│                                                   │
│  MOD-BE-001（认证&权限）                          │
│      ↓ 权限校验（所有请求拦截）                    │
│  MOD-BE-002（用户管理） ─────→ MOD-TECH-001       │
│  MOD-BE-003（任务管理）                           │
│      │ 发布事件                                   │
│      ↓                                            │
│  MOD-BE-006（协作通知） ←── Spring事件解耦        │
│  MOD-BE-004（任务视图）← 依赖MOD-BE-003（只读查询）│
│  MOD-BE-005（搜索筛选）← 依赖MOD-BE-003（只读查询）│
│  MOD-BE-007（Sprint管理）← 依赖MOD-BE-003（写sprint_id）│
│                                                   │
│  MOD-TECH-001（公共基础）← 所有模块依赖（横切）   │
└───────────────────────────────────────────────────┘
    │ JDBC
    ↓
MySQL 8.0
```

### 5.2 依赖关系表

| 调用方 | 被调用方 | 依赖类型 | 调用方式 | 依赖强度 |
|-------|---------|---------|---------|---------|
| MOD-FE-001 | MOD-BE-001 | 同步HTTP | REST API `/auth/**` | 强依赖 |
| MOD-FE-001 | MOD-BE-002 | 同步HTTP | REST API `/users/**` | 强依赖 |
| MOD-FE-001 | MOD-BE-003 | 同步HTTP | REST API `/tasks/**` | 强依赖 |
| MOD-FE-001 | MOD-BE-004 | 同步HTTP | REST API `/tasks/list`, `/tasks/board` | 强依赖 |
| MOD-FE-001 | MOD-BE-005 | 同步HTTP | REST API `/tasks/search`, `/filter-preferences/**` | 强依赖 |
| MOD-FE-001 | MOD-BE-006 | 同步HTTP + HTTP轮询 | REST API `/comments/**`, `/notifications/**` | 强依赖 |
| MOD-FE-001 | MOD-BE-007 | 同步HTTP | REST API `/sprints/**` | 强依赖 |
| MOD-BE-001 | MOD-BE-002 | 同进程调用 | Java方法调用 | 强依赖（查询用户） |
| MOD-BE-002 | MOD-TECH-001 | 同进程调用 | @AuditLog注解 AOP | 弱依赖（异步） |
| MOD-BE-003 | MOD-BE-006 | 同进程事件 | Spring ApplicationEvent | 松耦合（事件驱动） |
| MOD-BE-003 | MOD-TECH-001 | 同进程调用 | @Transactional + @AuditLog | 中等依赖 |
| MOD-BE-004 | MOD-BE-003 | 同进程调用 | Java方法调用（只读） | 中等依赖 |
| MOD-BE-005 | MOD-BE-003 | 同进程调用 | Java方法调用（只读） | 中等依赖 |
| MOD-BE-007 | MOD-BE-003 | 同进程调用 | Java方法调用 | 中等依赖 |

### 5.3 循环依赖检测

- ✅ **无循环依赖**
- **依赖层次**：
  - L0：MOD-FE-001（前端）
  - L1：MOD-BE-001（认证，横切所有请求）
  - L2：MOD-BE-002（用户），MOD-BE-003（任务核心），MOD-BE-007（Sprint）
  - L3：MOD-BE-004（视图），MOD-BE-005（搜索），MOD-BE-006（协作）
  - L-CROSS：MOD-TECH-001（横切，不参与业务层次）
- **原有循环依赖处理**：SAD文档中提到"评论服务 ↔ 通知服务"双向依赖，本方案通过**Spring ApplicationEvent**解耦，MOD-BE-003发布任务事件，MOD-BE-006订阅消费，消除循环调用 ✅

---

## 第6章：模块部署架构

```
【生产环境 - 企业内网】
┌────────────────────────────────────────────────────────┐
│  Linux服务器（CentOS 7+ / Ubuntu 20.04+）              │
│  硬件：4核CPU，8GB内存，100GB硬盘                      │
│  （追溯ADR-001 §缓解措施：内存从4GB升级到8GB）         │
│                                                        │
│  ┌──────────────────────────────────────────────────┐  │
│  │  Nginx 1.20+（端口80/443）                        │  │
│  │  - HTTPS TLS 1.2+ 证书                           │  │
│  │  - 反向代理：/api/* → 8081，/ → 8080             │  │
│  └──────────────────┬──────────────┬────────────────┘  │
│                     │              │                    │
│  ┌──────────────────▼──┐  ┌───────▼────────────────┐  │
│  │  Vue前端（端口8080） │  │ Spring Boot（端口8081） │  │
│  │  Nginx托管静态文件   │  │ JVM: -Xms512m -Xmx1g   │  │
│  │  (~5MB静态资源)      │  │ Tomcat内嵌容器         │  │
│  └─────────────────────┘  └──────────┬─────────────┘  │
│                                       │ JDBC:3306      │
│  ┌────────────────────────────────────▼──────────────┐  │
│  │  MySQL 8.0（端口3306）                            │  │
│  │  - InnoDB存储引擎，UTF8MB4字符集                  │  │
│  │  - 数据目录：/var/lib/mysql                       │  │
│  │  - 慢查询日志：开启（>1s）                        │  │
│  └───────────────────────────────────────────────────┘  │
│                                                        │
│  ┌───────────────────────────────────────────────────┐  │
│  │  备份（可选，追溯SAD §2.2）                        │  │
│  │  - 每日凌晨2点 mysqldump 全量备份                  │  │
│  │  - 保留30天备份历史                                │  │
│  └───────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────┘
```

### 部署清单

| 模块 | 部署形式 | 进程/容器 | 资源占用 | 启动顺序 |
|-----|---------|---------|---------|---------|
| MOD-FE-001 | Nginx静态文件 | 共用Nginx进程 | ~10MB内存 | 3 |
| MOD-BE-001~007 + TECH-001 | Spring Boot JAR | JVM进程（端口8081） | 512MB-1GB JVM堆 | 2 |
| MySQL 8.0 | 系统服务 | mysqld进程（端口3306） | 2GB内存 | 1 |
| Nginx | 系统服务 | nginx进程（端口80/443） | ~50MB内存 | 3 |

> **说明**：后端所有业务模块（MOD-BE-001 ~ MOD-BE-007 + MOD-TECH-001）打包为同一个Spring Boot JAR，共享JVM进程，符合单体分层架构设计（追溯ADR-001）。

---

## 第7章：模块与Story映射矩阵

| Story编号 | Story名称 | 优先级 | 主要模块 | 辅助模块 | 涉及模块数 | Sprint规划 |
|----------|----------|-------|---------|---------|-----------|----------|
| US001 | 用户登录系统 | P0 | MOD-BE-001 | MOD-FE-001, MOD-TECH-001 | 3 | Sprint 1 |
| US002 | 管理团队成员账号 | P0 | MOD-BE-002 | MOD-FE-001, MOD-TECH-001 | 3 | Sprint 1 |
| US003 | 分配用户角色权限 | P0 | MOD-BE-001 | MOD-BE-002, MOD-FE-001 | 3 | Sprint 1 |
| US004 | 修改个人密码 | P0 | MOD-BE-002 | MOD-FE-001 | 2 | Sprint 1 |
| US005 | 创建新任务 | P0 | MOD-BE-003 | MOD-FE-001, MOD-TECH-001 | 3 | Sprint 2 |
| US006 | 编辑任务信息 | P0 | MOD-BE-003 | MOD-FE-001 | 2 | Sprint 2 |
| US007 | 分配任务负责人 | P0 | MOD-BE-003 | MOD-BE-006, MOD-FE-001 | 3 | Sprint 2 |
| US008 | 更新任务状态 | P0 | MOD-BE-003 | MOD-FE-001 | 2 | Sprint 2 |
| US009 | 查看任务详情 | P0 | MOD-BE-003 | MOD-FE-001 | 2 | Sprint 2 |
| US010 | 删除任务 | P0 | MOD-BE-003 | MOD-FE-001 | 2 | Sprint 2 |
| US011 | 记录任务操作历史 | P0 | MOD-BE-003 | MOD-TECH-001 | 2 | Sprint 2 |
| US012 | 查看任务列表视图 | P0 | MOD-BE-004 | MOD-FE-001 | 2 | Sprint 2 |
| US013A | 基础看板视图展示 | P0 | MOD-BE-004 | MOD-FE-001 | 2 | Sprint 3 |
| US014 | 看板拖拽更新状态 | P0 | MOD-BE-003 | MOD-BE-004, MOD-FE-001 | 3 | Sprint 3 |
| US015 | 搜索任务 | P1 | MOD-BE-005 | MOD-FE-001 | 2 | Sprint 3 |
| US016 | 多维度筛选任务（含偏好保存） | P1 | MOD-BE-005 | MOD-FE-001 | 2 | Sprint 3 |
| US018 | 任务内评论讨论（含@提及） | P1 | MOD-BE-006 | MOD-FE-001, MOD-TECH-001 | 3 | Sprint 4 |
| US020 | 系统通知与通知中心 | P1 | MOD-BE-006 | MOD-FE-001 | 2 | Sprint 4 |
| US022 | 创建Sprint迭代 | P1 | MOD-BE-007 | MOD-FE-001 | 2 | Sprint 4 |
| US023 | 分配任务到Sprint | P1 | MOD-BE-007 | MOD-BE-003, MOD-FE-001 | 3 | Sprint 4 |
| US024 | 查看Sprint进度统计 | P1 | MOD-BE-007 | MOD-BE-003, MOD-FE-001 | 3 | Sprint 4 |
| US025 | 查看操作审计日志 | P0 | MOD-BE-002 | MOD-TECH-001, MOD-FE-001 | 3 | Sprint 2 |

**✅ Story覆盖率：21/21 = 100%**

---

## 第8章：模块工作量估算

| 模块编号 | 模块名称 | Story Points | 开发人天 | 负责团队 | Sprint规划 |
|---------|---------|-------------|---------|---------|----------|
| MOD-FE-001 | 前端应用层 | 45 SP | 20天 | 前端（2人，各10天） | Sprint 1-4 |
| MOD-BE-001 | 用户认证与权限模块 | 10 SP | 4天 | 后端A | Sprint 1 |
| MOD-BE-002 | 用户管理模块 | 12 SP | 5天 | 后端A | Sprint 1-2 |
| MOD-BE-003 | 任务管理核心模块 | 20 SP | 8天 | 后端B | Sprint 2 |
| MOD-BE-004 | 任务视图模块 | 10 SP | 4天 | 后端B | Sprint 2-3 |
| MOD-BE-005 | 搜索与筛选模块 | 8 SP | 3天 | 后端A | Sprint 3 |
| MOD-BE-006 | 协作与通知模块 | 10 SP | 4天 | 后端B | Sprint 4 |
| MOD-BE-007 | Sprint管理模块 | 8 SP | 3天 | 后端B | Sprint 4 |
| MOD-TECH-001 | 公共基础模块 | 5 SP | 2天 | 后端A+B（搭框架） | Sprint 1（优先） |

**总计**：

| 汇总项 | 数值 |
|-------|-----|
| 总Story Points | 128 SP |
| 总开发人天（后端） | 33天 |
| 总开发人天（前端） | 20天 |
| 总人天 | 53天（含测试预估15天，共68天≈11周） |
| 开发团队 | 后端2人 + 前端2人 + 测试1人 |
| 预计交付周期 | **11周（Sprint 1-4，每Sprint 2-3周）** |

> **交付可行性评估**：11周53人天，5人团队，符合ADR-001中"11周MVP交付"约束（追溯ADR-001 §技术约束）✅

---

## 附录A：技术决策追溯

| 决策点 | 决策内容 | 来源文档 |
|-------|---------|---------|
| 架构风格：单体分层架构 | 5人小团队，MVP优先，避免微服务复杂度 | ADR-001 §决策，SAD §1.3 |
| 前端技术栈：Vue 3 + TypeScript + Element Plus | 团队Vue经验，Element Plus中文文档友好 | ADR-001 §方案A，Epic §5 技术栈 |
| 后端技术栈：Java 17 + Spring Boot 3.x | 3人Java经验，企业级成熟度，Spring Security安全框架 | ADR-001 §方案A权衡分析 |
| 数据库：MySQL 8.0（非PostgreSQL） | ADR-001最终决策，简化运维 | ADR-001 §决策 |
| ORM：MyBatis-Plus | 代码生成器提升开发效率，满足11周交付 | ADR-001 §缓解措施，SAD §2.1 |
| 认证：JWT Token（30分钟） | 轻量无状态，适合前后端分离 | ADR-001 §安全标准，Epic §5 |
| 通知推送：HTTP轮询（非WebSocket） | MVP降低技术复杂度，US020明确简化方案 | 用户故事列表v2.0 §US020 |
| 评论↔通知解耦：Spring ApplicationEvent | 消除循环依赖，保持架构DAG | SAD §2.1依赖说明 |
| 审计日志：@Async异步写入 | 不阻塞主业务，日志写入失败不影响操作 | SAD §2.1关键设计决策5 |

---

## 附录B：后续设计指引

| 下一步文档 | 内容 | 依赖本文档内容 |
|-----------|-----|--------------|
| HLD-02 接口设计 | 各模块REST API详细定义（请求/响应Schema） | 第2章模块清单，第3章接口清单 |
| HLD-03 数据库设计 | 完整ER图，建表SQL | 第3章数据存储设计 |
| HLD-04 时序图设计 | 关键业务流程时序（登录、创建任务、通知推送） | 第5章依赖关系，第3章模块职责 |
| HLD-05 概要设计评审 | 架构质量评审Checklist | 全文 |
