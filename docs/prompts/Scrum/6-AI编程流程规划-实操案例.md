# AI编程流程规划 - 实操案例（GeekBooks Sprint 3）

> **📌 文档定位**: 本文档是「6-AI编程流程规划提示词V2.0」的配套实操演示。  
> 通过 GeekBooks Sprint 3「智能图书推荐」的 3 个真实任务，手把手演示完整流程。  
>
> **前置条件**: 已阅读 `6-AI编程流程规划提示词-V2.0.md`，了解🟢/🟡/🔴/🟣分类和评分规则
>
> **阅读时间**: 20分钟（理解流程）+ 60分钟（实际操作）

---

## 🗺️ 本次演示全景

**业务背景**：GeekBooks 极客书店，Spring 3 目标是完成「智能图书推荐」功能

**演示的 3 个任务**：

| # | 任务 | 评分 | 模式 | 本案例重点 |
|---|------|------|------|----------|
| 案例1 | 创建推荐结果 DTO/VO 类 | 20分 | 🟢 | 完整 Subagent Prompt 演示 |
| 案例2 | 编写推荐服务单元测试 | 18分 | 🟢 | 测试类 Prompt 演示 + Review 要点 |
| 案例3 | 实现协同过滤推荐算法 | 10分 | 🟡 | 人机协作流程 + 迭代上限控制 |

**项目技术栈**：Spring Boot 3.x + Java 17 + MyBatis-Plus + Redis + JUnit 5 + Mockito

---

## 📁 假设的代码库结构

> 本案例假设项目已有以下参考代码（Sprint 1-2 遗留），**AI 分类评分的「参考可用度」即基于此**。

```
src/
├── main/java/com/geekbooks/
│   ├── controller/
│   │   └── ProductController.java   ← 参考：REST API 示例
│   ├── service/
│   │   ├── UserService.java         ← 参考：Service 层示例
│   │   └── ProductService.java      ← 参考：Service 层示例
│   ├── repository/
│   │   └── UserRepository.java      ← 参考：数据访问层示例
│   ├── model/dto/
│   │   └── UserDTO.java             ← 参考：DTO 类示例（Lombok）
│   ├── model/vo/
│   │   └── ProductVO.java           ← 参考：VO 类示例（Lombok）
│   └── model/entity/
│       └── Book.java                ← 实体类示例
└── test/java/com/geekbooks/
    ├── service/
    │   └── UserServiceTest.java     ← 参考：Service 单元测试示例
    └── controller/
        └── ProductControllerTest.java
```

---

## 案例1：创建推荐结果 DTO/VO 类（🟢 Subagent 自主）

### Step 1：4 维度评分

> ⏱ 预计耗时：3 分钟

| 维度 | 分数 | 评分依据 |
|------|------|----------|
| **输入明确度（×30%）** | **5** | 有 API 契约文档，字段和类型完全确定：`BookId(Long)、title(String)、author(String)、coverUrl(String)、score(Double)、reason(String)` |
| **参考可用度（×25%）** | **5** | `UserDTO.java` + `ProductVO.java` 完全可参考，结构几乎一致 |
| **复杂度（×25%）** | **5** | 纯 Java Bean，仅字段定义 + Lombok 注解，无业务逻辑 |
| **验证难度（×20%）** | **5** | `mvn compile` 通过即验证完成 |
| **加权总分** | **20分** | 20 × 30% + 20 × 25% + 20 × 25% + 20 × 20% = **20分** |

**结论**：20分 → 🟢 **Subagent 自主执行**

**传统工时预估**：1.5h（含冗余）  
**AI 工时预估**：0.7h（Prompt 设计 0.2h + AI 执行 0.1h + Review 0.3h + 修复 buffer 0.1h）  
**预期效率提升**：53%

---

### Step 2：编写 Subagent Prompt

> ⏱ 预计耗时：10 分钟  
> 💾 保存到：`ai-prompts/sprints/sprint-03/US-001/T-001.md`

---

**【可直接复制使用的 Prompt】**

````markdown
## 任务背景

