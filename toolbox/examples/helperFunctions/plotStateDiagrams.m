% Copyright 2025 The MathWorks, Inc.

function [hfig_PH, hfig_TS] = plotStateDiagrams(libLoc, Fluid, P_min, P_max, H_min, H_max, P_unit, H_unit, T_unit)
% Plot PH & TS Diagrams in custom units

% libLoc = 'C:\Program Files (x86)\REFPROP 10.0\';
% libLoc = 'C:\Users\ytang\AppData\Roaming\CoolProp';
% Fluid   = "R134a";
% P_min   = 1e4;  % Pa
% P_max   = 6e6;  % Pa
% H_min   = 1e5;  % J/kg
% H_max   = 5e5;  % J/kg
% P_unit  = "Pa";
% H_unit  = "J/kg";
% T_unit  = "K";

%% Critical Point
    [P_crit, H_crit, T_crit, S_crit] = find_critical_states(Fluid, libLoc);

%% PH Diagram Calculation

    % Convert pressure and enthalpy to SI units
    P_min = unit_convert_SI(P_min, P_unit, 'p', 1); % minimum pressure
    P_max = unit_convert_SI(P_max, P_unit, 'p', 1); % maximum pressure
    H_min = unit_convert_SI(H_min, H_unit, 'h', 1); % minimum enthalpy
    H_max = unit_convert_SI(H_max, H_unit, 'h', 1); % maximum enthalpy   
  
    % Define P-H Grid & T-contour
    H_vec = linspace(H_min, H_max, 200);                    % J/kg, enthalpy vector
    P_vec = 10.^linspace(log10(P_min), log10(P_max), 200);  %   Pa, pressure vector
    [H_grid, P_grid] = meshgrid(H_vec, P_vec);              % enthalpy-pressure grid
    if contains(libLoc, 'refprop', 'IgnoreCase', true)
        T_contr = getFluidProperty(libLoc, 'T', 'H', H_vec, 'P', P_vec, Fluid, 1, 1, 'MASS BASE SI');  % K, temperature contour data
    elseif contains(libLoc, 'coolprop', 'IgnoreCase', true)
        T_contr = getFluidProperty(libLoc, 'T', 'Hmass', H_vec, 'P', P_vec, Fluid, 1, keepLibraryLoaded=true);  % K, temperature contour data
    end % end if REFPROP, else CoolProp

    % Find Critical Point & Phase Line
    P_line0  = 10.^(linspace(log10(min(P_vec)), log10(P_crit), 200));
    P_line1  = 10.^(linspace(log10(P_crit), log10(min(P_vec)), 200));
    if contains(libLoc, 'refprop', 'IgnoreCase', true)
        H_line0 = getFluidProperty(libLoc, 'H', 'Q', 0, 'P', P_line0, Fluid, 1, 1, 'MASS BASE SI');
        H_line1 = getFluidProperty(libLoc, 'H', 'Q', 1, 'P', P_line1, Fluid, 1, 1, 'MASS BASE SI');
    elseif contains(libLoc, 'coolprop', 'IgnoreCase', true)
        H_line0 = getFluidProperty(libLoc, 'Hmass', 'Q', 0, 'P', P_line0, Fluid, 1, keepLibraryLoaded=true);
        H_line1 = getFluidProperty(libLoc, 'Hmass', 'Q', 1, 'P', P_line1, Fluid, 1, keepLibraryLoaded=true);
    end % end if REFPROP, else CoolProp

%% TS Diagram Calculation

    % Estimate TS boundary from P & H limits
    if contains(libLoc, 'refprop', 'IgnoreCase', true)
        T_min = getFluidProperty(libLoc, 'T', 'P', P_max / 2, 'H', H_min, Fluid, 1, 1, 'MASS BASE SI');
        T_max = getFluidProperty(libLoc, 'T', 'P', P_max / 2, 'H', H_max, Fluid, 1, 1, 'MASS BASE SI');
        S_min = getFluidProperty(libLoc, 'S', 'P', P_min * 2, 'H', H_min, Fluid, 1, 1, 'MASS BASE SI');
        S_max = getFluidProperty(libLoc, 'S', 'P', P_min * 2, 'H', H_max, Fluid, 1, 1, 'MASS BASE SI');
    elseif contains(libLoc, 'coolprop', 'IgnoreCase', true)
        T_min = getFluidProperty(libLoc, 'T',     'P', P_max / 2, 'Hmass', H_min, Fluid, 1, keepLibraryLoaded=true);
        T_max = getFluidProperty(libLoc, 'T',     'P', P_max / 2, 'Hmass', H_max, Fluid, 1, keepLibraryLoaded=true);
        S_min = getFluidProperty(libLoc, 'Smass', 'P', P_min * 2, 'Hmass', H_min, Fluid, 1, keepLibraryLoaded=true);
        S_max = getFluidProperty(libLoc, 'Smass', 'P', P_min * 2, 'Hmass', H_max, Fluid, 1, keepLibraryLoaded=true);
    end % end if REFPROP, else CoolProp
    T_min = round(T_min, -1);
    T_max = round(T_max, -1);
    S_min = round(S_min, -1);
    S_max = round(S_max, -1);

    % Define T-S Grid & P-contour
    S_vec = linspace(S_min, S_max, 200);
    T_vec = linspace(T_min, T_max, 200);
    [S_grid, T_grid] = meshgrid(S_vec, T_vec);
    warning off
    if contains(libLoc, 'refprop', 'IgnoreCase', true)
        P_contr = getFluidProperty(libLoc, 'P', 'S', S_vec, 'T', T_vec, Fluid, 1, 1, 'MASS BASE SI');  % Pa
    elseif contains(libLoc, 'coolprop', 'IgnoreCase', true)
        P_contr = getFluidProperty(libLoc, 'P', 'Smass', S_vec, 'T', T_vec, Fluid, 1, keepLibraryLoaded=true);  % Pa
    end % end if REFPROP, else CoolProp
    warning on

    % Find Critical Point & Phase Line
    T_line0 = linspace(min(T_vec), T_crit, 200);
    T_line1 = linspace(T_crit, min(T_vec), 200);
    if contains(libLoc, 'refprop', 'IgnoreCase', true)
        S_line0 = getFluidProperty(libLoc, 'S', 'Q', 0, 'T', T_line0, Fluid, 1, 1, 'MASS BASE SI');
        S_line1 = getFluidProperty(libLoc, 'S', 'Q', 1, 'T', T_line1, Fluid, 1, 1, 'MASS BASE SI');
    elseif contains(libLoc, 'coolprop', 'IgnoreCase', true)
        S_line0 = getFluidProperty(libLoc, 'Smass', 'Q', 0, 'T', T_line0, Fluid, 1, keepLibraryLoaded=true);
        S_line1 = getFluidProperty(libLoc, 'Smass', 'Q', 1, 'T', T_line1, Fluid, 1, keepLibraryLoaded=true);
    end % end if REFPROP, else CoolProp

