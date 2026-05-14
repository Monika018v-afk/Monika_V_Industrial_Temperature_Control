clc;
clear;
close all;

%% =========================================================
% ADVANCED INDUSTRIAL TEMPERATURE CONTROL SYSTEM
% =========================================================
% Plant:
%           G(s) = 2 / (10s + 1)
%
% Objectives:
% ✓ Overshoot < 5%
% ✓ Stable response
% ✓ Zero steady-state error
% ✓ Disturbance rejection
% ✓ Smooth control effort
% =========================================================

%% Transfer Function

s = tf('s');

G = 2/(10*s + 1);

disp('Plant Transfer Function:')
G

%% =========================================================
% IMPROVED PID CONTROLLER
% Tuned for Overshoot < 5%
% =========================================================

Kp = 1.2;
Ki = 0.18;
Kd = 2.5;

Cpid = pid(Kp,Ki,Kd);

disp('PID Controller:')
Cpid

%% =========================================================
% CLOSED LOOP SYSTEM
% =========================================================

Tpid = feedback(Cpid*G,1);

%% =========================================================
% STEP RESPONSE
% =========================================================

t = 0:0.1:80;

figure;

step(Tpid,t);

grid on;

title('Closed Loop Step Response');
xlabel('Time (seconds)');
ylabel('Temperature');

h = findobj(gca,'Type','line');
set(h,'LineWidth',2);

%% =========================================================
% STEP RESPONSE CHARACTERISTICS
% =========================================================

info = stepinfo(Tpid);

disp(' ')
disp('===================================')
disp('STEP RESPONSE CHARACTERISTICS')
disp('===================================')

fprintf('Rise Time       : %.2f sec\n',info.RiseTime);
fprintf('Settling Time   : %.2f sec\n',info.SettlingTime);
fprintf('Overshoot       : %.2f %%\n',info.Overshoot);
fprintf('Peak Time       : %.2f sec\n',info.PeakTime);

steady_error = abs(1 - dcgain(Tpid));

fprintf('Steady-State Error : %.6f\n',steady_error);

%% =========================================================
% DISTURBANCE REJECTION
% =========================================================
% Heat loss at t = 15 sec

disturbance = -0.15*sin(0.2*t);

disturbance(t >= 15) = disturbance(t >= 15) - 0.25;

[y,t_out] = lsim(Tpid,disturbance,t);

% Sensor noise
noise = 0.01*randn(size(y));

y_noisy = y + noise;

figure;

plot(t_out,y_noisy,'LineWidth',2);

hold on;

xline(15,'r--','Heat Loss Applied');

grid on;

title('Disturbance Rejection with Sensor Noise');
xlabel('Time (seconds)');
ylabel('Temperature Change');

legend('Temperature Response');

%% =========================================================
% CONTROL EFFORT ANALYSIS
% =========================================================

[y_step, t2] = step(Tpid, t);

% Error signal
e = 1 - y_step;

% Integral term
integral_term = cumtrapz(t2,e);

% Derivative term
derivative_term = gradient(e,t2);

% PID control signal
u = Kp*e + Ki*integral_term + Kd*derivative_term;

% Heater saturation
u(u > 1) = 1;
u(u < 0) = 0;

figure;

plot(t2,u,'LineWidth',2);

grid on;

title('Heater Control Effort');
xlabel('Time (seconds)');
ylabel('Heater Power');

%% =========================================================
% OPEN LOOP VS CLOSED LOOP
% =========================================================

figure;

step(G,Tpid,t);

grid on;

title('Open Loop vs Closed Loop Response');

xlabel('Time (seconds)');
ylabel('Temperature');

legend('Open Loop','Closed Loop');

h = findobj(gca,'Type','line');
set(h,'LineWidth',2);

%% =========================================================
% ROOT LOCUS
% =========================================================

figure;

rlocus(Cpid*G);

grid on;

title('Root Locus');

%% =========================================================
% BODE PLOT
% =========================================================

figure;

bode(Cpid*G);

grid on;

title('Bode Plot');

%% =========================================================
% GAIN AND PHASE MARGIN
% =========================================================

figure;

margin(Cpid*G);

grid on;

title('Gain Margin and Phase Margin');

%% =========================================================
% POLE ZERO MAP
% =========================================================

figure;

pzmap(Tpid);

grid on;

title('Pole Zero Map');

%% =========================================================
% NYQUIST PLOT
% =========================================================

figure;

nyquist(Cpid*G);

grid on;

title('Nyquist Plot');

%% =========================================================
% ENERGY CONSUMPTION
% =========================================================

energy = trapz(t2,u.^2);

fprintf('\nTotal Heater Energy Used = %.4f Units\n',energy);

%% =========================================================
% SAFETY ALARM SYSTEM
% =========================================================

max_temp = max(y_step);

if max_temp > 1.05
    disp('WARNING: Overshoot Above Safe Limit')
else
    disp('Temperature Within Safe Limit')
end

%% =========================================================
% STABILITY CHECK
% =========================================================

disp(' ')
disp('===================================')
disp('SYSTEM STATUS')
disp('===================================')

if isstable(Tpid)
    disp('System is Stable')
else
    disp('System is Unstable')
end

if info.Overshoot < 5
    disp('Overshoot Requirement Satisfied')
else
    disp('Overshoot Requirement NOT Satisfied')
end

if steady_error < 0.01
    disp('Steady-State Error Approximately Zero')
else
    disp('Steady-State Error High')
end

disp('===================================')

%% =========================================================
% REAL-TIME TEMPERATURE ANIMATION
% =========================================================

figure;

for k = 1:length(t2)

    plot(t2(1:k),y_step(1:k),'b','LineWidth',2);

    grid on;

    axis([0 80 0 1.1]);

    title('Real-Time Furnace Temperature');

    xlabel('Time (seconds)');
    ylabel('Temperature');

    drawnow;

end

%% =========================================================
% END OF PROGRAM
% =========================================================