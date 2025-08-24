clear; clc; close all;

% === Parameters ===
target_P_dB = 40;                    % Fixed TX power (dB)
P_tx = 10^(target_P_dB / 10);        % Linear scale
Niter = 500;                         % Large-scale fading iterations
alpha = 4;                           % Pathloss exponent
sigma_ind = 8;                       % Shadowing std-dev (dB)
Users = 10;                           % Number of users
Np_U_values = [1, 3, 7];             % Pilot-to-user ratio cases
colors = {'b', 'r', 'g'};            % Plot colors
r_min = 200;       
r_max = 1500;       
radius = sqrt(rand(Users,1)*(r_max^2 - r_min^2) + r_min^2);

figure; hold on;

for idx = 1:length(Np_U_values)
    pilot_reuse_factor = Np_U_values(idx);
    all_SIR_u = [];

    for iter = 1:Niter
        % === Generate user positions in hexagonal cell (central cell assumed unit radius) ===
        theta = 2 * pi * rand(Users, 1);
        radius = 2000 * sqrt(rand(Users, 1));         % uniform in area, max radius = 2 km
        x = radius .* cos(theta);
        y = radius .* sin(theta);
        d = sqrt(x.^2 + y.^2);                 % distance to central BS

        % === Large-scale fading beta: pathloss + shadowing ===
        z = 10.^((randn(Users, 1) * sigma_ind / 10));  % shadowing (linear scale)
        beta = z ./ (d.^alpha);                        % beta_jk = z_jk / r_jk^alpha

        txP = ones(Users, 1) * (P_tx / Users);  % uniform DL power allocation

        % === SIR Calculation ===
        for u = 1:Users
            signal_power = txP(u) * beta(u)^2;

            % === Add pilot contamination penalty to interference ===
            beta_interf = beta([1:u-1,u+1:end])./ pilot_reuse_factor;
            txP_interf = txP([1:u-1,u+1:end]);
            interf_power = sum(txP_interf .* (beta_interf.^2));

            SIR_u = signal_power / interf_power;
            all_SIR_u = [all_SIR_u; SIR_u];
        end
    end

    % === CDF Calculation ===
    SIR_dB = 10 * log10(all_SIR_u);
    [F, X] = ecdf(SIR_dB);
    plot(X, F, 'LineWidth', 2, 'DisplayName', ['N_P/U = ' num2str(pilot_reuse_factor)], 'Color', colors{idx});
end

% === Final plot settings ===
grid on;
xlabel('Average user SIR (dB)');
ylabel('CDF');
title('CDF of average user SIR for different pilot reuse factors');
legend('Location', 'southeast');
xlim([-100 60]);

% Save EPS
print ('-depsc2', 'hw8_10_42 .eps');