


# TaskFit Flutter

### " 진짜 실무 경험을 제공해 드립니다. "

**TaskFit**은 취업 준비생들이 실제 기업의 직무 환경을 미리 경험하고 성장을 도모할 수 있도록 돕는 **기업 맞춤형 실무 과제 체험 플랫폼**입니다. 

사용자가 목표로 하는 기업과 직무 공고 데이터를 기반으로 AI가 맞춤형 과제를 생성하며, 제출 후에는 AI 상사 페르소나와의 질의응답을 통해 실전과 같은 압박 면접 및 요구사항 협의 상황을 시뮬레이션합니다. 모든 과정은 데이터 기반의 역량 분석을 통해 구체적인 피드백으로 제공됩니다.

---

## 🚀 주요 기능 (UI/UX Highlights)

### 1. 지능형 3단계 목표 설정 (3-Step Smart Goal Setting)
* **사용자 인지 부하 최소화**: 카테고리 → 세부 직무 → 기업명으로 이어지는 계층적 자동완성 UI를 통해 방대한 실무 데이터 중 본인에게 필요한 과제를 단 몇 초 만에 설정할 수 있습니다.
* **동적 문장 미리보기**: 선택에 따라 "나는 [개발]의 [백엔드]를 경험하고 싶습니다"와 같이 목표가 시각화되어 사용자에게 명확한 동기를 부여합니다.

### 2. AI 페르소나 기반 몰입형 채팅 (Immersive Boss-Persona Chat)
* **실제 상사와의 대화 시뮬레이션**: 과제 제출 후, "AI 팀장" 페르소나가 등장하여 결과물에 대한 날카로운 질문을 던집니다.
* **실시간 인터랙션**: 단순 결과 확인이 아닌, 대화형 UX를 통해 실제 업무 현장의 긴장감을 재현하고 논리적 사고력을 기를 수 있도록 돕습니다.

### 3. 데이터 시각화 역량 분석 대시보드 (Competency Analysis Dashboard)
* **성장 지표의 시각화**: 과제 점수, 풀이 시간, 약점 태그 등을 그래프와 차트로 제공하여 사용자가 본인의 강점과 보완점을 한눈에 파악할 수 있게 합니다.
* **AI 인사이트**: 최근 풀이 기록을 분석하여 "지난주 대비 정답률 상승" 등 구체적인 학습 동기부여 메시지를 전달합니다.

---

## 🛠 기술 스택

### Mobile (Frontend)
| 분류 | 기술 |
|------|------|
| **Framework** | Flutter 3.x |
| **State Management** | Provider, Riverpod |
| **Network** | Retrofit & Dio (REST API Communication) |
| **Architecture** | Clean Architecture (Data / Domain / Presentation) |
| **Auth** | Google OAuth 2.0 (Firebase Auth) |

### Backend & Infra
| 분류 | 기술 |
|------|------|
| **Runtime** | Python 3.12, FastAPI |
| **Package Manager** | uv |
| **DB** | Cloud SQL (PostgreSQL) + SQLAlchemy 2.0 + asyncpg |
| **AI Engine** | Google Gemini API (google-genai SDK) |
| **Infra** | Google Cloud Run, Secret Manager |

---

## 📂 프로젝트 구조 (Clean Architecture)

```text
lib/
├── data/           # API 호출 및 데이터 모델 (Retrofit, JSON Serializable)
├── domain/         # 비즈니스 로직 및 엔티티 (Repository Interface)
├── presentation/    # UI 위젯 및 상태 관리 (Provider/ViewModel)
│   ├── screens/    # 각 기능별 화면 (Home, Chat, Dashboard 등)
│   └── widgets/    # 재사용 가능한 UI 컴포넌트
└── core/           # 공통 유틸리티 및 테마 설정

```

---

## ⚙️ 시작하기 (Installation)

1. **저장소 복제**
```bash
git clone [https://github.com/your-repo/taskfit-flutter.git](https://github.com/your-repo/taskfit-flutter.git)

```


2. **패키지 설치**
```bash
flutter pub get

```


3. **코드 생성 (API & Model)**
```bash
dart run build_runner build --delete-conflicting-outputs

```


4. **앱 실행**
```bash
flutter run

```



---

## 🔮 TODO (Future Plans)

* **Kotlin Multiplatform (KMP) 도입**: 비즈니스 로직의 플랫폼 공용화를 통해 네이티브 성능 최적화 및 코드 유지보수 효율성 증대.
* **자격증 데이터 기반 문항 고도화**: SQLD 등 IT 자격증 핵심 개념을 실무 과제 시나리오와 연동하여 자격증 취득과 실무 준비를 동시에 지원.
* **오답 노트 및 PDF 리포트 생성**: 분석된 역량 피드백을 PDF 형태의 포트폴리오 리포트로 변환하여 실제 취업 자료로 활용할 수 있는 기능 추가.

---


