%% 멀티에이전트 파이프라인 오케스트레이터
% 역할: 에이전트 A → B → C 를 순서대로 자동 실행
%
% 실행 방법 (택 1):
%   (1) MATLAB 커맨드 창: run('scripts/pipeline_orchestrator.m')
%   (2) 프로젝트 루트에서: run_pipeline.bat
%   (3) 배치 모드: matlab -batch "run('<절대경로>/scripts/pipeline_orchestrator.m')"
%
% 파이프라인:
%   [엑셀] → Agent A (agent_a_analysis.m)      → [JSON]
%           → Agent B (agent_b_visualization.m) → [graph_01~06.png x 6]
%           → Agent C (agent_c_paper_writer.py) → [CFD_Paper_Final.docx]
%
% 이식성: mfilename/Path(__file__) 기반 경로 해석
%         → 드라이브 문자·폴더 위치가 바뀌어도 동작
%
% 주의: agent_a/b 내부의 clc;clear; 가 호출자 변수를 초기화하므로
%       타이머와 경로는 환경변수(setenv/getenv)로 보존합니다.

clc; clear; close all;

%% ── 경로 초기화 ───────────────────────────────────────────────────
SCRIPTS_DIR = fileparts(mfilename('fullpath'));
BASE_DIR    = fileparts(SCRIPTS_DIR);
setenv('PIPELINE_SCRIPT_DIR', SCRIPTS_DIR);
setenv('PIPELINE_T0',         num2str(now, '%.10f'));

%% ── 출력 디렉토리 보장 ────────────────────────────────────────────
for d = {fullfile(BASE_DIR,'figures'), fullfile(BASE_DIR,'reports')}
    if ~isfolder(d{1})
        mkdir(d{1});
        fprintf('Directory created: %s\n', d{1});
    end
end

%% ── Python 실행 파일 탐지 ─────────────────────────────────────────
py_exe = find_python();
setenv('PIPELINE_PYTHON', py_exe);

%% ── 파이프라인 시작 헤더 ──────────────────────────────────────────
fprintf('╔══════════════════════════════════════════════╗\n');
fprintf('║     CFD 멀티에이전트 파이프라인 시작          ║\n');
fprintf('╚══════════════════════════════════════════════╝\n');
fprintf('  Base  : %s\n', BASE_DIR);
fprintf('  Python: %s\n\n', py_exe);

%% ── AGENT A: 데이터 분석 ─────────────────────────────────────────
fprintf('[1/3] 에이전트 A — 데이터 분석 시작...\n');
setenv('AGENT_T0', num2str(now, '%.10f'));
run(fullfile(getenv('PIPELINE_SCRIPT_DIR'), 'agent_a_analysis.m'));

% clear 이후 경로 재초기화
SCRIPTS_DIR = getenv('PIPELINE_SCRIPT_DIR');
DATA_DIR    = fullfile(fileparts(SCRIPTS_DIR), 'data');
elapsed_a   = (now - str2double(getenv('AGENT_T0'))) * 86400;
fprintf('[1/3] 에이전트 A 완료 (%.1f초)\n\n', elapsed_a);

assert(isfile(fullfile(DATA_DIR, 'cfd_results_summary.json')), ...
    '에이전트 A 실패: data/cfd_results_summary.json 없음');

%% ── AGENT B: 시각화 ──────────────────────────────────────────────
fprintf('[2/3] 에이전트 B — 시각화 시작...\n');
setenv('AGENT_T0', num2str(now, '%.10f'));
run(fullfile(SCRIPTS_DIR, 'agent_b_visualization.m'));

% clear 이후 경로 재초기화
SCRIPTS_DIR = getenv('PIPELINE_SCRIPT_DIR');
FIGURES_DIR = fullfile(fileparts(SCRIPTS_DIR), 'figures');
elapsed_b   = (now - str2double(getenv('AGENT_T0'))) * 86400;
fprintf('[2/3] 에이전트 B 완료 (%.1f초)\n\n', elapsed_b);

% 6개 개별 그래프 파일 생성 확인
graph_files = {'graph_01_velocity_U.png','graph_02_velocity_V.png', ...
               'graph_03_velocity_magnitude.png','graph_04_pressure.png', ...
               'graph_05_temperature.png','graph_06_turbulence.png'};
for gi = 1:numel(graph_files)
    assert(isfile(fullfile(FIGURES_DIR, graph_files{gi})), ...
        ['에이전트 B 실패: figures/' graph_files{gi} ' 없음']);
end

%% ── AGENT C: Word 논문 작성 ─────────────────────────────────────
fprintf('[3/3] 에이전트 C — Word 논문 작성 시작...\n');
setenv('AGENT_T0', num2str(now, '%.10f'));

SCRIPTS_DIR = getenv('PIPELINE_SCRIPT_DIR');
REPORTS_DIR = fullfile(fileparts(SCRIPTS_DIR), 'reports');
py_exe      = getenv('PIPELINE_PYTHON');
py_script   = fullfile(SCRIPTS_DIR, 'agent_c_paper_writer.py');

[status, output] = system(['"' py_exe '" "' py_script '"']);
fprintf('%s\n', output);
if status ~= 0
    error('에이전트 C 실패:\n%s', output);
end

elapsed_c = (now - str2double(getenv('AGENT_T0'))) * 86400;
fprintf('[3/3] 에이전트 C 완료 (%.1f초)\n\n', elapsed_c);

assert(isfile(fullfile(REPORTS_DIR, 'CFD_Paper_Final.docx')), ...
    '에이전트 C 실패: reports/CFD_Paper_Final.docx 없음');

%% ── 완료 요약 ────────────────────────────────────────────────────
total = (now - str2double(getenv('PIPELINE_T0'))) * 86400;
fprintf('╔══════════════════════════════════════════════╗\n');
fprintf('║     파이프라인 완료 (총 %.1f초)               ║\n', total);
fprintf('╠══════════════════════════════════════════════╣\n');
fprintf('║  생성된 파일:                                 ║\n');
fprintf('║  data/cfd_results_summary.json  (분석 결과)  ║\n');
fprintf('║  figures/graph_01_velocity_U.png             ║\n');
fprintf('║  figures/graph_02_velocity_V.png             ║\n');
fprintf('║  figures/graph_03_velocity_magnitude.png     ║\n');
fprintf('║  figures/graph_04_pressure.png               ║\n');
fprintf('║  figures/graph_05_temperature.png            ║\n');
fprintf('║  figures/graph_06_turbulence.png             ║\n');
fprintf('║  reports/CFD_Paper_Final.docx   (논문)       ║\n');
fprintf('╚══════════════════════════════════════════════╝\n');

%% ── 로컬 함수 ────────────────────────────────────────────────────
function py_exe = find_python()
%FIND_PYTHON  python / python3 / py 중 Python 3.8+ 인 첫 번째를 반환
    candidates = {'python', 'python3', 'py -3'};
    for i = 1:numel(candidates)
        [s, o] = system([candidates{i} ' -c "import sys; print(sys.version)"']);
        if s == 0 && contains(o, '3.')
            ver_str = strtrim(o);
            fprintf('  Python found: %s (%s)\n', candidates{i}, ver_str(1:min(20,end)));
            py_exe = candidates{i};
            return;
        end
    end
    error(['Python 3.8+ 를 PATH 에서 찾을 수 없습니다.\n' ...
           '  설치: https://www.python.org/downloads/\n' ...
           '  설치 시 "Add Python to PATH" 옵션 체크 필수\n' ...
           '  설치 후 setup.bat 실행']);
end
