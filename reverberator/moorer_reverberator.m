pkg load signal;
addpath('../utilities');

[x,fs] = audioread('C:\Users\alfre\Tesis\Samples\piano-lid.wav');
x = x(:,1);

%lowpass filter 
%lowpass gain < 1-comb gain 
lpG = 0.4;
lpB = 1-lpG;
lpA = zeros(301,1); lpA(1) = 1; lpA(end) = -lpG;

CF_g = [.41 .43 .45 .47 .48 .5];
CF_k(1) = primes(mstosmp(50,fs))(end); CF_k(2) = primes(mstosmp(56,fs))(end);
CF_k(3) = primes(mstosmp(61,fs))(end); CF_k(4) = primes(mstosmp(68,fs))(end);
CF_k(5) = primes(mstosmp(72,fs))(end); CF_k(6) = primes(mstosmp(78,fs))(end);

A1 = zeros(CF_k(1),1); A1(1) = 1; A1(end) = -CF_g(1);
B1 = 1;
comb1 = filter(B1,filter(lpB,lpA,A1),x);  %implement LP inside fb loop
A2 = zeros(CF_k(2),1); A2(1) = 1; A2(end) = -CF_g(2);
B2 = 1;
comb2 = filter(B2,filter(lpB,lpA,A2),x); 
A3 = zeros(CF_k(3),1); A3(1) = 1; A3(end) = -CF_g(3);
B3 = 1;
comb3 = filter(B3,filter(lpB,lpA,A3),x); 
A4 = zeros(CF_k(4),1); A4(1) = 1; A4(end) = -CF_g(4);
B4 = 1;
comb4 = filter(B4,filter(lpB,lpA,A4),x); 
A5 = zeros(CF_k(5),1); A5(1) = 1; A5(end) = -CF_g(5);
B5 = 1;
comb5 = filter(B5,filter(lpB,lpA,A5),x); 
A6 = zeros(CF_k(6),1); A6(1) = 1; A6(end) = -CF_g(6);
B6 = 1;
comb6 = filter(B6,filter(lpB,lpA,A6),x); 

y = comb1+comb2+comb3+comb4+comb5+comb6;

apG = 0.7;
apK = primes(mstosmp(6,fs))(end);
apA = zeros(apK,1); apA(1) = 1; apA(end) = -apG;
apB = flip(apA);
allpass = filter(apB,apA,y);
G = 0.2;
yy = G*allpass + x;


%sound(x,fs);
sound(yy,fs);
%figure(1) 
%plot(x)
%axis([0 length(x)])
%title('Original signal', 'fontsize',16)
%xlabel('n samples','fontsize',14)
%ylabel('x[n]','fontsize',14)
%print -dpng ~/Tesis/Pictures/moorerx.png
%figure(2) 
%plot(yy)
%title('Output signal','fontsize',16)
%xlabel('n samples','fontsize',14)
%ylabel('y[n]','fontsize',14)
%axis([0 length(yy)])
%print -dpng ~/Tesis/Pictures/moorery.png
