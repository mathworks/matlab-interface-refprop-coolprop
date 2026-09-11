% Copyright 2025 The MathWorks, Inc.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set location of REFPROP library installation %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get Critical point of water - The output is the desired value,        %
% first input is CRIT, second input is empty, input values don't matter %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tCrit = getFluidProperty(libLoc, "T", "CRIT", 1, "", 1, "Water", 1, 1, "MKS");
disp("Critical Temperature = ")
disp(tCrit);
% Output is given as 1x1 array: tCrit = 647.0960

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get Triple point of water - The output is the desired value,          %
% first input is TRIP, second input is empty, input values don't matter %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tTrip = getFluidProperty(libLoc, "T", "TRIP", 0, "", nan, "Water", 1, 1, "MKS");
disp("Triple Point Temperature = ");
disp(tTrip);
% Output is given as 1x1 array: tTrip = 273.1600

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get the melting point of water - The output is the desired value, %
% the first input is the property value to find the melting value,  %
% the second input is empty and its value doesn't matter            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pMelt = getFluidProperty(libLoc, "P", "TMELT", 274, "", 328991, "Water", 1, 1, "MKS");
disp("Melting pressure at 274K = ")
disp(pMelt)
% Output is given as 1x1 array: pMelt = 640329.17765911

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To select a specific branch, use the special characters on the last input value %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sPH = getFluidProperty(libLoc, "S", "P", 300, "H", [100, 800], "Water", 1, 1, "MKS");
disp("Entropy:")
disp(sPH);
% Output is given as 1X2 array: sPH = [0.349994032961696, 2.25836610560853]

sPH = getFluidProperty(libLoc, "S", "P", 300, "H<", [100, 800], "Water", 1, 1, "MKS");
disp("Entropy:")
disp(sPH);
% Output is given as 1X2 array: sPH = [0.349994052255697, 2.22177013280536]

sPH = getFluidProperty(libLoc, "S", "P", 300, "H>", [100, 800], "Water", 1, 1, "MKS");
disp("Entropy:")
disp(sPH);
% Output is given as 1X2 array: sPH = [0.34999403295267, 2.221770408808]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% request multiple output properties %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[h1, s1, d1] = getFluidProperty(libLoc, 'H,S,D', 'T', [293.15 400.0 542.0], 'P', 101.325, 'Water', 1, 1, 'MKS');
disp("Enthalpy:")
disp(h1)
disp(newline + "Entropy:")
disp(s1)
disp(newline + "Density:")
disp(d1)
% output is given as 3 3x1 arrays: h1 = [  84.0073008508034
%                                        2730.30138592574
%                                        3012.04786856515]
%                                  s1 = [   0.29646283622616
%                                           7.49620215239088
%                                           8.09900566147266]
%                                  d1 = [ 998.20715046745
%                                           0.554943903490502
%                                           0.406296343124391]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% request multiple output properties with the output given as a struct %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outVal = getFluidProperty(libLoc, 'H,S,D', 'T', [293.15 400.0 542.0], 'P', 101.325, 'Water', 1, 1, 'MKS',...
                          outputAsStruct=true);
disp("Output")
disp(outVal)
disp(newline + "Enthalpy:")
disp(outVal.H)
disp(newline + "Entropy:")
disp(outVal.S)
disp(newline + "Density:")
disp(outVal.D)

% output is given a struct with fields: outVal = 
%                                                 H: [3×1 double]
%                                                 S: [3×1 double]
%                                                 D: [3×1 double]
%                                                 T: [293.15 400 542]
%                                                 P: 101.325

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% change the reference set point %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[h1, s1, d1] = getFluidProperty(libLoc, 'H,S,D', 'T', [293.15 400.0 542.0], 'P', 101.325, 'Water', 1, 1, 'MKS',...
                                referenceState='ASH');
disp("Using ASHRE reference point: h,s=0 @ -40C")
disp("Enthalpy:")
disp(h1)
disp(newline + "Entropy:")
disp(s1)
disp(newline + "Density:")
disp(d1)
% output is given as 3 3x1 arrays: h1 = [  84.0073008508034
%                                        2730.30138592574
%                                        3012.04786856515]
%                                  s1 = [   0.29646283622616
%                                           7.49620215239088
%                                           8.09900566147266]
%                                  d1 = [ 998.20715046745
%                                           0.554943903490502
%                                           0.406296343124391]

