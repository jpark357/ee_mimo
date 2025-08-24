clear; clc;

% === Channel Setup ===
Nt = 2; Nr = 2; U = 3;
H1 = [1, 0.25*exp(1j*pi/3);
      0.5*exp(-1j*pi/2), 1];
H2 = [0.3*exp(1j*pi/4), 0.6*exp(1j*pi/3);
      0.6*exp(1j*2*pi/3), 0.8*exp(1j*pi/4)];
H3 = [exp(1j*pi/4), 1.25*exp(-1j*pi/4);
      0.95*exp(1j*pi/3), 1.1*exp(1j*2*pi/5)];
H_all = cat(3, H1, H2, H3);

snr_db = [10, 5, 2];
snr_lin = 10.^(snr_db / 10);
P = Nt;

% === Run Iterative Waterfilling for the subset ===
[~, Cov_UL] = iterative_waterfill(H_all, P, 100);

%compute downlink covariance matrices
Cov_DL = MAC_to_BC(H_all, Cov_UL);

for k = 1:U
    Z = Cov_DL(:,:,k);
    norm_sq = norm(Z, 'fro')^2;
    if norm_sq > 0
        Cov_DL(:,:,k) = Z * sqrt(Nr^2 / norm_sq);
    else
         warning('Covariance matrix for user %d is all-zero.', k);
    end
end

% === All decoding orders ===
orders = perms(1:U);
fprintf('Decoding Order |    R0    |    R1    |    R2    |  Sum Rate\n');
fprintf('----------------------------------------------------------\n');

I = eye(Nr);
H = {H1, H2, H3};

for k = 1:size(orders, 1)
    encode_order = orders(k, :);
    Ru = zeros(1, U);

    for idx = 1:U
        u = encode_order(idx);
        A = I;
        B = I;

        for j = idx:U
            v = encode_order(j);
            Hv = H{v};
            Zv = Cov_DL(:,:,v);
            A = A + (snr_lin(v)/Nr) * (Hv') * Zv * Hv;
        end

        for j = idx+1:U
            v = encode_order(j);
            Hv = H{v};
            Zv = Cov_DL(:,:,v);
            B = B + (snr_lin(v)/Nr) * (Hv') * Zv * Hv;
        end

        Ru(u) = real(log2(det(A)) - log2(det(B)));
    end

    fprintf('   [%d %d %d]     |  %5.2f  |  %5.2f  |  %5.2f  |   %5.2f\n', ...
        encode_order, Ru(1), Ru(2), Ru(3), sum(Ru));
end
