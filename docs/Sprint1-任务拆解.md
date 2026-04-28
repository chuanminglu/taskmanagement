# Sprint 1 任务拆解 — 任务管理系统

> **Sprint 编号**: Sprint 1
> **Sprint 周期**: 2026-04-28（周一）→ 2026-05-15（周四）
> **基准文档**: [Sprint1-迭代任务计划.md](./Sprint1-迭代任务计划.md)
> **文档版本**: v1.0 | 生成日期: 2026-04-28
> **团队**: BE1（后端1）、BE2（后端2）、FE（前端）

---

## 📋 第1部分：任务拆解总览

### 1.1 故事任务统计

| 序号 | 故事 ID | 故事标题 | SP | 任务数 | 主要分工 | 完成时限 |
|:---:|--------|---------|:--:|:-----:|---------|:-------:|
| 0 | **TS001** | **初始化项目（技术故事）** | — | **5** | BE1 + BE2 + FE | **Day 1 结束前** |
| 1 | US001 | 用户登录系统 | 5 | 8 | BE1 + BE2 + FE | Week 1（Day 1-5）|
| 2 | US004 | 修改个人密码 | 3 | 4 | BE1 + FE | Week 1（Day 3-5）|
| 3 | US002 | 管理团队成员账号 | 6 | 6 | BE2 + FE | Week 2（Day 6-8）|
| 4 | US003 | 分配用户角色权限 | 8 | 7 | BE2 + FE | Week 2（Day 7-10）|
| 5 | US005 | 创建新任务 | 6 | 7 | BE1 + FE | Week 2（Day 8-10）|
| 6 | US007 | 分配任务负责人 | 3 | 4 | BE1 + FE | Week 2（Day 9-10）|
| 7 | US008 | 更新任务状态 | 3 | 5 | BE1 + FE | Week 2-3（Day 10-11）|
| 8 | US012 | 查看任务列表视图 | 6 | 7 | BE1 + FE | Week 3（Day 11-13）|
| — | — | **合计** | **40** | **53** | — | — |

---

### 1.2 任务号索引

| 故事 | 任务号范围 |
|-----|----------|
| TS001 初始化项目 | T001 – T005 |
| US001 用户登录 | T006 – T013 |
| US004 修改密码 | T014 – T017 |
| US002 用户管理 | T018 – T023 |
| US003 角色权限 | T024 – T030 |
| US005 创建任务 | T031 – T037 |
| US007 分配负责人 | T038 – T041 |
| US008 更新状态 | T042 – T046 |
| US012 任务列表 | T047 – T053 |

---

### 1.3 按角色任务分配汇总

| 角色 | 承担任务数 | 主要负责模块 |
|-----|:--------:|------------|
| BE1（后端1）| 24 | 仓库初始化、登录 API、密码 API、任务 CRUD API、列表查询 API |
| BE2（后端2）| 17 | 数据库 Schema、Spring Security/JWT、用户管理 API、RBAC 框架 |
| FE（前端）| 23 | 所有页面/组件、路由守卫、权限控制指令、状态管理 |

> **注意**：BE1 承担任务数较多，但其中许多任务可在 BE2 完成 RBAC 后并行推进；FE 存在瓶颈，见风险说明。

---

## 📋 第2部分：任务拆解详情

---

### 🏗️ TS001：初始化项目（技术故事）

> **完成时限**：Day 1 结束前（April 28 全天）
> **说明**：4 项初始化动作合并为技术故事，所有用户故事在此基础上并行展开。

| 任务 ID | 任务名称 | 负责人 | 优先级 | 前置依赖 | 完成标准 |
|--------|---------|:------:|:-----:|:-------:|---------|
| T001 | 创建代码仓库，配置分支保护（main / develop / feature/\*） | BE1 | 🔴 P0 | 无 | GitHub/GitLab 仓库可访问；main/develop 分支保护开启；团队成员均有 push 权限 |
| T002 | 初始化 Spring Boot 项目骨架（Java 17 + SpringBoot 3.1.x + Security + JWT + MyBatis-Plus + Flyway 依赖） | BE1 | 🔴 P0 | T001 | `mvn compile` 无报错；目录结构（controller/service/mapper/entity）建立；application.yml 配置正确 |
| T003 | 初始化数据库 Schema（用户表、角色表、用户角色关联表、任务表）+ 首个 Flyway 迁移脚本（V1__init.sql） | BE2 | 🔴 P0 | T001 | Flyway 执行 V1__init.sql 成功；本地数据库四张表创建正确；字段设计经团队 Review 确认 |
| T004 | 初始化 Vue 3 项目（Vite + TypeScript + Element Plus + Pinia + Vue Router + Axios + ESLint 配置） | FE | 🔴 P0 | T001 | `pnpm dev` 启动成功；目录结构（views/components/api/stores/router）建立；Element Plus 全局注册 |
| T005 | 配置 CI 基础流水线（代码提交自动触发后端 Maven Build + 前端 `pnpm build`） | BE1 | 🟡 P1 | T002、T004 | GitHub Actions/CI 工作流文件提交；推送 feature 分支后 CI 自动运行；构建结果在 PR 中可见 |

