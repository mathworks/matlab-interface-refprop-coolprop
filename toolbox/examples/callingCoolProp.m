
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get Critical point of water - The output is the desired value,        %
% first input is CRIT, second input is empty, input values don't matter %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tCrit = getFluidProperty(libLoc, "TCRIT", "", 1, "", 1, "Water", 1);
disp("Critical Temperature = ")
disp(tCrit);
% Output is given as 1x1 array: tCrit = 647.0960

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get Triple point of water - The output is the desired value,          %
% first input is TRIP, second input is empty, input values don't matter %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tTrip = getFluidProperty(libLoc, "TTRIPLE", "", 0, "", nan, "Water", 1);
disp("Triple Point Temperature = ");
disp(tTrip);
% Output is given as 1x1 array: tTrip = 273.1600

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% request multiple output properties %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[h1, s1, d1] = getFluidProperty(libLoc, 'H,S,D', 'T', [293.15 400.0 542.0], 'P', 101.325, 'Water',...
                                keepLibraryLoaded=true);
disp("Enthalpy:")
disp(h1)
disp(newline + "Entropy")
disp(s1)
disp(newline + "Density")
disp(d1)
% output is given as 3 3x1 arrays: h1 = [  84007.3008506628
%                                        2730301.38592019
%                                        3012047.86854244]
%                                  s1 = [    296.46283622518
%                                           7496.20215237541
%                                           8099.00566142102]
%                                  d1 = [    998.207150467928
%                                              0.554943903490499
%                                              0.40629634312439]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% request multiple output properties with the output given as a struct %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outVal = getFluidProperty(libLoc, 'H,S,D', 'T', [293.15 400.0 542.0], 'P', 101.325, 'Water', keepLibraryLoaded=true,...
                          outputAsStruct=true);
disp("Output")
disp(outVal)
disp(newline + "Enthalpy:")
disp(outVal.H)
disp(newline + "Entropy:")
disp(outVal.S)
disp(newline + "Density:")
disp(outVal.D)

%    output is given a struct with fields: outVal = 
%                                                    H: [3×1 double]
%                                                    S: [3×1 double]
%                                                    D: [3×1 double]
%                                                    T: [293.15 400 542]
%                                                    P: 101.325

