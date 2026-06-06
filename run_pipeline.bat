@echo off
chcp 65001 > nul

REM ── 이 파일이 있는 폴더 = 프로젝트 루트 ────────────────────────
set "ROOT=%~dp0"
set "ROOT=%ROOT:~0,-1%"

REM 슬래시를 /로 변환 (MATLAB 경로용)
set "SCRIPT=%ROOT%\scripts\pipeline_orchestrator.m"
set "SCRIPT=%SCRIPT:\=/%"

REM ── MATLAB PATH 확인 ──────────────────────────────────────────────
where matlab >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] 'matlab' 명령을 찾을 수 없습니다.
    echo.
    echo MATLAB을 PATH에 추가하거나, MATLAB 커맨드 창에서 직접 실행하세요:
    echo   run('scripts/pipeline_orchestrator.m')
    echo.
    pause
    exit /b 1
)

echo ================================================================
echo  CFD Pipeline 실행 중...
echo  스크립트: %SCRIPT%
echo ================================================================
echo.

matlab -batch "run('%SCRIPT%')"

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] 파이프라인 실행 실패. 위의 오류 메시지를 확인하세요.
    pause
    exit /b 1
)

echo.
echo 완료! reports\CFD_Paper_Final.docx 를 확인하세요.
pause
