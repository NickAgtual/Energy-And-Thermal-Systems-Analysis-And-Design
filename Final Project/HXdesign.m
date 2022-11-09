%% Heat Exchanger Design
% clear; clc; close all

% Excel file name
excel.fileName = "ME 555 Final Project Lookup Tables";

%% Input Parameters

% Water inlet temperature
water.inletTemp = 25; % Deg C

% Water exit temperature
water.exitTemp = 80; % Deg C

% Gas inlet temp
air.inletTemp = 309; % Deg C

% Gas mass flow rate
air.massFlowRate = .49; % kg/s

% General specific heat of water for energy balance calcs
water.cp = 4.179; % kJ/kgK

% General specific heat of air for energy balance calcs
air.cp = 1.005; % kJ/kgK

%% Water Mass Flow Rate (SD Marriott Marquis & Marina Hotel)

% Water consumption of hotel per room per day
hotel.waterPerRoom = 280.84; % L/day

% Number of rooms in hotel
hotel.numRooms = 1362;

% Total hotel volume flow rate
hotel.volumeFlowRate = (hotel.waterPerRoom * hotel.numRooms) / ...
    (24 * 60 * 60);

% Density of water @ bulk average temp
water.density = .986888643; % kg/L

water.massFlowRate = water.density * hotel.volumeFlowRate / 10;

%% Gas Exit Temperature

% Definign symbolic variable
syms airTout

% Energy balance on hot and cold fluid
energyBalance = water.massFlowRate * water.cp * ...
    (water.exitTemp - water.inletTemp) == air.massFlowRate * air.cp * ...
    (air.inletTemp - airTout);

air.outletTemp = solve(energyBalance, airTout);

%% HX Surface Characteristics (CF-9.05-3/4J (a))

%% Fluid Properties

% ----- Temperature Values -----

% Bulk average temperature of water
water.bulkAvgTemp = (water.inletTemp + water.exitTemp) / 2; % Deg C

% Bulk average temperature of exhaust gas
air.bulkAvgTemp = double((air.inletTemp + air.outletTemp)) / 2; % Deg C

% Temp difference for point 1
temp.delta1 = air.inletTemp - water.exitTemp;

% Temp difference for point 2
temp.delta2 = air.outletTemp - water.inletTemp;

% Log mean temperature difference
temp.lm = (temp.delta2 - temp.delta1) / (log(temp.delta2 / temp.delta1));

% ----- Specific Heat -----

% Reading excel file with cp data for air
excel.cpDataSheet = "Specific Heat of Air";
air.cpData = xlsread(excel.fileName, excel.cpDataSheet);

% True specific heat of air @ bulk average temp
air.cp = interp1(air.cpData(:, 1), air.cpData(:, 2),...
    air.bulkAvgTemp + 273.15);

% True specific heat of water @ bulk average temp
water.cp = 1;

%% Design Calculations

% Air and water velocities

% Reynold's number for air and water

% Stanton number & friction factor for air and water

% Heat transfer coeff. for air and water

% Overall surface efficiency & fin efficiency

% Total surface are of HX

%% Design Verification






