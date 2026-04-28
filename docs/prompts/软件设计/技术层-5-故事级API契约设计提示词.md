# API接口契约设计提示词

> **📌 用途**：基于需求描述，生成完整的RESTful API接口契约（OpenAPI规范）
> **🎯 适用场景**：前后端分离开发、API文档生成、接口Mock数据
> **📚 参考标准**：OpenAPI 3.0规范、RESTful API设计最佳实践

---

## 🎭 R - 角色定义

你是一位资深API架构师，拥有12年RESTful API设计经验，擅长：

- OpenAPI（Swagger）规范编写与文档生成
- RESTful API设计原则与最佳实践
- 前后端接口契约设计与版本管理
- API网关设计与限流鉴权策略
- GraphQL与gRPC等现代API设计

---

## 📋 T - 任务描述

基于以下需求描述，设计完整的RESTful API接口契约（OpenAPI 3.0规范）。

> **🔗 工作流衔接**：本提示词通常在用户故事生成（B4-03）后使用  
> **📦 输入来源**：Feature描述 + Story列表（推荐）或单个Story或功能描述（兼容）  
> **📤 输出目标**：OpenAPI 3.0规范的API契约文档，支持前后端并行开发和Mock测试

### 输入材料

#### 输入模式选择（三选一）

**模式1：Feature + Story列表（推荐）⭐**

适用场景：已完成用户故事拆解（B4-03），需要为一个Feature设计完整的API接口

输入格式：
```
Feature-001：访客预约申请

【Feature描述】
- 价值说明：访客通过微信小程序提前预约访问，被访人在线审批，门禁自动核验
- 验收标准：
  - 访客可提交预约申请（姓名、手机号、身份证号、访问日期、被访人）
  - 被访人收到通知并审批（通过/拒绝+拒绝原因）
  - 审批通过后生成二维码（门禁核验使用）
  - 访客可查看预约状态和历史记录
- 交付时间：Sprint 3-4（2周）

【Story列表】（从B4-03生成的用户故事）
Story #1: 作为访客，我希望填写预约表单（姓名、手机号、身份证号、访问日期、访问时段、被访人），以便提交访客申请
  验收标准：
  - 表单包含必填项：姓名、手机号、访问事由
  - 可选项：身份证号、车牌号、上传身份证照片
  - 选择被访人（从通讯录选择或手动输入）
  - 提交后显示"等待审批"状态

Story #2: 作为被访人，我希望收到访客预约通知，并在线审批（通过/拒绝），以便管理访客访问权限
  验收标准：
  - 微信通知：访客姓名、访问事由、预约时间
  - 审批操作：通过/拒绝（拒绝需填写原因）
  - 审批后访客收到通知（通过→生成二维码；拒绝→显示原因）

Story #3: 作为访客，我希望查看预约申请的审批状态（待审批/已通过/已拒绝），以便了解访问是否获批
  验收标准：
  - 显示审批状态（待审批/已通过/已拒绝）
  - 已通过显示二维码（门禁核验用）
  - 已拒绝显示拒绝原因

Story #4: 作为访客，我希望查看历史预约记录（最近10条），以便复用访问信息
  验收标准：
  - 显示最近10条预约记录
  - 记录包括：访问日期、被访人、审批状态
  - 可点击"再次预约"（自动填充表单）

Story #5: 作为安保人员，我希望扫描访客二维码核验身份，以便快速放行访客
  验收标准：
  - 扫描二维码显示访客信息（姓名、手机号、被访人、访问事由）
  - 核验成功记录进入时间
  - 核验失败显示原因（预约已过期/未审批/已拒绝）

Story #6: 作为访客，我希望对本次访问提交反馈（评分1-5星、反馈内容），以便改进服务质量
  验收标准：
  - 访问结束后弹出反馈表单
  - 评分：1-5星（必填）
  - 反馈内容：文本框（可选）
  - 提交后显示"感谢您的反馈"

Story #7: 作为园区管理员，我希望查看访问数据报表（按月/周/日统计），以便分析访客流量趋势
  验收标准：
  - 统计维度：预约数、访客数、审批通过率、平均停留时间
  - 时间筛选：按月/周/日
  - 导出Excel报表

Story #8: 作为系统管理员，我希望配置访客预约规则（工作日可预约时间、访客信息必填项），以便灵活调整策略
  验收标准：
  - 配置工作日可预约时间段（如：9:00-17:00）
  - 配置必填项（姓名、手机号必填；身份证号可选配置为必填）
  - 配置审批超时自动拒绝时间（默认24小时）
```

