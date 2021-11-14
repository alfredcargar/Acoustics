pkg load signal
addpath("../utilities");

% x = signal
% fs = sample rate
[x,fs] = audioread('../sounds/sample.wav');
x = x(:,1);
fs = 44100;
dt = 1/fs;

% ----------------------parallel comb filters section---------------------------------%
% delays must be spread over a range 1:1.5
% around 30ms-45ms
% gains can't exceed .85
% gains should be adjusted according to the formula:
%     T = 3*(delay(n))/(-log |g(n)| )
% where T is the desired reverberation time
% |g(n)| = 10^(-3*delay(n)/T)
% k = samples delayed; has to be a prime number
% g = gain
% A = feedback vector
% B = feedforward vector

CF_k(1) = primes(mstosmp(30,fs))(end);
CF_k(2) = primes(mstosmp(34,fs))(end);
CF_k(3) = primes(mstosmp(39,fs))(end);
CF_k(4) = primes(mstosmp(42,fs))(end);
CF_g(1) = abs(10^(-3*30/1200));
CF_g(2) = abs(10^(-3*34/1200));
CF_g(3) = abs(10^(-3*39/1200));
CF_g(4) = abs(10^(-3*42/1200));

%comb1
A1 = zeros(CF_k(1),1); 
A1(1) = 1; 
A1(end) = -CF_g(1);
B1 = [1];
comb1 = filter(B1, A1, x);

%comb2
A2 = zeros(CF_k(2),1); 
A2(1) = 1; 
A2(end) = -CF_g(2);
B2 = [1];
comb2 = filter(B2, A2, x);

%comb3
A3 = zeros(CF_k(3),1); 
A3(1) = 1; 
A3(end) = -CF_g(3);
B3 = [1];
comb3 = filter(B3, A3, x);

%comb4
A4 = zeros(CF_k(4),1); 
A4(1) = 1; 
A4(end) = -CF_g(4);
B4 = [1];
comb4 = filter(B4, A4, x);

y1 = comb1 + comb2 + comb3 + comb4;

%---------------------- cascade allpass section ------------------------------%
%
% Here the output of the comb section is passed through the allpass filters in
% cascade. 
% H = (g + z^-M) / (1 + gz^-M)
% y(n) = x(n) + gx(n-k) - gy(n-k)
%
% good choices for the allpass delays 1 and 2 are respectively 5 and 1.7 ms
% their gains are most conveniently made to 0.7

AP_g = [0.7 0.7];
AP_k = [primes(mstosmp(5, fs))(end), primes(mstosmp(1.7, fs))(end)];

%allpass 1
ap_fb = zeros(AP_k(1),1); 
ap_fb(1) = 1; ap_fb(end) = -AP_g(1);
ap_ff = flipud(ap_fb);
allpass1 = filter(ap_ff, ap_fb, y1);

%allpass 2
ap_fb2 = zeros(AP_k(2),1);
ap_fb2(1) = 1; ap_fb2(end) = -AP_g(2);
ap_ff2 = flipud(ap_fb2);
allpass2 = filter(ap_ff2, ap_fb2, allpass1);


%The final gain determines the amount of reverberation mixed with the original signal
% this simulates proximity of the source

G = 0.8;
output = G * allpass2 + x;

# plays the output
%sound(output, fs);

figure(1)
plot(x)
title('Original signal',"fontsize",14)
xlabel('n samples',"fontsize",14)
ylabel('x[n]',"fontsize",14)
%print -dpng ~/Tesis/Pictures/sch1.png
figure(2)
plot(output)
title('Output',"fontsize",14)
xlabel('n samples',"fontsize",14)
ylabel('x[n]',"fontsize",14)
%print -dpng ~/Tesis/Pictures/sch2.png



