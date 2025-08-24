clear; clc; close all;

% Channel vectors
H0 = [0.3 - 1j, 0.7 + 1.2j];
H1 = [0.4j, 2 - 0.3j];
I = eye(2);

% Gram matrices
H0H0H = H0' * H0;
H1H1H = H1' * H1;

% SNRs
SNR0 = 10^(6/10);
SNR1 = 10^(10/10);

% Build convex region from polygonal boundary points
alpha_vec = linspace(0.01, 0.99, 100);
point_list = [];

for i = 1:length(alpha_vec)
    alpha = alpha_vec(i);
    beta = 1 - alpha;

    C0 = log2(real(det(I + alpha * SNR0 * H0H0H)));
    C1 = log2(real(det(I + beta  * SNR1 * H1H1H)));
    Csum = log2(real(det(I + alpha * SNR0 * H0H0H + beta * SNR1 * H1H1H)));

    corner0 = [C0, Csum - C0]; % user 0 first
    corner1 = [Csum - C1, C1]; % user 1 first

    point_list = [point_list;
                  0, 0;
                  0, C1;
                  corner1;
                  corner0;
                  C0, 0];
end

% Compute convex hull
K = convhull(point_list(:,1), point_list(:,2));
hull_pts = point_list(K, :);

% === Find all intersections with y = x line
equal_pts = [];
for i = 1:length(hull_pts)-1
    x1 = hull_pts(i,1); y1 = hull_pts(i,2);
    x2 = hull_pts(i+1,1); y2 = hull_pts(i+1,2);

    dx = x2 - x1;
    dy = y2 - y1;
    denom = dx - dy;
    if abs(denom) < 1e-6, continue; end  % avoid division by zero

    % Solve for intersection with y = x
    t = (y1 - x1) / denom;
    if t >= 0 && t <= 1
        x_eq = x1 + t * dx;
        y_eq = y1 + t * dy;
        if abs(x_eq - y_eq) < 1e-3
            equal_pts = [equal_pts; x_eq, y_eq];
        end
    end
end

% === Choose the outermost (maximum R0 = R1) equal rate point
if ~isempty(equal_pts)
    [~, idx] = max(equal_pts(:,1)); % since R0 = R1
    eq_pt = equal_pts(idx,:);
else
    eq_pt = [];
end

% === Plot result
figure; hold on; grid on;

fill(hull_pts(:,1), hull_pts(:,2), [0.85 0.9 1], ...
    'EdgeColor', 'none', 'FaceAlpha', 0.3);
plot(hull_pts(:,1), hull_pts(:,2), 'k-', 'LineWidth', 2);

% Diagonal (y = x) for visual reference (no legend)
plot([0 6], [0 6], 'k--', 'LineWidth', 1.2, 'HandleVisibility','off');

% Mark equal rate point
if ~isempty(eq_pt)
    plot(eq_pt(1), eq_pt(2), 'ms', 'MarkerSize', 10, 'LineWidth', 2);
    text(eq_pt(1)+0.1, eq_pt(2), sprintf('Equal (%.2f, %.2f)', eq_pt(1), eq_pt(2)), ...
        'Color', 'm', 'FontSize', 10);
else
    disp('No equal point found on convex hull.');
end

xlabel('R_0/B (bps/Hz)');
ylabel('R_1/B (bps/Hz)');
title('BC Capacity Region with Equal Spectral Efficiency Point');
axis([0 4 0 6]); axis square;
legend('Region', 'Convex Hull', 'Equal Point', 'Location', 'SouthWest');

% Save EPS
print('-depsc2', 'fig/hw8_36_c.eps');
