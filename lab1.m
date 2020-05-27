%% Task 1 - generate time domain signals of notes
clear all; close all; clc
Fs=8e3;   %sample rate
L=0.5;  %duration of each note in seconds
f=[440 495 550 587 660 773 825];   %list of notes
count = Fs*L;   %sample count for one note
%4000 samples in one note

%generating individual notes
t=0:(1/Fs):((count/Fs)-(1/Fs));
notes=zeros(size(f,2),Fs*L);
for i=1:1:size(f,2)
    notes(i,:)=sin(2*pi*f(i)*t);
end
%{
do=sin(2*pi*f(1)*t);
re=sin(2*pi*f(2)*t);
mi=sin(2*pi*f(3)*t);
fa=sin(2*pi*f(4)*t);
sp=sin(2*pi*f(5)*t);
la=sin(2*pi*f(6)*t);
ti=sin(2*pi*f(7)*t);
%}

%writing to wav file
notes_str=['do'; 're'; 'mi'; 'fa'; 'so'; 'la'; 'ti'];   %notes_str(1,:)
wav='.wav';

for i=1:1:size(f,2)
    filename=[notes_str(i,:),wav];
    audiowrite(filename,notes(i,:),Fs);  %audiowrite(filename,signal,sample_rate);
end

%% Task 2 - generate time-frequency representation of signals
figure;
spectrogram(notes(1,:));    %'do'
title('Spectrogram of "do"');

figure;
mixed_signal=notes(1,:)+notes(2,:)+notes(3,:)+notes(4,:)+notes(5,:)+notes(6,:)+notes(7,:);
spectrogram(mixed_signal);  %'mixed signals'

figure;
concat_signal=[notes(1,:),notes(2,:),notes(3,:),notes(4,:),notes(5,:),notes(6,:),notes(7,:)];
spectrogram(concat_signal); %'concatenated signals'
title('Spectrogram of Notes in Melody');

%% Task 2 in time(s) and frequency(KHz) axis
figure;
spectrogram(concat_signal,440,120,440,Fs)
title('Spectrogram of Notes in Melody');
xlim([0 1.5]);
%% Task 3 - compose twinkle twinkle little star
clear all; close all; clc
Fs=8e3;   %sample rate
L=0.5;  %duration of each note in seconds
f_melody=[440 495 550 587 660 773 825 0];   %list of notes
f_chorus=[206 220 248 275 293 330 367];
count = Fs*L;   %sample count for one note

%generating notes =====
t=0:(1/Fs):((count/Fs)-(1/Fs));
notes_melody=zeros(size(f_melody,2),Fs*L);   %added row for nu
for i=1:1:size(f_melody,2)
    notes_melody(i,:)=sin(2*pi*f_melody(i)*t);
end
notes_chorus=zeros(size(f_chorus,2),Fs*L);
for i=1:1:size(f_chorus,2)
    notes_chorus(i,:)=sin(2*pi*f_chorus(i)*t);
end
%constructing song =====
%notes_melody=['do'; 're'; 'mi'; 'fa'; 'so'; 'la'; 'ti'; 'nu'];
song_melody=[1,8,1,8,5,8,5,8,6,8,6,8,5,8,8,8,4,8,4,8,3,8,3,8,2,8,2,8,1,8,8,8];
song_chorus=[1,5,3,5,1,5,3,5,1,6,4,6,1,5,3,5,7,5,4,5,1,5,2,5,7,5,4,5,1,5,3,5];
mel=zeros(size(song_melody,2),size(notes_melody,2));    %initializing zero matrix
chor=zeros(size(song_chorus,2),size(notes_chorus,2));
for i=1:1:size(song_melody,2)
    mel(i,:)=notes_melody(song_melody(i),:);
end
for i=1:1:size(song_chorus,2)
    chor(i,:)=notes_chorus(song_chorus(i),:);
