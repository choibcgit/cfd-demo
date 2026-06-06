%% 에이전트 B — 시각화
% 역할: JSON + xlsx 읽기 → 그래프 6개를 개별 PNG로 저장
% 이전 에이전트: agent_a_analysis.m
% 다음 에이전트: agent_c_paper_writer.py
% 출력:
%   figures/graph_01_velocity_U.png
%   figures/graph_02_velocity_V.png
%   figures/graph_03_velocity_magnitude.png
%   figures/graph_04_pressure.png
%   figures/graph_05_temperature.png
%   figures/graph_06_turbulence.png

clc; clear; close all;
fprintf('=== 에이전트 B 시작: 시각화 ===\n');

%% 경로 설정
BASE        = fileparts(fileparts(mfilename('fullpath')));
DATA_DIR    = fullfile(BASE, 'data');
FIGURES_DIR = fullfile(BASE, 'figures');

%% 1. 데이터 로드
fid = fopen(fullfile(DATA_DIR, 'cfd_results_summary.json'), 'r');
raw = fread(fid, '*char')'; fclose(fid);
res = jsondecode(raw);

data = readtable(fullfile(DATA_DIR, 'cfd_results.xlsx'), 'Sheet', 'CFD_Results');
x = data.Position_X_m_;
U = data.Velocity_U_m_s_;
V = data.Velocity_V_m_s_;
P = data.Pressure_Pa_;
T = data.Temperature_K_;
k = data.Turbulence_k_m__s__;

TI_vals = sqrt(k) ./ res.U_avg * 100;   % 난류 강도 [%]
Vmag    = sqrt(U.^2 + V.^2);     % 속도 크기

%% 공통 스타일
W = 900; H = 600;
FS_T = 14; FS_L = 12; FS_A = 11;

%% ── Figure 1: 축방향 속도 U ─────────────────────────────────────────────────
fig = figure('Position',[50 50 W H],'Color','white','Visible','off');
plot(x, U, '-o', 'Color',[0.18 0.55 0.84], 'LineWidth',1.8, ...
     'MarkerSize',5, 'MarkerFaceColor',[0.18 0.55 0.84]);
yline(res.U_avg, '--', sprintf('Mean = %.4f m/s', res.U_avg), ...
      'Color',[0.90 0.40 0.10], 'LineWidth',1.6, ...
      'LabelHorizontalAlignment','left', 'FontSize',10);
xlabel('Position X (m)', 'FontSize',FS_L);
ylabel('Velocity U (m/s)', 'FontSize',FS_L);
title('Streamwise Velocity (U) Along X-Axis', 'FontSize',FS_T, 'FontWeight','bold');
legend('U-velocity', 'Location','best', 'FontSize',10);
grid on; box on; set(gca,'FontSize',FS_A,'GridAlpha',0.3);
set(fig,'Visible','on');
exportgraphics(fig, fullfile(FIGURES_DIR,'graph_01_velocity_U.png'), 'Resolution',150);
close(fig);
fprintf('  [1/6] graph_01_velocity_U.png\n');

%% ── Figure 2: 횡방향 속도 V ─────────────────────────────────────────────────
fig = figure('Position',[50 50 W H],'Color','white','Visible','off');
plot(x, V, '-o', 'Color',[0.85 0.25 0.25], 'LineWidth',1.8, ...
     'MarkerSize',5, 'MarkerFaceColor',[0.85 0.25 0.25]);
yline(0, 'k--', 'LineWidth',1.2);
xlabel('Position X (m)', 'FontSize',FS_L);
ylabel('Velocity V (m/s)', 'FontSize',FS_L);
title('Transverse Velocity (V) Along X-Axis', 'FontSize',FS_T, 'FontWeight','bold');
legend('V-velocity', 'Location','best', 'FontSize',10);
grid on; box on; set(gca,'FontSize',FS_A,'GridAlpha',0.3);
set(fig,'Visible','on');
exportgraphics(fig, fullfile(FIGURES_DIR,'graph_02_velocity_V.png'), 'Resolution',150);
close(fig);
fprintf('  [2/6] graph_02_velocity_V.png\n');

%% ── Figure 3: 속도 크기 ─────────────────────────────────────────────────────
fig = figure('Position',[50 50 W H],'Color','white','Visible','off');
plot(x, Vmag, '-o', 'Color',[0.18 0.55 0.84], 'LineWidth',1.8, ...
     'MarkerSize',5, 'MarkerFaceColor',[0.18 0.55 0.84]);
