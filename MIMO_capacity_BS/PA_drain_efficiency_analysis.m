%% PA Input–Output Characteristics (Linear X-axis)
clear; clc; close all;

%% Parameters
gain_dB = 45;              % PA small-signal gain (dB)
gain_lin = 10^(gain_dB/10);% Linear gain
P_sat_W = 70;              % Saturation output power (W)
P_DC_const = 100;          % DC consumed power (W)

%% Input power sweep (RF input in mW, linear scale)
P_in_mW = linspace(0,20,300);   % 0 ~ 100 mW
P_in_W  = P_in_mW * 1e-3;        % Convert to W

%% Output power calculation
P_out_lin_W = P_in_W * gain_lin;           % Ideal linear output
P_out_W = min(P_out_lin_W, P_sat_W);       % Apply saturation

%% Drain efficiency
eta = P_out_W ./ P_DC_const;

%% Plot
figure('Color','w');
yyaxis left
plot(P_in_mW, P_out_W,'b-','LineWidth',2); hold on;
yline(P_DC_const,'g--','LineWidth',2);
ylabel('RF Output Power (W)');
xlabel('RF Input Power (mW)');
title('PA Input–Output Characteristics (Linear Scale)');

grid on;

yyaxis right
plot(P_in_mW, eta,'r-.','LineWidth',2);
legend('RF Output Power','DC Power Consumed','Drain Efficiency','Location','southeast');
ylabel('Drain Efficiency');
