%sweep sine function
pkg load signal
f0 = 20; f1 = 20480;
t1 = 1;
Fs = 44100;  
dt = 1/Fs;                       
x = chirp([0:dt:t1], f0, t1, f1);     # freq. sweep from f0-f1 over t1 sec.
step=ceil(20*Fs/1000);                # one spectral slice every 20 ms
window=ceil(100*Fs/1000);             # 100 ms data window

specgram(x, 2^nextpow2(window), Fs, window, window-step);
%sound(x)
