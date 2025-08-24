% LMMSE-SIC Capacity Simulation for 2x2 MIMO System

Nt = 2; % Number of transmit antennas
Nr = 2; % Number of receive antennas
SNR_dB = 10; % SNR in dB
SNR = 10^(SNR_dB/10);
num_iter = 1e5; % Number of iterations

capacity_optimal = zeros(num_iter,1);
capacity_common = zeros(num_iter,1);

for idx = 1:num_iter
    % Generate IID Rayleigh channel matrix
    H = (randn(Nr,Nt) + 1j*randn(Nr,Nt))/sqrt(2);
    
    % Optimal per-stream capacity
    capacity_optimal(idx) = real(log2(det(eye(Nr) + (SNR/Nt)*(H*H'))));
    
    % Common rate encoding with best decoding order
    h1 = H(:,1);
    h2 = H(:,2);
    
    % Decoding order: h1 then h2
    C1_first = real(log2(1 + h1' * ((2/SNR)*eye(Nr) + h2*h2')^-1 * h1));
    C1_second = real(log2(1 + (SNR/2)*norm(h2)^2));
    rate1 = 2 * min(C1_first, C1_second);
    
    % Decoding order: h2 then h1
    C2_first = real(log2(1 + h2' * ((2/SNR)*eye(Nr) + h1*h1')^-1 * h2));
    C2_second = real(log2(1 + (SNR/2)*norm(h1)^2));
    rate2 = 2 * min(C2_first, C2_second);
    
    % Select the better decoding order
    capacity_common(idx) = max(rate1, rate2);
end

% Compute average capacities
avg_capacity_optimal = mean(capacity_optimal);
avg_capacity_common = mean(capacity_common);
capacity_ratio = avg_capacity_common / avg_capacity_optimal;

% Display results
fprintf('Ergodic capaticy of an IID Rayleigh-faded channel: %.4f bps/Hz\n', avg_capacity_optimal);
fprintf('Achievable rate of the codewords using same rate encoder: %.4f bps/Hz\n', avg_capacity_common);
fprintf('Capacity Ratio: %.2f%%\n', capacity_ratio*100);
