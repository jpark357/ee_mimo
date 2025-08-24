clear; clc; close all;

% === Channel Setup ===
Nt = 2; Nr = 2; U = 3;
H1 = [1, 0.25*exp(1j*pi/3);
      0.5*exp(-1j*pi/2), 1];
H2 = [0.3*exp(1j*pi/4),   0.6*exp(1j*pi/3);
      0.6*exp(1j*2*pi/3), 0.8*exp(1j*pi/4)];
H3 = [exp(1j*pi/4),       1.25*exp(-1j*pi/4);
      0.95*exp(1j*pi/3),  1.1*exp(1j*2*pi/5)];
H_all = cat(3, H1, H2, H3);

snr_db = [10, 5, 2];                    
snr_lin_full = 10.^(snr_db / 10);            
P = Nt;           % total power constraint for MAC

% === Define all subsets of users (1-based indexing) ===
subsets = { [1], [2], [3], ...
            [1 2], [2 3], [1 3], ...
            [1 2 3] };
subset_labels = { '1', '2', '3', '1,2', '2,3', '1,3', '1,2,3' };

% === Store results ===
subset_rate_bound = zeros(length(subsets), 1);

% === Loop through each subset ===
for i = 1:length(subsets)
    U_set = subsets{i};
    num_users = length(U_set);

    % Extract user-specific channels and SNRs for this subset
    H_sub = zeros(Nr, Nt, num_users);
    snr_lin = zeros(1, num_users);
    for k = 1:num_users
        H_sub(:,:,k) = H_all(:,:,U_set(k));
        snr_lin(k) = snr_lin_full(U_set(k));
    end

    % === Run Iterative Waterfilling for the subset ===
    [~, Cov] = iterative_waterfill(H_sub, P, 100);
    for k = 1:num_users
        Q = Cov(:,:,k);
        norm_sq = norm(Q, 'fro')^2;
        if norm_sq > 0
            Cov(:,:,k) = Q * sqrt(Nt^2 / norm_sq);
        else
            warning('Covariance matrix for user %d in subset {%s} is all-zero.', k, subset_labels{i});
        end
    end
    
    % === Compute log2 det RHS of (8.18) ===
    Sig = eye(Nr);
    for k = 1:num_users
        Sig = Sig + (snr_lin(k)/Nt) * H_sub(:,:,k) * Cov(:,:,k)* H_sub(:,:,k)';
    end
    d = det(Sig);
    subset_rate_bound(i) = real(log2(max(eps, d))); % Upper bound on sum of Ru in this subset
end

% === Display results ===
fprintf('--- Capacity Bound for Each Subset (Eq. 8.18 with iterative waterfilling) ---\n');
for i = 1:length(subsets)
    fprintf('Subset {%s}:  Bound = %.4f bps/Hz\n', subset_labels{i}, subset_rate_bound(i));
end