---

**数据库 Schema（V1__init.sql）核心表结构**：

```sql
-- 用户表
CREATE TABLE sys_user (
  id        BIGINT       NOT NULL AUTO_INCREMENT PRIMARY KEY,
  username  VARCHAR(50)  NOT NULL UNIQUE,
  email     VARCHAR(100) NOT NULL UNIQUE,
  password  VARCHAR(100) NOT NULL,           -- BCrypt hash
  status    TINYINT      NOT NULL DEFAULT 1, -- 1=启用 0=禁用
  fail_count TINYINT     NOT NULL DEFAULT 0,
  lock_until DATETIME,
  created_at DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 角色表
CREATE TABLE sys_role (
  id   BIGINT      NOT NULL AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(20) NOT NULL UNIQUE,  -- ADMIN / MEMBER
  name VARCHAR(50) NOT NULL
);

-- 用户角色关联表
CREATE TABLE sys_user_role (
  user_id BIGINT NOT NULL,
  role_id BIGINT NOT NULL,
  PRIMARY KEY (user_id, role_id)
);

-- 任务表
CREATE TABLE task (
  id          BIGINT        NOT NULL AUTO_INCREMENT PRIMARY KEY,
  title       VARCHAR(100)  NOT NULL,
  description TEXT,
  status      VARCHAR(20)   NOT NULL DEFAULT 'TODO',  -- TODO / IN_PROGRESS / DONE
  priority    VARCHAR(10),                             -- HIGH / MEDIUM / LOW
  assignee_id BIGINT,
  due_date    DATE,
  creator_id  BIGINT        NOT NULL,
  deleted     TINYINT       NOT NULL DEFAULT 0,
  created_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

---

### 🔐 US001：用户登录系统（5 SP）

> **Sprint 范围**：完整实现（无缩减）
> **完成时限**：Day 1-5（Week 1）
> **Sprint 1 缩减**：无

| 任务 ID | 任务名称 | 负责人 | 优先级 | 前置依赖 | 完成标准 |
|--------|---------|:------:|:-----:|:-------:|---------|
| T006 | 实现 User 实体 + UserDetailsService（加载用户 + 权限）| BE2 | 🔴 P0 | T003 | 单元测试通过；用户可通过 username/email 查询 |
| T007 | 实现 JWT 工具类（生成/验证/解析 Token，30 分钟有效期；Remember-Me Token 7 天有效期）| BE2 | 🔴 P0 | T002 | 单元测试覆盖 Token 生成与过期验证 |
| T008 | 实现登录接口（POST /api/auth/login）含账号锁定逻辑（5 次失败锁定 30 分钟）| BE1 | 🔴 P0 | T006、T007 | Postman 测试：正确账号返回 Token；错误密码 5 次后接口返回 423；锁定时间准确 |
| T009 | 实现 JWT 认证过滤器（OncePerRequestFilter）+ Spring Security 配置（白名单/权限拦截）| BE2 | 🔴 P0 | T007 | Token 缺失或过期接口返回 401；白名单接口（/login）无须 Token |
| T010 | 实现 Token 刷新接口（POST /api/auth/refresh）+ 前端续签策略 | BE1 | 🟡 P1 | T008、T009 | Token 在有效期内可换新 Token；过期 Token 无法续签 |
| T011 | 开发登录页面（表单 + 密码可见切换 + "记住我" 复选框 + 响应式布局）| FE | 🔴 P0 | T004 | 设计稿还原；表单客户端校验（非空）；移动端可用 |
| T012 | 配置 Axios 请求/响应拦截器（自动注入 Token；401 自动跳转登录页）| FE | 🔴 P0 | T004 | 每个请求 Header 携带 Bearer Token；401 触发跳转；Token 存入 Pinia Store |
| T013 | 配置 Vue Router 全局前置守卫（未登录跳转登录页；已登录访问登录页跳转首页）| FE | 🔴 P0 | T011 | 手动测试：直接访问 /tasks 无 Token 时跳转 /login；登录后跳转 /tasks |

---

### 🔑 US004：修改个人密码（3 SP）

> **完成时限**：Day 3-5（Week 1）
> **Sprint 1 缩减**：无

| 任务 ID | 任务名称 | 负责人 | 优先级 | 前置依赖 | 完成标准 |
|--------|---------|:------:|:-----:|:-------:|---------|
| T014 | 实现修改密码接口（PUT /api/user/me/password）：旧密码校验 + 新密码强度校验（长度≥8位含字母+数字）+ 修改后当前 Token 失效 | BE1 | 🔴 P0 | T008 | 接口测试：旧密码错误返回 400；弱密码返回 400；成功后原 Token 401 |
| T015 | 修改密码页面/设置弹窗（旧密码 + 新密码 + 确认密码表单，实时密码强度条）| FE | 🔴 P0 | T012 | 修改成功后 Toast 提示 + 自动跳转登录页；弱密码实时提示 |
| T016 | 前端表单校验（新密码 ≠ 旧密码；两次密码一致；复杂度规则提示）| FE | 🟡 P1 | T015 | 所有校验规则在提交前客户端拦截 |
| T017 | 强制首次登录修改密码流程（后端标记 `password_changed = false`，前端登录后检测并跳转修改密码页）| BE1 + FE | 🟡 P1 | T008、T015 | 新账号首次登录强制跳转密码修改；完成后方可进入系统 |

---

### 👥 US002：管理团队成员账号（6 SP，无批量禁用）

> **完成时限**：Day 6-8（Week 2）
> **Sprint 1 缩减**：去掉批量禁用，保留单个禁用/启用

| 任务 ID | 任务名称 | 负责人 | 优先级 | 前置依赖 | 完成标准 |
|--------|---------|:------:|:-----:|:-------:|---------|
| T018 | 实现用户管理 CRUD API（POST /api/users 创建、GET /api/users 分页查询、PUT /api/users/{id} 编辑、PUT /api/users/{id}/status 启用/禁用、POST /api/users/{id}/reset-password 重置密码）| BE2 | 🔴 P0 | T006 | 每个接口有 Swagger 注解；邮箱唯一校验；禁用时已登录 Token 失效 |
| T019 | 用户创建时发送初始密码（Sprint 1 降级：接口返回临时密码，不发邮件）+ `password_changed = false` 标记 | BE2 | 🔴 P0 | T018 | 创建用户接口返回临时密码字段；新用户首次登录触发强制修改密码 |
| T020 | 用户列表页面（Element Plus Table：姓名、邮箱、角色、状态、操作列；分页；按姓名/邮箱搜索）| FE | 🔴 P0 | T012、T027* | \*可用 Mock 数据先开发，T027（角色 API）完成后接入 |
| T021 | 新建用户模态框（表单：姓名、邮箱、角色选择、初始密码展示）| FE | 🔴 P0 | T020 | 提交成功后关闭模态框并刷新列表；邮箱重复前端提示 |
| T022 | 编辑用户模态框（复用新建表单，带回显；角色可修改）| FE | 🟡 P1 | T021 | 保存后列表数据立即更新 |
| T023 | 禁用/启用/重置密码操作按钮（确认弹窗 + 操作反馈 Toast）| FE | 🔴 P0 | T020 | 禁用成功后用户状态标签变灰；重置密码弹窗展示新密码 |

---

### 🛡️ US003：分配用户角色权限（8 SP）

> **完成时限**：Day 7-10（Week 2）
> **Sprint 1 缩减**：无（RBAC 安全核心，不可缩减）

| 任务 ID | 任务名称 | 负责人 | 优先级 | 前置依赖 | 完成标准 |
|--------|---------|:------:|:-----:|:-------:|---------|
| T024 | 设计 RBAC 框架：角色（ADMIN/MEMBER）+ 权限常量定义；Spring Security 注解（@PreAuthorize）配置 | BE2 | 🔴 P0 | T003、T009 | 技术方案文档（1页）Day 1 下午完成，供团队确认 |
| T025 | 实现角色分配接口（PUT /api/users/{id}/roles）+ 防止删除最后一个管理员的业务规则 | BE2 | 🔴 P0 | T024、T018 | 分配成功；最后管理员降级被拒并返回 400 |
| T026 | 在关键接口添加权限注解（@PreAuthorize）：用户管理接口仅 ADMIN 可访问；任务接口 ADMIN + MEMBER 可访问 | BE2 | 🔴 P0 | T024、T008 | 用 MEMBER Token 调用 /api/users 返回 403；/api/tasks 返回 200 |
| T027 | 角色变更实时生效：Spring Security 权限缓存策略（无缓存或变更时清除）确保无须重新登录 | BE2 | 🔴 P0 | T026 | 测试：角色从 MEMBER 升为 ADMIN，不重新登录直接访问用户管理接口返回 200 |
| T028 | 用户列表页角色列显示 + 角色快速切换下拉（复用 T020 用户列表组件）| FE | 🔴 P0 | T020、T025 | 角色 Tag 颜色区分（管理员=蓝，成员=灰）；下拉切换后列表角色列更新 |
| T029 | Vue Router 路由守卫按角色控制菜单显隐（管理员菜单：用户管理 + 审计日志；成员菜单：任务相关）| FE | 🔴 P0 | T013 | MEMBER 登录后导航栏无「用户管理」入口；ADMIN 直接访问 /admin/users 正常打开 |
| T030 | 按钮级权限控制自定义指令 `v-permission`（如「新建用户」按钮仅管理员可见）| FE | 🟡 P1 | T029 | MEMBER 登录后「新建用户」按钮不渲染（非禁用，而是不显示）|

---

### 📋 US005：创建新任务（6 SP，无文件附件）

> **完成时限**：Day 8-10（Week 2）
> **Sprint 1 缩减**：去掉文件附件上传；Markdown 编辑器降级为普通 textarea

| 任务 ID | 任务名称 | 负责人 | 优先级 | 前置依赖 | 完成标准 |
|--------|---------|:------:|:-----:|:-------:|---------|
| T031 | 实现创建任务接口（POST /api/tasks）：参数校验（标题非空、长度≤100）+ 自动记录创建人/创建时间 + 默认状态 TODO | BE1 | 🔴 P0 | T003（任务表）、T026（权限）| Postman：创建成功返回 201；空标题返回 400；标题>100字符返回 400 |
| T032 | 任务创建后通知负责人（Sprint 1 降级：写入通知表 / 预留接口，不发邮件/消息推送）| BE1 | 🟡 P1 | T031 | 任务表 assignee_id 有值时在通知表插入一条记录；接口不影响主流程 |
| T033 | 任务创建表单（模态框/侧边栏）：标题 + 描述（textarea）+ 优先级选择 + 截止日期选择器 + 负责人选择器 | FE | 🔴 P0 | T012、T041（负责人选择器）| 所有字段表单校验通过；提交成功后关闭并刷新列表 |
| T034 | 优先级颜色标识（高=红、中=黄、低=蓝）+ 优先级选择组件 | FE | 🔴 P0 | T033 | 优先级 Tag 颜色正确；列表和表单中颜色一致 |
| T035 | 负责人选择器组件（搜索成员下拉 + 成员头像 + 姓名；显示当前任务数量）| FE | 🔴 P0 | T020（用户列表 API）| 搜索防抖 300ms；选择后显示头像；无可用成员时提示 |
| T036 | 顶部「+」快速创建入口（打开任务创建模态框）| FE | 🟡 P1 | T033 | 在任意页面顶部导航点击「+」可打开创建任务模态框 |
| T037 | 任务创建操作历史记录（任务创建时自动写入 task_history 表：操作类型=CREATE、操作人、时间）| BE1 | 🟡 P1 | T031 | 创建任务后 task_history 表有一条 CREATE 记录；不影响主流程性能 |

> **Sprint 1 降级说明**：
> - Markdown 编辑器 → 普通 textarea（Sprint 2 升级为 md-editor-v3）
> - 文件附件上传 → 整体移至 Sprint 2
> - 任务依赖（前置任务）→ 移至 Sprint 2

---

### 👤 US007：分配任务负责人（3 SP）

> **完成时限**：Day 9-10（Week 2）
> **Sprint 1 缩减**：与 US005 创建表单共享负责人选择器（T035），增量开发量小

| 任务 ID | 任务名称 | 负责人 | 优先级 | 前置依赖 | 完成标准 |
|--------|---------|:------:|:-----:|:-------:|---------|
| T038 | 实现任务负责人变更接口（PUT /api/tasks/{id}/assignee）：变更操作记录到 task_history 表 | BE1 | 🔴 P0 | T031 | 接口成功更新 assignee_id；task_history 记录 ASSIGNEE_CHANGED |
| T039 | 账号禁用时任务自动标记「待分配」：禁用用户时批量将其负责任务的 assignee_id 置空 | BE2 | 🟡 P1 | T018、T038 | 禁用用户后查询其原负责任务，assignee_id = NULL，状态不变 |
| T040 | 任务列表行内快速分配负责人（点击负责人头像/「待分配」区域弹出成员选择器）| FE | 🔴 P0 | T035、T047（任务列表）| 点击后弹出选择器；选择后头像立即更新；调用 T038 接口 |
| T041 | 成员选择器显示当前任务数（GET /api/users/workload 接口返回每个成员的任务数）| BE1 | 🟡 P1 | T038 | 选择器中每个成员姓名后显示「(3个任务)」；数据准确 |

---

### 🔄 US008：更新任务状态（3 SP）

> **完成时限**：Day 10-11（Week 2-3）
> **Sprint 1 缩减**：无

| 任务 ID | 任务名称 | 负责人 | 优先级 | 前置依赖 | 完成标准 |
|--------|---------|:------:|:-----:|:-------:|---------|
| T042 | 实现状态变更接口（PUT /api/tasks/{id}/status）：状态流转校验（TODO→IN_PROGRESS→DONE，可回退）| BE1 | 🔴 P0 | T031 | 有效流转成功；无效流转（如 TODO→DONE）返回 400 |
| T043 | 无负责人时自动分配：任务进入 IN_PROGRESS 且 assignee_id 为空时，自动设为当前登录用户 | BE1 | 🟡 P1 | T042 | 单元测试覆盖该逻辑；接口日志可见自动分配 |
| T044 | 状态变更记录到 task_history 表（操作类型 = STATUS_CHANGED；记录旧值 → 新值）| BE1 | 🔴 P0 | T042 | task_history 记录：`状态变更：TODO → IN_PROGRESS` |
| T045 | 任务列表状态下拉切换（快速切换三态，带颜色 Tag：TODO=灰、IN_PROGRESS=蓝、DONE=绿）| FE | 🔴 P0 | T047（任务列表）| 点击 Tag 弹出下拉菜单；切换成功后 Tag 颜色立即变更 |
| T046 | 状态变更视觉反馈（切换时 loading 态；成功后短暂高亮动画）| FE | 🟢 P2 | T045 | 状态切换有 0.3s 高亮过渡（可降级为无动画）|

---

### 📊 US012：查看任务列表视图（6 SP，无分组视图）

> **完成时限**：Day 11-13（Week 3）
> **Sprint 1 缩减**：去掉「按状态/负责人分组展示」；移动端适配降级（基础响应式即可）

| 任务 ID | 任务名称 | 负责人 | 优先级 | 前置依赖 | 完成标准 |
|--------|---------|:------:|:-----:|:-------:|---------|
| T047 | 实现任务列表查询接口（GET /api/tasks?page=1&size=20&sort=createdAt,desc）：分页 + 多列排序 + 基础状态筛选 | BE1 | 🔴 P0 | T031 | 返回分页数据结构（total/pages/list）；sort 参数正确映射到 MyBatis-Plus 排序 |
| T048 | 任务数量统计接口（GET /api/tasks/stats）：返回各状态任务数 | BE1 | 🟡 P1 | T047 | 返回 `{todo: N, inProgress: N, done: N, total: N}` |
| T049 | 任务列表页面主结构（Element Plus Table：标题、负责人头像、优先级 Tag、截止日期、状态 Tag、操作列）| FE | 🔴 P0 | T012 | 表格正确渲染；空状态展示「暂无任务」 |
| T050 | 分页组件（el-pagination）+ 每页大小切换（20/50/100 条）| FE | 🔴 P0 | T049 | 切换页码和每页大小正确触发接口重新加载 |
| T051 | 多列排序（点击列头切换升序/降序，列头显示排序箭头）| FE | 🔴 P0 | T049 | 点击标题列头按创建时间排序；点击截止日期列头按截止日期排序 |
| T052 | 排序和分页偏好保存（存入 localStorage，刷新后保持上次设置）| FE | 🟡 P1 | T051 | 关闭浏览器再打开，排序列和顺序保持上次设置 |
| T053 | 行悬停快捷操作（悬停显示：状态切换下拉 + 分配负责人按钮，复用 T045 和 T040 组件）| FE | 🟡 P1 | T045、T040 | 行 hover 显示操作按钮；移开后隐藏 |

---

## 📊 第3部分：按角色任务分配

### 3.1 BE1（后端工程师1）任务清单

**主要技能**：Spring Boot、JWT 认证、Task 业务域、CI/CD
**承担任务**：T001、T002、T005、T008、T010、T014、T017（后端部分）、T031、T032、T037、T038、T041、T042、T043、T044、T047、T048

| 任务 ID | 任务名称 | 计划周 | 优先级 |
|--------|---------|:------:|:-----:|
| T001 | 创建代码仓库 + 配置分支保护 | Week 1 Day 1 | 🔴 P0 |
| T002 | 初始化 Spring Boot 项目骨架 | Week 1 Day 1 | 🔴 P0 |
| T005 | 配置 CI 基础流水线 | Week 1 Day 1-2 | 🟡 P1 |
| T008 | 登录接口（含账号锁定）| Week 1 Day 2-3 | 🔴 P0 |
| T010 | Token 刷新接口 | Week 1 Day 3 | 🟡 P1 |
| T014 | 修改密码接口 | Week 1 Day 4 | 🔴 P0 |
| T017 | 强制修改密码流程（后端部分）| Week 1 Day 5 | 🟡 P1 |
| T031 | 创建任务接口 | Week 2 Day 8 | 🔴 P0 |
| T032 | 任务通知（预留接口）| Week 2 Day 8 | 🟡 P1 |
| T037 | 任务创建历史记录 | Week 2 Day 8-9 | 🟡 P1 |
| T038 | 任务负责人变更接口 | Week 2 Day 9 | 🔴 P0 |
| T041 | 成员工作量接口（workload）| Week 2 Day 9 | 🟡 P1 |
| T042 | 状态变更接口 | Week 2 Day 10 | 🔴 P0 |
| T043 | 自动分配负责人逻辑 | Week 2 Day 10 | 🟡 P1 |
| T044 | 状态变更历史记录 | Week 2 Day 10 | 🔴 P0 |
| T047 | 任务列表查询接口（分页+排序）| Week 3 Day 11 | 🔴 P0 |
| T048 | 任务统计接口 | Week 3 Day 11 | 🟡 P1 |

---

### 3.2 BE2（后端工程师2）任务清单

**主要技能**：Spring Security、RBAC 框架、数据库设计、用户域
**承担任务**：T003、T006、T007、T009、T018、T019、T024、T025、T026、T027、T039

| 任务 ID | 任务名称 | 计划周 | 优先级 |
|--------|---------|:------:|:-----:|
| T003 | 初始化 DB Schema + Flyway V1 | Week 1 Day 1 | 🔴 P0 |
| T006 | User 实体 + UserDetailsService | Week 1 Day 1-2 | 🔴 P0 |
| T007 | JWT 工具类 | Week 1 Day 2 | 🔴 P0 |
| T009 | JWT 认证过滤器 + Security 配置 | Week 1 Day 2-3 | 🔴 P0 |
| **T024** | **RBAC 框架设计（技术方案 Day 1 下午）** | **Week 1 Day 1** | 🔴 P0 |
| T018 | 用户管理 CRUD API | Week 1-2 Day 5-6 | 🔴 P0 |
| T019 | 用户初始密码 + 强制修改标记 | Week 2 Day 6 | 🔴 P0 |
| T025 | 角色分配接口 + 最后管理员保护 | Week 2 Day 7 | 🔴 P0 |
| T026 | 关键接口 @PreAuthorize 注解 | Week 2 Day 7-8 | 🔴 P0 |
| T027 | 角色变更实时生效（权限缓存策略）| Week 2 Day 8 | 🔴 P0 |
| T039 | 禁用用户时任务自动「待分配」| Week 2 Day 9 | 🟡 P1 |

---

### 3.3 FE（前端工程师）任务清单

**主要技能**：Vue 3、TypeScript、Element Plus、Pinia
**注意**：FE 是唯一瓶颈，任务串行，需严格按优先级执行

| 任务 ID | 任务名称 | 计划周 | 优先级 | 注意事项 |
|--------|---------|:------:|:-----:|---------|
| T004 | 初始化 Vue 3 项目 | Week 1 Day 1 | 🔴 P0 | — |
| T011 | 登录页面 | Week 1 Day 1-2 | 🔴 P0 | 优先级最高，其他页面依赖 |
| T012 | Axios 拦截器 | Week 1 Day 2 | 🔴 P0 | 所有 API 调用前提 |
| T013 | Vue Router 守卫 | Week 1 Day 2 | 🔴 P0 | — |
| T015 | 修改密码页面 | Week 1 Day 3 | 🔴 P0 | — |
| T016 | 密码表单校验 | Week 1 Day 3 | 🟡 P1 | — |
| T017 | 强制修改密码流程（前端跳转）| Week 1 Day 4 | 🟡 P1 | — |
| T029 | Vue Router 角色菜单控制 | Week 1 Day 4-5 | 🔴 P0 | 可与后端并行（不依赖 T026）|
| T030 | v-permission 指令 | Week 2 Day 5 | 🟡 P1 | — |
| T020 | 用户列表页面 | Week 2 Day 6 | 🔴 P0 | 可用 Mock 先开发 |
| T021 | 新建用户模态框 | Week 2 Day 6-7 | 🔴 P0 | — |
| T022 | 编辑用户模态框 | Week 2 Day 7 | 🟡 P1 | — |
| T023 | 禁用/启用/重置密码操作 | Week 2 Day 7 | 🔴 P0 | — |
| T028 | 用户列表角色显示 + 切换 | Week 2 Day 7-8 | 🔴 P0 | — |
| T033 | 任务创建表单 | Week 2 Day 8 | 🔴 P0 | — |
| T034 | 优先级颜色组件 | Week 2 Day 8 | 🔴 P0 | — |
| T035 | 负责人选择器组件 | Week 2 Day 8-9 | 🔴 P0 | 复用于 T040 |
| T036 | 顶部「+」快速创建入口 | Week 2 Day 9 | 🟡 P1 | — |
| T049 | 任务列表页面主结构 | Week 3 Day 11 | 🔴 P0 | — |
| T045 | 状态下拉切换 + Tag 颜色 | Week 3 Day 11 | 🔴 P0 | — |
| T040 | 列表行内分配负责人 | Week 3 Day 11-12 | 🔴 P0 | — |
| T050 | 分页组件 | Week 3 Day 12 | 🔴 P0 | — |
| T051 | 多列排序 | Week 3 Day 12 | 🔴 P0 | — |
| T052 | 偏好保存（localStorage）| Week 3 Day 12-13 | 🟡 P1 | — |
| T053 | 行悬停快捷操作 | Week 3 Day 13 | 🟡 P1 | — |
| T046 | 状态切换动画 | 按需 | 🟢 P2 | 可不实现 |

> **⚠️ FE 进度检查点**：
> - **Day 5 结束**：必须完成 T011 + T012 + T013 + T015 + T029（登录与路由基础）
> - **Day 8 结束**：必须完成 T020 + T023 + T028（用户管理页面）
> - **Day 11 结束**：必须开始 T049（任务列表页），否则触发范围削减

---

### 3.4 Sprint 看板（Kanban Board）— 初始状态

| 待办（To Do） | 进行中（In Progress） | 待测试（To Test）| 已完成（Done）|
|:---|:---|:---|:---|
| **TS001** T001 T002 T003 T004 T005 | — | — | — |
| **US001** T006–T013 | — | — | — |
| **US004** T014–T017 | — | — | — |
| **US002** T018–T023 | — | — | — |
| **US003** T024–T030 | — | — | — |
| **US005** T031–T037 | — | — | — |
| **US007** T038–T041 | — | — | — |
| **US008** T042–T046 | — | — | — |
| **US012** T047–T053 | — | — | — |

**看板使用规则**：
- 每人同一时刻最多 1 个任务处于「进行中」
- 任务完成开发后移入「待测试」（开发者自测 DoD 清单）
- 通过自测后移入「已完成」
- Daily Standup 时同步更新看板状态

---

## 🔗 第4部分：依赖关系与开发顺序

### 4.1 关键依赖链（Critical Dependency Chain）

```
TS001（初始化项目）Day 1
  ├─→ BE 方向
  │     T006 → T007 → T009（Security Filter）
  │     T008（登录接口）
  │     T024（RBAC 设计）← ⚡ Day 1 下午完成，阻塞 US003 全部后端任务
  │     T018（用户 CRUD）→ T025（角色分配）→ T026（接口权限）→ T027（实时生效）
  │     T031（创建任务）→ T038（分配负责人）→ T042（更新状态）→ T047（列表查询）
  │
  └─→ FE 方向
        T011（登录页）→ T012（Axios）→ T013（Router）
        T015（修改密码页）
        T029（路由角色控制）← 可与 BE 并行（不依赖后端接口）
        T020（用户列表）← 可用 Mock 并行开发（T035 负责人选择器共享）
        T033（任务创建表单）← 依赖 T035（负责人选择器）
        T049（任务列表）← 依赖 T045（状态组件）和 T040（分配组件）