GeekBooks 极客书店，Sprint 3 开发「智能图书推荐」功能（US-001）。
本任务是该功能的第 1 步：创建数据传输对象，供 Controller 和 Service 层使用。

## 任务目标

创建推荐功能所需的 2 个 Java 类：
1. `RecommendationRequestDTO`：前端请求参数封装
2. `RecommendationResultVO`：推荐结果返回给前端的视图对象

## 输入材料

### 参考代码（先读取，学习代码风格）

请先读取以下文件，学习项目的 DTO/VO 编写风格：
- DTO 参考：`src/main/java/com/geekbooks/model/dto/UserDTO.java`
- VO 参考：`src/main/java/com/geekbooks/model/vo/ProductVO.java`

### 字段定义

**RecommendationRequestDTO**（接收前端请求）：
| 字段名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| userId | Long | 是 | 用户 ID |
| limit | Integer | 否 | 推荐数量，默认 8，最大 20 |
| category | String | 否 | 按品类筛选（如"编程"、"算法"），为空则不筛选 |

**RecommendationResultVO**（返回给前端）：
| 字段名 | 类型 | 说明 |
|--------|------|------|
| bookId | Long | 图书 ID |
| title | String | 图书标题 |
| author | String | 作者 |
| coverUrl | String | 封面图 URL |
| price | BigDecimal | 当前售价 |
| score | Double | 推荐分数（0-1），仅供内部排序 |
| reason | String | 推荐理由，如"购买了《算法导论》的用户也喜欢" |

## 输出要求

### 需要创建的文件

| 文件路径 | 说明 |
|----------|------|
| `src/main/java/com/geekbooks/model/dto/RecommendationRequestDTO.java` | 请求 DTO |
| `src/main/java/com/geekbooks/model/vo/RecommendationResultVO.java` | 结果 VO |

### 代码规范（参考 UserDTO.java 和 ProductVO.java）

- 使用 Lombok 注解：`@Data`、`@Builder`、`@NoArgsConstructor`、`@AllArgsConstructor`
- 每个字段添加 JavaDoc 注释（注释说明字段含义，不要只写字段名）
- 包名：与参考文件保持一致（`com.geekbooks.model.dto` 和 `com.geekbooks.model.vo`）
- `limit` 字段添加 `@Max(20)` 和 `@Min(1)` 注解（参数校验）
- `score` 字段添加注释说明：「前端不展示，仅用于排序」

## 约束条件

- ❌ 不修改任何现有文件
- ❌ 不引入新的 Maven 依赖（项目已有 Lombok + Validation 依赖）
- ✅ 仅创建上述 2 个新文件

## 工具使用指引

1. 先用 `read_file` 读取 `UserDTO.java` 和 `ProductVO.java`，理解代码风格
2. 然后用 `create_file` 创建 2 个新文件
3. 完成后运行编译验证：`mvn compile -q`

## 验收标准

- [ ] `mvn compile -q` 编译通过，无报错
- [ ] 两个类的字段与上述字段定义完全一致
- [ ] 代码风格与 `UserDTO.java` 一致（Lombok 注解写法相同）
- [ ] 每个字段都有 JavaDoc 注释
- [ ] `limit` 字段有 `@Max(20)` 和 `@Min(1)` 注解
````

---

### Step 3：执行 & Review

> ⏱ 执行：2-5 分钟 | Review：5-10 分钟

**执行步骤**：
1. 打开 GitHub Copilot Chat（或 Claude）
2. 粘贴上方 Prompt
3. 等待 AI 生成两个文件
4. 运行验证命令

**Review 要点**（逐一检查）：

```
✅ Review Checklist

基础正确性：
□ 编译通过（mvn compile -q 无报错）
□ 两个文件都已创建，路径正确
□ 所有字段存在，类型正确（特别注意 price 是 BigDecimal，不是 Double）

代码规范：
□ 有 @Data @Builder @NoArgsConstructor @AllArgsConstructor 四个注解
□ 每个字段有 JavaDoc 注释（不是空注释或复制字段名）
□ limit 字段有 @Max(20) @Min(1)
□ score 字段注释说明了"前端不展示"

边界情况：
□ limit 的默认值（是否需要 @Builder.Default？参考参考代码怎么处理）
□ category 允许为 null，没有加 @NotNull 注解
```

