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

% Alpha values
alpha_vec = [0, 0.25, 0.5, 0.75, 1];
colors = {'k', 'b', 'g', 'r', 'm'};

% Plot
figure; hold on; grid on;
for i = 1:length(alpha_vec)
    alpha = alpha_vec(i);
    beta = 1 - alpha;

    % Individual full-power capacities
    C0 = log2(real(det(I + alpha * SNR0 * H0H0H)));
    C1 = log2(real(det(I + beta  * SNR1 * H1H1H)));

    % Joint capacity
    Csum = log2(real(det(I + alpha * SNR0 * H0H0H + beta * SNR1 * H1H1H)));

    % Corner points
    corner0 = [C0, Csum - C0]; % user 0 decoded first
    corner1 = [Csum - C1, C1]; % user 1 decoded first

    % Polygon vertices
    x_poly = [0, 0, corner1(1), corner0(1), C0];
    y_poly = [0, C1, corner1(2), corner0(2), 0];

    % Fill and outline each polygon
    fill(x_poly, y_poly, colors{i}, ...
        'FaceAlpha', 0.15, 'EdgeColor', colors{i}, 'LineWidth', 1.8, ...
        'DisplayName', sprintf('\\alpha = %.2f', alpha));
end

xlabel('R_0 (bps/Hz)');
ylabel('R_1 (bps/Hz)');
title('MAC-style Polygonal BC Capacity Regions for Multiple \\alpha');
legend('Location', 'SouthWest');
xlim([0 4]); ylim([0 6]);

% Save
if ~exist('fig', 'dir'); mkdir('fig'); end
print('-depsc2', 'fig/ex8_28_mac_polygons_multiple_alpha.eps');