```

### 4.2 可并行开发组

| 并行组 | 任务组合 | 并行原因 |
|:-----:|---------|---------|
| **Week 1 并行 A** | BE2: T003 + T006 + T007 + T009 同时推进 | 各有独立切入点（DB / 实体 / JWT / Filter）|
| **Week 1 并行 B** | BE1: T008（登录接口）与 BE2: T024（RBAC 设计）并行 | BE1 先完成基础认证，BE2 专注安全框架 |
| **Week 1 并行 C** | FE: T029（路由角色控制）与 BE2: T026（接口权限注解）并行 | 前端路由控制不依赖后端 API |
| **Week 2 并行 D** | FE: T020 用 Mock 开发用户列表，BE2: T018 开发用户 CRUD API 并行 | FE 用静态数据先开发，接口就绪后联调 |
| **Week 2 并行 E** | BE1: T031-T037（任务 API）与 FE: T033（任务表单）并行 | FE 用 Mock 先开发表单，任务 API 完成后联调 |
| **Week 3 并行 F** | BE1: T047-T048（列表 API）与 FE: T049（列表组件）并行 | FE 先做空状态页和骨架屏，API 完成后接入 |

### 4.3 三个关键路径节点（Critical Milestones）

| 里程碑 | 时间 | 阻塞影响 | 负责人 |
|-------|:----:|---------|:------:|
| 🔴 **M1：RBAC 技术方案确认** | Day 1 下午 17:00 | 未确认则 US003 全部后端任务无法开始 | BE2 |
| 🔴 **M2：BE 登录接口 + FE 登录页面完成** | Day 3 结束 | 未完成则 FE 所有需要认证的页面无法联调 | BE1 + FE |
| 🔴 **M3：首次测试环境部署** | Day 5（May 2）下午 | 部署失败则 Week 2 的联调工作无法推进 | BE1 |

### 4.4 联调时间节点规划

| 联调内容 | 计划时间 | 参与方 | 产出 |
|---------|:-------:|-------|------|
| 登录接口联调（BE T008 + FE T011/T012）| Day 3 下午 | BE1 + FE | 登录功能完整可用 |
| 用户管理接口联调（BE T018 + FE T020）| Day 7 下午 | BE2 + FE | 用户增删改查可用 |
| RBAC 权限联调（BE T026/T027 + FE T029/T030）| Day 8 下午 | BE2 + FE | 角色权限控制完整可用 |
| 任务 CRUD 联调（BE T031 + FE T033）| Day 10 下午 | BE1 + FE | 任务创建可用 |
| 任务列表联调（BE T047 + FE T049）| Day 12 上午 | BE1 + FE | 任务列表完整可用 |
| **全功能回归测试** | Day 13（May 14）全天 | 全员 | Sprint Demo 准备完成 |

---

## 🗓️ 附录：三周任务执行时间线

```
Week 1（Apr 28 - May 2）：认证与用户基础
────────────────────────────────────────────
Day 1（Apr 28 周一）：
  BE1: T001（仓库）→ T002（Spring Boot 骨架）→ T005（CI 流水线）
  BE2: T003（DB Schema）→ T006（User 实体）→ T024 ⚡ RBAC 技术方案（17:00 前产出）
  FE:  T004（Vue 3 初始化）

