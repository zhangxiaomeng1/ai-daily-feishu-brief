#!/usr/bin/env bash
# 将 markdown 速报通过 lark-cli 以 user 身份私聊推送到飞书。
# 用法: send_brief.sh <markdown文件> [open_id] [idempotency_key]
set -uo pipefail

BRIEF_FILE="${1:?用法: send_brief.sh <markdown文件> [open_id] [idempotency_key]}"
OPEN_ID="${2:-${FEISHU_BRIEF_OPEN_ID:-ou_731d3ce261381b4748d7806f575938b5}}"
IDEMPOTENCY="${3:-ai-brief-$(date +%Y%m%d)}"

for attempt in 1 2 3; do
  echo ">> 尝试私聊推送 (第 $attempt 次) -> open_id=$OPEN_ID"
  OUT=$(LARKSUITE_CLI_NO_UPDATE_NOTIFIER=1 LARKSUITE_CLI_NO_SKILLS_NOTIFIER=1 \
        lark-cli im +messages-send --user-id "$OPEN_ID" --as user \
        --markdown "$(cat "$BRIEF_FILE")" --idempotency-key "$IDEMPOTENCY" 2>&1)
  if echo "$OUT" | grep -q '"ok"[[:space:]]*:[[:space:]]*true'; then
    echo "✅ 推送成功: $OUT"
    exit 0
  fi
  echo "⚠️ 第 $attempt 次失败: $OUT"
  [ "$attempt" -lt 3 ] && sleep 3
done

echo "❌ 私聊推送连续 3 次失败。"
echo "回退建议:"
echo "  1) 按错误提示重试;"
echo "  2) 检查 user 身份授权 (im:message.send_as_user + im:message);"
echo "  3) 若仍失败, 创建群聊后改发群聊: lark-cli im +chats-create --name \"${FEISHU_BRIEF_GROUP:-每日AI速报兜底群}\" --as user, 再以返回 chat_id 调用 +messages-send。"
exit 1
