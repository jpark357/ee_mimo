% Waterfilling Example 4.16 in MATLAB
clear; clc;

% Parameters
SNR_dB = 6;
SNR = 10^(SNR_dB / 10);
h_gain = [0.5, 0.4, 0.1];  % |h[k]|^2 k=0,1,2 (3 SISO subchannel)
K= size(h_gain,2);

%% Water-filling fuction
P_opt = water_filling_ofdm(SNR, h_gain);

% %K = length(h_gain);
% K= size(H_gain,1);
% 
% % Step 1: Define inverse channel gains
% inv_gain = 1 ./ (SNR * H_gain);
% 
% % Step 2: Sort the inverse gains (ascending) to apply waterfilling 
% % (channel gain descending)
% [inv_gain_sorted, idx] = sort(inv_gain);
% P_sorted = zeros(1, K);
% 
% % Step 3: Find water level η satisfying the power constraint
% found = false;
% for m = K:-1:1
%     inv_eta_candidate = (K + sum(inv_gain_sorted(1:m)))/m;
%     eta_candidate = 1/inv_eta_candidate
% 
%     P_temp = inv_eta_candidate - inv_gain_sorted(1:m);
% 
%     if all(P_temp >= 0)
%         P_sorted(1:m) = P_temp;
%         found = true;
%         break;
%     end
%         fprintf("%d trial, eta: %f Power: %s\n", K-m+1, eta_candidate, mat2str(P_temp, 4));
% end
% 
% 
% 
% if ~found
%     error('No feasible water level found.');
% end
% 
% % Step 4: Reorder power allocations to original subchannel order
% P_opt = zeros(1, K);
% P_opt(idx) = P_sorted;


%%

% Step 5: Display Results
disp('Optimal Power Allocation P*[k]:');
disp(P_opt);

% Step 6: Spectral Efficiency Calculation
capacity = mean(log2(1 + SNR * h_gain .* P_opt));
fprintf('Spectral Efficiency: %.4f b/s/Hz\n', capacity);

% Step 7: Histogram of Power Allocation
figure;
bar(0:K-1, P_opt, 0.6, 'FaceColor', [0.2 0.6 1]);  % bar
xlabel('Subchannel Index k');
ylabel('Allocated Power P^*[k]');
title('Histogram of Waterfilling Power Allocation');
grid on;