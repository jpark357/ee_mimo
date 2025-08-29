function P_opt = water_filling_ofdm(SNR, h_gain)

N_sc= size(h_gain,2);
% Step 1: Define inverse channel gains
inv_gain = 1 ./ (SNR * h_gain);

% Step 2: Sort the inverse gains (ascending) to apply waterfilling 
% (channel gain descending)
[inv_gain_sorted, idx] = sort(inv_gain);
P_sorted = zeros(1, N_sc);

% Step 3: Find water level η satisfying the power constraint
found = false;
for m = N_sc:-1:1
    inv_eta_candidate = (N_sc + sum(inv_gain_sorted(1:m)))/m;
    eta_candidate = 1/inv_eta_candidate

    P_temp = inv_eta_candidate - inv_gain_sorted(1:m);

    if all(P_temp >= 0)
        P_sorted(1:m) = P_temp;
        found = true;
        break;
    end
        fprintf("%d trial, eta: %f Power: %s\n", N_sc-m+1, eta_candidate, mat2str(P_temp, 4));
end
    


if ~found
    error('No feasible water level found.');
end

% Step 4: Reorder power allocations to original subchannel order
P_opt = zeros(1, N_sc);
P_opt(idx) = P_sorted;
