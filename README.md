# 🐿️ Baby Kkoramji (아기꼬람지)

> A pure-minded squirrel agent that asks the questions you forgot to ask.

아기꼬람지는 Claude Code의 **UserPromptSubmit 훅**으로 동작하는 소형 에이전트야.  
네가 질문하기 직전, Claude가 haiku 서브에이전트를 실행해서 순수하고 단순한 시각으로 핵심 질문 하나를 던져줘.  
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
훅이 프롬프트 주입 (API 호출 없음, 초경량)
    ↓ 컨텍스트 주입
Claude가 Agent tool로 haiku 서브에이전트 실행
    → 독립 컨텍스트에서 아기꼬람지 생각 생성
    ↓
Claude 답변 + 끝에 아기꼬람지 반응 (--- 구분선)
```

**예시 대화:**

```
나: 서버가 자꾸 느려지는데 어떻게 최적화해?

꼬람지 답변:
  [최적화 방법 설명...]

  ---
  🐿️ 아기꼬람지: 근데 느려지는 게 항상이야, 아니면 특정 시간에만이야?
```

---

## 특징

- **독립적 시각** — haiku 서브에이전트가 별도 컨텍스트에서 생각 생성
- **초경량 훅** — API 호출/외부 의존성 없음, 프롬프트 주입만
- **API 키 불필요** — Claude Code 세션 내 서브에이전트 사용
- **비침습적** — 실패해도 원래 답변에 영향 없음
- **재사용 가능** — 어떤 Claude Code 환경에도 설치 가능

---

## 설치

### 요구사항
- Claude Code (2.x 이상)
- Python 3.x

### 설치 방법

```bash
git clone https://github.com/heewinkim/baby-ramg.git
cd baby-ramg
chmod +x setup.sh
./setup.sh
```

설치 시 **전역/로컬** 중 선택:

| 모드 | 대상 경로 | 적용 범위 |
|------|----------|----------|
| 전역 (`1`) | `~/.claude/` | 모든 프로젝트 |
| 로컬 (`2`) | `../.claude/` (상위 프로젝트) | 해당 프로젝트만 |

**로컬 설치**는 프로젝트 안에서 이 레포를 clone한 뒤 실행하면 상위 프로젝트 디렉토리의 `.claude/`에 설치돼:

```
my-project/          ← 여기에 설치됨 (.claude/)
├── .claude/
│   ├── hooks/baby-kkoramji.py
│   ├── rules/baby-kkoramji.md
│   └── settings.json
├── baby-ramg/       ← 여기서 setup.sh 실행
│   └── ...
└── src/
```

### 제거

```bash
cd baby-ramg
./uninstall.sh
```

전역/로컬 모두 자동으로 정리됨.

---

## 파일 구조

```
baby-ramg/
├── hooks/
│   └── baby-kkoramji.py   # UserPromptSubmit 훅 (프롬프트 주입만)
├── claude-rule.md          # Claude 서브에이전트 실행 규칙
├── setup.sh                # 설치 스크립트
├── uninstall.sh            # 제거 스크립트
├── legacy_uninstall.sh     # v1 (API 키 방식) 제거용
└── README.md
```

---

## 라이선스

MIT
