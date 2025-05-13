
% Copyright 2025 The MathWorks, Inc.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set location of CoolProp library installation %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
userName = 'kmcgarri';
libLoc   = ['C:\Users\' userName '\AppData\Roaming\CoolProp']; % default CoolProp install location

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get the specific enthalpy of water at STP in J/mol: %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h1 = getFluidProperty(libLoc, 'Hmass', 'T', 293.15, 'P', 101325, 'Water', 1);
disp("h1 = ");
disp(h1);
% Output is given as a 1x1 array: h1 = 84007.3009

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get specific enthalpy of water at STP in J/mol at three different temperatures for a single pressure: %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h1 = getFluidProperty(libLoc, 'Hmass', 'T', [293.15, 400.0, 542.0], 'P', 101325, 'Water', 1);
disp("h1 = ");
disp(h1);
% Output is given as a 3x1 column vector: h1 = [  84007.3009;
%                                               2730301.3859;
%                                               3012047.8685]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get specific enthalpy of water at STP in J/mol at 1 temperature and 2 different pressures: %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h1 = getFluidProperty(libLoc, 'Hmolar', 'T', 293.15, 'P', [101325, 104100], 'Water', 1 );
disp("h1 = ");
disp(h1);
% Output is given as a 1x2 row vector: h1 = [1513.4140, 1513.4611]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get specific enthalpy of water at STP in J/mol at 3 different temperatures and 2 different pressures: %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h1 = getFluidProperty(libLoc, 'Hmolar', 'T', [293.15, 400.0, 542.0], 'P', [101325, 104100], 'Water', 1);
disp("h1 = ");
disp(h1);
% Output is given as a 3x2 array: h1 = [ 1513.4140,  1513.4611;
%                                       49187.1112, 49182.3587;
%                                       54262.8496, 54261.3874]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get specific enthalpy for Oxygen/Nitrogen mixture at STP in J/mol: %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h1 = getFluidProperty(libLoc, 'Hmolar', 'T', 293.15, 'P', 101325, 'Nitrogen;Oxygen;Hydrogen;Water',...
                      [0.71, 0.16, 0.1, 0.03]);
disp("h1 = ");
disp(h1);
% Output is given as a 1x1 array: h1 = 9374.9875

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get specific enthalpy for Oxygen/Nitrogen mixture at STP in J/mol: %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h1 = getFluidProperty(libLoc, 'Hmolar', 'T', [293.15, 300.00, 310.0], 'P', [101325, 104100],...
                      'Nitrogen;Oxygen;Hydrogen;Water', [0.71, 0.16, 0.1, 0.03]);
disp("h1 = ");
disp(h1);
% Output is given as a 3x2 array: h1 = [ 9374.9875,  9343.7779;
%                                        9762.2208,  9762.0559;
%                                       10055.4953, 10055.3424]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% keep the CoolProp library loaded for multiple calls where vectorizing does not make sense %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic
for ix = 1:10
    T_min = getFluidProperty(libLoc,'Tmin', "", [], "", [], 'R410A', 1);
    T_max = getFluidProperty(libLoc,'Tmax', "", [], "", [], 'R410A', 1);
    h_min = getFluidProperty(libLoc,'H', 'T', T_min, 'P', 800000, 'R410A', 1);
    h_max = getFluidProperty(libLoc,'H', 'T', T_max, 'P', 800000, 'R410A', 1);
end
t1 = toc;
disp("Time to query 40 individual values while loading and unloading the library:")
disp(num2str(t1) + " seconds")
disp("T_min = " + num2str(T_min));
disp("T_max = " + num2str(T_max));
disp("h_min = " + num2str(h_min));
disp("h_max = " + num2str(h_max) + newline);
% output is given as:
% Time to query 40 individual values while loading and unloading the library:
% 18.2734 seconds
% T_min = 200
% T_max = 500
% h_min = 97296.6733
% h_max = 650989.485

tic
for ix = 1:10
    T_min = getFluidProperty(libLoc,'Tmin', "", [], "", [], 'R410A', 1, keepLibraryLoaded=true);
    T_max = getFluidProperty(libLoc,'Tmax', "", [], "", [], 'R410A', 1, keepLibraryLoaded=true);
    h_min = getFluidProperty(libLoc,'H', 'T', T_min, 'P', 800000, 'R410A', 1, keepLibraryLoaded=true);
    h_max = getFluidProperty(libLoc,'H', 'T', T_max, 'P', 800000, 'R410A', 1, keepLibraryLoaded=true);
end
t2 = toc;

disp("Time to query 40 individual values while keeping the library loaded:")
disp(num2str(t2) + " seconds")
disp("T_min = " + num2str(T_min));
disp("T_max = " + num2str(T_max));
disp("h_min = " + num2str(h_min));
disp("h_max = " + num2str(h_max));
% output is given as:
% Time to query 40 individual values while keeping the library loaded:
% 0.51861 seconds
% T_min = 200
% T_max = 500
% h_min = 97296.6733
% h_max = 650989.485

%%%%%%%%%%%%%%%%%%%%%%
% unload the library %
%%%%%%%%%%%%%%%%%%%%%%
unloadlibrary('CoolProp')
