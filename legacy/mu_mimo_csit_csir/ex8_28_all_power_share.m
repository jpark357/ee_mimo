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

% Fine alpha values
alpha_vec = linspace(0, 1, 60);

% Plot
figure; hold on; grid on;
for i = 1:length(alpha_vec)
    alpha = alpha_vec(i);
    beta = 1 - alpha;

    % Individual user capacities
    C0 = log2(real(det(I + alpha * SNR0 * H0H0H)));
    C1 = log2(real(det(I + beta  * SNR1 * H1H1H)));

    % Joint sum capacity
    Csum = log2(real(det(I + alpha * SNR0 * H0H0H + beta * SNR1 * H1H1H)));

    % Corner points from SIC
    corner0 = [C0, Csum - C0]; % user 0 first
    corner1 = [Csum - C1, C1]; % user 1 first

    % Polygon points (5 total)
    x_poly = [0, 0, corner1(1), corner0(1), C0];
    y_poly = [0, C1, corner1(2), corner0(2), 0];

    % Fill all polygons with same color
    fill(x_poly, y_poly, [0.75 0.85 1], ...
        'EdgeColor', 'none', ...
        'FaceAlpha', 0.5);
end

xlabel('R_0 (bps/Hz)');
ylabel('R_1 (bps/Hz)');
title('BC Capacity Region (MAC-style Polygons, Fine \alpha Sweep)');
xlim([0 4]); ylim([0 6]);
axis square;

% Save
if ~exist('fig', 'dir'); mkdir('fig'); end
print('-depsc2', 'fig/ex8_28_mac_filled_region.eps');
