# CFD Multi-Agent Pipeline

MATLAB + Python 기반 자동 CFD 데이터 분석 및 Elsevier 형식 논문 생성 파이프라인

---

## 파이프라인 구조

```
data/cfd_results.xlsx
    │
    ▼ Agent A (MATLAB)  agent_a_analysis.m
    data/cfd_results_summary.json
    │
    ▼ Agent B (MATLAB)  agent_b_visualization.m
    figures/graph_01~06.png  (6개 개별 그래프)
    │
    ▼ Agent C (Python)  agent_c_paper_writer.py
    reports/CFD_Paper_Final.docx  (Elsevier Word 논문)
```

---

## 필수 소프트웨어

| 소프트웨어 | 최소 버전 | 비고 |
|-----------|----------|------|
| MATLAB    | R2020a   | `exportgraphics` 함수 필요 |
| Python    | 3.8      | PATH 등록 필수 |

### Python 패키지
```
python-docx >= 0.8.11
lxml        >= 4.9.0
```

---

## 최초 설치 (1회)

### Windows (권장)
프로젝트 루트에서 **`setup.bat`** 더블클릭

또는 CMD/PowerShell:
```cmd
setup.bat
```

`setup.bat`이 자동으로 수행하는 작업:
- Python 3.8+ 설치 여부 확인
- `requirements.txt` 패키지 설치 (`python-docx`, `lxml`)
- `figures/`, `reports/` 디렉토리 생성

### Mac / Linux
```bash
python3 -m pip install -r requirements.txt
mkdir -p figures reports
```

---

## 파이프라인 실행

### 방법 1 — `run_pipeline.bat` 더블클릭 (Windows, MATLAB PATH 등록 시)

### 방법 2 — MATLAB 커맨드 창
```matlab
run('scripts/pipeline_orchestrator.m')
```

### 방법 3 — 배치 모드 (CI/자동화)
```cmd
matlab -batch "run('C:/path/to/cfd_demo/scripts/pipeline_orchestrator.m')"
```
> 경로는 해당 환경의 실제 경로로 변경

---

## 생성 파일

| 경로 | 설명 |
|------|------|
| `data/cfd_results_summary.json` | 분석 결과 (Re, Nu, f_D 등) |
| `figures/graph_01_velocity_U.png` | 축방향 속도 U(x) |
| `figures/graph_02_velocity_V.png` | 횡방향 속도 V(x) |
| `figures/graph_03_velocity_magnitude.png` | 속도 크기 |
| `figures/graph_04_pressure.png` | 정압 분포 + 선형 피팅 |
| `figures/graph_05_temperature.png` | 온도 분포 |
| `figures/graph_06_turbulence.png` | TKE + 난류 강도 (이중 축) |
| `reports/CFD_Paper_Final.docx` | Elsevier 형식 Word 논문 (OMML 수식 포함) |

---

## 다른 컴퓨터 / 외부 드라이브로 이동 시

1. `cfd_demo/` 폴더 **전체** 복사 (하위 폴더 포함)
2. 새 환경에서 **`setup.bat`** 실행 (Python 패키지 재설치)
3. MATLAB에서 파이프라인 실행

> **경로 독립성**: 모든 스크립트는 `mfilename('fullpath')` (MATLAB) 및
> `Path(__file__).resolve()` (Python) 로 실행 위치를 자동 계산합니다.
> 드라이브 문자(C: → D:)나 폴더 위치가 바뀌어도 수정 없이 동작합니다.

---

## 프로젝트 구조

```
cfd_demo/
├── setup.bat                        ← 최초 설치 (Windows)
├── run_pipeline.bat                 ← 파이프라인 실행 단축키 (Windows)
├── requirements.txt                 ← Python 패키지 목록
├── README.md
├── data/
│   ├── cfd_results.xlsx             ← 입력: CFD 시뮬레이션 데이터
│   └── cfd_results_summary.json    ← 출력: Agent A 분석 결과
├── figures/
│   └── graph_01~06.png             ← 출력: Agent B 그래프 6개
├── reports/
│   └── CFD_Paper_Final.docx        ← 출력: Agent C 논문
└── scripts/
    ├── pipeline_orchestrator.m     ← 오케스트레이터 (A→B→C 순차 실행)
    ├── agent_a_analysis.m          ← Agent A: 데이터 분석 → JSON
    ├── agent_b_visualization.m     ← Agent B: 시각화 → PNG x6
    └── agent_c_paper_writer.py     ← Agent C: 논문 작성 → DOCX
```

---

## 문제 해결

### Python을 찾을 수 없다는 오류
```
Python 3.8+ 를 PATH 에서 찾을 수 없습니다.
```
→ Python 설치 후 **새 CMD 창**을 열거나 재부팅 후 재시도  
→ `python --version` 으로 PATH 등록 확인

### pip 설치 실패 (네트워크 오류)
```cmd
python -m pip install python-docx lxml --index-url https://pypi.org/simple/
```

### MATLAB `exportgraphics` 오류
→ MATLAB R2020a 이상인지 확인: `>> ver` 실행 후 버전 확인

### Excel 파일을 읽을 수 없음
→ `data/cfd_results.xlsx` 파일이 존재하는지, 시트 이름이 `CFD_Results`인지 확인
