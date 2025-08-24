clear; clc; close all;

% Channel vectors
H0 = [0.3 - 1j, 0.7 + 1.2j];
H1 = [0.4j, 2 - 0.3j];

% Gram matrices
H0H0H = H0' * H0;
H1H1H = H1' * H1;

% SNR values
SNR0 = 10^(6/10);
SNR1 = 10^(10/10);
I = eye(2);

% Fine alpha sampling
alpha_vec = linspace(0.01, 0.99, 100);

% Store all polygon corner points
point_list = [];

% Loop: collect all polygon corner points
for i = 1:length(alpha_vec)
    alpha = alpha_vec(i);
    beta = 1 - alpha;

    % Individual capacities
    C0 = log2(real(det(I + alpha * SNR0 * H0H0H)));
    C1 = log2(real(det(I + beta  * SNR1 * H1H1H)));
    Csum = log2(real(det(I + alpha * SNR0 * H0H0H + beta * SNR1 * H1H1H)));

    corner0 = [C0, Csum - C0];  % user 0 decoded first
    corner1 = [Csum - C1, C1];  % user 1 decoded first

    % Add the 5 polygon points: (0,0), (0,C1), corner1, corner0, (C0,0)
    point_list = [point_list;
                  0, 0;
                  0, C1;
                  corner1;
                  corner0;
                  C0, 0];
end

% Compute convex hull of all points
K = convhull(point_list(:,1), point_list(:,2));

% Plot
figure; hold on; grid on;

% Plot filled region for context (optional)
fill(point_list(K,1), point_list(K,2), [0.85 0.9 1], 'EdgeColor', 'none', 'FaceAlpha', 0.3);

% Outer convex hull
plot(point_list(K,1), point_list(K,2), 'k-', 'LineWidth', 2.2);

xlabel('R_0 (bps/Hz)');
ylabel('R_1 (bps/Hz)');
title('Outer Convex Hull of MAC-style BC Region');
axis([0 4 0 6]); axis square;

% Save EPS
if ~exist('fig', 'dir'); mkdir('fig'); end
print('-depsc2', 'fig/ex8_28_mac_convex_hull.eps');