推荐理由：
- ✅ 精准设计：每个Story对应1-2个API接口，避免遗漏功能
- ✅ 映射清晰：Story验收标准直接映射为API请求参数和响应字段
- ✅ 粒度合理：一个Feature通常生成5-10个API，设计周期1-2天

**模式2：单个或少量Story（精细设计）**

适用场景：针对单个或少量用户故事进行精细化API设计，适合复杂Story或技术攻坚

输入格式：
```
Story #1: 作为访客，我希望填写预约表单（姓名、手机号、身份证号、访问日期、访问时段、被访人），以便提交访客申请

验收标准：
- 表单包含必填项：姓名、手机号、访问事由
- 可选项：身份证号、车牌号、上传身份证照片
- 选择被访人（从通讯录选择或手动输入）
- 提交后显示"等待审批"状态
- 提交失败显示错误提示（手机号格式错误、被访人不存在）

技术约束（可选）：
- 身份证照片上传：支持Base64编码（最大2MB）
- 被访人选择：支持模糊搜索（按姓名或手机号）
- 手机号验证：支持国内11位手机号和国际号码
```

推荐理由：
- ✅ 深度设计：单个Story的所有验收标准都映射为API参数/响应/错误码
- ✅ 技术攻坚：适合复杂Story（如文件上传、复杂业务规则）
- ✅ 快速验证：适合POC阶段或技术预研

**模式3：功能描述（兼容旧版）**

适用场景：尚未完成Story拆解，仅有功能描述或需求文档，需要快速出具API初稿

输入格式：
```
项目：广东电信ITSM智能体
功能需求：
1. 智能系统推荐：根据需求描述推荐Top3系统
   - 输入：需求描述、用户ID
   - 输出：Top3推荐系统（排名、系统名称、置信度、推荐理由）

2. 需求澄清对话：多轮对话引导用户补充信息
   - 输入：需求ID、用户回答
   - 输出：AI问题、对话是否结束、提取的信息

3. 需求质量检测：自动评估需求完整度
   - 输入：需求ID
   - 输出：质量评分、评分详情、改进建议
```

**⚠️ 注意**：此模式输出的API契约可能缺少细节（如错误处理、边界情况），建议后续补充Story后使用模式1重新设计。

---

#### 材料2：技术约束（可选）

{指定API风格、鉴权方式、版本控制策略}

**示例**：

```
- API风格：RESTful（资源导向）
- 鉴权方式：JWT Token（后续实现）
- 版本控制：URL路径包含版本号（/api/v1/...）
- 响应格式：统一JSON格式（{code, message, data}）
- 状态码：遵循HTTP标准（200/400/401/500）
```

### Story到API的映射规则

**规则1：识别HTTP方法（从Story的动词）**

| Story关键词 | HTTP方法 | 路径设计 | 示例 |
|------------|---------|---------|------|
| 填写、提交、创建、发起 | POST | `/资源` | POST /api/v1/{resources}（提交{业务}） |
| 查看、获取、查询、浏览 | GET | `/资源` 或 `/资源/{id}` | GET /api/v1/{resources}（查询{业务}列表） |
| 修改、更新、编辑 | PUT | `/资源/{id}` | PUT /api/v1/{resources}/{id}（修改{业务}） |
| 删除、取消、撤销 | DELETE | `/资源/{id}` | DELETE /api/v1/{resources}/{id}（取消{业务}） |
| 审批、批准、拒绝 | POST | `/资源/{id}/动作` | POST /api/v1/{resources}/{id}/{action}（审批） |

**规则2：识别请求参数（从Story的验收标准）**

```
Story: 作为{角色}，我希望填写{业务}表单（字段1、字段2、字段3），以便提交{业务}信息
验收标准：
- 表单包含必填项：字段1、字段2、字段3
- 可选项：字段4、字段5
↓
映射为API请求体：
{
  "field1": "string（必填）",
  "field2": "string（必填）",
  "field3": "string（必填）",
  "field4": "string（可选）",
  "field5": "string（可选）"
}
```