**常见 AI 错误**（Review 时重点排查）：

| 常见错误 | 表现 | 判断方法 |
|----------|------|----------|
| 类型错误 | `price` 用了 `Double` 而非 `BigDecimal` | 看字段类型声明 |
| 过度设计 | 添加了不必要的方法（如 `toEntity()`） | 检查是否只有字段 |
| 风格不一致 | Lombok 写法与参考不同（如用了 `@Getter @Setter` 而非 `@Data`） | 对比参考文件 |
| 注释敷衍 | 注释内容 = 字段名（如 `/** bookId */`） | 检查注释有无实质内容 |

---

### Step 4：填写效果跟踪

> ⏱ 2 分钟（**现在就填，不要事后补**）

```
任务ID: T-001
模式: 🟢
传统工时: 1.5h
Prompt 设计: 0.2h
AI 执行: 0.1h
Review: 0.3h（Review 通过，无需修复）
修复: 0h
实际总计: 0.6h
效率提升: (1.5 - 0.6) / 1.5 = 60%  ✅
Review 轮次: 1次（首次通过）
```

---

## 案例2：编写推荐服务单元测试（🟢 Subagent 自主）

> **学习重点**：测试类 Prompt 的特殊要点——必须提供"被测类的接口定义"作为输入

### Step 1：4 维度评分

| 维度 | 分数 | 评分依据 |
|------|------|----------|
| **输入明确度（×30%）** | **5** | `RecommendationService` 的接口已定义，方法签名清晰 |
| **参考可用度（×25%）** | **5** | `UserServiceTest.java` 是完整的 Mockito 测试示例 |
| **复杂度（×25%）** | **4** | 测试方法有规律，但需要考虑多个场景 |
| **验证难度（×20%）** | **5** | `mvn test -pl . -Dtest=RecommendationServiceTest` 直接验证 |
| **加权总分** | **18.75分 → 取整 19分** | → 🟢 |

**传统工时预估**：3h  
**AI 工时预估**：1.2h（Prompt 设计 0.3h + AI 执行 0.2h + Review 0.5h + buffer 0.2h）  
**预期效率提升**：60%

---

### Step 2：Subagent Prompt

> 💾 保存到：`ai-prompts/sprints/sprint-03/US-001/T-003.md`

````markdown
## 任务背景

GeekBooks Sprint 3，为推荐服务（RecommendationService）编写单元测试。
推荐服务已完成接口定义，现在需要为其编写完整的单元测试。

## 被测接口定义

```java
// 文件：src/main/java/com/geekbooks/service/RecommendationService.java
public interface RecommendationService {
    
    /**
     * 获取用户的个性化推荐图书
     * @param userId 用户 ID
     * @param limit  推荐数量（1-20）
     * @param category 品类筛选，null 表示不筛选
     * @return 推荐结果列表，按 score 降序排列
     * @throws UserNotFoundException 用户不存在时抛出
     */
    List<RecommendationResultVO> getRecommendations(Long userId, int limit, String category);
    
    /**
     * 更新用户行为（浏览/购买），触发推荐模型更新
     * @param userId 用户 ID
     * @param bookId 图书 ID
     * @param action "VIEW" 或 "PURCHASE"
     */
    void recordUserAction(Long userId, Long bookId, String action);
}
```

## 输入材料

### 参考代码（先读取，学习测试风格）
- 测试参考：`src/test/java/com/geekbooks/service/UserServiceTest.java`

### 需要覆盖的测试场景

**getRecommendations 方法**：
1. **正常场景**：有历史行为的用户，返回 limit 数量的推荐（按 score 降序）
2. **品类筛选**：传入 category="编程" 时，返回结果全部是该品类
3. **无历史数据**：用户无行为记录，降级返回热门图书
4. **用户不存在**：抛出 `UserNotFoundException`
5. **limit 边界**：limit=1 返回最高分图书；limit=20 返回最多 20 本

