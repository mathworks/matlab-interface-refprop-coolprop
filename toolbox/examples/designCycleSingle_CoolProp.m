%% Design a Single-Stage Refrigeration Cycle
% and plot the Pressure-Enthalpy (PH) & Temperature-Entropy (TS) diagrams

%% Choose Library, Fluid, P & H Ranges
% Set up Library and Units
libLoc = 'C:\Program Files\CoolProp\'; % Location for CoolProp might be: 'C:\Users\<userName>\AppData\Roaming\CoolProp';

% default: 0.01-6 MPa, 100-500 kJ/kg, R134a.
% English: 1.5-950 psi, 40-220 Btu/lbm
Fluid   = "R134a";
P_min   = 0.01;
P_max   = 6; 
P_unit  = "MPa";
H_min   = 100;
H_max   = 500;
H_unit  = "kJ/kg";
% System Design Information

% default: T_sat_cond=60, T_sat_evap=5, T_sc=5, T_sh=5, degC
% English: 140, 40, 10, 10, degF
T_sat_cond = 60; % saturation temperature of condensation degC
T_sat_evap = 5;  % saturation temperature of evaporation  degC
T_sc       = 5;  % temperature of subcooled liquid at compressor outlet degC
T_sh       = 5;  % temperature at evaporator outlet/compressor inlet    degC
T_unit     = "degC";
eta_s      = 0.6; % viscosity of saturation

%% Plot PH & TS Diagrams

% Plot PH & TS Diagrams in custom units
[hfig_PH, hfig_TS] = plotStateDiagrams(libLoc, Fluid, P_min, P_max, H_min, H_max, P_unit, H_unit, T_unit);

% Use light mode for PH & TS diagrams. Doesn't look good in dark mode.
if ~isMATLABReleaseOlderThan("R2025a")
    hfig_PH.Theme.BaseColorStyle = 'light';
    hfig_TS.Theme.BaseColorStyle = 'light';
end

%% States Calculation
% Single-Stage Vapor Compression Cycle

% Initialize arrays for pressure, enthalpy, entropy, temperature, and quality
P = zeros(1,8);  % pressure
H = zeros(1,8);  % enthalpy
S = zeros(1,8);  % entropy
T = zeros(1,8);  % temperature
Q = zeros(1,8);  % quality

% Calculate pressure values at different states
P(1) = getFluidProperty(libLoc, 'P', 'Q', 1, 'T', unit_convert_SI(T_sat_evap, T_unit, 'T', 1), Fluid, 1, keepLibraryLoaded=true); % Compressor Inlet : assuming saturation pressure at evaporating temperature
P(2) = getFluidProperty(libLoc, 'P', 'Q', 1, 'T', unit_convert_SI(T_sat_cond, T_unit, 'T', 1), Fluid, 1, keepLibraryLoaded=true); % Compressor Outlet: assuming saturation pressure at condensing temperature
P(3) = P(2); % Pressure in condenser volume, saturated vapor
P(4) = P(2); % Pressure in condenser volume, saturated liquid
P(5) = P(2); % Pressure at condenser outlet & expansion valve inlet, subcooled liquid
P(6) = P(1); % Pressure at expansion valve outlet & evaporator inlet, mixture
P(7) = P(1); % Pressure in evaporator volume, saturated vapor
P(8) = P(1); % Pressure at evaporator outlet, superheated vapor

% Calculate enthalpy values at different states
H(1) = getFluidProperty(libLoc, 'Hmass', 'P', P(1), 'T', unit_convert_SI(T_sat_evap + T_sh, T_unit, 'T', 1), Fluid, 1, keepLibraryLoaded=true); % Enthalpy at evaporator exit & compressor inlet
S(1) = getFluidProperty(libLoc, 'Smass', 'P', P(1), 'Hmass', H(1), Fluid, 1, keepLibraryLoaded=true); % Entropy at evaporator exit
H(2) = getFluidProperty(libLoc, 'Hmass', 'P', P(2), 'Smass', S(1), Fluid, 1, keepLibraryLoaded=true); % Enthalpy after isentropic compression
H(2) = (H(2)-H(1))/eta_s+H(1);  % Adjust enthalpy for isentropic efficiency
H(3) = getFluidProperty(libLoc, 'Hmass', 'P', P(3), 'Q', 1, Fluid, 1, keepLibraryLoaded=true); % Enthalpy in codenser, saturated vapor
H(4) = getFluidProperty(libLoc, 'Hmass', 'P', P(4), 'Q', 0, Fluid, 1, keepLibraryLoaded=true); % Enthalpy in codenser, saturated liquid
H(5) = getFluidProperty(libLoc, 'Hmass', 'P', P(5), 'T', unit_convert_SI(T_sat_cond - T_sc, T_unit, 'T', 1), Fluid, 1, keepLibraryLoaded=true); % Enthalpy at condenser outlet, subcooled liquid
H(6) = H(5); % Enthalpy remain unchanged through expansion valve
H(7) = getFluidProperty(libLoc, 'Hmass', 'P', P(7), 'Q', 1, Fluid, 1, keepLibraryLoaded=true); % Enthalpy in evaporator, saturated vapor
H(8) = H(1); % Enthalpy at evaporator outlet, superheated vapor

% Calculate temperature and entropy for each state based on pressure and enthalpy
for i = 1:length(P)
    T(i) = getFluidProperty(libLoc, 'T',     'P', P(i), 'Hmass', H(i), Fluid, 1, keepLibraryLoaded=true); % Temperature at each state
    S(i) = getFluidProperty(libLoc, 'Smass', 'P', P(i), 'Hmass', H(i), Fluid, 1, keepLibraryLoaded=true); % Entropy at each state
end

% Set quality values for specific states
Q([1, 2, 3, 7, 8]) = 1; % Quality at superheated or saturated vapor states
Q([4, 5]) = 0;       % Quality at subcooled or saturated liquid states
Q(6) = getFluidProperty(libLoc, 'Q', 'P', P(6), 'H', H(6), Fluid, 1, keepLibraryLoaded=true); % Quality at mixture state

% Convert calculated properties to user-selected units
T = unit_convert_SI(T, T_unit, 'T', -1); % Convert temperature to selected unit
P = unit_convert_SI(P, P_unit, 'P', -1); % Convert pressure to selected unit
H = unit_convert_SI(H, H_unit, 'H', -1); % Convert enthalpy to selected unit
S = unit_convert_SI(unit_convert_SI(S, H_unit, 'S', -1), T_unit, 'S', -1); % Convert entropy to selected unit
%% Plot Design Points

% Use the calculated properties for design conditions
H_Design = H; % Enthalpy design values
P_Design = P; % Pressure design values
T_Design = T; % Temperature design values
S_Design = S; % Entropy design values

% Plotting the design cycle on the PH diagram
figure(hfig_PH);
hold on; % Hold on to the current figure
plot(H_Design, P_Design, 'r-o', LineWidth=1.5, MarkerSize=5, DisplayName="Cycle Design") % Plot design cycle

% Plotting the design cycle on the TS diagram
figure(hfig_TS); 
hold on; % Hold on to the current figure
plot(S_Design, T_Design, 'r-o', LineWidth=1.5, MarkerSize=5, DisplayName="Cycle Design") % Plot design cycle