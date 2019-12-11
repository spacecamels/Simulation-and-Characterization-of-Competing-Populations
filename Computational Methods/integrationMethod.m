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

load X1
load X2

dataTimeSeries = X1.time;

speciesOne = X1.data;
speciesTwo = X2.data;

m = length(speciesOne)-1;
n = 2;

sampleRate = dataTimeSeries(2)-dataTimeSeries(1);

%% Solving for Species 1

dMatrixOne = zeros(m, 1);
xBarOne = zeros(m, n);

for i = (1:m)
    dMatrixOne(i) = (speciesOne(i+1) - speciesOne(i))/sampleRate;
    xBarOne(i,1) = (speciesOne(i+1) + speciesOne(i))/2;
    xBarOne(i,2) = ((speciesOne(i+1))^2 + (speciesOne(i))^2)/2;
    xBarOne(i,3) = (speciesOne(i+1)*speciesTwo(i+1) + speciesOne(i)*speciesTwo(i))/2;
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
    d2(i) = (speciesTwo(i+1) - speciesTwo(i))/sampleRate;
    xdash2(i,1) = (speciesTwo(i+1) + speciesTwo(i))/2;
    xdash2(i,2) = ((speciesTwo(i+1))^2 + (speciesTwo(i))^2)/2;
    xdash2(i,3) = (speciesOne(i+1)*speciesTwo(i+1) + speciesOne(i)*speciesTwo(i))/2;
end

global a2 r2 k2 alpha21;
a2 = (inv(transpose(xdash2)*xdash2)*transpose(xdash2)*d2);
r2 = a2(1);
k2 = -r2/a2(2);
alpha21 = -(a2(3)*k2)/r2;

%% Resimulate  Results by Solving System of ODE's using A's

tspan = linspace(0, dataTimeSeries(end), (dataTimeSeries(end)/sampleRate)+1);
x_init = [0.01 0.02];
[t,y] = ode45(@mysysfun,tspan,x_init);
x2_fit = y(:,2);
x2_error = speciesTwo - x2_fit;
x1_fit = y(:,1);
x1_error = speciesOne - x1_fit;


%% Verification 1: Checking Overall Shape 1)Original vs. 2)Fitted

figure(1)

title("Ver.1--Checking Overall Shape 1)Original vs. 2)Fitted")

hold on;

scatter(dataTimeSeries, speciesOne)
scatter(dataTimeSeries, speciesTwo)

plot(t,x1_fit);
plot(t,x2_fit);

legend("S1","S2", "S1 Calculated", "S2 Calculated")

hold off
%% Verification 2: 1)X1 2)X2

figure(2)

title("Ver.2-- 1)X1 2)X2")

subplot(2,1,1);

hold on;

plot(X1)
plot(t,x1_fit)

legend("X1","Fitted X1")

hold off;

subplot(2,1,2);

hold on;

plot(X2)
plot(t,x2_fit)

legend("X2","Fitted X2")

hold off
%% Resimulate the results by Solving System of ODE's using useful parameters

tspan = linspace(0, dataTimeSeries(end), (dataTimeSeries(end)/sampleRate)+1);
x_init = [0.01 0.02];
[t,y] = ode45(@mysysfun2,tspan,x_init);


x2_reg = y(:,2);
x1_reg = y(:,1);

x1_reg_error = speciesOne - x1_reg;
x2_reg_error = speciesTwo - x2_reg;

variance_x1 = sum(x1_reg_error.^2)/(length(dataTimeSeries)-2)
variance_x2 = sum(x2_reg_error.^2)/(length(dataTimeSeries)-2)

%% Verifcation 3: Verifying matrix fits with useful parameters

figure(3)

hold on;

plot(X1)
plot(t,x1_fit)
plot(X2)
plot(t,x2_fit)
plot(t,x1_reg)
plot(t,x2_reg)

title("Ver.3 -- Checking all shapes, both method give same graph")
legend("X1","Fitted X1","X2","Fitted X2","Param Fit X1","Param Fit X2")

hold off
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