end
x_melody=reshape(mel',1,[]);   %transpose and reshape into one row vector
x_chorus=reshape(chor',1,[]);
%song =====
x=(0.6*x_melody)+(0.4*x_chorus);  %concatenating melody and chorus
filename='song.wav';
audiowrite(filename,x,Fs);

%% Task 4 - generate spectrogram of musical score, x
spectrogram(x);

%% Task 4 in time(s) and frequency(Hz) axis
figure;
spectrogram(x,1200,120,1200,Fs)
title('Spectrogram of Twinkle Twinle Little Stars');
xlim([0 1.5]);

%% Task 5 - filter function and write to WAV file
%run after task 3, x is defined in task 3
[x_filtered]=IIR_filter_h(x);

filename='filtered_song.wav';
audiowrite(filename,x_filtered,Fs);

%for observation
figure;
spectrogram(x_filtered,1200,120,1200,Fs)
title('Spectrogram of Filtered Twinkle Twinkle Little Stars');
xlim([0 1.5]);
%% Task 6 - generate a magnitude response plot of the IIR filter
b0=1;
b1=-3.1820023;
b2=3.9741082;
b3=-2.293354;
b4=0.52460587;
a0=0.62477732;
a1=-2.444978;
a2=3.64114;
a3=-2.444978;
a4=0.62477732;

num=[a0 a1 a2 a3 a4];
den=[b0 b1 b2 b3 b4];

Fs=8e3;
[h,w]=freqz(num,den,'whole',Fs);    %a/b, x-coeffs/y-coeffs
figure;
mag=plot(w/pi,20*log10(abs(h)));
ax = gca;
ax.YLim = [-100 20];
ax.XTick = 0:.5:2;
xlim([0 1]);
xlabel('Normalized Frequency (\times\pi rad/sample)')
ylabel('Magnitude (dB)')
title('Magnitude Response of IIR Filter')
set(mag,'LineWidth', 2);

%% Observe zeros and poles
num=[a0 a1 a2 a3 a4];
den=[b0 b1 b2 b3 b4];
[zeros,pole,gain]=tf2zp(num,den)
fvtool(num,den,'polezero')  %pole-zero plot
%verifying result using roots
r_zeros=roots(num)
r_poles=roots(den)
%using pole zero plot
H=tf(num,den);
figure;
H_pole_zero=pzplot(H);
set(H_pole_zero.allaxes.Children(1).Children,'LineWidth', 2, 'MarkerSize', 8);
title('Pole-Zero Plot of IIR Filter');

%% Task 7 - c file
% on linux terminal run: (link math library at the end)
% gcc -lm -o skeleton Lab1.c $(pkg-config sndfile --cflags --libs) -lm
% ./skeleton song_c.wav

% read output file into MATLAB
[y,Fs1] = audioread('song_c.wav');
y=y';   %transposing the c-output
figure;
spectrogram(y,1200,120,1200,Fs1)    %C program
title('Spectrogram of Twinkle Twinkle Little Stars From C Code');
xlim([0 1.5]);

figure;
spectrogram(x_melody,1200,120,1200,Fs)  %MATLAB melody only
title('Spectrogram of Twinkle Twinkle Little Stars (Melody only) from MATLAB');
xlim([0 1.5]);

%Relative error
rel_error=abs((norm(y)-norm(x))/norm(y));
fprintf('Relative error = %.2f percent', rel_error*100)
%% Task 8 - Filtered song using C porgram
[y_filtered,Fs2] = audioread('filtered_song_c.wav');
y_filtered=y_filtered';   %transposing the c-output
figure;
spectrogram(y_filtered,1200,120,1200,Fs2)    %C program
title('Spectrogram of Filtered Song Using C Program Implementation');
xlim([0 1.5]);

%Spectrogram of MATLAB filtered implementation for comparison
figure;
spectrogram(x_filtered,1200,120,1200,Fs)
title('Spectrogram of Filtered Song Using MATLAB Implementation');
xlim([0 1.5]);