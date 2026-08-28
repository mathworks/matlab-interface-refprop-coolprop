%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set up the necessary variables for LUT T(H, P) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
libLoc     = 'C:\Program Files (x86)\REFPROP\'; % Location for REFPROP install
Fluid      = "R134a";                           % fluid name
Comp       = 1;                                 % fluid composition (fractions of species - must sum to 1)
massOrMole = 1;                                 % REFPROP only: 0 -> Molar, 1 -> Mass 
x_min      = 100000;                            % minimum enthalpy (kJ/kg)
x_max      = 500000;                            % maximum enthalpy (kJ/kg)
y_min      = 0.01e6;                            % minimum pressure (kPa)
y_max      = 6e6;                               % maximum pressure (kPa)
nCols      = 100;                               % number of columns in LUT for y
nRowsL     =  50;                               % number of rows in LUT for x below liquid saturation
nRowsV     =  50;                               % number of rows in LUT for x above vapor saturation
nRowsD     =   5;                               % number of rows in LUT for x inside dome
outProp    = "T";                               % output property symbol required by REFPROP
xProp      = "H";                               % LUT x-axis property symbol required by REFPROP
yProp      = "P";                               % LUT y-axis property symbol required by REFPROP
units      = 'MASS BASE SI';                    % REFPROP ONLY: Units to use

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create the two phase lookup table class object %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
myLUT = twoPhaseFluidLUT(outProp, xProp, yProp);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create the lookup table using REFPROP %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp("Creating the LUT")
tic
myLUT.createLUT(libLoc, Fluid, [x_min, x_max], [y_min, y_max], nCols, nRowsL, nRowsV, nRowsD, Comp, massOrMole, units);
toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot the LUT (phase diagram) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
myLUT.plotLUT;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save the LUT for use in the future %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
myLUT.saveLUT("toolbox\examples\LUT4TofHandP");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get the grid points to make sure our lookup function is what we expect %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numPts = (nRowsL + nRowsV + nRowsD) * nCols;
xVals  = reshape([myLUT.LUT.x_liq; myLUT.LUT.x_dome; myLUT.LUT.x_vap], numPts, 1);
yVals  = reshape(repmat(myLUT.LUT.y_vec, (nRowsL + nRowsV + nRowsD), 1), numPts, 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get a random sample in space to test the robustness of the lookup function %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numPts2 = 1000;
xVals2  = randsample(linspace(x_min, x_max, numPts2), numPts2);
yVals2  = randsample(logspace(log10(y_min), log10(y_max), numPts2), numPts2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% now do the calculation and look up the value you want at the given x, y inputs %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outVals = nan(1, numPts);
disp("Looking up " + numPts + " " + outProp + "(" + xProp + ", " + yProp + ") with the LUT")
tic
for ix = 1:numPts
    outVals(ix) = myLUT.getFluidPropertyLUT(xVals(ix), yVals(ix));
end % end loop over number of points (ix)
toc

disp("Looking up " + numPts + " " + outProp + "(" + xProp + ", " + yProp + ") with the direct call to REFPROP")
tic
outValsOld = nan(1, numPts);
for ix = 1:numPts
    outValsOld(ix) = getFluidProperty(libLoc, outProp, xProp, xVals(ix), yProp, yVals(ix), Fluid, Comp, massOrMole, units);
end
toc

figure(2)
clf
hold on
xlabel(xProp)
ylabel(yProp)
zlabel(outProp)
plot3(xVals, yVals, outVals,    "*", "LineWidth", 2)
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load the saved LUT for use %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp("Loading the saved file and repeating above process with random sampling of P and H data.")
myLUT2 = twoPhaseFluidLUT;
myLUT2.loadLUT("toolbox\examples\LUT4TofHandP.mat");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get the same output values from the class %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outVals2 = nan(1, numPts2);
for jx = 1:numPts2
    outVals2(jx) = myLUT2.getFluidPropertyLUT(xVals2(jx), yVals2(jx));
end % end loop over number of points (ix)
outValsOld2 = nan(1, numPts2);
for jx = 1:numPts2
    outValsOld2(jx) = getFluidProperty(libLoc, outProp, xProp, xVals2(jx), yProp, yVals2(jx), Fluid, Comp, massOrMole, units);
end % end loop over number of points (jx)
figure(4)
clf
hold on
xlabel(xProp)
ylabel(yProp)
zlabel(outProp)
plot3(xVals2, yVals2, outVals2,    "*", "LineWidth", 2)
plot3(xVals2, yVals2, outValsOld2, "x", "LineWidth", 2)
legend("LUT", "Function")
ax = gca;
ax.YScale = "log";
view(3)

figure(5)
clf
hold on
xlabel("Points")
ylabel("(" + outProp + "_{REFPROP} - "  + outProp + "_{LUT}) / " + outProp + "_{REFPROP}" )
plot((outValsOld2 - outVals2) ./ outValsOld2)




