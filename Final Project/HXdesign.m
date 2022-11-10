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
% Reading excel sheet with air properties
excel.airPropertiesSheet = "Properties of Air";
air.propertyData = xlsread(excel.fileName, excel.airPropertiesSheet);

% True specific heat of air @ bulk average temp
air.cp = interp1(air.propertyData(:, 1), air.propertyData(:, 3),...
    air.bulkAvgTemp + 273.15);

% Kinematic viscocity of water
air.kinematicViscocity = interp1(air.propertyData(:, 1), ...
    air.propertyData(:, 5), air.bulkAvgTemp + 273.15); % m^2/s

% Dynamic viscocity of water
air.dynamicViscocity = interp1(air.propertyData(:, 1), ...
    air.propertyData(:, 4), air.bulkAvgTemp + 273.15); % Ns/m^2

% Density of water
air.density = interp1(air.propertyData(:, 1), ...
    air.propertyData(:, 2), air.bulkAvgTemp + 273.15); % kg/m^3

% Thermal conductivity of water
air.k = interp1(air.propertyData(:, 1), ...
    air.propertyData(:, 6), air.bulkAvgTemp + 273.15); % m^2/s

% Density of water
air.Pr = interp1(air.propertyData(:, 1), ...
    air.propertyData(:, 8), air.bulkAvgTemp + 273.15);

% Prandtl number for air

% ----- Water -----
% Reading excel sheet with water properties
excel.waterPropertiesSheet = "Properties of Water";
water.propertyData = xlsread(excel.fileName, excel.waterPropertiesSheet);

% Dynamic viscocity of water
water.dynamicViscocity = interp1(water.propertyData(:, 1), ...
    water.propertyData(:, 3), water.bulkAvgTemp + 273.15); % Ns/m^2

% Specific heat of water
water.cp = interp1(water.propertyData(:, 1), ...
    water.propertyData(:, 2), water.bulkAvgTemp + 273.15); % Ns/m^2

% Thermal conductivity of water
water.k = interp1(water.propertyData(:, 1), ...
    water.propertyData(:, 3), water.bulkAvgTemp + 273.15); % Ns/m^2

% Prandtl number of water
water.Pr = interp1(water.propertyData(:, 1), ...
    water.propertyData(:, 3), water.bulkAvgTemp + 273.15); % Ns/m^2

% Reading excel sheet with water densitiies
excel.waterPropertiesSheet = "Water Density";
water.densityData = xlsread(excel.fileName, excel.waterPropertiesSheet);

% Density of water
water.density = interp1(water.densityData(:, 1), ...
    water.densityData(:, 2), water.bulkAvgTemp); % kg/m^3

%% Design Calculations

% Air and water velocities 
air.w = 16; % m/s
water.w = 1.5; % m/s

% ----- Reynold's number for air and water ------
% Mass velocity of air and water
air.G = air.density * air.w; % kg/sm^2
water.G = water.density * water.w; % kg/sm^2

% Reynolds number for air
air.Re = (4 * HXair.rh * air.G) / air.dynamicViscocity;
water.Re = (4 * HXwater.rh * water.G) / water.dynamicViscocity;

% ----- Friction factor of air and water -----
% Friction factor of air (HX Plot)
air.f = .028;

% Friction factor of water (Karman-Nikuradse Equation)
water.f = .079 * (water.Re ^ -.25);

% ----- Stanton number for air and water -----
% Stanton number of air (HX Plot)
air.St = .0068 / air.Pr;

% Stanton number of water


% Heat transfer coeff. for air and water

% Overall surface efficiency & fin efficiency

% Total surface are of HX

%% Design Verification






