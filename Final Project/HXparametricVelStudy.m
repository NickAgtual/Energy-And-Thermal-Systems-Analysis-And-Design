clear; clc; close all;

% Excel file name
excel.fileName = "ME 555 Final Project Lookup Tables";

%% Input Parameters

% Water inlet temperature
water.inletTemp = 30; % Deg C

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

% Number of C65 Microturbines
hotel.numMicroturbines = 7;

water.massFlowRate = water.density * hotel.volumeFlowRate / ...
    hotel.numMicroturbines;

%% Gas Exit Temperature

% Definign symbolic variable
syms airTout

% Energy balance on hot and cold fluid
energyBalance = water.massFlowRate * water.cp * ...
    (water.exitTemp - water.inletTemp) == air.massFlowRate * air.cp * ...
    (air.inletTemp - airTout);

air.outletTemp = solve(energyBalance, airTout);

%% HX Surface Characteristics 
%[(CF-9.05-3/4J (a)) (CF-7.34) (CF-8.8-1.0J (b))]

HX.types = {'CF-9.05-3/4J (a)', 'CF-7.34', 'CF-8.8-1.0J (b)'};

% ----- Air Side -----
% Flow-passage hydraulic radius
HXair.rh = [(5.13 / 4) (4.75 / 4) (13.21 / 4)] * 10 ^ -3; % m

% Total gas-side transfer area/total volume
HXair.alpha = [354 459 191]; % m^2/m^3

% Fin area/total area
HXair.sigma = [.455 .538 .634]; 

% Fin-metal thickness
HXair.delta = [.31 .46 .31] * 10 ^ -3; % m

% Fin material
HXair.finMaterial = 'Copper';

% Fin thermal conductivity
HXair.finThermalConductivity = 389.5; % W/mK

% Fin outer diameter
HXair.finOD = [37.2 23.4 44.1] * 10 ^ -3; % m

% Fin inner diameter = tube outer diameter
HXair.tubeDiameter = [19.66 9.65 26] * 10 ^ -3; % m

% Fin height
HXair.hFin = (HXair.finOD ./ 2) - (HXair.tubeDiameter ./ 2); % m

% Fin pitch
% 39.3701 in/meter
HX.finPitch = [9.05 7.34 8.8] * 39.3701; % Fin / meter

% ----- Water Side -----
% Outer diameter of tube
HXwater.OD = [19.66 9.65 26] * 10 ^ -3; % m

% Inner diameter
% 39.3701 in/meter
HXwater.ID = [(3 / 4) .5 1] / 39.3701; % m

% Transverse tube spacing
HXwater.S = [39.5 24.8 78.2] * 10 ^ -3; % m

% Longitudinal Spacing
HXwater.L = [44.5 20.3 52.4] * 10 ^ - 3; % m

% Frontal area associated with one tube
HXwater.Afr = HXwater.L .* HXwater.S; % m^2

% Free flow area of one tube
HXwater.Ac = pi * ((HXwater.ID .^ 2) / 4); % m^2

% Free flow area over frontal area
HXwater.sigma = HXwater.Ac ./ HXwater.Afr;

% Flow-passage hydraulic radius
HXwater.rh = HXwater.ID ./ 4; % m

% Transfer area over total volume
HXwater.alpha = HXwater.sigma ./ HXwater.rh;

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
    air.propertyData(:, 5), air.bulkAvgTemp + 273.15) * 10 ^ -6; % m^2/s

% Dynamic viscocity of water
air.dynamicViscocity = interp1(air.propertyData(:, 1), ...
    air.propertyData(:, 4), air.bulkAvgTemp + 273.15) * 10 ^ -7; % Ns/m^2

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
    water.propertyData(:, 3), water.bulkAvgTemp + 273.15) * ...
    10 ^ -6; % Ns/m^2

% Specific heat of water
water.cp = interp1(water.propertyData(:, 1), ...
    water.propertyData(:, 2), water.bulkAvgTemp + 273.15); % kJ/kgK

% Thermal conductivity of water
water.k = interp1(water.propertyData(:, 1), ...
    water.propertyData(:, 4), water.bulkAvgTemp + 273.15) * 10 ^ -3; % W/mK

% Prandtl number of water
water.Pr = interp1(water.propertyData(:, 1), ...
    water.propertyData(:, 5), water.bulkAvgTemp + 273.15);

% Reading excel sheet with water densitiies
excel.waterPropertiesSheet = "Water Density";
water.densityData = xlsread(excel.fileName, excel.waterPropertiesSheet);

