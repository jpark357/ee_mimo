clear; clc; close all;

% Channel vectors
h0 = [0.3 - 1j, 0.7 + 1.2j];
h1 = [0.4j, 2 - 0.3j];

% H H^H
H0H0H = h0' * h0;
H1H1H = h1' * h1;

% SNR values
SNR0 = 10^(6/10);
SNR1 = 10^(10/10);

% === Step 1: boundary points (0,C1), (C0,0) ===
C0 = real(log2(det(eye(2) + SNR0 * H0H0H)));  % user 0 full power
C1 = real(log2(det(eye(2) + SNR1 * H1H1H)));  % user 1 full power

% === Step 2: All alpha values (Eu/Es ratio) ===
alphas = linspace(0.01, 0.99, 100);
R0_list = zeros(size(alphas));
R1_list = zeros(size(alphas));

for i = 1:length(alphas)
    alpha = alphas(i);           % power share for user 0
    beta = 1 - alpha;            % power share for user 1
    
    % Capacity under SIC: R0 decoded first, R1 last
    A = eye(2) + alpha * SNR0 * H0H0H + beta * SNR1 * H1H1H;
    A1 = eye(2) + beta * SNR1 * H1H1H;

    C_total = real(log2(det(A)));
    R1 = real(log2(det(A1)));
    R0 = C_total - R1;

    R0_list(i) = R0;
    R1_list(i) = R1;
end

% === Plot ===
figure; hold on; grid on;

% Polygon fill region
x_poly = [0, 0, R0_list, C0];
y_poly = [0, C1, R1_list, 0];
fill(x_poly, y_poly, [0.9 0.9 0.9], 'EdgeColor', 'k', 'LineWidth', 1.8);

% Boundary points
plot(C0, 0, 'ks', 'MarkerSize', 8, 'LineWidth', 2);      
plot(0, C1, 'ks', 'MarkerSize', 8, 'LineWidth', 2);      

% Curve from alpha sweep
plot(R0_list, R1_list, 'b-', 'LineWidth', 2);

% Annotations
text(C0 - 0.4, -0.3, sprintf('(%.2f, 0)', C0), 'FontSize', 10);
text(0.1, C1 + 0.2, sprintf('(0, %.2f)', C1), 'FontSize', 10);

xlabel('R_0 (bps/Hz)');
ylabel('R_1 (bps/Hz)');
title('BC Capacity Region (H0, H1, All Power Splits)');
legend('Region', '(C_0, 0)', '(0, C_1)', 'Power share curve', 'Location', 'SouthWest');
axis tight;
xlim([0 4]); ylim([0 6]);

% Save
if ~exist('fig', 'dir'); mkdir('fig'); end
print('-depsc2', 'fig/ex8_28_bc_region_full.eps');
