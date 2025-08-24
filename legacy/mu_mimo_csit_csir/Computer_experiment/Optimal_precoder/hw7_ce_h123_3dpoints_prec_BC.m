clear; clc; close all;

% === (1) BC points on each plane ===
P_plane = [
    4.5536, 0,      0;        % R1 only
    0,      2.3596, 0;        % R2 only
    4.5536, 1.8912, 0;        % R1->R2 (corner_xy_r)
    4.0852, 2.3596, 0;        % R2->R1 (corner_xy_b)

    0,      0,      3.2753;   % R3 only
    0,      2.3596, 1.6020;   % R2->R3 (corner_yz_r)
    0,      0.6863, 3.2753;   % R3->R2 (corner_yz_b)

    4.5536, 0,      2.3709;   % R1->R3 (corner_xz_r)
    3.6492, 0,      3.2753;   % R3->R1 (corner_xz_b)
];

% === (2) BC points on roofs ===
P_roof = [
    4.5536, 1.8912, 0.4797;   % p3d_xy_r
    4.0852, 2.3596, 0.4797;   % p3d_xy_b
    2.9629, 2.3596, 1.6020;   % p3d_yz_r
    2.9629, 0.6863, 3.2753;   % p3d_yz_b
    4.5536, 0.0000, 2.3709;   % p3d_xz_r
    3.6492, 0.0000, 3.2753;   % p3d_xz_b
];

% === (3) Merge all points ===
P = [P_plane; P_roof];

% === (4) Convex Hull  ===
K = convhull(P(:,1), P(:,2), P(:,3));

% === (5) 3D Convex Polyhedron  ===
figure(); hold on; grid on; camzoom(0.7);
trisurf(K, P(:,1), P(:,2), P(:,3), ...
        'FaceAlpha', 0.7, ...
        'FaceColor', [1 0.8 0.6], ...
        'EdgeColor', 'k', ...
        'LineWidth', 1.2);

% === (6) Plot===
xlabel('R_0 / B (bps/Hz)', 'FontSize', 12);
ylabel('R_1 / B (bps/Hz)', 'FontSize', 12);
zlabel('R_2 / B (bps/Hz)', 'FontSize', 12);
title('Convex Hull of BC Capacity Region (3D)', 'FontSize', 14);
axis vis3d;
xlim([0 6]); ylim([0 6]); zlim([0 6]);
view([-45, 25]);
set(gca, ...
    'XDir', 'reverse', ...
    'YDir', 'reverse', ...
    'BoxStyle', 'full', ...
    'FontSize', 12);

% === (6.5) 지붕 점 마커 및 Sum Rate 표시 ===
C_sum = 6.92;
scatter3(P_roof(:,1), P_roof(:,2), P_roof(:,3), ...
         80, '^', 'filled', 'MarkerFaceColor', 'm');

% 각 지붕 점에 sum rate 표시
for i = 1:size(P_roof,1)
    pt = P_roof(i,:);
    text(pt(1), pt(2), pt(3)+0.2, sprintf('%.2f', C_sum), ...
         'FontSize', 10, 'Color', 'm', 'FontWeight', 'bold');
end

% === (7) EPS 저장 ===
print(gcf, 'hw7_com_convex_hull_3D_prec_BC.eps', '-depsc2');