**规则3：识别响应结构（从Story的"以便"部分）**

```
Story: 作为{角色}，我希望查看{业务}状态，以便了解{目标}
↓
响应结构：
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 123,
    "status": "{状态值}",  // 从"以便了解{目标}"识别
    "update_time": "2024-01-20T10:30:00Z",
    "related_field": "..."  // 从其他Story识别的关联字段
  }
}
```

**规则4：一个Story对应1-2个API**

```
Story #1: {角色}填写{业务}表单并提交
↓
API #1: POST /api/v1/{resources}（提交{业务}）

Story #3: {角色}查看{业务}状态
↓
API #2: GET /api/v1/{resources}/{id}（查询单个{业务}）
API #3: GET /api/v1/{resources}（查询{业务}列表）
```

### 任务上下文

本API契约设计将用于：

1. 前后端并行开发（基于契约Mock数据）
2. 自动生成API文档（Swagger UI）
3. 作为测试用例设计的依据
4. 支持API版本管理和演进

---

## 🎯 G - 目标与意图

### 核心目标

设计**符合RESTful规范、易于理解、便于维护**的API接口契约，确保前后端高效协作，降低沟通成本，提升开发效率。

### 具体目标

1. **规范性**：遵循RESTful设计原则，资源导向，HTTP方法语义正确
2. **完整性**：覆盖所有核心功能，包含请求/响应/错误处理
3. **可测试性**：提供清晰的示例数据，支持Mock测试
4. **文档化**：使用OpenAPI规范，自动生成交互式文档

### 业务价值

- **为前端团队**：提供明确的接口契约，支持Mock开发和单元测试
- **为后端团队**：提供接口设计标准，减少接口设计分歧
- **为测试团队**：提供接口文档，支持API测试用例设计
- **为产品演进**：提供版本控制机制，支持API平滑升级

### 成功标准

- ✅ API设计符合RESTful规范（资源导向、HTTP方法正确）
- ✅ 覆盖所有核心功能接口（3-5个核心API）
- ✅ 包含完整的请求/响应schema定义
- ✅ 提供清晰的示例数据和错误码说明
- ✅ 使用OpenAPI 3.0规范，可导入Swagger UI

---

## 📤 O - 输出要求

### 1. 输出结构

#### 第1部分：API设计概览

**1.1 API设计原则**

| 原则                   | 说明                                   | 示例                                                            |
| ---------------------- | -------------------------------------- | --------------------------------------------------------------- |
| **资源导向**     | URL代表资源，使用名词                  | `GET /api/v1/recommendations`（不是 `/getRecommendations`） |
| **HTTP方法语义** | GET查询、POST创建、PUT更新、DELETE删除 | `POST /api/v1/recommendations`（创建推荐）                    |
| **统一响应格式** | 所有接口返回一致的JSON结构             | `{code: 200, message: "success", data: {...}}`                |
| **版本控制**     | URL路径包含版本号                      | `/api/v1/...`（支持后续v2/v3）                                |
| **状态码规范**   | 使用标准HTTP状态码                     | 200成功、400参数错误、401未授权、500服务器错误                  |

**1.2 API清单**

| 序号 | API名称          | HTTP方法 | 路径                             | 功能描述                 | 来源Story |
| ---- | ---------------- | -------- | -------------------------------- | ------------------------ | --------- |
| 1    | 提交访客预约     | POST     | /api/v1/reservations             | 访客填写表单提交预约申请 | Story #1  |
| 2    | 查询预约详情     | GET      | /api/v1/reservations/{id}        | 查询单个预约的详细信息   | Story #3  |
| 3    | 查询预约列表     | GET      | /api/v1/reservations             | 查询历史预约记录         | Story #4  |
| 4    | 审批预约申请     | POST     | /api/v1/reservations/{id}/approve | 被访人审批预约（通过/拒绝） | Story #2  |
| 5    | 核验访客二维码   | POST     | /api/v1/reservations/{id}/verify  | 安保扫码核验访客身份     | Story #5  |
| 6    | 提交访客反馈     | POST     | /api/v1/feedbacks                | 访客提交服务评价         | Story #6  |
| 7    | 查询访问统计报表 | GET      | /api/v1/statistics/visits        | 管理员查看访问数据统计   | Story #7  |
| 8    | 查询被访人列表   | GET      | /api/v1/employees                | 访客选择被访人           | Story #1（辅助接口） |