**recordUserAction 方法**：
6. **正常记录**：VIEW 和 PURCHASE 都能成功记录（验证 Repository 被调用）
7. **无效 action**：传入 "LIKE" 等无效值，抛出 `IllegalArgumentException`

## 输出要求

### 需要创建的文件
`src/test/java/com/geekbooks/service/RecommendationServiceTest.java`

### 测试规范（参考 UserServiceTest.java）
- 使用 JUnit 5 + Mockito（`@ExtendWith(MockitoExtension.class)`）
- 每个测试方法命名：`方法名_场景描述_预期结果`，例如 `getRecommendations_withHistory_returnsRankedList`
- Mock 对象：`RecommendationRepository`、`UserRepository`、`RedisTemplate`
- 使用 `@BeforeEach` 准备通用测试数据
- 断言使用 AssertJ（`assertThat`），不用 JUnit 原生 assert

## 约束条件

- ❌ 不修改任何现有文件
- ❌ 不实现 RecommendationService（只写测试，实现类留给后续任务）
- ✅ 测试类可以编译，但部分测试暂时 @Disabled（因为实现类还不存在）

## 工具使用指引

1. 用 `read_file` 读取 `UserServiceTest.java`，学习测试结构
2. 用 `create_file` 创建测试文件
3. 用以下命令验证编译：`mvn test-compile -q`（只编译测试，不运行）

## 验收标准

- [ ] `mvn test-compile -q` 测试代码编译通过
- [ ] 7 个场景都有对应的测试方法
- [ ] 每个测试方法有 Given/When/Then 注释（`// Given` / `// When` / `// Then`）
- [ ] 方法命名符合规范（`方法名_场景_预期`）
- [ ] 使用 AssertJ 的 `assertThat`，没有使用 `assertEquals`
````

---

### Step 3：Review 要点（测试类特殊检查）

```
✅ 测试类 Review Checklist

编译验证：
□ mvn test-compile -q 通过

测试完整性：
□ 7 个场景都有对应方法（逐一数）
□ 方法名包含三部分：方法_场景_预期

测试质量：
□ 每个测试只测一件事（没有一个方法测多个场景）
□ Given/When/Then 结构清晰
□ Mock 使用正确（verify 验证调用次数，not just 返回值）

⚠️ 常见问题：
□ AI 可能没写「无历史数据降级」场景（需要人工补充）
□ AI 可能用了 assertEquals 而不是 assertThat
□ 异常测试用的是 assertThrows 还是 try/catch（应该用前者）
```

---

### Step 4：效果跟踪

```
任务ID: T-003
传统工时: 3h
实际总计: 1.3h（Prompt 设计 0.3h + AI 0.2h + Review 0.5h + 补写1个场景 0.3h）
效率提升: (3 - 1.3) / 3 = 57%  ✅
Review 轮次: 1次（AI 遗漏了「降级」场景，人工补充）
备注: AI 没写降级场景，Prompt 改进：把降级场景单独列出来更显眼
```

**Prompt 改进记录**（每次 Review 后更新）：
> 改进前：「无历史数据」混在普通场景里，AI 未生成  
> 改进后：在场景列表中单独标注 `（⚠️ 重要：降级场景，必须包含）`

---

## 案例3：实现协同过滤推荐算法（🟡 人机协作）

> **学习重点**：如何控制🟡任务的迭代节奏，何时该坚持、何时该人工接管

### Step 1：4 维度评分

| 维度 | 分数 | 评分依据 |
|------|------|----------|
| **输入明确度（×30%）** | **3** | 有 User Story 和验收标准，但算法实现方式有多个可选方案 |
| **参考可用度（×25%）** | **1** | 无类似算法实现，全新开发 |
| **复杂度（×25%）** | **1** | 协同过滤涉及向量计算、相似度算法，属于算法复杂度 |
| **验证难度（×20%）** | **3** | 单元测试可部分验证，但推荐质量需人工判断 |
| **加权总分** | **3×30% + 1×25% + 1×25% + 3×20% = 1.95** | → **10分** → 🟡 |

