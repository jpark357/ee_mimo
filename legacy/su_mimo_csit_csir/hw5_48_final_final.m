clear; clc; close all;

% Parameters
Nt = 2; Nr = 2;
snr_dB = -5:1:20;
snr = 10.^(snr_dB / 10);
n_iter = 10000;

% Correlation matrices
Rt = [1 0.6; 0.6 1];
Rr = [1 0.4; 0.4 1];
R_kron = kron(Rt.', Rr);
    
alpha = 0.002;         % Pilot overhead
Nc = 100000;            % Coherence block length


C_iid_indep = zeros(size(snr));
C_corr_indep = zeros(size(snr));
C_iid_joint = zeros(size(snr));
C_corr_joint = zeros(size(snr));

for i = 1:length(snr)
    cap_iid_indep = 0; cap_corr_indep = 0;
    cap_iid_joint = 0; cap_corr_joint = 0;

    % MMSE + SNR_eff
    MMSE = 1 ./ (1 + (alpha * Nc / Nt) * snr(i));
    SNR_eff = snr(i) * (1 - MMSE) ./ (1 + snr(i) * MMSE);

    for k = 1:n_iter
        % -------- Shared channel realization --------
        H_base = (randn(Nr,Nt) + 1j * randn(Nr,Nt)) / sqrt(2);
        H_iid = H_base;
        H_corr = sqrtm(Rr) * H_base * sqrtm(Rt);

        % -------- Independent LMMSE (SNR_eff) --------
        cap_iid_indep  = cap_iid_indep  + (1 - alpha) * real(log2(det(eye(Nr) + (SNR_eff / Nt) * H_iid  * H_iid')));
        cap_corr_indep = cap_corr_indep + (1 - alpha) * real(log2(det(eye(Nr) + (SNR_eff / Nt) * H_corr * H_corr')));

        % -------- Joint LMMSE (same channel base) --------
        h_base = reshape(H_base, [], 1);
        H_iid_joint  = reshape(h_base, Nr, Nt);
        H_corr_joint = reshape(sqrtm(R_kron) * h_base, Nr, Nt);
        cap_iid_joint  = cap_iid_joint  + (1 - alpha) * real(log2(det(eye(Nr) + (SNR_eff / Nt) * H_iid_joint  * H_iid_joint')));
        cap_corr_joint = cap_corr_joint + (1 - alpha) * real(log2(det(eye(Nr) + (SNR_eff / Nt) * H_corr_joint * H_corr_joint')));
    end

    C_iid_indep(i) = cap_iid_indep / n_iter;
    C_corr_indep(i) = cap_corr_indep / n_iter;
    C_iid_joint(i) = cap_iid_joint / n_iter;
    C_corr_joint(i) = cap_corr_joint / n_iter;
end

% Indices
idx_0dB = find(snr_dB == 0);
idx_10dB = find(snr_dB == 10);

% Reduction
reduction0_indep = 100 * (C_iid_indep(idx_0dB) - C_corr_indep(idx_0dB)) / C_iid_indep(idx_0dB);
reduction10_indep = 100 * (C_iid_indep(idx_10dB) - C_corr_indep(idx_10dB)) / C_iid_indep(idx_10dB);

reduction0_joint = 100 * (C_iid_joint(idx_0dB) - C_corr_joint(idx_0dB)) / C_iid_joint(idx_0dB);
reduction10_joint = 100 * (C_iid_joint(idx_10dB) - C_corr_joint(idx_10dB)) / C_iid_joint(idx_10dB);

%% --------- Figure 1: Independent LMMSE (Correlation) ---------
figure(1);
h1 = plot(snr_dB, C_iid_indep, 'b-', 'LineWidth', 2); hold on;
h2 = plot(snr_dB, C_corr_indep, 'r--', 'LineWidth', 2);
xlabel('SNR (dB)');
ylabel('Spectral Efficiency [bps/Hz]');
title('Independent LMMSE: Correlation vs No Correlation');

grid on;

% Markers and text
plot(snr_dB(idx_0dB), C_iid_indep(idx_0dB), 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b');
plot(snr_dB(idx_0dB), C_corr_indep(idx_0dB), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
text(snr_dB(idx_0dB)+0.5, C_iid_indep(idx_0dB)+1.5, sprintf('%.2f bps/Hz', C_iid_indep(idx_0dB)));
text(snr_dB(idx_0dB)+0.5, C_corr_indep(idx_0dB), ...
     sprintf('%.2f bps/Hz\n(↓%.2f%%)', C_corr_indep(idx_0dB), reduction0_indep));

plot(snr_dB(idx_10dB), C_iid_indep(idx_10dB), 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b');
plot(snr_dB(idx_10dB), C_corr_indep(idx_10dB), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
text(snr_dB(idx_10dB)+0.5, C_iid_indep(idx_10dB)+1.5, sprintf('%.2f bps/Hz', C_iid_indep(idx_10dB)));
text(snr_dB(idx_10dB)+0.5, C_corr_indep(idx_10dB), ...
     sprintf('%.2f bps/Hz\n(↓%.2f%%)', C_corr_indep(idx_10dB), reduction10_indep));
legend([h1, h2], {'No Correlation', 'With Correlation'}, 'Location', 'SouthEast');
print(gcf, '5_48_ac', '-depsc2');

%% --------- Figure 2: Joint LMMSE (Correlation) ---------
figure(2);
h3 = plot(snr_dB, C_iid_joint, 'b-', 'LineWidth', 2); hold on;
h4 = plot(snr_dB, C_corr_joint, 'r--', 'LineWidth', 2);
xlabel('SNR (dB)');
ylabel('Spectral Efficiency [bps/Hz]');
title('Joint LMMSE: Correlation vs No Correlation');

grid on;

% Markers and text
plot(snr_dB(idx_0dB), C_iid_joint(idx_0dB), 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b');
plot(snr_dB(idx_0dB), C_corr_joint(idx_0dB), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
text(snr_dB(idx_0dB)+0.5, C_iid_joint(idx_0dB)+1.5, sprintf('%.2f bps/Hz', C_iid_joint(idx_0dB)));
text(snr_dB(idx_0dB)+0.5, C_corr_joint(idx_0dB), ...
     sprintf('%.2f bps/Hz\n(↓%.2f%%)', C_corr_joint(idx_0dB), reduction0_joint));

plot(snr_dB(idx_10dB), C_iid_joint(idx_10dB), 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b');
plot(snr_dB(idx_10dB), C_corr_joint(idx_10dB), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
text(snr_dB(idx_10dB)+0.5, C_iid_joint(idx_10dB)+1.5, sprintf('%.2f bps/Hz', C_iid_joint(idx_10dB)));
text(snr_dB(idx_10dB)+0.5, C_corr_joint(idx_10dB), ...
     sprintf('%.2f bps/Hz\n(↓%.2f%%)', C_corr_joint(idx_10dB), reduction10_joint));
legend([h3, h4], {'No Correlation', 'With Correlation'}, 'Location', 'SouthEast');
print(gcf, '5_48_bc', '-depsc2');