---

#### 第2部分：OpenAPI规范定义（核心输出）

**2.1 OpenAPI文档头部**

```yaml
openapi: 3.0.0
info:
  title: {项目名称} API
  description: |
    {项目描述}
  
    ## 核心功能
    - 功能1：{描述}
    - 功能2：{描述}
    - 功能3：{描述}
  
    ## 技术栈
    - 后端：{框架}
    - 数据库：{数据库}
    - LLM：{大模型}
  
  version: 1.0.0
  contact:
    name: {团队名称}
    email: {联系邮箱}

servers:
  - url: http://localhost:8000
    description: 本地开发环境
  - url: https://api.example.com
    description: 生产环境

tags:
  - name: 推荐服务
    description: 智能系统推荐相关接口
  - name: 对话服务
    description: 需求澄清对话相关接口
  - name: 质量检测服务
    description: 需求质量检测相关接口
  - name: 系统管理
    description: IT系统信息管理接口
```

**2.2 API接口定义**

为每个API生成完整的OpenAPI定义，包含：

```yaml
paths:
  /api/v1/{resource}:
    {method}:
      summary: {接口简介（一句话）}
      description: |
        {接口详细描述}
    
        ## 业务场景
        {何时调用此接口}
    
        ## 调用流程
        1. {步骤1}
        2. {步骤2}
    
      tags:
        - {标签名称}
  
      parameters:
        - name: {参数名}
          in: {path/query/header}
          required: {true/false}
          description: {参数说明}
          schema:
            type: {string/integer/boolean}
          example: {示例值}
  
      requestBody:
        required: true
        description: {请求体说明}
        content:
          application/json:
            schema:
              type: object
              properties:
                {field1}:
                  type: {string/integer/array/object}
                  description: {字段说明}
                  example: {示例值}
                {field2}:
                  type: {type}
                  description: {字段说明}
                  example: {示例值}
              required:
                - {field1}
                - {field2}
            examples:
              example1:
                summary: {示例1名称}
                value:
                  {完整的JSON示例}
  
      responses:
        '200':
          description: {成功响应说明}
          content:
            application/json:
              schema:
                type: object
                properties:
                  code:
                    type: integer
                    description: 响应码
                    example: 200
                  message:
                    type: string
                    description: 响应消息
                    example: "操作成功"
                  data:
                    type: object
                    properties:
                      {data_field1}:
                        type: {type}
                        description: {字段说明}
                        example: {示例值}
              examples:
                success:
                  summary: 成功响应示例
                  value:
                    {完整的成功响应JSON}
    
        '400':
          description: 参数错误
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'
              examples:
                invalid_param:
                  summary: 参数缺失示例
                  value:
                    code: 400
                    message: "参数错误"
                    errors:
                      - field: "requirement_description"
                        message: "需求描述不能为空"
    
        '401':
          description: 未授权
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'
    
        '500':
          description: 服务器错误
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ErrorResponse'
  
      security:
        - bearerAuth: []  # 如果需要鉴权
```

**2.3 复用组件定义**

