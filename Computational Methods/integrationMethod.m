%% Reference Values [Error Debugging and Results Validation]:

%   x1_init = 0.01
%   R1: 1.5
%   Alpha12: 1.1
%   K1 = 1.2

%   x2_init = 0.02
%   R2: 1.6
%   Alpha21: 1.4
%   K2 = 1.3

%% Initialisation 

clear
clc

load X1_Noisy
load X1_Clean
load X2_Noisy
load X2_Clean

TimeSeries = (speciesOne_Clean(1,:)).';
speciesOne_Clean = (speciesOne_Clean(2, :)).';
speciesOne_Noisy = (speciesOne_Noisy(2, :)).';
speciesTwo_Clean = (speciesTwo_Clean(2, :)).';
speciesTwo_Noisy = (speciesTwo_Noisy(2, :)).';

m = length(speciesOne_Noisy)-1;
n = 2;

sampleRate = TimeSeries(2)-TimeSeries(1);

%% Solving for Species 1

dMatrixOne = zeros(m, 1);
xBarOne = zeros(m, n);

for i = (1:m)
    dMatrixOne(i) = (speciesOne_Noisy(i+1) - speciesOne_Noisy(i))/sampleRate;
    xBarOne(i,1) = (speciesOne_Noisy(i+1) + speciesOne_Noisy(i))/2;
    xBarOne(i,2) = ((speciesOne_Noisy(i+1))^2 + (speciesOne_Noisy(i))^2)/2;
    xBarOne(i,3) = (speciesOne_Noisy(i+1)*speciesTwo_Noisy(i+1) + speciesOne_Noisy(i)*speciesTwo_Noisy(i))/2;
end

global a1 r1 k1 alpha12;
a1 = (inv(transpose(xBarOne)*xBarOne)*transpose(xBarOne)*dMatrixOne);
r1 = a1(1);
k1 = -r1/a1(2);
alpha12 = -(a1(3)*k1)/r1;

%% Solving for Species 2

d2 = zeros(m, 1);
xdash2 = zeros(m, n);

for i = (1:m)
    d2(i) = (speciesTwo_Noisy(i+1) - speciesTwo_Noisy(i))/sampleRate;
    xdash2(i,1) = (speciesTwo_Noisy(i+1) + speciesTwo_Noisy(i))/2;
    xdash2(i,2) = ((speciesTwo_Noisy(i+1))^2 + (speciesTwo_Noisy(i))^2)/2;
    xdash2(i,3) = (speciesOne_Noisy(i+1)*speciesTwo_Noisy(i+1) + speciesOne_Noisy(i)*speciesTwo_Noisy(i))/2;
end

global a2 r2 k2 alpha21;
a2 = (inv(transpose(xdash2)*xdash2)*transpose(xdash2)*d2);
r2 = a2(1);
k2 = -r2/a2(2);
alpha21 = -(a2(3)*k2)/r2;

%% Resimulate  Results by Solving System of ODE's using A's

tspan = linspace(0, TimeSeries(end), (TimeSeries(end)/sampleRate)+1);
x_init = [0.01 0.02];
[t,y] = ode45(@mysysfun,tspan,x_init);
x2_raw_fit = y(:,2);
x1_raw_fit = y(:,1);



%% Verification 1: Noisy Signal and Raw Regression

figure(1)

title("Noisy Signal and Raw Regression")

hold on;

scatter(TimeSeries, speciesOne_Noisy)
scatter(TimeSeries, speciesTwo_Noisy)

plot(t,x1_raw_fit);
plot(t,x2_raw_fit);

legend("S1","S2", "S1 Calculated", "S2 Calculated")

hold off

%% Error Calculations for Raw Regresion

x1_error = speciesOne_Clean - x1_raw_fit;
x2_error = speciesTwo_Clean - x2_raw_fit;
var_raw_x1 = sum(x1_error.^2)/(length(TimeSeries)-2);
var_raw_x2 = sum(x2_error.^2)/(length(TimeSeries)-2);

figure(2)

subplot(2,1,1)
title("Calculated vs. Expected Species One")
scatter(x1_raw_fit, speciesOne_Clean);

subplot(2,1,2)
title("Calculated vs. Expected Species Two")
scatter(x2_raw_fit, speciesTwo_Clean);



%% Resimulate the results by Solving System of ODE's using useful parameters

tspan = linspace(0, TimeSeries(end), (TimeSeries(end)/sampleRate)+1);
x_init = [0.01 0.02];
[t,y] = ode45(@mysysfun2,tspan,x_init);


x2_reg_fit = y(:,2);
x1_reg_fit = y(:,1);


%% Verification 2: Noisy Signal and Regularized Regression

figure(3)

title("Noisy Signal and Raw Regression")

hold on;

scatter(TimeSeries, speciesOne_Noisy)
scatter(TimeSeries, speciesTwo_Noisy)

plot(t,x1_reg_fit);
plot(t,x2_reg_fit);

legend("S1","S2", "S1 Calculated", "S2 Calculated")

hold off

%% Error Calculations for Regularized Regresion
x1_reg_error = speciesOne_Clean - x1_reg_fit;
x2_reg_error = speciesTwo_Clean - x2_reg_fit;

var_reg_x1 = sum(x1_reg_error.^2)/(length(TimeSeries)-2);
var_reg_x2 = sum(x2_reg_error.^2)/(length(TimeSeries)-2);

figure(4)

subplot(2,1,1)
title("Calculated vs. Expected Species One")
scatter(x1_reg_fit, speciesOne_Clean);

subplot(2,1,2)
title("Calculated vs. Expected Species Two")
scatter(x2_reg_fit, speciesTwo_Clean);

%% Functions
function f = mysysfun(t,X)

global a1
global a2
f(1,1) = (X(1)*a1(1) + (X(1)^2)*a1(2) + X(1)*X(2)*a1(3));
f(2,1) = (X(2)*a2(1) + (X(2)^2)*a2(2) + X(2)*X(1)*a2(3));
end

function f = mysysfun2(t,X)

global r1 k1 alpha12 r2 k2 alpha21;
f(1,1) = r1*X(1) - ((r1*X(1)^2)/k1) - ((r1*alpha12*X(2)*X(1))/k1);
f(2,1) = r2*X(2) - ((r2*X(2)^2)/k2) - ((r2*alpha21*X(2)*X(1))/k2);
end
