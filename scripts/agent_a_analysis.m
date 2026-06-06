%% 에이전트 A — CFD 데이터 분석
% 역할: cfd_results.xlsx 읽기 → 유동 해석 → cfd_results_summary.json 저장
% 다음 에이전트: agent_b_visualization.m
% 실행: Claude Code 채팅창에 "run agent_a_analysis.m" 입력

clc; clear;
fprintf('=== 에이전트 A 시작: 데이터 분석 ===\n');

%% 경로 설정 (scripts/ 기준 → 프로젝트 루트)
BASE     = fileparts(fileparts(mfilename('fullpath')));
DATA_DIR = fullfile(BASE, 'data');

%% 1. 데이터 로드
data = readtable(fullfile(DATA_DIR, 'cfd_results.xlsx'), 'Sheet', 'CFD_Results');
x = data.Position_X_m_;
U = data.Velocity_U_m_s_;
V = data.Velocity_V_m_s_;
P = data.Pressure_Pa_;
T = data.Temperature_K_;
k = data.Turbulence_k_m__s__;

%% 2. 유동 특성 계산
rho = 1.225; mu = 1.81e-5; D = 0.1; cp = 1005; kf = 0.0257;
Pr    = mu * cp / kf;
U_avg = mean(U);
Re    = rho * U_avg * D / mu;
dP    = max(P) - min(P);
Ma    = U_avg / 343;
L     = max(x);
gradP = dP / L;
f_D   = dP / (L/D * 0.5 * rho * U_avg^2);   % Darcy 마찰계수
Nu    = round(0.023 * Re^0.8 * Pr^0.4, 1);   % Dittus-Boelter
h_val = round(Nu * kf / D, 2);               % 대류열전달계수 [W/m²K]
[~, k_max_idx] = max(k);
TI_avg = round(mean(sqrt(k)) / U_avg * 100, 2);  % 평균 난류강도 [%]

if Re < 2300,     flowType = 'laminar';
elseif Re < 4000, flowType = 'transitional';
else,             flowType = 'turbulent';
end

fprintf('Re = %.1f (%s)\n', Re, flowType);
fprintf('dP = %.2f Pa | gradP = %.2f Pa/m | Ma = %.5f\n', dP, gradP, Ma);
fprintf('Nu = %.1f | h = %.2f W/m2K | TI_avg = %.2f%%\n', Nu, h_val, TI_avg);

%% 3. 결과 JSON 저장
results.Re        = round(Re, 1);
results.flowType  = flowType;
results.U_avg     = round(U_avg, 4);
results.U_min     = round(min(U), 3);
results.U_max     = round(max(U), 3);
results.U_std     = round(std(U), 4);
results.V_min     = round(min(V), 4);
results.V_max     = round(max(V), 4);
results.dP        = round(dP, 2);
results.P_min     = round(min(P), 1);
results.P_max     = round(max(P), 1);
results.gradP     = round(gradP, 2);
results.f_D       = round(f_D, 6);
results.T_min     = round(min(T), 1);
results.T_max     = round(max(T), 1);
results.T_avg     = round(mean(T), 2);
results.deltaT    = round(max(T) - min(T), 1);
results.k_max     = round(max(k), 5);
results.k_avg     = round(mean(k), 5);
results.k_max_pos = round(x(k_max_idx), 2);
results.Ma        = round(Ma, 5);
results.Nu        = Nu;
results.h         = h_val;
results.Pr        = round(Pr, 3);
results.TI_avg    = TI_avg;
results.n_points  = height(data);
results.L         = round(L, 2);
results.D         = D;

fid = fopen(fullfile(DATA_DIR, 'cfd_results_summary.json'), 'w');
fprintf(fid, '%s', jsonencode(results));
fclose(fid);

fprintf('=== 에이전트 A 완료 → data/cfd_results_summary.json 저장 ===\n');
fprintf('다음: 에이전트 B 실행 (agent_b_visualization.m)\n');