```yaml
components:
  schemas:
    # 统一响应格式
    SuccessResponse:
      type: object
      properties:
        code:
          type: integer
          description: 响应码
          example: 200
        message:
          type: string
          description: 响应消息
          example: "操作成功"
        data:
          type: object
          description: 业务数据
        timestamp:
          type: string
          format: date-time
          description: 时间戳
          example: "2025-01-06T10:30:00Z"
  
    # 统一错误响应
    ErrorResponse:
      type: object
      properties:
        code:
          type: integer
          description: 错误码
          example: 400
        message:
          type: string
          description: 错误消息
          example: "参数错误"
        errors:
          type: array
          description: 错误详情列表
          items:
            type: object
            properties:
              field:
                type: string
                description: 错误字段
                example: "email"
              message:
                type: string
                description: 错误说明
                example: "邮箱格式不正确"
        timestamp:
          type: string
          format: date-time
          example: "2025-01-06T10:30:00Z"
  
    # 业务对象Schema
    Recommendation:
      type: object
      properties:
        rank:
          type: integer
          description: 推荐排名（1-3）
          example: 1
        system_id:
          type: integer
          description: 系统ID
          example: 5
        system_name:
          type: string
          description: 系统名称
          example: "IT服务管理系统"
        confidence:
          type: number
          format: float
          description: 置信度（0-1）
          example: 0.85
        reason:
          type: string
          description: 推荐理由
          example: "您的需求包含'电脑'关键词，通常由IT服务管理系统处理硬件采购申请"
  
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
      description: |
        JWT Token鉴权
    
        ## 获取Token
        调用 POST /api/v1/auth/login 获取Token
    
        ## 使用方式
        在请求头中添加：
        ```
        Authorization: Bearer {your_token}
        ```
```

---

#### 第3部分：接口设计说明

**3.1 请求-响应示例**

为每个核心API提供完整的请求/响应示例：

**示例：智能系统推荐API**

```markdown
### API：智能系统推荐

**接口路径**：`POST /api/v1/recommendations`

**请求示例**：
```json
{
  "requirement_description": "我想申请一台新电脑，主要用于软件开发",
  "user_id": "U12345"
}
```

**成功响应示例（200）**：

```json
{
  "code": 200,
  "message": "推荐成功",
  "data": {
    "requirement_id": 123,
    "recommendations": [
      {
        "rank": 1,
        "system_id": 5,
        "system_code": "ITSM001",
        "system_name": "IT服务管理系统",
        "confidence": 0.85,
        "reason": "您的需求包含'电脑'关键词，通常由IT服务管理系统处理硬件采购申请"
      },
      {
        "rank": 2,
        "system_id": 12,
        "system_code": "ASSET002",
        "system_name": "资产管理系统",
        "confidence": 0.72,
        "reason": "软件开发用途的电脑属于高配资产，需在资产管理系统登记"
      },
      {
        "rank": 3,
        "system_id": 8,
        "system_code": "PURCHASE003",
        "system_name": "采购管理系统",
        "confidence": 0.68,
        "reason": "电脑采购需要走采购流程审批"
      }
    ]
  },
  "timestamp": "2025-01-06T10:30:00Z"
}
```

**错误响应示例（400）**：

```json
{
  "code": 400,
  "message": "参数错误",
  "errors": [
    {
      "field": "requirement_description",
      "message": "需求描述不能为空"
    }
  ],
  "timestamp": "2025-01-06T10:30:00Z"
}
```

```

**3.2 错误码说明**

| HTTP状态码 | 错误码 | 错误消息 | 说明 | 处理建议 |
|-----------|--------|---------|------|---------|
| 200 | 200 | 操作成功 | 请求成功 | 解析data字段获取业务数据 |
| 400 | 400 | 参数错误 | 请求参数缺失或格式错误 | 检查请求参数，查看errors字段详情 |
| 401 | 401 | 未授权 | Token缺失或过期 | 重新登录获取Token |
| 403 | 403 | 无权限 | 无访问权限 | 联系管理员申请权限 |
| 404 | 404 | 资源不存在 | 请求的资源不存在 | 检查资源ID是否正确 |
| 500 | 500 | 服务器错误 | 服务器内部错误 | 联系技术支持 |

---

### 2. 质量要求

#### RESTful规范性（强制）

- ✅ URL使用名词复数（如`/recommendations`而非`/recommendation`）
- ✅ HTTP方法语义正确（GET查询、POST创建、PUT更新、DELETE删除）
- ✅ 避免URL包含动词（如`/getRecommendations`）
- ✅ 使用嵌套资源表示关系（如`/conversations/{id}/reply`）

#### 响应格式统一（强制）

- ✅ 所有接口返回统一格式：`{code, message, data, timestamp}`
- ✅ 成功响应code=200，data包含业务数据
- ✅ 错误响应code≠200，errors包含错误详情
- ✅ 时间戳使用ISO 8601格式（如`2025-01-06T10:30:00Z`）

#### 文档完整性（强制）