%% Unit Conversion

    % Convert pressure, enthalpy & temperature contour to custom units
    P_line0 = unit_convert_SI(P_line0, P_unit, 'p', -1);
    P_line1 = unit_convert_SI(P_line1, P_unit, 'p', -1);
    P_crit  = unit_convert_SI(P_crit , P_unit, 'p', -1);    
    P_grid  = unit_convert_SI(P_grid , P_unit, 'p', -1);    
    H_line0 = unit_convert_SI(H_line0, H_unit, 'h', -1);
    H_line1 = unit_convert_SI(H_line1, H_unit, 'h', -1);
    H_crit  = unit_convert_SI(H_crit , H_unit, 'h', -1);
    H_grid  = unit_convert_SI(H_grid , H_unit, 'h', -1);
    T_contr = unit_convert_SI(T_contr, T_unit, 'T', -1);

    % Convert temperature, entropy and pressure contour to custom units
    T_line0 = unit_convert_SI(T_line0, T_unit, 'T', -1);
    T_line1 = unit_convert_SI(T_line1, T_unit, 'T', -1);
    T_crit  = unit_convert_SI(T_crit,  T_unit, 'T', -1);    
    T_grid  = unit_convert_SI(T_grid,  T_unit, 'T', -1);    
    S_line0 = unit_convert_SI(unit_convert_SI(S_line0, H_unit, 's', -1), T_unit, 's', -1);
    S_line1 = unit_convert_SI(unit_convert_SI(S_line1, H_unit, 's', -1), T_unit, 's', -1);
    S_crit  = unit_convert_SI(unit_convert_SI(S_crit,  H_unit, 's', -1), T_unit, 's', -1);
    S_grid  = unit_convert_SI(unit_convert_SI(S_grid,  H_unit, 's', -1), T_unit, 's', -1);
    P_contr = unit_convert_SI(P_contr, P_unit, 'p', -1);
    
%% Plot PH Diagram

    % Contour
    hfig_PH = figure;
    clf; 
    box on; 
    hold on;
    set(gcf, 'Visible', 'on')
    [~, c] = contour(H_grid, P_grid, T_contr');

    Tmin = round(min(T_contr, [], "all"), -1);
    Tmax = round(max(T_contr, [], "all"), -1);
    c.LevelList = Tmin:10:Tmax;

    ax = gca;
    ax.YScale = "log";

    % Phase Line
    plot([H_line0, H_crit, H_line1], [P_line0, P_crit, P_line1], 'k-', LineWidth=2)
    hold off

    % Labels
    xlabel("Specific Enthalpy (" + H_unit + ")")
    ylabel("Pressure (" + P_unit + ")")
    title("PH Diagram (" + Fluid + ")")
    legend("Iso-Temperature Contour", Location="northwest")

%% Plot TS Diagram

    % Contour 
    hfig_TS = figure;
    clf; 
    box on; 
    hold on;
    set(gcf,'Visible','on')
    [~, c] = contour(S_grid, T_grid, P_contr');

    P_level = reshape([1, 2, 5]' * 10.^(-8:8), [], 1);
    c.LevelList = P_level;

    ax = gca;
    ax.YScale = "linear";

    % Phase Line
    plot([S_line0, S_crit, S_line1], [T_line0, T_crit, T_line1], 'k-', LineWidth=2)
    hold off

    % Labels
    xlabel("Specific Entropy (" + H_unit + "/" + T_unit + ")")
    ylabel("Temperature (" + T_unit + ")")
    title("TS Diagram (" + Fluid + ")")
    legend("Iso-Pressure Contour", Location="northwest")
end % end plotStateDiagrams