[h1, s1, d1] = getFluidProperty(libLoc, 'H,S,D', 'T', [293.15 400.0 542.0], 'P', 101.325, 'Water', 1, 1, 'MKS',...
                                referenceState='NBP');
disp("Using Normal Boiling Point(s) reference point: h,s=0 @ normal boiling points")
disp("Enthalpy:")
disp(h1)
disp(newline + "Entropy:")
disp(s1)
disp(newline + "Density:")
disp(d1)
% output is given as 3 3x1 arrays: h1 = [-335.050432246858
%                                        2311.24365282808
%                                        2592.99013546748]
%                                  s1 = [  -1.01045797632444
%                                           6.18928133984027
%                                           6.79208484892206]
%                                  d1 = [ 998.20715046745
%                                           0.554943903490502
%                                           0.406296343124391]

[h1, s1, d1] = getFluidProperty(libLoc, 'H,S,D', 'T', [293.15 400.0 542.0], 'P', 101.325, 'Water', 1, 1, 'MKS',...
                                referenceState='IIR');
disp("Using IIR Convention reference point: h=200kJ/kg, s=1 kJ/kg-K for sat. liquid @ 0C")
disp("Enthalpy:")
disp(h1)
disp(newline + "Entropy:")
disp(s1)
disp(newline + "Density:")
disp(d1)
% output is given as 3 3x1 arrays: h1 = [ 283.91175099254
%                                        2930.20583606748
%                                        3211.95231870688]
%                                  s1 = [   1.29660818416891
%                                           8.49634750033363
%                                           9.09915100941541]
%                                  d1 = [ 998.20715046745
%                                           0.554943903490502
%                                           0.406296343124391]

[h1, s1, d1] = getFluidProperty(libLoc, 'H,S,D', 'T', [293.15 400.0 542.0], 'P', 101.325, 'Water', 1, 1, 'MKS',...
                                referenceState='DEF');
disp("Using default reference point from fluid file. Compare to the output without hrf option used.")
disp("Enthalpy:")
disp(h1)
disp(newline + "Entropy:")
disp(s1)
disp(newline + "Density:")
disp(d1)
% output is given as 3 3x1 arrays: h1 = [  84.0073008508034
%                                        2730.30138592574
%                                        3012.04786856515]
%                                  s1 = [   0.29646283622616
%                                           7.49620215239088
%                                           8.09900566147266]
%                                  d1 = [ 998.20715046745
%                                           0.554943903490502
%                                           0.406296343124391]

[h1, s1, d1] = getFluidProperty(libLoc, 'H,S,D', 'T', [293.15 400.0 542.0], 'P', 101.325, 'Water', 1, 1, 'MKS',...
                                referenceState='OTH;10.0;1.0;323.15;101.325');
disp("Using User-defined reference point for real gas: H0=10.0 J/mol, S0=1.0 J/mol-K, T0 = 323.15K, P0 = 101.325kPa")
disp("Enthalpy:")
disp(h1)
disp(newline + "Entropy:")
disp(s1)
disp(newline + "Density:")
disp(d1)
% output is given as 3 3x1 arrays: h1 = [-124.856106424922
%                                        2521.43797865002
%                                        2803.18446128942]
%                                  s1 = [  -0.351796093457317
%                                           6.8479432227074
%                                           7.45074673178918]
%                                  d1 = [ 998.20715046745
%                                           0.554943903490502
%                                           0.406296343124391]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% request multiple output properties with the output given as a struct %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outVal = getFluidProperty(libLoc, 'H,S,D', 'T', [293.15 400.0 542.0], 'P', 101.325, 'Water', outputAsStruct=true);
disp("Output")
disp(outVal)
disp(newline + "Enthalpy:")
disp(outVal.H)
disp(newline + "Entropy:")
disp(outVal.S)
disp(newline + "Density:")
disp(outVal.D)

