clear; clc;

% === Channel matrices (fixed) ===
H1 = [1, 0.25*exp(1j*pi/3);
      0.5*exp(-1j*pi/2), 1];
H2 = [0.3*exp(1j*pi/4),   0.6*exp(1j*pi/3);
      0.6*exp(1j*2*pi/3), 0.8*exp(1j*pi/4)];
H3 = [exp(1j*pi/4),       1.25*exp(-1j*pi/4);
      0.95*exp(1j*pi/3),  1.1*exp(1j*2*pi/5)];

% === SNRs ===
snr_db = [10, 5, 2];                     % in dB
snr_lin = 10.^(snr_db / 10);            % linear scale
Nt = 2; Nr = 2;
I = eye(Nr);
U = 3;

% === Channel cell array ===
H = {H1, H2, H3};

% === All decoding orders (6 permutations) ===
orders = perms(1:3);

fprintf('Decoding Order |    R0    |    R1    |    R2    |  Sum Rate\n');
fprintf('----------------------------------------------------------\n');

for k = 1:size(orders, 1)
    decode_order = orders(k, :);
    Ru = zeros(1, U);
    for idx = 1:U
        u = decode_order(idx);
        A = I;
        B = I;

        % === Numerator ===
        for v = idx:U
            v_idx = decode_order(v);
            snr_v = snr_lin(v_idx);
            Hv = H{v_idx};
            A = A + (snr_v / Nt) * (Hv * Hv');
        end

        % === Denominator ===
        for v = idx+1:U
            v_idx = decode_order(v);
            snr_v = snr_lin(v_idx);
            Hv = H{v_idx};
            B = B + (snr_v / Nt) * (Hv * Hv');
        end

        % === Rate computation ===
        Ru(u) = real(log2(det(A)) - log2(det(B)));
    end

    % === Print ===
    fprintf('   [%d %d %d]     |  %5.2f  |  %5.2f  |  %5.2f  |   %5.2f\n', ...
        decode_order, Ru(1), Ru(2), Ru(3), sum(Ru));
end
