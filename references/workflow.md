# 每日 AI 热点速报 — 工作流细节

本文件供 skill 执行时按需参考，包含搜索模板、核验源清单、markdown 模板与自动化记忆格式。

## 一、搜索查询模板（并行 2 组，freshness=d2）

组 A（模型 / 发布 / 产品）：
- `AI 大模型 发布 2026年8月20日`
- `OpenAI Anthropic 智谱 阿里 大模型 最新 今天`

组 B（开源 / 融资 / 监管 / 安全）：
- `AI 人工智能 热门新闻 今天 2026年8月`
- `AI 融资 并购 监管 开源 模型 本周`

> 中文优先；当日聚合站（腾讯新闻 AI 早报、AIbase、CSDN AI 热点日报）信息密度最高，一次可捞十几条候选。

## 二、核验一手源清单（对最重磅 1–3 条追加验证）

- 厂商官方：z.ai / openai.com blog / anthropic.com / qwenlm.github.io
- 行情 / 资本：上交所 / 深交所行情、证券时报、澎湃新闻、Bloomberg、Reuters
- 监管 / 安全：法新社、央视新闻、每日经济新闻、Hugging Face 官方报告、insideai.news
- 交叉验证原则：聚合站的 benchmark 数字多为厂商自测，不可直接当事实；至少找 1 个一手 / 权威源支撑后再写入。

## 三、markdown 模板

```markdown
# 每日 AI 热点速报（YYYY-MM-DD）

以下为今日最热门的 5 条 AI 消息，覆盖模型 / 产品 / 商业 / 开源 / 监管五个维度。

---

### 1. <标题>
- 来源与日期：[已知] <来源, 来源, 2026-MM-DD>
- 核心要点：[已知] ... [已知] ...
- 为何热门：[已知] ... [推断] ...

### 2. <标题>
...

### 5. <标题>
...

---

**一句话简讯**
- [已知] <简讯1>
- [已知] <简讯2>

---

置信度：高。5 条主报均有<一手/权威源>交叉支撑；<某数字>为厂商自测/非一手聚合，已单独降级标注。
```

## 四、自动化记忆格式（追加到 .workbuddy/automations/<id>/memory.md）

```markdown
### YYYY-MM-DD
- 状态：成功。message_id `om_xxx`, HH:MM:SS 送达，无重试 / 无建群回退。
- 选题维度：监管安全(...) / 模型(...) / 产品(...) / 商业(...) / 开源(...)
- 整体置信度定为「高」：<支撑来源>。执行路径：WebSearch 并行 2 组 → 追加一手源验证 → 写本地 md → lark-cli 以 user 身份发送。
```

## 五、已验证命令（可直接复用）

```bash
# 私聊推送（user 身份）
LARKSUITE_CLI_NO_UPDATE_NOTIFIER=1 LARKSUITE_CLI_NO_SKILLS_NOTIFIER=1 \
lark-cli im +messages-send --user-id ou_731d3ce261381b4748d7806f575938b5 \
  --as user --markdown "$(cat ai_speedbrief_YYYY-MM-DD-workbuddy.md)" \
  --idempotency-key ai-brief-YYYYMMDD
```

> user token 有效期约 2 小时、refresh 有效期 7 天，会自动刷新；`status: needs_refresh` 不是错误，不必处理。
