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

% ----- Air Side -----
% Flow-passage hydraulic radius
HXair.rh = (5.13 / 4) * 10 ^ -3; % m

% Total gas-side transfer area/total volume
HXair.alpha = 354; % m^2/m^3

% Fin area/total area
HXair.freeOverfrontal = .917; 

% Fin-metal thickness
HXair.delta = .31 * 10 ^ -3; % m

% Fin material
HXair.finMaterial = 'Copper';

% Fin thermal conductivity
HXair.finThermalConductivity = 389.5; % W/mK

% Fin outer diameter
HXair.finOD = 37.2 * 10 ^ 03; % m

% Fin inner diameter = tube outer diameter
HXair.tubeDiameter = 19.66 * 10 ^ -3; % m

% Fin height
HXair.hFin = (HXair.finOD / 2) - (HXair.tubeDiameter / 2); % m

% Fin pitch
% 39.3701 in/meter
HX(1).finPitch = 9.05 * 39.3701; % Fin / meter

% ----- Water Side -----
% Outer diameter of tube
HXwater.OD = 19.66 * 10 ^ -3; % m

% Inner diameter
% 39.3701 in/meter
HXwater.ID = (3 / 4) / 39.3701; % m

% Transverse tube spacing
HXwater.S = 39.5 * 10 ^ -3; % m

% Longitudinal Spacing
HXwater.L = 44.5 * 10 ^ - 3; % m

% Frontal area associated with one tube
HXwater.Afr = HXwater.L * HXwater.S; % m^2

% Free flow area of one tube
HXwater.Ac = pi * ((HXwater.ID ^ 2) / 4); % m^2

% Free flow area over frontal area
HXwater.sigma = HXwater.Ac / HXwater.Afr;

% Flow-passage hydraulic radius
HXwater.rh = HXwater.ID / 4; % m

% Transfer area over total volume
HXwater.alpha = HXwater.sigma / HXwater.rh;

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

% ----- Air -----
% Reading excel sheet with cp data for air
% Col1 = Temperature (K)
% Col2 = Specific heat (
excel.cpDataSheet = "Specific Heat of Air";
air.cpData = xlsread(excel.fileName, excel.cpDataSheet);

% True specific heat of air @ bulk average temp
air.cp = interp1(air.cpData(:, 1), air.cpData(:, 2),...
    air.bulkAvgTemp + 273.15);

% Reading excel sheet with air properties
% Col1 = Temp (C)
% Col2 = Density (kg/m^3); 
% Col3 = Dynamic Viscocity (Ns/m^2)
% Col4 = Kinematic Viscocity (m^2/s)
% True specific heat of water @ bulk average temp
excel.airPropertiesSheet = "Properties of Air";
air.propertyData = xlsread(excel.fileName, excel.airPropertiesSheet);

% Kinematic viscocity of water
air.kinematicViscocity = interp1(air.propertyData(:, 1), ...
    air.propertyData(:, 4), air.bulkAvgTemp); % m^2/s

% Dynamic viscocity of water
air.dynamicViscocity = interp1(air.propertyData(:, 1), ...
    air.propertyData(:, 3), air.bulkAvgTemp); % Ns/m^2

% Density of water
air.density = interp1(air.propertyData(:, 1), ...
    air.propertyData(:, 2), air.bulkAvgTemp) * 10 ^-3; % kg/L

% ----- Water -----

% Reading excel sheet with water properties
% Col1 = Temp (C)
% Col2 = Density (kg/m^3); 
% Col3 = Dynamic Viscocity (Ns/m^2)
% Col4 = Kinematic Viscocity (m^2/s)
% True specific heat of water @ bulk average temp
excel.waterPropertiesSheet = "Properties of Water";
water.propertyData = xlsread(excel.fileName, excel.waterPropertiesSheet);

% Kinematic viscocity of water
water.kinematicViscocity = interp1(water.propertyData(:, 1), ...
    water.propertyData(:, 4), water.bulkAvgTemp); % m^2/s

% Dynamic viscocity of water
water.dynamicViscocity = interp1(water.propertyData(:, 1), ...
    water.propertyData(:, 3), water.bulkAvgTemp); % Ns/m^2

% Density of water
water.density = interp1(water.propertyData(:, 1), ...
    water.propertyData(:, 2), water.bulkAvgTemp) * 10 ^-3; % kg/L

%% Design Calculations

% Air and water velocities

% Reynold's number for air and water

% Stanton number & friction factor for air and water

% Heat transfer coeff. for air and water

% Overall surface efficiency & fin efficiency

% Total surface are of HX

%% Design Verification