% Density of water
water.density = interp1(water.densityData(:, 1), ...
    water.densityData(:, 2), water.bulkAvgTemp); % kg/m^3

%% Design Calculations

% Air and water velocities 
air.w = 16; % m/s
water.w = linspace(.1, 3.5, 250); % m/s

% ----- Reynold's number for air and water ------
% Mass velocity of air and water
air.G = air.density * air.w; % kg/sm^2
water.G = water.density * water.w; % kg/sm^2

for ii = 1:length(water.w)
% Reynolds number for air
air.Re = (4 * HXair.rh * air.G) / air.dynamicViscocity;
water.Re(ii, :) = (4 * HXwater.rh .* water.G(ii)) / water.dynamicViscocity;
end

% ----- Friction factor of air and water -----
% Friction factor of air (HX Plot)
air.f = .028;

% Friction factor of water (Karman-Nikuradse Equation)
water.f = .079 * (water.Re .^ -.25);

% ----- Stanton/Nusselt number for air and water -----
% Stanton number of air (HX Plot)
air.St = .0068 / air.Pr;

% Nusselt number of water (Nusselt # for turbulent flow plot) Figure 8
water.Nu = .023 * (water.Re .^ .8) * (water.Pr .^ .4);

% ----- Heat transfer coeff. for air and water -----
air.h = air.St * air.G * air.cp * 1000; % W/m^2K
water.h = (water.Nu .* water.k) ./ (4 .* HXwater.rh); % W/m^2K

% Overall surface efficiency & fin efficiency
HXair.m = sqrt((2 * air.h) ./ (HXair.finThermalConductivity .* HXair.delta));
HXair.mr = HXair.m .* HXair.hFin; 
HXair.ratio = HXair.finOD ./ HXair.tubeDiameter;

% Fin efficiency (eta n) (From figure 6)
efficiency.fin = [.95 .96 .92];

% Overall surface efficiency (eta o)
efficiency.overall = 1 - (HXair.sigma .* (1 - efficiency.fin));

% Overall heat transfer coefficient
HX.U = 1 ./ ((HXair.alpha ./ (HXwater.alpha .* water.h)) + ...
    (1 ./ (efficiency.overall .* air.h)));

% ----- HX Geometry ----- 
% Heat exchanger heat transfer
HX.q = water.massFlowRate * water.cp * ...
    (water.exitTemp - water.inletTemp); % kJ

% Heat exchanger area
HX.A = double((HX.q * 1000) ./ (HX.U * temp.lm)); % m^2

% Matrix frontal area for gas
HX.Afg = air.massFlowRate ./ (HXair.sigma .* air.G);

% Tube matrix length
HX.LtmPreliminary = HX.A ./ (HX.Afg .* HXair.alpha);

% Number of tube passes (TURNS)
HX.NtbPreliminary = HX.LtmPreliminary ./ HXwater.L;

% Number of tube passes rounded up 
HX.numTubePasses = round(HX.NtbPreliminary) + 1;

% Updated tube matrix length
HX.Ltm = HX.numTubePasses .* HXwater.L;

for ii = 1:length(water.w)
% Mass flow rate of water per one tube passage
HX.mWaterPtube(ii, :) = HXwater.Ac .* water.G(ii);
end

% Number of tube passages required
HX.NtpPreliminary = water.massFlowRate ./ HX.mWaterPtube;

% Number of tube passages (VERTICAL)
HX.numTubePassages = ceil(HX.NtpPreliminary);

% HX Height
HX.height = HX.numTubePassages .* HXwater.S; % m

% HX Width
HX.width = HX.Afg ./ HX.height; % m

% HX Total volume
HX.V = HX.height .* HX.width .* HX.Ltm;

% Water frontal area
HX.Afro = (HX.Ltm ./ HX.numTubePasses) .* HX.height;

%% Pressure Drop
air.specificVol2 = (air.outletTemp / air.inletTemp) * (1 / air.density);
air.meanSpecificVol = (air.specificVol2 + (1 / air.density)) / 2;
air.meanTemp = (air.meanSpecificVol * air.inletTemp) / (1 / air.density);

pressureDrop = ((air.G .^ 2) * (1 / air.density) / 2) * ...
    ((1 + HXair.sigma .^ 2) * ((air.specificVol2 / (1 / air.density)) -1)...
    + (air.f .* (HX.Ltm ./ HXair.rh) * (air.meanTemp / air.inletTemp))); % Pa


%% Design Verification

% Mass flow rate of water
verificationWater.massFlowRate = HX.q / (water.cp * (water.exitTemp - ...
    water.inletTemp));

% ----- Mass Velocity ------
% Mass velocity of air
verificationAir.G = air.massFlowRate ./ (HX.Afg .* HXair.sigma);

% Mass velocity of water
verificationWater.G = verificationWater.massFlowRate ./ ...
    (HX.Afro .* HXwater.sigma);

% ----- Reynolds Number -----
% Reynolds number of air
verificationAir.Re = (4 * HXair.rh .* verificationAir.G) ./...
    air.dynamicViscocity;

% Reynolds number of water
verificationWater.Re = (4 * HXwater.rh .* verificationWater.G) ./ ...
    water.dynamicViscocity;

% ----- Computation of St, f, and h -----
% Stanton number * Prantll number ^ 2/3 (Figure 2)
verificationAir.StPr23 = [.0092 .0092 .0092]; 

% Stanton number for air
verificationAir.St = verificationAir.StPr23 / (air.Pr ^ (2/3));

% Heat transfer coefficient for air
verificationAir.h = verificationAir.St .* verificationAir.G .* ...
    air.cp * 10^3; %W/m^2K

% Nusselt number for water
verificationWater.Nu = .023 * (verificationWater.Re .^ (.8)) .* ...
    (water.Pr ^ (.4));

% Friction factor for water
verificationWater.f = .079 * (verificationWater.Re .^ (-.25));

% Heat transfer coefficient for water
verificationWater.h = (verificationWater.Nu * water.k) ./ (4 * ...
    HXwater.rh);

% ----- Determination of eta and U -----
verificationAir.m = sqrt((2 * verificationAir.h) / ...
    (HXair.finThermalConductivity * HXair.delta));
verificationAir.mr = verificationAir.m * HXair.hFin;
verificationAir.ratio = HXair.finOD ./ HXair.tubeDiameter;

% Heat transfer effectiveness of air (Figure 6)
verificationAir.eta = [.93 .945 .925];

% Heat transfer effectiveness of water 
verificationWater.eta = 1 - (HXair.sigma .* (1 - verificationAir.eta));

% Overall HT coefficient
verification.U = 1 ./ ((HXair.alpha ./ (HXwater.alpha .* ...
    verificationWater.h)) + (1 ./ (verificationWater.eta .* ...
    verificationAir.h)));

% ----- Determination of NTU, epsilon, and outletTemp -----
% Heat capacity rate of water
verificationWater.C = verificationWater.massFlowRate * water.cp; % kW/K

% Heat capacity rate of air
verificationAir.C = air.massFlowRate * air.cp; % kW/K

% Number of transfer units
verification.NTU = (verification.U .* HXair.alpha .* HX.V) / ...
    (min(verificationAir.C, verificationWater.C) * 10 ^ 3);

% Ratio of heat capacity rates
verification.CRatio = min(verificationAir.C, verificationWater.C) ./ ...
    max(verificationAir.C, verificationWater.C);

% Effectiveness
verification.epsilon = (1 - exp(-verification.NTU * (1 + ...
    verification.CRatio))) ./ (1 + verification.CRatio);

%gas temp out
verificationAir.outletTemp = (verification.epsilon * 10 ^ -2 .* ...
    (air.inletTemp - water.inletTemp) - air.inletTemp) * -1;

%water temp out
verificationWater.outletTemp = (verificationAir.C / ...
    verificationWater.C) * (air.inletTemp - verificationAir.outletTemp) ...
    + water.inletTemp;

%% Plots

% Creating new figure
figure(1)

% Plotting pressure drops
for ii = 1:length(HX.types)
    plot(water.w, pressureDrop(:, ii)', 'DisplayName', HX.types{ii});
    hold on
end

% Vertical line at selected water velocity
xline(.5, 'k--', 'DisplayName', 'Selected Water Velocity')

% Adding grid
grid on
grid minor

% Plot descriptors
xlabel('\emph {Water Velocity ($\frac{m}{s}$)}','fontsize',14,...
    'Interpreter', 'latex');
ylabel('\emph {Pressure Drop (Pa)}','fontsize',14,'Interpreter','latex');
title('\emph {Pressure Drop Across Different HX for Varying Velocities}',...
    'fontsize',16, 'Interpreter', 'latex')
legend('location', 'best', 'Interpreter', 'latex')


