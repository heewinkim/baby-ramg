#!/usr/bin/env python3
"""
🐿️ Baby Kkoramji - UserPromptSubmit Hook
프롬프트 주입만 담당. 실제 생각 생성은 Claude가 서브에이전트로 처리.

동작:
  - 사용자 질문 제출 직전에 실행
  - 사용자 질문을 컨텍스트 메시지로 주입
  - Claude가 Agent tool(haiku)로 아기꼬람지 생각을 독립 생성
  - 답변 끝에 아기꼬람지 반응 추가

출력: {"success": true, "message": "..."}  (UserPromptSubmit 훅 형식)
"""

import sys
import json


def main():
    try:
        raw = sys.stdin.read().strip()
        if not raw:
            print(json.dumps({"success": True}))
            return

        data = json.loads(raw)

        user_prompt = (
            data.get("prompt")
            or data.get("user_message")
            or data.get("message")
            or ""
        ).strip()

        if not user_prompt or len(user_prompt) < 3:
            print(json.dumps({"success": True}))
            return

        user_preview = user_prompt[:600]

        message = (
            f"[🐿️ 아기꼬람지 훅 활성화]\n"
            f"사용자 질문: {user_preview}\n\n"
            f"claude-rule에 따라 아기꼬람지 서브에이전트를 실행하고 답변 끝에 반응해줘."
        )
        print(json.dumps({"success": True, "message": message}, ensure_ascii=False))

    except Exception:
        print(json.dumps({"success": True}))


if __name__ == "__main__":
    main()