Day 2-3（Apr 29-30）：
  BE1: T008（登录接口 + 锁定逻辑）→ T010（Token 刷新）
  BE2: T007（JWT 工具类）→ T009（Security Filter）
  FE:  T011（登录页面）→ T012（Axios 拦截器）→ T013（路由守卫）
  🔗 Day 3 下午：登录接口联调（M2 里程碑）

Day 4-5（May 1-2）：
  BE1: T014（修改密码接口）→ T017（强制修改后端）→ T018 开始（用户 CRUD）
  BE2: T018 继续（用户 CRUD）→ T019（初始密码）
  FE:  T015（修改密码页面）→ T016（表单校验）→ T029（路由角色控制，与后端并行）
  🔗 Day 5 下午：首次测试环境部署演练（M3 里程碑）

Week 2（May 5 - May 9）：RBAC + 用户管理 + 任务核心
────────────────────────────────────────────────────
Day 6-7（May 5-6）：
  BE2: T018 完成 → T025（角色分配 API）→ T026（接口权限注解）
  FE:  T030（v-permission）→ T020（用户列表，可用 Mock）→ T021（新建用户弹窗）
  🔗 Day 7 下午：用户管理接口联调

Day 8（May 7）：
  ⚠️ 中期检查点：已完成 SP 目标 ≥ 15 SP，否则触发范围削减
  BE2: T027（权限实时生效）→ T039（禁用时任务重置）
  BE1: T031（创建任务接口）→ T037（任务历史）
  FE:  T022（编辑用户）→ T023（禁用/重置操作）→ T028（用户角色显示）
  🔗 Day 8 下午：RBAC 权限联调

