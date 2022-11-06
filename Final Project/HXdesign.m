%% Heat Exchanger Design
clear; clc; close all

%% Input Parameters

% Water inlet temperature
water.inletTemp = 25; % Deg C

% Water exit temperature
water.exitTemp = 80; % Deg C

% Gas inlet temp
gas.inletTemp = 309; % Deg C

% Gas mass flow rate
gas.massFlowRate = .49; % kg/s

%% HX Surface Characteristics (CF-9.05-3/4J (a))