> 💡 **评分解读**：总分是加权求和后 ×4 换算到 20 分制：10 分，处于🟡区间

**传统工时预估**：8h  
**AI 工时预估**：6h（协作模式效率提升有限）  
**预期效率提升**：25%

---

### Step 2：人机协作执行流程

#### 2.1 第 1 轮：AI 生成方案 + 初版代码

> **执行方**：开发者（发送 Prompt）+ AI（生成代码）  
> **预计时长**：AI 执行 5 分钟

**第 1 轮 Prompt**（让 AI 先给方案，再给代码）：

````markdown
## 任务背景

GeekBooks Sprint 3，实现推荐服务的核心算法：基于用户行为的协同过滤推荐。

## 接口定义

```java
// 需要实现的方法
List<RecommendationResultVO> getRecommendations(Long userId, int limit, String category);
```

## 业务约束

- 算法：User-based 协同过滤（用户相似度计算）
- 数据范围：最近 30 天的浏览和购买记录
- 性能要求：P95 < 1 秒（50万用户，热门用户最多 1000 条行为记录）
- 缓存：结果缓存 30 分钟（Redis）
- 降级：用户无数据时返回热门图书 Top N

## 可用数据

```sql
-- 用户行为表（已有）
user_behavior: user_id, book_id, action_type(VIEW/PURCHASE), created_at
-- 图书表（已有）
book: id, title, author, category, price, cover_url
-- 热门图书缓存（已有服务）
HotBookService.getHotBooks(limit, category): List<Book>
```

## 请求

1. **先输出方案对比**（不要直接给代码）：
   - 方案A：实时计算相似度（每次请求时计算）
   - 方案B：预计算相似度（定时任务更新，Redis 缓存）
   - 方案C：简化版（基于购买同一本书的用户推荐）
   - 每个方案的实现复杂度、性能、准确度对比

2. 根据「P95<1秒」和「实现复杂度」权衡，**推荐哪个方案，为什么**？

3. **输出推荐方案的完整实现代码**
````

---

#### 2.2 第 1 轮 Review（人工，20-30 分钟）

**Review 记录表**：

```
第 1 轮 Review 记录
===================
AI 推荐方案：方案C（简化版，基于共同购买者推荐）
AI 推荐理由：实现简单，P95 可以控制在 200ms 以内

✅ 接受的部分：
- 选择方案C是合理的（第一个Sprint先跑通，再优化）
- 降级逻辑（调用 HotBookService）代码完整
- Redis 缓存 key 设计合理：recommendation:{userId}

⚠️ 需要调整的部分：
- 相似度计算直接在 Java 代码里做了全表扫描，性能有问题
  期望：加一个「只查最近30天行为」的 WHERE 条件
- 结果没有按 score 降序排列
  期望：在 return 之前加 sort

❌ 不接受的部分：
- 代码中有 System.out.println 调试语句，应删除

决策确认：
- 选择方案C（同意）
- limit 默认值：实现里硬编码了 8，需改为从参数读取
```

---

#### 2.3 第 2 轮：AI 按反馈修改

**第 2 轮 Prompt**（基于 Review 反馈）：

````markdown
## 基于上次代码的修改需求

请修改 RecommendationServiceImpl.java，具体修改点：

1. **性能修复**：`queryUserBehaviors` 方法的 SQL 需加时间范围条件：
   WHERE created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)

2. **排序修复**：getRecommendations 方法 return 前加：
   recommendations.sort(Comparator.comparingDouble(RecommendationResultVO::getScore).reversed())

3. **删除调试代码**：删除所有 System.out.println 语句

4. **参数读取**：将硬编码的 `8` 改为使用传入的 `limit` 参数

请输出修改后的完整文件内容。
````

---

#### 2.4 第 2 轮 Review（人工，10-15 分钟）

