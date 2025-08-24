clear; clc; close all;

% Channel vectors
H0 = [0.3 - 1j, 0.7 + 1.2j];
H1 = [0.4j, 2 - 0.3j];
I = eye(2);

% Gram matrices
H0H0H = H0' * H0;
H1H1H = H1' * H1;

% SNRs (linear)
SNR0 = 10^(6/10);
SNR1 = 10^(10/10);

% --- Objective 1: User 0 decoded first
pf1 = @(alpha) -( ...
    log(log2(real(det(I + alpha * SNR0 * H0H0H + (1-alpha) * SNR1 * H1H1H))) ...
  - log2(real(det(I + (1-alpha) * SNR1 * H1H1H)))) ...
  + log(log2(real(det(I + (1-alpha) * SNR1 * H1H1H)))) ...
);

% --- Objective 2: User 1 decoded first
pf2 = @(alpha) -( ...
    log(log2(real(det(I + (1-alpha) * SNR1 * H1H1H + alpha * SNR0 * H0H0H))) ...
  - log2(real(det(I + alpha * SNR0 * H0H0H)))) ...
  + log(log2(real(det(I + alpha * SNR0 * H0H0H)))) ...
);

% --- Optimization
opts = optimoptions('fmincon','Display','none');
[alpha1, fval1] = fmincon(pf1, 0.5, [], [], [], [], 0.01, 0.99, [], opts);
[alpha2, fval2] = fmincon(pf2, 0.5, [], [], [], [], 0.01, 0.99, [], opts);

% --- Compute rates
a1 = alpha1; b1 = 1 - a1;
R1_1 = log2(real(det(I + b1 * SNR1 * H1H1H)));
R0_1 = log2(real(det(I + a1 * SNR0 * H0H0H + b1 * SNR1 * H1H1H))) - R1_1;

a2 = alpha2; b2 = 1 - a2;
R0_2 = log2(real(det(I + a2 * SNR0 * H0H0H)));
R1_2 = log2(real(det(I + b2 * SNR1 * H1H1H + a2 * SNR0 * H0H0H))) - R0_2;

if -fval1 > -fval2
    R0_star = R0_1; R1_star = R1_1;
    alpha_star = a1; beta_star = b1;
    fprintf('🔺 User 0 decoded first is better (Proportional Fairness)\n');
else
    R0_star = R0_2; R1_star = R1_2;
    alpha_star = a2; beta_star = b2;
    fprintf('🔺 User 1 decoded first is better (Proportional Fairness)\n');
end

fprintf('Alpha = %.4f, Beta = %.4f\n', alpha_star, beta_star);
fprintf('R0 = %.4f bps/Hz, R1 = %.4f bps/Hz\n', R0_star, R1_star);

% === Generate MAC-style convex hull
alpha_vec = linspace(0.01, 0.99, 100);
point_list = [];

for i = 1:length(alpha_vec)
    alpha = alpha_vec(i);
    beta = 1 - alpha;

    C0 = log2(real(det(I + alpha * SNR0 * H0H0H)));
    C1 = log2(real(det(I + beta  * SNR1 * H1H1H)));
    Csum = log2(real(det(I + alpha * SNR0 * H0H0H + beta * SNR1 * H1H1H)));

    corner0 = [C0, Csum - C0];
    corner1 = [Csum - C1, C1];

    point_list = [point_list;
                  0, 0;
                  0, C1;
                  corner1;
                  corner0;
                  C0, 0];
end

% === Convex hull
K = convhull(point_list(:,1), point_list(:,2));

% === Plot
figure; hold on; grid on;

% Fill region and hull
fill(point_list(K,1), point_list(K,2), [0.85 0.9 1], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
plot(point_list(K,1), point_list(K,2), 'k-', 'LineWidth', 2);

% Mark PF point
plot(R0_star, R1_star, 'ro', 'MarkerSize', 8, 'LineWidth', 2);
text(R0_star + 0.1, R1_star, sprintf('PF (%.2f, %.2f)', R0_star, R1_star), 'FontSize', 10, 'Color', 'r');

xlabel('R_0/B (bps/Hz)');
ylabel('R_1/B (bps/Hz)');
title('BC Capacity Region with Proportional Fairness Point');
axis([0 4 0 6]); axis square;
legend('Region', 'Convex Hull', 'PF Point', 'Location', 'SouthWest');

% Save EPS
if ~exist('fig', 'dir'); mkdir('fig'); end
print('-depsc2', 'fig/hw_8_36_b.eps');
