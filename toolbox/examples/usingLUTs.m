libLoc = 'C:\Program Files (x86)\REFPROP\'; % Location for REFPROP install
Fluid   = "R134a";                          % fluid name
H_min   = 100000;                           % minimum enthalpy (kJ/kg)
H_max   = 500000;                           % maximum enthalpy (kJ/kg)
P_min   = 0.01e6;                           % minimum pressure (kPa)
P_max   = 6e6;                              % maximum pressure (kPa)
nRowsL  = 25;                               % number of rows in LUT for H below liquid saturation
nRowsV  = 25;                               % number of rows in LUT for H above vapor saturation
nCols   = 50;                               % number of columns in LUT for P
outProp = "T";                              % output property symbol required by REFPROP
xProp   = "H";                              % LUT x-axis property symbol required by REFPROP
yProp   = "P";                              % LUT y-axis property symbol required by REFPROP

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create the two phase lookup table class object %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pdt = twoPhaseFluidLUT(outProp, xProp, yProp);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create the lookup table using REFPROP %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pdt.createTable(libLoc, Fluid, [H_min, H_max], [P_min, P_max], nRowsL, nRowsV, nCols);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot the LUT (phase diagram) %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pdt.plotLUT;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save the LUT for use in the future %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pdt.saveLUT("toolbox\examples\LUT4TofHandP");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% now do the calculation and look up the value you want at the given x, y inputs %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numPts  = 100000;
xVals   = randsample(linspace(H_min, H_max, numPts), numPts);
yVals   = randsample(logspace(log10(P_min), log10(P_max), numPts), numPts);
outVals = nan(1, numPts);

for ix = 1:numPts
    outVals(ix) = pdt.getFluidPropertyLUT(xVals(ix), yVals(ix));
end % end loop over number of points (ix)

figure(2)
clf
hold on
plot3(xVals, yVals, outVals, "*", "LineWidth", 2)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load the saved LUT for use %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pdt2 = twoPhaseFluidLUT;
pdt2.loadTable("toolbox\examples\LUT4TofHandP.mat");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get the same output values from the class %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outVals2 = nan(1, numPts);
for ix = 1:numPts
    outVals2(ix) = pdt2.getFluidPropertyLUT(xVals(ix), yVals(ix));
end % end loop over number of points (ix)
plot3(xVals, yVals, outVals2, "x", "LineWidth", 2)