```
第 2 轮 Review 记录
===================
✅ 4 个修改点全部正确
✅ 无新引入的问题

决策：通过，进入功能验证
```

**🎉 第 2 轮通过，未触发 3 轮上限**

---

#### 2.5 功能验证

```bash
# 1. 运行单元测试
mvn test -Dtest=RecommendationServiceTest -pl .

# 2. 启动服务，手动验证
curl -X GET "http://localhost:8080/api/recommendations?userId=1001&limit=6"

# 3. 性能简单测试（用 ab 或 JMeter）
ab -n 100 -c 10 http://localhost:8080/api/recommendations?userId=1001&limit=6
```

---

### Step 3：效果跟踪

```
任务ID: T-002（算法实现）
模式: 🟡
传统工时: 8h
Prompt 设计（含 Review 反馈整理）: 0.5h
AI 执行（2轮）: 0.2h
Review（2轮）: 1h
功能验证: 0.5h
修复（第1轮 Review 问题由 AI 修复，不计入人工）: 0h
实际总计: 2.2h
效率提升: (8 - 2.2) / 8 = 73%  ✅（超过了🟡的平均预期 30-40%）
Review 轮次: 2次
备注: AI 生成的算法框架质量较高，节省了大量思考时间
```

---

## 📊 本次演示汇总

### 效率数据汇总

| 任务 | 模式 | 传统工时 | AI总工时 | 效率提升 | Review轮次 |
|------|------|----------|----------|----------|------------|
| T-001 DTO/VO类 | 🟢 | 1.5h | 0.6h | **60%** | 1次 |
| T-003 单元测试 | 🟢 | 3.0h | 1.3h | **57%** | 1次（补1个场景） |
| T-002 推荐算法 | 🟡 | 8.0h | 2.2h | **73%** | 2次 |
| **合计** | | **12.5h** | **4.1h** | **67%** | |

> ⚠️ **注意**：这是第 2-3 个Sprint的数据（有参考模板可复用）。  
> 若是第 1 个Sprint，Prompt 设计时间会增加 3-5 倍，实际效率提升约 20-30%。

---

### 三个任务的 Prompt 质量对比

| 维度 | 案例1（DTO） | 案例2（测试） | 案例3（算法）|
|------|------------|------------|------------|
| Prompt 复杂度 | 低（字段定义清晰） | 中（需提供接口定义） | 高（需先要方案再要代码） |
| 关键成功因素 | 提供参考文件路径 | 列出所有测试场景 | 先要方案对比，再确认 |
| AI 遗漏的内容 | 无 | 降级测试场景 | 排序逻辑 |
| 改进 Prompt 的方向 | 已是精品模板 | 高亮重要场景 | 在方案确认后再要代码 |

---

### Prompt 模板库积累

> 本次演示后，可将以下内容加入模板库：

```
ai-prompts/templates/
├── ⭐⭐⭐⭐⭐-java-dto-vo-class.md         案例1 的 Prompt（首次通过率 100%）
├── ⭐⭐⭐⭐-java-service-unittest.md       案例2 改进后的 Prompt（加了⚠️标注）
└── ⭐⭐⭐⭐-algorithm-two-phase.md         案例3 的"先方案后代码"模式
```

---

## 🔁 整体流程总结（一页纸）