Day 9-10（May 8-9）：
  BE1: T032（通知预留）→ T038（分配负责人接口）→ T041（workload 接口）→ T042（状态接口）→ T044（状态历史）
  FE:  T033（任务创建表单）→ T034（优先级组件）→ T035（负责人选择器）→ T036（快速创建入口）
  🔗 Day 10 下午：任务 CRUD 联调

Week 3（May 12 - May 15）：任务列表 + 联调 + 上线
────────────────────────────────────────────────
Day 11-12（May 12-13）：
  BE1: T043（自动分配）→ T047（列表查询 API）→ T048（统计 API）
  FE:  T045（状态 Tag 组件）→ T040（行内分配负责人）→ T049（列表主结构）→ T050（分页）→ T051（排序）
  🔗 Day 12 上午：任务列表联调

Day 13（May 13）：
  ⚠️ 最终冲刺评估：是否有 Committed 任务未开始
  全员：T052（偏好保存）→ T053（悬停操作）
  全员：全功能回归测试（对照 Sprint 1 Backlog 的 DoD 清单逐条验证）
  BE1: 生产环境配置 + 部署脚本准备

Day 14（May 14-15）：
  全员：Bug 修复（回归测试发现的问题）
  BE1: 生产环境部署
  May 15 上午：Sprint 1 Review + 演示 MVP
  May 15 下午：🚀 MVP 上线
```

---

> **文档说明**：本文档为 Sprint 1 任务拆解基准，Sprint 启动后不做修改。执行进度记录在 `PROJECT_STATUS_v1.0.md`。
> **下一步**：参考任务清单，使用 Jira/禅道/GitHub Projects 创建对应的 Task 卡片，将任务挂到对应 Story 下。
