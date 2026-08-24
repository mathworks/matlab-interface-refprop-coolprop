%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set up the necessary variables for LUT T(H, P) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
libLoc     = 'C:\Program Files (x86)\REFPROP\'; % Location for REFPROP install
Fluid      = "R134a";                           % fluid name
Comp       = 1;                                 % fluid composition (fractions of species - must sum to 1)
massOrMole = 1;                                 % REFPROP only: 0 -> Molar, 1 -> Mass 
x_min      = 100000;                            % minimum x value (e.g. enthalpy (kJ/kg))
x_max      = 500000;                            % maximum x value (e.g. enthalpy (kJ/kg))
y_min      = 0.01e6;                            % minimum y value (e.g. pressure (kPa))
y_max      = 6e6;                               % maximum y value (e.g. pressure (kPa))
nCols      = 100;                               % number of columns in LUT for y
nRowsL     = 100;                               % number of rows in LUT for x below liquid saturation
nRowsV     = 100;                               % number of rows in LUT for x above vapor saturation
nRowsD     = 100;                               % number of rows in LUT for x inside dome
outProp    = "T";                               % output property symbol required by REFPROP
xProp      = "H";                               % LUT x-axis property symbol required by REFPROP
yProp      = "P";                               % LUT y-axis property symbol required by REFPROP
units      = 'MASS BASE SI';                    % Units to use for REFPROP
numPts     = 1000;                              % number of points to look up using the LUT

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create the two phase lookup table class object %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
T_of_H_P = twoPhaseFluidLUT(outProp, xProp, yProp);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create the lookup table using REFPROP %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp("Creating the LUT")
tic
T_of_H_P.createLUT(libLoc, Fluid, [x_min, x_max], [y_min, y_max], nCols, nRowsL, nRowsV, nRowsD, Comp, massOrMole, units);
toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot the LUT (phase diagram) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
T_of_H_P.plotLUT;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save the LUT for use in the future %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
T_of_H_P.saveLUT("toolbox\examples\LUT4TofHandP");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get a random sample in space to test the robustness of the lookup function %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xVals  = randsample(linspace(x_min, x_max, numPts), numPts);
yVals  = randsample(logspace(log10(y_min), log10(y_max), numPts), numPts);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% now do the calculation and look up the value you want at the given x, y inputs %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outVals = nan(1, numPts);
disp("Looking up " + numPts + " " + outProp + "(" + xProp + ", " + yProp + ") with the LUT")
tic
for ix = 1:numPts
    outVals(ix) = T_of_H_P.getFluidPropertyLUT(xVals(ix), yVals(ix));
end % end loop over number of points (ix)
toc

%%%%%%%%%%%%%%%%%%
% load saved LUT %
%%%%%%%%%%%%%%%%%%
disp("Loading LUT for " + outProp + "(" + xProp + ", " + yProp + ")")
tic
T_of_H_P_Loaded = twoPhaseFluidLUT;
T_of_H_P_Loaded.loadLUT("toolbox\examples\LUT4TofHandP.mat")
toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get the same output values from the class %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outVals2 = nan(1, numPts);
disp("Looking up " + numPts + " " + outProp + "(" + xProp + ", " + yProp + ") with the LUT")
tic
for jx = 1:numPts
    outVals2(jx) = T_of_H_P_Loaded.getFluidPropertyLUT(xVals(jx), yVals(jx));
end % end loop over number of points (ix)
toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get the same output values directly from REFPROP %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outValsOld = nan(1, numPts);
disp("Looking up " + numPts + " " + outProp + "(" + xProp + ", " + yProp + ") with REFPROP")
tic
for ix = 1:numPts
    outValsOld(ix) = getFluidProperty(libLoc, outProp, xProp, xVals(ix), yProp, yVals(ix), Fluid, Comp, massOrMole, units);
end
toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot the different output values %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(2)
clf
hold on
xlabel(xProp)
ylabel(yProp)
zlabel(outProp)
title(outProp + "(" + xProp + ", " + yProp + ") with the LUT")
plot3(xVals, yVals, outVals,    "*", "LineWidth", 2)
plot3(xVals, yVals, outVals2,   "x", "LineWidth", 2)
plot3(xVals, yVals, outValsOld, "d", "LineWidth", 2)
legend("Calculated", "Loaded", "REFPROP")
ax = gca;
ax.YScale = "log";
view(3)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot the difference between output values %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(3)
clf
hold on
title("LUT vs REFPROP " + outProp + " calculation results")
xlabel("Points")
ylabel("(" + outProp + "_{REFPROP} - "  + outProp + "_{LUT}) / " + outProp + "_{REFPROP}" )
plot((outValsOld - outVals)  ./ outValsOld, "-" )
plot((outValsOld - outVals2) ./ outValsOld, "--")
legend("Calculated", "Loaded")