% output is given a struct with fields: outVal = 
%                                                 H: [3×1 double]
%                                                 S: [3×1 double]
%                                                 D: [3×1 double]
%                                                 T: [293.15 400 542]
%                                                 P: 101.325

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% keep the REFPROP library loaded and skip input checking for multiple calls where vectorizing does not make sense %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic
for ix = 1:100
    h_min = getFluidProperty(libLoc,'H', 'T', 293.15, 'P', 101.325, 'Water', 1, rapidMode=false);
    h_max = getFluidProperty(libLoc,'H', 'T', 542.0,  'P', 101.325, 'Water', 1, rapidMode=false);
    s_min = getFluidProperty(libLoc,'S', 'T', 293.15, 'P', 101.325, 'Water', 1, rapidMode=false);
    s_max = getFluidProperty(libLoc,'S', 'T', 542.0,  'P', 101.325, 'Water', 1, rapidMode=false);
    d_min = getFluidProperty(libLoc,'D', 'T', 293.15, 'P', 101.325, 'Water', 1, rapidMode=false);
    d_max = getFluidProperty(libLoc,'D', 'T', 542.0,  'P', 101.325, 'Water', 1, rapidMode=false);
end
t1 = toc;
disp("Time to query 600 individual values while loading and unloading the library and running input checks:")
disp(num2str(t1) + " seconds")
disp("h_min = " + num2str(h_min));
disp("h_max = " + num2str(h_max) + newline);
disp("s_min = " + num2str(s_min));
disp("s_max = " + num2str(s_max) + newline);
disp("d_min = " + num2str(d_min));
disp("d_max = " + num2str(d_max) + newline);
% output is given as:
% Time to query 600 individual values while loading and unloading the library:
% 4.3759 seconds
% h_min = 84.0073
% h_max = 3012.0479
% s_min = 0.29646
% s_max = 8.099
% d_min = 998.2072
% d_max = 0.4063

tic
for ix = 1:100
    h_min = getFluidProperty(libLoc,'H', 'T', 293.15, 'P', 101.325, 'Water', 1, rapidMode=true);
    h_max = getFluidProperty(libLoc,'H', 'T', 542.0,  'P', 101.325, 'Water', 1, rapidMode=true);
    s_min = getFluidProperty(libLoc,'S', 'T', 293.15, 'P', 101.325, 'Water', 1, rapidMode=true);
    s_max = getFluidProperty(libLoc,'S', 'T', 542.0,  'P', 101.325, 'Water', 1, rapidMode=true);
    d_min = getFluidProperty(libLoc,'D', 'T', 293.15, 'P', 101.325, 'Water', 1, rapidMode=true);
    d_max = getFluidProperty(libLoc,'D', 'T', 542.0,  'P', 101.325, 'Water', 1, rapidMode=true);
end
t2 = toc;

disp("Time to query 600 individual values while keeping the library loaded and skipping input checks:")
disp(num2str(t2) + " seconds")
disp("h_min = " + num2str(h_min));
disp("h_max = " + num2str(h_max) + newline);
disp("s_min = " + num2str(s_min));
disp("s_max = " + num2str(s_max) + newline);
disp("d_min = " + num2str(d_min));
disp("d_max = " + num2str(d_max) + newline);
% output is given as:
% Time to query 600 individual values while keeping the library loaded:
% 0.060821 seconds
% h_min = 84.0073
% h_max = 3012.0479
% s_min = 0.29646
% s_max = 8.099
% d_min = 998.2072
% d_max = 0.4063

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Request the pressure of Nitrogen at various melting temperatures %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Pmelt = getFluidProperty(libLoc, "P", "TMELT", (-195:1:-170)+273.15, "", 1, "Nitrogen", 1, 1, "MKS");
disp("Melting pressures (kPa) at various temperatures (K) for Nitrogen")
disp("Output:")
disp(Pmelt)
% output is given as:
% Pmelt =
% 
% 1.0e+05 *
% 
% 0.7441
% 0.7981
% 0.8526
% 0.9077
% 0.9633
% 1.0195
% 1.0762
% 1.1334
% 1.1912
% 1.2495
% 1.3083
% 1.3677
% 1.4276
% 1.4880
% 1.5489
% 1.6104
% 1.6723
% 1.7348
% 1.7979
% 1.8614
% 1.9255
% 1.9901
% 2.0552
% 2.1208
% 2.1869
% 2.2535

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Request the Sublimation temperature of water at various pressures %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Tsubl = getFluidProperty(libLoc, "T", "PSUBL", [611.2, 195.8, 76.0, 101.325], "", 1, "Water", 1, 1, "MOLAR BASE SI");
disp("Sublimation temperatures (K) at various pressures (Pa) for Water")
disp("Output:")
disp(Tsubl)

