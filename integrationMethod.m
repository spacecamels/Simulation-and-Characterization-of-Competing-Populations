%Values in simulation:
%   x1_init = 0.01
%   R1: 1.5
%   Alpha12: 1.1
%   K1 = 1.2

%   x2_init = 0.02
%   R2: 1.6
%   Alpha21: 1.4
%   K2 = 1.3

clc
clear

load X1
load X2

% hold on
% title("Analyzed Timeseries")
% scatter(X1)
% scatter(X2)

S1 = X1.data;
S2 = X2.data;
m = length(S1)-1;
n = 2;

% Solving for Species 1

d1 = zeros(m, 1);
xdash1 = zeros(m, n);

for i = (1:m)
    d1(i) = (S1(i+1) - S1(i));
    xdash1(i,1) = (S1(i+1) + S1(i))/2;
    xdash1(i,2) = ((S1(i+1))^2 + (S1(i))^2)/2;
    xdash1(i,3) = (S1(i+1)*S2(i+1) + S1(i)*S2(i))/2;
end

global a1
a1 = inv(transpose(xdash1)*xdash1)*transpose(xdash1)*d1;

r1 = a1(1)
k1 = -r1/a1(2)
alpha12 = -(a1(3)*k1)/r1

% Solving for Species 2

d2 = zeros(m, 1);
xdash2 = zeros(m, n);

for i = (1:m)
    d2(i) = (S2(i+1) - S2(i));
    xdash2(i,1) = (S2(i+1) + S2(i))/2;
    xdash2(i,2) = ((S2(i+1))^2 + (S2(i))^2)/2;
    xdash2(i,3) = (S1(i+1)*S2(i+1) + S1(i)*S2(i))/2;
end

global a2
a2 = inv(transpose(xdash2)*xdash2)*transpose(xdash2)*d2;

r2 = a2(1)
k2 = -r2/a2(2)
alpha21 = -(a2(3)*k2)/r2


%% Resimulate the results by Solving System of ODE's

tspan = [0 10];
x_init = [0.01 0.02];


[t,y] = ode45(@mysysfun,tspan,x_init)

dy1 = gradient(y(:,1));
dy2 = gradient(y(:,2));

hold on

plot(t,y(:,1))
plot(t,y(:,2))
legend("x1","x2")

function f = mysysfun(t,X)

global a1
global a2
f(1,1) = X(1)*a1(1)*10 + (X(1)^2)*a1(2) + X(1)*X(2)*a1(3);
f(2,1) = X(2)*a2(1)*10 + (X(2)^2)*a2(2) + X(2)*X(1)*a2(3);
end
