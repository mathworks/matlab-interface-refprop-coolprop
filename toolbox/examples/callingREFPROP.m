%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set location of CoolProp library installation %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
libLoc = 'C:\Program Files (x86)\REFPROP\';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get the specific enthalpy of water at STP in J/mol: %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h1 = getFluidProperty(libLoc, 'H', 'T', 293.15, 'P', 101.325, 'Water', 1, 1, 'MKS');
disp("h1 = ");
disp(h1);
% Output is given as a 1x1 array: h1 = 84.0073

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get specific enthalpy of water at STP in J/mol at three different temperatures for a single pressure: %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h1 = getFluidProperty(libLoc, 'H', 'T', [293.15, 400.0, 542.0], 'P', 101.325, 'Water', 1, 1, 'MKS');
disp("h1 = ");
disp(h1);
% Output is given as a 3x1 column vector: h1 = [  84.0073;
%                                               2730.3014;
%                                               3012.0479]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get specific enthalpy of water at STP in J/mol at 1 temperature and 2 different pressures: %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h1 = getFluidProperty(libLoc, 'H', 'T', 293.15, 'P', [101.325 104.1], 'Water', 1, 1, 'MKS');
disp("h1 = ");
disp(h1);
% Output is given as a 1x2 row vector: h1 = [84.0073, 84.0099]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get specific enthalpy of water at STP in J/mol at 3 different temperatures and 2 different pressures: %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h1 = getFluidProperty(libLoc, 'H', 'T', [293.15, 400.0, 542.0], 'P', [101.325, 104.1], 'Water', 1, 1, 'MKS');
disp("h1 = ");
disp(h1);
% Output is given as a 3x2 array: h1 = [  84.0073,   84.0099;
%                                       2730.3014, 2730.0376;
%                                       3012.0479, 3011.9667]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get specific enthalpy for Oxygen/Nitrogen mixture at STP in J/mol: %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h1 = getFluidProperty(libLoc, 'H', 'T', 293.15, 'P', 101.325, 'Oxygen;Nitrogen', [0.2, 0.8], 1, 'MKS');
disp("h1 = ");
disp(h1);
% Output is given as a 1x1 array: h1 = 295.6969

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get specific enthalpy for Oxygen/Nitrogen mixture at STP in J/mol: %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h1 = getFluidProperty(libLoc, 'H', 'T', [293.15, 400.00, 542.0], 'P', [101.325, 104.1],...
                     'Nitrogen;Oxygen;Hydrogen;Water', [0.71, 0.16, 0.1, 0.03], 1, 'MKS');
disp("h1 = ");
disp(h1);
% Output is given as a 3x2 array: h1 = [371.2969, 371.2902;
%                                       493.3500, 493.3471;
%                                       657.9322, 657.9316]
                                                                                                                 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get specific enthalpy for Gulf Coast predefined mixture (Code detects .mix extension in the input species string): %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h1 = getFluidProperty(libLoc, 'H', 'T', 300, 'P', 101.325, 'GLFCOAST.MIX', 1, 1, 'MASS BASE SI');
disp("h1 = ");
disp(h1);
% Output is given as a 1x1 array: h1 = 888684.3501
