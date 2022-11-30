clear all;
addpath('../utilities');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[x,fs] = audioread('../sounds/sample.wav');
x = x(:,1);

D = [7,3];            %room dimensions 
S = [3,2];            %source position
L = [D(1)/2,D(2)/2];  %listener position
T = 20;               %room temperature °C
c = 331.4 + 0.6*T;    %speed of sound
hd = .17;             %head diamater [m]
rhd = hd/2;
Sg = 1.;              %Source amplitude
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%angle of incidence to the listener is given by 
% atan(y/x), will be used to determine ITD around the head
% y = abs(S(y)-L(y))
% x = abs(S(x)-L(x))
deltay = abs(S(2)-L(2));
deltax = abs(S(1)-L(1));
theta = atan(deltay/deltax);
theta_deg = theta*180/pi;

%first compute the 4 first order virtual sources coordinates
fo = ISM1(S,D);
%get the distance between each point and the listener
d1 = dpoints(fo(1,:),L);
d2 = dpoints(fo(2,:),L);
d3 = dpoints(fo(3,:),L);
d4 = dpoints(fo(4,:),L);
%now the delay times for the combs (in ms)
del1 = soundtime(fo(1,:),L,T)*1e3;
del2 = soundtime(fo(2,:),L,T)*1e3;
del3 = soundtime(fo(3,:),L,T)*1e3;
del4 = soundtime(fo(4,:),L,T)*1e3;

%compute theta for each virtual source
deltay1 = abs(fo(1,2)-L(2));
deltax1 = abs(fo(1,1)-L(1));
theta1 = atan(deltay1/deltax1);
theta_deg1 = theta1*180/pi;

deltay2 = abs(fo(2,2)-L(2));
deltax2 = abs(fo(2,1)-L(1));
theta2 = atan(deltay2/deltax2);
theta_deg2 = theta2*180/pi;

deltay3 = abs(fo(3,2)-L(2));
deltax3 = abs(fo(3,1)-L(1));
theta3 = atan(deltay3/deltax3);
theta_deg3 = theta3*180/pi;

deltay4 = abs(fo(4,2)-L(2));
deltax4 = abs(fo(4,1)-L(1));
theta4 = atan(deltay4/deltax4);
theta_deg4 = theta4*180/pi;

%lowpass filter 
%lowpass gain < 1-comb gain 
lpG = 0.4;
lpB = 1-lpG;
lpA = zeros(301,1); lpA(1) = 1; lpA(end) = -lpG;

CF_g = [Sg/d1 Sg/d2 Sg/d3 Sg/d4];
CF_k(1) = primes(mstosmp(del1,fs))(end); CF_k(2) = primes(mstosmp(del2,fs))(end);
CF_k(3) = primes(mstosmp(del3,fs))(end); CF_k(4) = primes(mstosmp(del4,fs))(end);

A1 = zeros(CF_k(1),1); A1(1) = 1; A1(end) = -CF_g(1);
B1 = 1;
comb1 = filter(B1,filter(lpB,lpA,A1),x);              %implement LP inside fb loop
A2 = zeros(CF_k(2),1); A2(1) = 1; A2(end) = -CF_g(2);
B2 = 1;
comb2 = filter(B2,filter(lpB,lpA,A2),x); 
A3 = zeros(CF_k(3),1); A3(1) = 1; A3(end) = -CF_g(3);
B3 = 1;
comb3 = filter(B3,filter(lpB,lpA,A3),x); 
A4 = zeros(CF_k(4),1); A4(1) = 1; A4(end) = -CF_g(4);
B4 = 1;
comb4 = filter(B4,filter(lpB,lpA,A4),x); 

%final output 
%if we consider the listener facing the upper wall, and assign to the walls UP,DOWN,LEFT,RIGHT respectively
%the indexes 1 2 3 4, then the left channel is the sum of the direct sound and the reflections coming from the
%left side and those from the right side + the time difference due to the head, and viceversa for
%the right channel

direct_delay = (rhd*sin(theta_deg)+rhd*theta_deg)/c*1e3;
direct_delay = mstosmp(direct_delay,fs);
vs1_delay = (rhd*sin(theta_deg1)+rhd*theta_deg1)/c*1e3;
vs1_delay = mstosmp(vs1_delay,fs);
vs2_delay = (rhd*sin(theta_deg2)+rhd*theta_deg2)/c*1e3;
vs2_delay = mstosmp(vs2_delay,fs);
vs3_delay = (rhd*sin(theta_deg3)+rhd*theta_deg3)/c*1e3;
vs3_delay = mstosmp(vs3_delay,fs);
vs4_delay = (rhd*sin(theta_deg4)+rhd*theta_deg4)/c*1e3;
vs4_delay = mstosmp(vs4_delay,fs);

left_channel = x+comb1+comb2+comb3+[zeros(vs4_delay,1);comb4(1:length(comb4)-vs4_delay)];
right_channel = [zeros(direct_delay,1);x(1:length(x)-direct_delay)] + ...
                [zeros(vs1_delay,1);comb1(1:length(comb1)-vs1_delay)] + ...
                [zeros(vs2_delay,1);comb2(1:length(comb2)-vs2_delay)] + ...
                [zeros(vs3_delay,1);comb3(1:length(comb3)-vs3_delay)] + comb4;

%allpass filter 
apG = 0.7;
apK = primes(mstosmp(6,fs))(end);
apA = zeros(apK,1); apA(1) = 1; apA(end) = -apG;
apB = flip(apA);
allpass_left = filter(apB,apA,left_channel);
allpass_right = filter(apB,apA,right_channel);

y = [allpass_left,allpass_right];

%verify using a single impulse difference and all, plots etc. using a 1

%sound(y,fs)
figure(1) 
plot(x)
axis([0 length(x)])
title('Original signal', 'fontsize',16)
xlabel('n samples','fontsize',14)
ylabel('x[n]','fontsize',14)

figure(2) 
plot(y)
title('Output signal','fontsize',16)
xlabel('n samples','fontsize',14)
ylabel('y[n]','fontsize',14)
axis([0 length(y)])

