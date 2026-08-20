
if ~exist("T_of_H_P", "var")

    libLoc = 'C:\Program Files (x86)\REFPROP\'; % Location for REFPROP install
    Fluid   = "R134a";                          % fluid name
    H_min   = 100000;                           % minimum enthalpy (kJ/kg)
    H_max   = 500000;                           % maximum enthalpy (kJ/kg)
    P_min   = 0.01e6;                           % minimum pressure (kPa)
    P_max   = 6e6;                              % maximum pressure (kPa)
    nRowsL  = 50;                               % number of rows in LUT for H below liquid saturation
    nRowsV  = 50;                               % number of rows in LUT for H above vapor saturation
    nCols   = 50;                               % number of columns in LUT for P
    outProp = "T";                              % output property symbol required by REFPROP
    xProp   = "H";                              % LUT x-axis property symbol required by REFPROP
    yProp   = "P";                              % LUT y-axis property symbol required by REFPROP

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % create the two phase lookup table class object %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    T_of_H_P = twoPhaseFluidLUT(outProp, xProp, yProp);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % create the lookup table using REFPROP %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp("Creating the LUT")
    tic
    T_of_H_P.createTable(libLoc, Fluid, [H_min, H_max], [P_min, P_max], nRowsL, nRowsV, nCols);
    toc
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % plot the LUT (phase diagram) %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    T_of_H_P.plotLUT;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % save the LUT for use in the future %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    T_of_H_P.saveLUT("toolbox\examples\LUT4TofHandP");

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % get the grid points to make sure our lookup function is what we expect %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    numPts = (nRowsL + nRowsV) * nCols;
    xVals  = reshape([T_of_H_P.LUT.x_liq; T_of_H_P.LUT.x_vap], numPts, 1);
    yVals  = reshape(repmat(T_of_H_P.LUT.y_vec, (nRowsL + nRowsV), 1), numPts, 1);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % get a random sample in space to test the robustness of the lookup function %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    numPts2 = 1000;
    xVals2  = randsample(linspace(H_min, H_max, numPts2), numPts2);
    yVals2  = randsample(logspace(log10(P_min), log10(P_max), numPts2), numPts2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% now do the calculation and look up the value you want at the given x, y inputs %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outVals = nan(1, numPts);
disp("Looking up " + numPts + " T(H, P) with the LUT")
tic
for ix = 1:numPts
    outVals(ix) = T_of_H_P.getFluidPropertyLUT(xVals(ix), yVals(ix));
end % end loop over number of points (ix)
toc

disp("Looking up " + numPts + " T(H, P) with the direct call to REFPROP")
tic
outValsOld = nan(1, numPts);
for ix = 1:numPts
    outValsOld(ix) = getFluidProperty(libLoc, "T", "H", xVals(ix), "P", yVals(ix), Fluid, 1, 1, 'MASS BASE SI');
end
toc

figure(2)
clf
hold on
xlabel("H")
ylabel("P")
zlabel("T")
plot3(xVals, yVals, outVals, "*", "LineWidth", 2)
plot3(xVals, yVals, outValsOld, "x", "LineWidth", 2)
legend("LUT", "Function")

figure(3)
clf
plot(outValsOld - outVals)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load the saved LUT for use %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp("Loading the saved file and repeating above process with random sampling of P and H data.")
pdt2 = twoPhaseFluidLUT;
pdt2.loadTable("toolbox\examples\LUT4TofHandP.mat");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get the same output values from the class %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outVals2 = nan(1, numPts2);
for jx = 1:numPts2
    outVals2(jx) = T_of_H_P.getFluidPropertyLUT(xVals2(jx), yVals2(jx));
end % end loop over number of points (ix)
outValsOld2 = nan(1, numPts2);
for jx = 1:numPts2
    outValsOld2(jx) = getFluidProperty(libLoc, "T", "H", xVals2(jx), "P", yVals2(jx), Fluid, 1, 1, 'MASS BASE SI');
end % end loop over number of points (ix)
figure(4)
clf
hold on
xlabel("H")
ylabel("P")
zlabel("T")
plot3(xVals2, yVals2, outVals2, "*", "LineWidth", 2)
plot3(xVals2, yVals2, outValsOld2, "x", "LineWidth", 2)
legend("LUT", "Function")

figure(5)
clf
plot(outValsOld2 - outVals2)