yline(mean(Vmag), '--', sprintf('Mean = %.4f m/s', mean(Vmag)), ...
      'Color',[0.93 0.69 0.13], 'LineWidth',2.0, ...
      'LabelHorizontalAlignment','left', 'FontSize',10);
xlabel('Position X (m)', 'FontSize',FS_L);
ylabel('Velocity Magnitude (m/s)', 'FontSize',FS_L);
title('Velocity Magnitude Distribution', 'FontSize',FS_T, 'FontWeight','bold');
legend({'|V| magnitude','Mean'}, 'Location','best', 'FontSize',10);
grid on; box on; set(gca,'FontSize',FS_A,'GridAlpha',0.3);
set(fig,'Visible','on');
exportgraphics(fig, fullfile(FIGURES_DIR,'graph_03_velocity_magnitude.png'), 'Resolution',150);
close(fig);
fprintf('  [3/6] graph_03_velocity_magnitude.png\n');

%% ── Figure 4: 정압 분포 ─────────────────────────────────────────────────────
p_fit = polyfit(x, P, 1);
fig = figure('Position',[50 50 W H],'Color','white','Visible','off');
plot(x, P, '-o', 'Color',[0.56 0.18 0.56], 'LineWidth',1.8, ...
     'MarkerSize',5, 'MarkerFaceColor',[0.56 0.18 0.56]);
hold on;
plot(x, polyval(p_fit, x), 'k--', 'LineWidth',1.5);
xlabel('Position X (m)', 'FontSize',FS_L);
ylabel('Pressure (Pa)', 'FontSize',FS_L);
title('Static Pressure Distribution Along X-Axis', 'FontSize',FS_T, 'FontWeight','bold');
legend({'Static Pressure','Linear fit'}, 'Location','best', 'FontSize',10);
grid on; box on; set(gca,'FontSize',FS_A,'GridAlpha',0.3);
set(fig,'Visible','on');
exportgraphics(fig, fullfile(FIGURES_DIR,'graph_04_pressure.png'), 'Resolution',150);
close(fig);
fprintf('  [4/6] graph_04_pressure.png\n');

%% ── Figure 5: 온도 분포 ─────────────────────────────────────────────────────
fig = figure('Position',[50 50 W H],'Color','white','Visible','off');
plot(x, T, '-o', 'Color',[0.93 0.35 0.25], 'LineWidth',1.8, ...
     'MarkerSize',5, 'MarkerFaceColor',[0.93 0.35 0.25]);
xlabel('Position X (m)', 'FontSize',FS_L);
ylabel('Temperature (K)', 'FontSize',FS_L);
title('Temperature Distribution Along X-Axis', 'FontSize',FS_T, 'FontWeight','bold');
legend('Temperature', 'Location','best', 'FontSize',10);
grid on; box on; set(gca,'FontSize',FS_A,'GridAlpha',0.3);
set(fig,'Visible','on');
exportgraphics(fig, fullfile(FIGURES_DIR,'graph_05_temperature.png'), 'Resolution',150);
close(fig);
fprintf('  [5/6] graph_05_temperature.png\n');

%% ── Figure 6: 난류 운동 에너지 & 난류 강도 ─────────────────────────────────
fig = figure('Position',[50 50 W H],'Color','white','Visible','off');
yyaxis left;
plot(x, k, '-o', 'Color',[0.18 0.63 0.18], 'LineWidth',1.8, ...
     'MarkerSize',5, 'MarkerFaceColor',[0.18 0.63 0.18]);
ylabel('TKE  k  (m²/s²)', 'FontSize',FS_L);
yyaxis right;
plot(x, TI_vals, '-o', 'Color',[0.93 0.50 0.18], 'LineWidth',1.8, ...
     'MarkerSize',5, 'MarkerFaceColor',[0.93 0.50 0.18]);
ylabel('Turbulence Intensity TI (%)', 'FontSize',FS_L);
xlabel('Position X (m)', 'FontSize',FS_L);
title('Turbulent Kinetic Energy & Turbulence Intensity', 'FontSize',FS_T, 'FontWeight','bold');
legend({'TKE (m²/s²)','TI (%)'}, 'Location','best', 'FontSize',10);
grid on; box on; set(gca,'FontSize',FS_A,'GridAlpha',0.3);
set(fig,'Visible','on');
exportgraphics(fig, fullfile(FIGURES_DIR,'graph_06_turbulence.png'), 'Resolution',150);
close(fig);
fprintf('  [6/6] graph_06_turbulence.png\n');

fprintf('=== 에이전트 B 완료 → figures/graph_01~06.png 저장 ===\n');
fprintf('다음: 에이전트 C 실행 (agent_c_paper_writer.py)\n');
