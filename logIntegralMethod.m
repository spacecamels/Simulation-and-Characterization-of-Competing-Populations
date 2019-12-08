clc
clear

load X1
load X2

% hold on
% title("Analyzed Timeseries")
% plot(X1)
% plot(X2)

S1 = X1.data;
S2 = X2.data;
m = length(S1)-1;
n = 2;

% Solving for Species 1

l1 = zeros(m, 1);
xdash1 = ones(m, n);

for i = (1:m)
    l1(i) = (log(S1(i+1)) - log(S1(i)));
    xdash1(i,2) = (S1(i+1) + S1(i))/2;
    xdash1(i,3) = (S2(i+1) + S2(i))/2;
end


a1 = inv(transpose(xdash1)*xdash1)*transpose(xdash1)*l1;

global r1 k1 alpha12
r1 = a1(1)*10
k1 = -r1/a1(2)
alpha12 = -(a1(3)*k1)/r1

% Solving for Species 2

l2 = zeros(m, 1);
xdash2 = ones(m, n);

for i = (1:m)
    l2(i) = (log(S2(i+1)) - log(S2(i)));
    xdash2(i,2) = (S2(i+1) + S2(i))/2;
    xdash2(i,3) = (S1(i+1) + S1(i))/2;
end


a2 = inv(transpose(xdash2)*xdash2)*transpose(xdash2)*l2;

global r2 k2 alpha21
r2 = a2(1)*10
k2 = -r2/a2(2)
alpha21 = -(a2(3)*k2)/r2


%% Resimulate the results by Solving System of ODE's using useful parameters
tspan = [0 10];
x_init = [0.01 0.02];
[t,y] = ode45(@mysysfun2,tspan,x_init);
% % dy1 = gradient(y(:,1));
% % dy2 = gradient(y(:,2));
x2_fit_ = y(:,2);
x1_fit_ = y(:,1);
%% Verification 1: Checking Overall Shape 1)Original vs. 2)Fitted
% Scale is off by 10?
figure(1)
sgtitle("Ver.1--Checking Overall Shape 1)Original vs. 2)Fitted useful parameter")
subplot(2,1,1);
hold on;
plot(X1)
plot(X2)
legend("x1","x2")
hold off;
subplot(2,1,2);
hold on;
plot(t,x1_fit_);
plot(t,x2_fit_);
title("Scale is off by 10?")
legend("x1","x2")
hold off
%% Verification 2: on a matrix: 1)X1 2)X2
figure(2)
sgtitle("Ver.2-- 1)X1 2)X2")
subplot(2,1,1);
hold on;
plot(X1)
plot(t,x1_fit_/10)
legend("X1","Fitted X1")
hold off;
subplot(2,1,2);
hold on;
plot(X2)
plot(t,x2_fit_/10)
legend("X2","Fitted X2")
hold off
%% Verification 3: on useful param. All on same graph
figure(3)
hold on;
plot(X1)
plot(t,x1_fit_/10)
plot(X2)
plot(t,x2_fit_/10)
title("Ver.3 -- Checking Shape After DiviDing Fit by 10")
legend("X1","Fitted X1","X2","Fitted X2")
hold off

%% Verification 4: comparing log intergral and regular

figure(4)
hold on;
plot(X1)
plot(X2)
plot(t,x1_fit_/10)
plot(t,x2_fit_/10)
plot(t,x1_reg/10)
plot(t,x2_reg/10)
title("Ver.4 -- Checking all shaapes")
legend("X1","X2","Log Fit X1","Log Fit X2","Intrgrl Fit X1","Intrgrl Fit X2")
xlabel("seems to give same result")
hold off

%% Functions
function f = mysysfun2(t,X)

global r1 k1 alpha12 r2 k2 alpha21;
f(1,1) = r1*X(1) - (r1*X(1)^2)/k1 - (r1*alpha12*X(2)*X(1))/k1;
f(2,1) = r2*X(2) - (r2*X(2)^2)/k2 - (r2*alpha21*X(2)*X(1))/k2;
end
