%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set location of CoolProp library installation %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
libLoc = 'C:\Program Files\CoolProp\';

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
