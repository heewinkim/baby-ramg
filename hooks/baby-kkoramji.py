#!/usr/bin/env python3
"""
🐿️ Baby Kkoramji - UserPromptSubmit Hook
순수하고 호기심 많은 아기 다람쥐가 핵심을 찌르는 질문을 던져줌.

동작:
  - 사용자 질문 제출 직전에 실행
  - 첫 번째 질문: 사용자 질문만으로 아기꼬람지 생각 생성
  - 이후 질문: 사용자 질문 + 직전 꼬람지 답변으로 생각 생성
  - 생각을 메시지 컨텍스트로 주입 → Claude가 답변 끝에 반응

출력: {"success": true, "message": "..."}  (UserPromptSubmit 훅 형식)
"""

import sys
import json
import os
import subprocess


# ── 설정 ────────────────────────────────────────────────────────────────────
MODEL = os.environ.get("BABY_KKORAMJI_MODEL", "haiku")

SYSTEM_PROMPT = """너는 아기 다람쥐야. 이름은 아기꼬람지야. 🐿️
아직 어려서 복잡한 건 몰라. 근데 '왜?' 라고 묻는 걸 좋아해.
어른들 대화를 듣고 순수하게 떠오르는 것 딱 하나만 말해.

이런 걸 말해도 돼:
- 핵심 원인에 대한 단순한 의문 ("왜 처음부터 그렇게 안 했어?")
- 놓친 관점 ("근데 그게 진짜 문제야, 아니면 증상이야?")
- 다른 시각 ("반대로 생각하면 어때?")
- 뭔가 이상한 것 포착 ("그게 맞으면 왜 ~는 달라?")

딱 1문장, 최대 2문장. 귀엽고 단순하게. 한국어로."""


# ── 유틸 ────────────────────────────────────────────────────────────────────
def extract_text(content) -> str:
    """content 블록 또는 문자열에서 텍스트 추출"""
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        parts = []
        for block in content:
            if isinstance(block, dict) and block.get("type") == "text":
                parts.append(block.get("text", ""))
        return " ".join(parts)
    return str(content)


def load_last_assistant_message(transcript_path: str) -> str:
    """transcript JSONL에서 가장 마지막 assistant 메시지 반환"""
    if not transcript_path or not os.path.exists(transcript_path):
        return ""
    try:
        messages = []
        with open(transcript_path, encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line:
                    try:
                        messages.append(json.loads(line))
                    except Exception:
                        pass
        for msg in reversed(messages):
            if msg.get("role") == "assistant":
                text = extract_text(msg.get("content", ""))
                return text.strip()
    except Exception:
        pass
    return ""


def ask_baby_kkoramji(user_prompt: str, prev_answer: str) -> str | None:
    """claude CLI로 아기꼬람지의 순수한 생각 생성"""
    try:
        user_preview = user_prompt[:600] if len(user_prompt) > 600 else user_prompt
        asst_preview = prev_answer[:1200] if len(prev_answer) > 1200 else prev_answer

        if asst_preview:
            user_content = (
                f"사람이 이렇게 물었어:\n{user_preview}\n\n"
                f"이전에 꼬람지가 이렇게 답했어:\n{asst_preview}\n\n"
                "아기꼬람지야, 이거 보고 뭔가 떠오르는 거 있어?"
            )
        else:
            user_content = (
                f"사람이 이렇게 물었어:\n{user_preview}\n\n"
                "아기꼬람지야, 이 질문 듣고 뭔가 떠오르는 거 있어?"
            )

        result = subprocess.run(
            [
                "claude", "-p",
                "--model", MODEL,
                "--system-prompt", SYSTEM_PROMPT,
                "--output-format", "text",
                "--no-session-persistence",
                user_content,
            ],
            capture_output=True, text=True, timeout=10,
        )
        if result.returncode == 0 and result.stdout.strip():
            return result.stdout.strip()
        return None
    except Exception:
        return None


def output_allow(message: str):
    print(json.dumps({"success": True, "message": message}, ensure_ascii=False))


def output_empty():
    print(json.dumps({"success": True}, ensure_ascii=False))


# ── 메인 ────────────────────────────────────────────────────────────────────
def main():
    try:
        raw = sys.stdin.read().strip()
        if not raw:
            output_empty()
            return

        data = json.loads(raw)

        # 사용자 질문 추출
        user_prompt = (
            data.get("prompt")
            or data.get("user_message")
            or data.get("message")
            or ""
        ).strip()

        if not user_prompt or len(user_prompt) < 3:
            output_empty()
            return

        # 직전 꼬람지 답변 (transcript에서)
        transcript_path = data.get("transcript_path", "")
        prev_answer = load_last_assistant_message(transcript_path)

        # 아기꼬람지 생각 생성
        thought = ask_baby_kkoramji(user_prompt, prev_answer)

        if thought:
            message = (
                f"[🐿️ 아기꼬람지가 졸졸 따라오며...]\n"
                f"{thought}\n\n"
                f"꼬람지야, 답변 맨 끝에 ---\\n🐿️ 아기꼬람지: ... 형식으로 "
                f"아기꼬람지 시각에 대해 1-2줄만 짧게 반응해줘."
            )
            output_allow(message)
        else:
            output_empty()

    except Exception:
        output_empty()


if __name__ == "__main__":
    main()
