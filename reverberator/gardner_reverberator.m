pkg load signal
addpath('../utilities');

%CONSTANTS T=room temperature; C=speed of sound; fs=sample rate; x=input
T = 20;
C = 331.6 +0.6*T;
fs = 44100;
dt = 1/fs;
N = 1000;

% x = impulse signal
x = zeros(N,1); 
x(N/10) = 1;

totDelay = 8;
ap_fb = zeros(8,1); ap_fb(1) = 1; ap_fb(end) = 0.3;
ap_ff = flipud(ap_fb);
allpass1 = filter(ap_ff,ap_fb,x);
totDelay = totDelay + 12 + 4;
ap_fb2 = zeros(12,1); ap_fb2(1) = 1; ap_fb2(end) = 0.3;
ap_ff2 = flipud(ap_fb2);
allpass2 = filter(ap_ff2,ap_fb2,allpass1);
output1 = [zeros(4,1);allpass2];
totDelay = totDelay+104;
ap_fb3 = zeros(104,1); ap_fb3(1) = 1; ap_fb3(end) = 0.5;
ap_ff3 = flipud(ap_fb3);
%inner filter 3(1)
totDelay = totDelay +62 +31;
ap_fb31 = zeros(62,1); ap_fb31(1) = 1; ap_fb31(end) = 0.25;
ap_ff31 = flipud(ap_fb31);
allpass3 = filter(ap_ff3,ap_fb3,filter(ap_ff31,ap_fb31,output1));
output2 = [zeros(31,1);allpass3];
totDelay = totDelay + 123;
ap_fb4 = zeros(123,1); ap_fb4(1) = 1; ap_fb4(end) = 0.5;
ap_ff4 = flipud(ap_fb4);
%inner filter 4(1)
totDelay = totDelay + 76;
ap_fb41 = zeros(76,1); ap_fb41(1) = 1; ap_fb41(end) = 0.25;
ap_ff41 = flipud(ap_fb41);
%inner filter4(2)
totDelay = totDelay + 30;
ap_fb42 = zeros(30,1); ap_fb42(1) = 1; ap_fb42(end) = 0.25;
ap_ff42 = flipud(ap_fb42);
ap4_in = filter(ap_ff42,ap_fb42,filter(ap_ff41,ap_fb41,output2));
allpass4 = filter(ap_ff4,ap_fb4,ap4_in);

%lowpass filter for modelling air absorption
t = smptoms(totDelay,fs)/1000;
d = C*t;   %distance of air propagation
fc = 2000^(log2(d/75));
w = fc/fs;
b = fir1(2,w,'low');
a = [1];
lp = filter(b,a,allpass4); lp(1) = 1;

y = filter(allpass4,lp,x);

plot(y)


