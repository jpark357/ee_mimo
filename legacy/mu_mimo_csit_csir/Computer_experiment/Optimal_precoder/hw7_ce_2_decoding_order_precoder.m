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

% === Run iterative waterfilling once for full user set ===
[~, Cov] = iterative_waterfill(H_all, P, 100);

% Normalize Frobenius norm to Nt^2
for k = 1:U
    Q = Cov(:,:,k);
    norm_sq = norm(Q, 'fro')^2;
    if norm_sq > 0
        Cov(:,:,k) = Q * sqrt(Nt^2 / norm_sq);
    end
end

% === All decoding orders ===
orders = perms(1:U);
fprintf('Decoding Order |    R0    |    R1    |    R2    |  Sum Rate\n');
fprintf('----------------------------------------------------------\n');

I = eye(Nr);
H = {H1, H2, H3};

for k = 1:size(orders, 1)
    decode_order = orders(k, :);
    Ru = zeros(1, U);

    for idx = 1:U
        u = decode_order(idx);
        A = I;
        B = I;

        for j = idx:U
            v = decode_order(j);
            Hv = H{v};
            Qv = Cov(:,:,v);
            A = A + (snr_lin(v)/Nt) * Hv * Qv * Hv';
        end

        for j = idx+1:U
            v = decode_order(j);
            Hv = H{v};
            Qv = Cov(:,:,v);
            B = B + (snr_lin(v)/Nt) * Hv * Qv * Hv';
        end

        Ru(u) = real(log2(det(A)) - log2(det(B)));
    end

    fprintf('   [%d %d %d]     |  %5.2f  |  %5.2f  |  %5.2f  |   %5.2f\n', ...
        decode_order, Ru(1), Ru(2), Ru(3), sum(Ru));
end