```
┌────────────────────────────────────────────────────────────────┐
│              AI 编程流程规划 · 完整执行路径                       │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  [Sprint Planning] → 获得任务列表                               │
│         │                                                      │
│         ▼                                                      │
│  [4维度评分] → 每个任务打分（5分钟/任务）                        │
│    输入明确度×30% + 参考×25% + 复杂度×25% + 验证×20%           │
│    18-20=🟢  12-17=🟡  6-11=🔴  调研=🟣                       │
│         │                                                      │
│         ▼                                                      │
│  [编写 Prompt] → 🟢任务必须在执行前1天完成                       │
│    6要素：背景+目标+参考文件+输出文件+约束+验收命令              │
│         │                                                      │
│   ┌─────┴──────┐                                              │
│   ▼            ▼                                              │
│  🟢 执行        🟡 执行                                        │
│  AI 执行        AI 生成初版                                    │
│  立即 Review    人工 Review（20-30min）                        │
│  填写跟踪表     若需调整→AI修改（最多3轮）                      │
│                 第3轮未通过→人工接管                           │
│   └─────┬──────┘                                              │
│         ▼                                                      │
│  [填写效果跟踪表] → 实时填，不要事后补                          │
│         │                                                      │
│         ▼                                                      │
│  [Sprint 回顾] → 哪些 Prompt 加入模板库？哪些分类要调整？        │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

---

## 🎯 学员实操练习题

> 完成以上案例学习后，用以下练习验证掌握程度：

### 练习1：独立评分（10分钟）

对以下任务独立完成 4 维度评分，给出分类结论：

**任务A**：为已有的 `OrderService.java` 新增「取消订单」方法
- 有 API 文档和取消规则（如仅可取消未支付订单）
- `OrderService` 已有「创建订单」「支付订单」方法可参考
- 业务逻辑：修改订单状态 + 还原库存 + 触发退款

> 参考答案：输入5 + 参考5 + 复杂度3 + 验证5 = 加权约 18分 → 🟢

**任务B**：设计并实现图书搜索的相关性排序算法（BM25 + 业务权重混合）
- 需求描述较模糊（"搜索结果要相关且实用"）
- 无类似算法实现
- 需要业务专家定义权重参数

> 参考答案：输入1 + 参考1 + 复杂度1 + 验证1 = 加权约 4分 → 🔴

---

### 练习2：改写 Prompt（20分钟）

下方是一个**写得很差的 Prompt**，找出所有问题并改写：

```
帮我写一个 Java 类：BookSearchService，
实现搜索图书功能，要求代码质量好，
风格参考项目现有代码，符合规范。
```

**问题清单（找出 ≥ 5 个）**：
1. 没有说明项目背景
2. 没有提供参考代码路径
3. 「代码质量好」是主观表达，不可验证
4. 没有列出方法签名和参数
5. 没有说明输出文件路径
6. 没有验收标准（如何验证完成？）
7. 没有约束条件（可以修改哪些文件？）

> 练习：用本文档的模板，把这个 Prompt 改写为可执行版本。

---

### 练习3：模拟 Review（15分钟）

下方是 AI 生成的 Java 代码片段，找出所有 Review 问题：

```java
@Service
public class RecommendationServiceImpl implements RecommendationService {
    
    @Autowired
    private UserBehaviorRepository behaviorRepo;
    
    public List<RecommendationResultVO> getRecommendations(Long userId, int limit, String category) {
        System.out.println("Getting recommendations for user: " + userId);  // ①
        
        List<UserBehavior> behaviors = behaviorRepo.findByUserId(userId);   // ②
        
        if (behaviors.isEmpty()) {
            return new ArrayList<>();  // ③
        }
        
        List<Long> bookIds = behaviors.stream()
            .map(b -> b.getBookId())
            .collect(Collectors.toList());
            
        // TODO: 实现相似度计算  // ④
        
        return bookIds.stream()
            .limit(limit)
            .map(id -> buildVO(id))
            .collect(Collectors.toList());  // ⑤
    }
}
```

**Review 问题（至少找出 5 个）**：

| # | 问题 | 严重程度 | 修改建议 |
|---|------|----------|----------|
| ① | `System.out.println` 调试语句 | 中 | 删除，用 `log.debug()` |
| ② | 没有时间范围过滤，全量查询 | 高 | 加 `WHERE created_at >= 30天前` |
| ③ | 空结果直接返回，未降级 | 高 | 调用 `HotBookService.getHotBooks()` |
| ④ | TODO 未实现就提交 | 高 | 补充实现或改为 `@Disabled` 测试 |
| ⑤ | 结果没有排序 | 中 | 按 score 降序排列后再 limit |
| + | `@Autowired` 字段注入 | 低 | 改为构造器注入（符合 Spring 最佳实践） |
