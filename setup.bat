@echo off
chcp 65001 > nul
setlocal EnableDelayedExpansion

echo ================================================================
echo  CFD Demo Pipeline - Setup
echo ================================================================
echo.

set "ROOT=%~dp0"
set "ROOT=%ROOT:~0,-1%"

REM ── 1. Python 확인 ───────────────────────────────────────────────
echo [1/3] Python 확인 중...
set "PY="

python -c "import sys; assert sys.version_info >= (3,8), 'need 3.8+'" 2>nul
if %errorlevel% equ 0 (
    set "PY=python"
) else (
    python3 -c "import sys; assert sys.version_info >= (3,8), 'need 3.8+'" 2>nul
    if %errorlevel% equ 0 (
        set "PY=python3"
    ) else (
        py -3 -c "import sys; assert sys.version_info >= (3,8), 'need 3.8+'" 2>nul
        if %errorlevel% equ 0 (
            set "PY=py -3"
        )
    )
)

if "!PY!"=="" (
    echo   [ERROR] Python 3.8 이상이 PATH에 없습니다.
    echo.
    echo   설치: https://www.python.org/downloads/
    echo   설치 중 "Add Python to PATH" 체크 필수
    echo.
    pause
    exit /b 1
)

for /f "usebackq tokens=*" %%v in (`!PY! --version`) do echo   OK: %%v

REM ── 2. Python 패키지 설치 ────────────────────────────────────────
echo.
echo [2/3] Python 패키지 설치 중...
!PY! -m pip install --quiet --upgrade -r "%ROOT%\requirements.txt"
if %errorlevel% neq 0 (
    echo   [ERROR] 패키지 설치 실패. 아래를 직접 실행하세요:
    echo     python -m pip install python-docx lxml
    pause
    exit /b 1
)
echo   OK: python-docx, lxml 설치 완료

REM ── 3. 출력 디렉토리 생성 ────────────────────────────────────────
echo.
echo [3/3] 출력 디렉토리 확인 중...
if not exist "%ROOT%\figures"  ( mkdir "%ROOT%\figures"  && echo   Created: figures\  )
if not exist "%ROOT%\reports"  ( mkdir "%ROOT%\reports"  && echo   Created: reports\  )
if not exist "%ROOT%\data"     ( echo   [WARN] data\ 디렉토리가 없습니다. cfd_results.xlsx 파일을 data\ 에 복사하세요. )

echo.
echo ================================================================
echo  설치 완료!
echo.
echo  파이프라인 실행 방법:
echo    1. run_pipeline.bat 더블클릭
echo    2. MATLAB 커맨드 창에서:
echo         run('scripts/pipeline_orchestrator.m')
echo ================================================================
echo.
pause
