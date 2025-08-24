% Solve ln(x) = 1 + 9/x using fzero

f = @(x) log(x) - (1 + 9./x);  % Define the function
x_guess = 8;                   % Initial guess near expected root

x_sol = fzero(f, x_guess);     % Solve for root

% Display result
fprintf('Solution x ≈ %.4f\n', x_sol);

% Plot to visualize
x_vals = linspace(5, 12, 500);
y_vals = f(x_vals);

figure;
plot(x_vals, y_vals, 'b', 'LineWidth', 2); hold on;
yline(0, '--k');
xline(x_sol, '--r', sprintf('x ≈ %.4f', x_sol));
xlabel('x'); ylabel('f(x)');
title('Solving ln(x) = 1 + 9/x');
grid on; legend('f(x)', 'y = 0', 'Root');