% Tsubl = 4×1
% 273.1509
% 259.9999
% 249.9983
% 252.9552

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% using parenthetical hOut options - looking for mass fraction of vapor for each constituent part of the mixture %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fluidString = 'R32;R125;R1234yf;R134a;R1234ze(E)';
composition = [0.26; 0.26; 0.2; 0.21; 0.07];

x_R32       = getFluidProperty(libLoc, 'xmassvap(1)', 'p', 74, 'Q', 0.2, fluidString, composition, 1, "MKS");
x_R125      = getFluidProperty(libLoc, 'xmassvap(2)', 'p', 74, 'Q', 0.2, fluidString, composition, 1, "MKS");
x_R1234yf   = getFluidProperty(libLoc, 'xmassvap(3)', 'p', 74, 'Q', 0.2, fluidString, composition, 1, "MKS");
x_R134a     = getFluidProperty(libLoc, 'xmassvap(4)', 'p', 74, 'Q', 0.2, fluidString, composition, 1, "MKS");
x_R1234zeE  = getFluidProperty(libLoc, 'xmassvap(5)', 'p', 74, 'Q', 0.2, fluidString, composition, 1, "MKS");

disp("Mass fraction of vapor for each consituient")
disp("Output:")
disp("R32:        " + num2str(x_R32))
disp("R125:       " + num2str(x_R125))
disp("R1234yf:    " + num2str(x_R1234yf))
disp("R134a:      " + num2str(x_R134a))
disp("R1234ze(E): " + num2str(x_R1234zeE))

% R32:        0.23941
% R125:       0.4154
% R1234yf:    0.18404
% R134a:      0.12331
% R1234ze(E): 0.037848

[x_R32, x_R125, x_R1234yf, x_R134a, x_R1234zeE] = getFluidProperty(libLoc,...
                                                     'xmassliq(1),xmassliq(2),xmassliq(3),xmassliq(4),xmassliq(5)',...
                                                     'p', 74, 'Q', 0.2, fluidString, composition, 1, "MKS");
disp(newline + "Mass fraction of liquid for each consituient")
disp("Output:")
disp("R32:        " + num2str(x_R32))
disp("R125:       " + num2str(x_R125))
disp("R1234yf:    " + num2str(x_R1234yf))
disp("R134a:      " + num2str(x_R134a))
disp("R1234ze(E): " + num2str(x_R1234zeE))

% R32:        0.11455
% R125:       0.29849
% R1234yf:    0.24806
% R134a:      0.24543
% R1234ze(E): 0.093463

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% change the equation of state used %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(newline + "Using Peng-Robinson for all calcuations")
h1 = getFluidProperty(libLoc, 'H', 'T', 293.15, 'P', 101.325, 'Water', 1, 1, 'MKS', equationOfState='PR2');
disp("Output:")
disp(h1);
% h1 = -12.7539

disp(newline + "Using Peng-Robinson with translation term deactivated")
h1 = getFluidProperty(libLoc, 'H', 'T', 293.15, 'P', 101.325, 'Water', 1, 1, 'MKS', equationOfState='PR3');
disp("Output:")
disp(h1);
% h1 = -12.7518

disp(newline + "Using GERG-2008")
h1 = getFluidProperty(libLoc, 'H', 'T', 293.15, 'P', 101.325, 'Water', 1, 1, 'MKS', equationOfState='GERG1');
disp("Output:")
disp(h1);
% h1 = -2.4602e+03

