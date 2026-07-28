# 동훈 패닉 (Donghun Panic)

PS1 / Baldi's Basics 스타일 1인칭 학교 코미디·서바이벌 게임.

국어 발표 시간, Google Drive 자료가 로그인 문제로 열리지 않으면서 패닉에 빠진 **동훈**이 학교 곳곳을 돌며 발표 자료를 구하는 이야기.

## 요구 사항

- [Godot 4.3+](https://godotengine.org/download) (Forward+ 렌더러)

## 실행 방법

1. Godot 4.3+ 설치
2. Godot에서 **Import** → `project.godot` 선택
3. **F5** 또는 **Play** 버튼으로 실행

```powershell
# Godot CLI (PATH 등록 시)
godot --path c:\Users\GRAM\dhp\donghunpanic
```

## 조작

| 키 | 동작 |
|----|------|
| WASD | 이동 |
| 마우스 | 시점 |
| E | 상호작용 / 대화 진행 |
| Shift | 달리기 (패닉 상승) |
| Esc | 일시정지 |

## 게임 흐름

1. **패닉 인트로** — 제공된 학생 사진 + 화면 흔들림
2. **Prologue** — 2층 2-A 교실, 국어 발표 / 패닉 상태의 동훈 NPC
3. 노트북 Google Drive → 로그인 실패 → 패닉 상승
4. **5층 학교** 탐험:
   - **1층** — 급식실(USB), 현관(어두움)
   - **2층** — 2-A 교실, 복도
   - **3층** — 컴퓨터실, 도서관
   - **4층** — 교무실, **어두운 복도**(불 꺼짐)
   - **5층** — **폐창고**(불 꺼짐), 옥상(도주)
5. 어두운 구역에서는 **손전등** 자동 점등
6. 자료 확보 후 2층 교실 복귀 → 발표 → 엔딩

## 엔딩 (5종+)

| ID | 조건 |
|----|------|
| 완벽 발표 | USB/PPT 등으로 자료 확보 후 발표 |
| 즉흥 발표 | 인쇄본만 있거나 패닉 60%+ |
| 패닉 멜tdown | 패닉 100% |
| 학교 탈출 | 운동장에서 도망 |
| 히든 | 소지품 3개 이상 후 발표 |

## Windows 빌드

1. Godot → **Project → Export**
2. **Windows Desktop** 프리셋 선택
3. Export Path: `build/donghunpanic.exe`
4. **Export Project**

## 프로젝트 구조

```
donghunpanic/
├── project.godot          # 프로젝트 설정 + Autoload
├── scenes/                # 씬 (메뉴, 게임, UI, NPC)
├── scripts/               # GDScript (플레이어, AI, 시스템)
├── shaders/               # PS1 스냅 + CRT 오버레이
├── data/                  # 대화, 아이템, 엔딩 JSON
└── assets/                # 캐릭터, 폰트
```

## Steam 출시 (추후)

Steamworks / GodotSteam 플러그인 연동은 별도 작업. 현재는 Windows/Linux export 프리셋만 포함.

## 라이선스

게임 코드: MIT (자유 사용).  
Noto Sans KR: [SIL Open Font License 1.1](https://scripts.sil.org/OFL)