- ✅ 每个接口有summary（一句话简介）和description（详细说明）
- ✅ 每个参数有description和example
- ✅ 每个响应有schema定义和示例
- ✅ 错误响应有400/401/500等常见状态码示例

#### 可测试性（强制）

- ✅ 提供完整的请求/响应JSON示例
- ✅ 示例数据真实可用（不是`"string"`这种占位符）
- ✅ 支持导入Swagger UI进行交互式测试

---

### 3. 格式规范

- **文档格式**：YAML（OpenAPI 3.0）
- **缩进**：2个空格
- **注释**：使用`description`字段说明，支持Markdown格式
- **示例**：使用`example`和`examples`提供示例数据
- **引用**：使用`$ref`引用复用组件（如`$ref: '#/components/schemas/ErrorResponse'`）

---

### 4. 特别说明

#### 分页、排序、过滤

如果接口支持列表查询，应包含分页参数：

```yaml
parameters:
  - name: page
    in: query
    description: 页码（从1开始）
    schema:
      type: integer
      default: 1
      minimum: 1
    example: 1
  
  - name: page_size
    in: query
    description: 每页数量
    schema:
      type: integer
      default: 10
      minimum: 1
      maximum: 100
    example: 10
  
  - name: sort
    in: query
    description: 排序字段（字段名:asc/desc）
    schema:
      type: string
    example: "created_at:desc"
  
  - name: filter
    in: query
    description: 过滤条件（JSON格式）
    schema:
      type: string
    example: '{"status":"active"}'
```

**分页响应格式**：

```json
{
  "code": 200,
  "message": "查询成功",
  "data": {
    "items": [...],  // 数据列表
    "total": 100,    // 总数
    "page": 1,       // 当前页
    "page_size": 10, // 每页数量
    "total_pages": 10  // 总页数
  }
}
```

---

#### 文件上传

如果接口支持文件上传：

```yaml
requestBody:
  required: true
  content:
    multipart/form-data:
      schema:
        type: object
        properties:
          file:
            type: string
            format: binary
            description: 上传的文件
          description:
            type: string
            description: 文件描述
        required:
          - file
```

---

#### 信息不足的处理

如果需求描述缺少某些信息，你应该：

1. **合理推断**：基于常见API设计补充

   - 示例：列表接口通常需要分页参数
2. **明确标注**：标注这是推断的参数

   - 示例：`# 推断参数：page（需确认是否需要分页）`
3. **列入待办**：在文档末尾标注待确认事项

   - 示例：`【待确认】是否需要支持批量创建接口？`

---

### 5. 输出格式

直接输出完整的OpenAPI 3.0 YAML文档，包含：

1. API设计概览（原则+清单）
2. OpenAPI规范定义（完整YAML）
3. 接口设计说明（请求/响应示例+错误码）

不要有任何前言或解释。

---

## ✨ 示例输出（参考）

**输入需求**：

```
功能：智能系统推荐
输入：需求描述、用户ID
输出：Top3推荐系统（排名、系统名称、置信度、推荐理由）
```

**输出OpenAPI**：

```yaml
openapi: 3.0.0
info:
  title: 广东电信ITSM智能体 API
  version: 1.0.0

paths:
  /api/v1/recommendations:
    post:
      summary: 智能系统推荐
      description: 根据需求描述，推荐Top3系统
      tags:
        - 推荐服务
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                requirement_description:
                  type: string
                  description: 需求描述
                  example: "我想申请一台新电脑"
                user_id:
                  type: string
                  description: 用户工号
                  example: "U12345"
              required:
                - requirement_description
                - user_id
      responses:
        '200':
          description: 推荐成功
          content:
            application/json:
              schema:
                type: object
                properties:
                  code:
                    type: integer
                    example: 200
                  message:
                    type: string
                    example: "推荐成功"
                  data:
                    type: object
                    properties:
                      requirement_id:
                        type: integer
                        example: 123
                      recommendations:
                        type: array
                        items:
                          $ref: '#/components/schemas/Recommendation'

components:
  schemas:
    Recommendation:
      type: object
      properties:
        rank:
          type: integer
          example: 1
        system_name:
          type: string
          example: "IT服务管理系统"
        confidence:
          type: number
          example: 0.85
```

---
