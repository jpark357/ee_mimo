clc; clear all; close all;
% Define SNR
SNR = 10;

% Precompute common terms
term1 = (1 + sqrt(1 + 4*SNR)) / 2;
log2_term1 = log2(term1);
sqrt_term = sqrt(1 + 4*SNR) - 1;

% Numerator
numerator = log2_term1;

% Denominator
denominator = 2 * log2_term1 - (log2(exp(1)) / (4 * SNR)) * (sqrt_term)^2;

% Final expression
result = numerator / denominator;

% Display the result
fprintf('Result at SNR = 10: %.6f\n', result);
