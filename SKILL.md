---
name: ai-daily-feishu-brief
description: This skill should be used when producing and delivering a daily AI news briefing — researching the latest hot AI developments via web search (covering model/product/business/open-source/regulation), verifying against primary sources, and pushing the result to a Feishu (Lark) IM user as a markdown message via lark-cli. Trigger phrases include "每日AI速报", "AI日报推飞书", "daily AI brief to Feishu", "AI热点速报". Designed to run as a scheduled daily task (每日复盘/日报).
agent_created: true
---

# AI 每日热点速报 → 飞书

将"搜索今日最热 AI 消息 → 核验 → 落盘 markdown → 推送到飞书私聊"封装为可复用流程。适用于每日定时触发的 AI 资讯速报（每日复盘 / 日报场景），任何 Agent（WorkBuddy / Codex 等）安装本 skill 后均可直接调用。

## 前置条件
- 已连接飞书 IM 连接器（lark-cli），且 user 身份已授权 `im:message` 与 `im:message.send_as_user`。（`status: needs_refresh` 不是错误，token 会自动刷新。）
- 环境可用 `WebSearch` 工具。
- 目标接收人 open_id：默认 `ou_731d3ce261381b4748d7806f575938b5`（用户本人）。更换接收人时设置环境变量 `FEISHU_BRIEF_OPEN_ID`，或直接给发送脚本传参。

## 执行流程
1. **搜索**：并行发起 2 组 `WebSearch`（`freshness=d2`），一组偏"模型 / 发布 / 产品"，一组偏"开源 / 融资 / 监管 / 安全"。优先中文聚合源（腾讯新闻 AI 早报、网易、智东西、IT之家、上海证券报、证券时报、央视 / 每日经济新闻等），一次能捞到十几条候选。
2. **选题**：筛出当日最热门的 5 条，必须覆盖 5 个维度各至少一条：模型 / 产品 / 商业 / 开源 / 监管（安全事件归入监管）。
3. **核验**：对最重磅的 1–3 条追加一轮 `WebSearch` 找一手源交叉验证（厂商官方博客、交易所行情、SEC / 财报、路透 / 法新 / 彭博、Hugging Face 报告等）。厂商自测 benchmark 数字不可直接当事实，需在文中标注来源边界。
4. **落盘**：写入本地 markdown，命名 `ai_speedbrief_YYYY-MM-DD-workbuddy.md`（遵循 `-workbuddy` 后缀约定，便于区分 AI 产出）。格式模板见 `references/workflow.md`。
5. **发送**：调用 `scripts/send_brief.sh <file.md>` 推送（已验证命令见下）。
   ```
   LARKSUITE_CLI_NO_UPDATE_NOTIFIER=1 LARKSUITE_CLI_NO_SKILLS_NOTIFIER=1 \
   lark-cli im +messages-send --user-id <open_id> --as user \
     --markdown "$(cat <file>.md)" --idempotency-key ai-brief-YYYYMMDD
   ```
   - 幂等键按日期生成（`ai-brief-YYYYMMDD`），防止同日重复触发发出两条。
   - `--markdown` 不支持设置 post 标题，标题只能作为正文首行 H1（如 `# 每日 AI 热点速报（2026-08-20）`）。
   - **不要用 `$'...'` 手拼长文本**：中文 + 特殊符号极易被 shell 破坏，务必用 `$(cat 文件)` 读文件。
6. **失败回退**：`send_brief.sh` 内置 3 次重试；仍失败则按错误提示处理——检查 user 身份授权，或创建群聊（`lark-cli im +chats-create`）后改发群聊（群名默认 `每日AI速报兜底群`，可用 `FEISHU_BRIEF_GROUP` 覆盖）。
7. **记忆**：若作为定时任务运行，将高层执行摘要（状态 / 选题维度 / 置信度 / message_id）追加到 `.workbuddy/automations/<automation-id>/memory.md`，不要写全文。

## 写作规范（用户全局约定）
- 每条事实陈述用 `[已知]` 标注；逻辑推导用 `[推断]`。
- 文末标注 `置信度：高/中/低`，并说明哪些数字来自厂商自测 / 非一手聚合（已单独降级）。
- 标题用 H1，每条结构为：【标题、来源与日期、核心要点、为何热门】。
- 可附 3–4 条"一句话简讯"补充当日其他热点。

## 参数
- `FEISHU_BRIEF_OPEN_ID`：接收人 open_id（默认用户本人）。
- `FEISHU_BRIEF_GROUP`：回退群聊名称。
