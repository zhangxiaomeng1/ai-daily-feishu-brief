# ai-daily-feishu-brief

Reusable Agent Skill：每日 AI 热点速报搜索、核验并推送至飞书 IM（user 身份私聊）。
兼容 **WorkBuddy** 与 **Codex** 等支持 SKILL.md 的 Agent。

## 它能做什么
- 用 WebSearch 抓取当日最热门的 5 条 AI 消息（覆盖模型 / 产品 / 商业 / 开源 / 监管 5 个维度）
- 对重磅消息做一手源交叉验证
- 按用户全局规范标注 `[已知]` 与文末「置信度」
- 落盘 `ai_speedbrief_YYYY-MM-DD-workbuddy.md`
- 通过 `lark-cli` 以 user 身份推送到飞书私聊，内置 3 次重试与群聊回退

## 安装
### WorkBuddy
```bash
git clone https://github.com/zhangxiaomeng1/ai-daily-feishu-brief.git \
  ~/.workbuddy/skills/ai-daily-feishu-brief
```
（或直接把本仓库内容放进 `~/.workbuddy/skills/ai-daily-feishu-brief/`）

### Codex
```bash
git clone https://github.com/zhangxiaomeng1/ai-daily-feishu-brief.git \
  ~/.codex/skills/ai-daily-feishu-brief
```

## 前置条件
- 飞书 IM 连接器（lark-cli）已连接，且 user 身份已授权 `im:message` 与 `im:message.send_as_user`
- Agent 环境可用 `WebSearch` 工具

## 配置
- 接收人 open_id：默认 `ou_731d3ce261381b4748d7806f575938b5`（用户本人）。
  更换时设置环境变量 `FEISHU_BRIEF_OPEN_ID` 或给脚本传参。
- 回退群聊名：默认 `每日AI速报兜底群`，可用 `FEISHU_BRIEF_GROUP` 覆盖。

## 手动运行
```bash
# 1. 按 SKILL.md 流程生成 ai_speedbrief_YYYY-MM-DD-workbuddy.md
# 2. 推送
bash ~/.workbuddy/skills/ai-daily-feishu-brief/scripts/send_brief.sh \
  ai_speedbrief_YYYY-MM-DD-workbuddy.md
```

## 作为每日定时任务（每日复盘 / 日报）
在 Agent 中创建一个每日触发的自动化，prompt 只需写：
> 调用 ai-daily-feishu-brief skill，执行每日 AI 热点速报推送飞书（每日复盘）。

幂等键按日期生成，重复触发不会发重。
