%% Heat Exchanger Design
clear; clc; close all

%% Input Parameters

% Water inlet temperature
water.inletTemp = 25; % Deg C

% Water exit temperature
water.exitTemp = 80; % Deg C

% Gas inlet temp
air.inletTemp = 309; % Deg C

% Gas mass flow rate
air.massFlowRate = .49; % kg/s

% Specific heat of water
water.cp = 4.179; % kJ/kgK

% Specific heat of air
air.cp = 1.005; % kJ/kgK

%% Water Mass Flow Rate (SD Marriott Marquis & Marina Hotel)

% Water consumption of hotel per room per day
hotel.waterPerRoom = 280.84; % L/day

% Number of rooms in hotel
hotel.numRooms = 1362;

% Total hotel volume flow rate
hotel.volumeFlowRate = (hotel.waterPerRoom * hotel.numRooms) / ...
    (24 * 60 * 60);

% Density of water
water.density = 1; % kg/L

water.massFlowRate = water.density * hotel.volumeFlowRate;

%% Gas Exit Temperature

% Definign symbolic variable
syms airTout

% Energy balance on hot and cold fluid
energyBalance = water.massFlowRate * water.cp * ...
    (water.exitTemp - water.inletTemp) == air.massFlowRate * air.cp * ...
    (airTout - air.inletTemp);

air.outletTemp = solve(energyBalance, airTout);

%% HX Surface Characteristics (CF-9.05-3/4J (a))

%% Fluid Properties

% Bulk average temperature of water
water.bulkAvgTemp = (water.inletTemp + water.exitTemp) / 2; % Deg C

% Bulk average temperature of exhaust gas
air.bulkAvgTemp = (air.inletTemp + air.outletTemp) / 2; % Deg C

