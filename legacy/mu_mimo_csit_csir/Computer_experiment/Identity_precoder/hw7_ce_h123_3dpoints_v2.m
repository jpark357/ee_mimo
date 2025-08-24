clc; clear all; close all;

% === (1) 평면상의 9개 점 정의 ===
P_plane = [
    5.02, 0,    0;      % R0 axis
    0,    1.91, 0;      % R1 axis 
    5.02, 0.55, 0;      % p_xy_r sum = 5.58
    3.66, 1.91, 0;      % p_xy_b

    0,    0,    2.74;   % R2 axis
    0,    1.91, 1.82;   % p_yz_r sum = 3.73
    0,    0.99, 2.74;   % p_yz_b

    5.02, 0,    1.06;   % p_xz_r
    3.34, 0,    2.74;   % p_xz_b sum = 6.08
];

% === (2) 공간상의 6개 roof 점 정의 ===
P_roof = [
    5.02, 0.55, 0.87;   % p3d_xy_r
    3.66, 1.91, 0.87;   % p3d_xy_b
    2.71, 1.91, 1.82;   % p3d_yz_r
    2.71, 0.99, 2.74;   % p3d_yz_b
    5.02, 0.36, 1.06;   % p3d_xz_r
    3.34, 0.36, 2.74;   % p3d_xz_b
];

% === (3) 전체 점 병합 ===
P = [P_plane; P_roof];

% === (4) Convex Hull 계산 ===
K = convhull(P(:,1), P(:,2), P(:,3));

% === (5) 3D Convex Polyhedron 그리기 ===
figure();
camzoom(1.2); 
trisurf(K, P(:,1), P(:,2), P(:,3), ...
        'FaceAlpha', 0.7, ...
        'FaceColor', [1 0.8 0.6], ...
        'EdgeColor', 'k', ...
        'LineWidth', 1.2);
hold on; grid on;
xlim([0 6]); ylim([0 6]); zlim([0 6]);
% === (6) 시각화 설정 ===
xlabel('R_0 / B (bps/Hz)', 'FontSize', 12);
ylabel('R_1 / B (bps/Hz)', 'FontSize', 12);
zlabel('R_2 / B (bps/Hz)', 'FontSize', 12);
title('Convex Hull of MAC Capacity Region (3D)', 'FontSize', 14);
axis vis3d;
view([-45, 25]);
set(gca, ...
    'XDir', 'reverse', ...
    'YDir', 'reverse', ...
    'BoxStyle', 'full', ...
    'FontSize', 12);
% === (6.5) 공간상 점 마커 표시 및 Sum Rate 텍스트 ===
C_sum = 6.44;  % 예시: 미리 계산된 sum rate


% 각 점과 색상 지정
scatter3(P_roof(:,1), P_roof(:,2), P_roof(:,3), ...
         80, '^', 'filled', 'MarkerFaceColor', 'm');

% Sum rate 텍스트 추가
for i = 1:size(P_roof,1)
    pt = P_roof(i,:);
    text(pt(1), pt(2), pt(3)+0.2, sprintf('%.2f', C_sum), ...
         'FontSize', 10, 'Color', 'm', 'FontWeight', 'bold');
end


% === 저장 ===
print(gcf, 'fig/hw7_com_convex_hull_3D.eps', '-depsc2');
