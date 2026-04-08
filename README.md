# 🐿️ Baby Kkoramji (아기꼬람지)

> A pure-minded squirrel agent that asks the questions you forgot to ask.

아기꼬람지는 Claude Code의 **UserPromptSubmit 훅**으로 동작하는 소형 에이전트야.  
네가 질문하기 직전, 빠른 모델(Haiku)이 순수하고 단순한 시각으로 핵심 질문 하나를 던져줘.  
Claude(꼬람지)는 그 시각을 받아 답변 끝에 짧게 반응해 — 놓친 원인이나 새로운 인사이트를 담아서.

---

## 왜 만들었어?

AI와 대화할 때 우리는 자꾸 "어떻게" 에만 집중해.  
아기꼬람지는 "왜?" 를 물어봐. 복잡한 생각 없이, 있는 그대로.

그 단순한 질문이 때로는 문제의 근원을 드러내고,  
때로는 완전히 다른 시각을 열어줘.

---

## 동작 방식

```
사용자 질문 submit
    ↓ [UserPromptSubmit 훅]
아기꼬람지 (Haiku 모델)가 생각 생성
    → 첫 질문: 사용자 질문만으로
    → 이후: 사용자 질문 + 직전 Claude 답변으로
    ↓ 컨텍스트 주입
Claude가 [아기꼬람지 생각 + 사용자 질문] 함께 받음
Claude 답변 + 끝에 아기꼬람지 반응 (--- 구분선)
```

**예시 대화:**

```
나: 서버가 자꾸 느려지는데 어떻게 최적화해?

🐿️ 아기꼬람지: 근데 느려지는 게 항상이야, 아니면 특정 시간에만이야?

꼬람지 답변:
  [최적화 방법 설명...]

  ---
  🐿️ 아기꼬람지: 맞아, 항상인지 특정 시간인지에 따라 원인이 완전 달라져.
  패턴 파악이 먼저라는거야!
```

---

## 특징

- **순수한 시각** — 복잡한 논리 없이 본질만 찌름
- **빠름** — Haiku 모델로 동작 (~1초 딜레이)
- **비침습적** — 훅이 실패해도 원래 답변에 영향 없음
- **재사용 가능** — 어떤 Claude Code 환경에도 설치 가능
- **설정 안전** — 기존 settings.json 초기화 없이 훅만 추가

---

## 설치

### 요구사항
- Claude Code (2.x 이상)
- Python 3.x
- `anthropic` 패키지: `pip install anthropic`
- `ANTHROPIC_API_KEY` 환경변수

### 설치 방법

```bash
git clone https://github.com/heewinkim/baby-ramg.git
cd baby-ramg
chmod +x setup.sh
./setup.sh
```

설치하면:
- `~/.claude/hooks/baby-kkoramji.py` 복사
- `~/.claude/rules/baby-kkoramji.md` 복사 (Claude에게 반응 방식 안내)
- `~/.claude/settings.json`에 `UserPromptSubmit` 훅 등록 (기존 설정 유지)

### 제거

```bash
rm ~/.claude/hooks/baby-kkoramji.py
rm ~/.claude/rules/baby-kkoramji.md
```

`~/.claude/settings.json`에서 `UserPromptSubmit` 항목 중 `baby-kkoramji.py` 관련 항목을 수동으로 제거.

---

## 설정

환경변수로 동작을 조정할 수 있어:

| 변수 | 기본값 | 설명 |
|------|--------|------|
| `BABY_KKORAMJI_MODEL` | `claude-haiku-4-5-20251001` | 사용할 모델 |
| `BABY_KKORAMJI_MAX_TOKENS` | `120` | 최대 토큰 수 |

---

## 파일 구조

```
baby-ramg/
├── hooks/
│   └── baby-kkoramji.py   # UserPromptSubmit 훅 스크립트
├── claude-rule.md          # Claude 반응 방식 규칙 (설치 시 ~/.claude/rules/ 로 복사)
├── setup.sh                # 설치 스크립트
└── README.md
```

---

## 라이선스

MIT
