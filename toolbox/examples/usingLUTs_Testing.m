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
outProp    = "S";                               % output property symbol required by REFPROP
xProp      = "H";                               % LUT x-axis property symbol required by REFPROP
yProp      = "P";                               % LUT y-axis property symbol required by REFPROP
units      = 'MASS BASE SI';                    % Units to use for REFPROP

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create the two phase lookup table class object %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
myLUT = twoPhaseFluidLUT(outProp, xProp, yProp);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create the lookup table using REFPROP %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp("Creating the LUT")
myLUT.createLUT(libLoc, Fluid, [x_min, x_max], [y_min, y_max], nCols, nRowsL, nRowsV, nRowsD, Comp, massOrMole, units);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot the LUT (phase diagram) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
myLUT.plotLUT;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get a random sample in space to test the robustness of the lookup function %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numPts = 1000;
xVals  = randsample(linspace(x_min, x_max, numPts), numPts);
yVals  = randsample(logspace(log10(y_min), log10(y_max), numPts), numPts);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% now do the calculation and look up the value you want at the given x, y inputs %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outVals = nan(1, numPts);
disp("Looking up " + numPts + " " + outProp + "(" + xProp + ", " + yProp + ") with the LUT")
for ix = 1:numPts
    outVals(ix) = myLUT.getFluidPropertyLUT(xVals(ix), yVals(ix));
end % end loop over number of points (ix)

outValsOld = nan(1, numPts);
for jx = 1:numPts
    outValsOld(jx) = getFluidProperty(libLoc, outProp, xProp, xVals(jx), yProp, yVals(jx), Fluid, Comp, massOrMole, units);
end % end loop over number of points (jx)

figure(2)
clf
hold on
xlabel(xProp)
ylabel(yProp)
zlabel(outProp)
title(outProp + "(" + xProp + ", " + yProp + ") with the LUT")
plot3(xVals, yVals, outVals, "*", "LineWidth", 2)
plot3(xVals, yVals, outValsOld, "x", "LineWidth", 2)
legend("LUT", "Function")
ax = gca;
ax.YScale = "log";
view(3)

figure(3)
clf
hold on
xlabel("Points")
ylabel("(" + outProp + "_{REFPROP} - "  + outProp + "_{LUT}) / " + outProp + "_{REFPROP}" )
plot((outValsOld - outVals) ./ outValsOld)




