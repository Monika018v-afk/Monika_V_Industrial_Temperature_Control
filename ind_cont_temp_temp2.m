clc;
clear;
close all;


s = tf('s');

G = 2/(10*s + 1);

disp('Plant Transfer Function:')
G


C = pidtune(G,'PID');

disp('PID Controller:')
C


T = feedback(C*G,1);


t = 0:0.01:80;

figure;
step(T,t);

grid on;
title('Closed Loop Step Response');
xlabel('Time (seconds)');
ylabel('Temperature');

% Increase line thickness
h = findobj(gca,'Type','line');
set(h,'LineWidth',2);



info = stepinfo(T);

disp('===================================')
disp('STEP RESPONSE CHARACTERISTICS')
disp('===================================')

fprintf('Rise Time       : %.4f sec\n',info.RiseTime);
fprintf('Settling Time   : %.4f sec\n',info.SettlingTime);
fprintf('Overshoot       : %.4f %%\n',info.Overshoot);
fprintf('Peak Time       : %.4f sec\n',info.PeakTime);
fprintf('Peak Value      : %.4f\n',info.Peak);

steady_state_error = abs(1 - dcgain(T));

fprintf('Steady State Error : %.6f\n',steady_state_error);

c

t = 0:0.01:80;

disturbance = -0.5*(t >= 15);

[y,t_out] = lsim(T,disturbance,t);

figure;
plot(t_out,y,'LineWidth',2);

hold on;

xline(15,'r--','Disturbance Applied');

grid on;

title('Disturbance Rejection');
xlabel('Time (seconds)');
ylabel('Temperature Change');

legend('System Response');



figure;
rlocus(C*G);

grid on;

title('Root Locus');



figure;
bode(C*G);

grid on;

title('Bode Plot');


figure;
margin(C*G);

grid on;

title('Gain Margin and Phase Margin');


figure;
pzmap(T);

grid on;

title('Pole Zero Map');


figure;
nyquist(C*G);

grid on;

title('Nyquist Plot');


figure;

step(G,T,t);

grid on;

title('Open Loop vs Closed Loop');

legend('Open Loop','Closed Loop');

h = findobj(gca,'Type','line');
set(h,'LineWidth',2);


U = feedback(C,G);

figure;
step(U,t);

grid on;

title('Control Effort');

xlabel('Time (seconds)');
ylabel('Control Signal');

h = findobj(gca,'Type','line');
set(h,'LineWidth',2);



disp(' ')
disp('===================================')
disp('SYSTEM PERFORMANCE SUMMARY')
disp('===================================')

if isstable(T)
    disp('System is Stable')
else
    disp('System is Unstable')
end

if info.Overshoot < 5
    disp('Overshoot Requirement Satisfied')
else
    disp('Overshoot Requirement NOT Satisfied')
end

if steady_state_error < 0.01
    disp('Steady-State Error Approximately Zero')
else
    disp('Steady-State Error is High')
end

disp('===================================')

