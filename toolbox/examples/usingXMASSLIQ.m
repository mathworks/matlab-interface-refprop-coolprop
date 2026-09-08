clc
clearvars

libLoc = 'C:\Program Files (x86)\REFPROP\';
unit = 'SI WITH C';
ref  = 'R448A.mix';
fluidString = 'R32;R125;R1234yf;R134a;R1234ze(E)';
composition = [0.26;0.26;0.2;0.21;0.07];
p_suc = getFluidProperty(libLoc, 'P', 'T', -46, 'Q', 1, ref,1, 1, unit);
%get mass fraction at specified state
x_R32      = getFluidProperty(libLoc, 'xmassliq(1)', 'p', p_suc, 'Q', 0.2, fluidString, composition, 1, unit);
x_R125     = getFluidProperty(libLoc, 'xmassliq(2)', 'p', p_suc, 'Q', 0.2, fluidString, composition, 1, unit);
x_R1234yf  = getFluidProperty(libLoc, 'xmassliq(3)', 'p', p_suc, 'Q', 0.2, fluidString, composition, 1, unit);
x_R134a    = getFluidProperty(libLoc, 'xmassliq(4)', 'p', p_suc, 'Q', 0.2, fluidString, composition, 1, unit);
x_R1234zeE = getFluidProperty(libLoc, 'xmassliq(5)', 'p', p_suc, 'Q', 0.2, fluidString, composition, 1, unit);

disp("R32        mass fraction of liquid: " + num2str(x_R32))
disp("R125       mass fraction of liquid: " + num2str(x_R125))
disp("R1234yf    mass fraction of liquid: " + num2str(x_R1234yf))
disp("R134a      mass fraction of liquid: " + num2str(x_R134a))
disp("R1234ze(E) mass fraction of liquid: " + num2str(x_R1234zeE))

[x_R32, x_R125, x_R1234yf, x_R134a, x_R1234zeE] = getFluidProperty(libLoc, 'xmassliq(1),xmassliq(2),xmassliq(3),xmassliq(4),xmassliq(5)', 'p', p_suc, 'Q', 0.2, fluidString, composition, 1, unit);
disp("R32        mass fraction of liquid: " + num2str(x_R32))
disp("R125       mass fraction of liquid: " + num2str(x_R125))
disp("R1234yf    mass fraction of liquid: " + num2str(x_R1234yf))
disp("R134a      mass fraction of liquid: " + num2str(x_R134a))
disp("R1234ze(E) mass fraction of liquid: " + num2str(x_R1234zeE))

