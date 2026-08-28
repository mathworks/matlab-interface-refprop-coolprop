%% Runner for Copper–Helium Quench Pressure Model (REFPROP-based)
clear; clc; close all;

clear mex;

cfg = struct();

cfg.use_refpropm = false;%true;

cfg.hA_W_perK   = 100;     % stronger conduction path
cfg.beta_direct = 0.2;    % 25% of P(t) goes directly to helium
cfg.verbose     = true;    % see details during solve
cfg.print_dt    = 0.05;    % denser prints

cfg.live_plot = true;     % set true to watch p(t) live


% --- REFPROP ---
cfg.libLoc = 'C:\Program Files (x86)\REFPROP\';
cfg.Fluid  = 'Helium';

% --- Geometry / Initial Helium State ---
cfg.Vtot   = 0.34;    % [m^3]
cfg.T0     = 4.0;     % [K]
cfg.phi_v0 = 0.1;    % [-] initial vapor fraction by volume

% --- Copper ---
cfg.m_Cu          = 600;      % [kg]
cfg.T_Cu_initial  = 4.0;      % [K]
cfg.cp_Cu_model   = 'cryogenicFit'; % 'cryogenicFit' or 'constant'
cfg.cp_Cu_const_J = 385;      % [J/kg-K] used only if cp_Cu_model='constant'

% --- Venting ---
cfg.vent_area_m2   = 1.5e-3;  % 1 cm^2
cfg.vent_set_bar   = 1.3;   % absolute setpoint
cfg.vent_delay_s   = 0.1;   % delay before opening
cfg.vent_Cd        = 0.6;   % discharge coefficient
cfg.vent_p_amb_bar = 1.0;   % ambient/downstream pressure


% --- Electrical input (I(t)) ---
cfg.I0         = 240;       % [A]
cfg.If         = 24;        % [A] at t_final
cfg.t_final    = 20.0;      % [s]
cfg.E_quench_J = 2.5e6;     % [J]

% --- Output sampling & numerics ---
cfg.Nt_out = 200;   % samples for plotting
cfg.Tcrit  = 5.20;      % [K]
cfg.Tmin   = 2.1768;    % [K]
cfg.T_eps  = 1e-3;      % [K]
cfg.Tmax   = 400;       % [K]
cfg.plot   = true;      % make plots


tic;  % Start timer

% --- Run the model ---
results = quench_pressure_cu_he_refprop_vent_universal(cfg);

elapsedTime = toc;  % Stop timer

% Quick console summary
fprintf('Final time: T_Cu = %.2f K, T_He = %.2f K, p = %.2f bar, phase = %s\n', ...
    results.T_Cu(end), results.T_He(end), results.p_bar(end), results.phase{end});


if elapsedTime > 60
    fprintf('Execution time: %.2f minutes\n', elapsedTime / 60);
else
    fprintf('Execution time: %.2f seconds\n', elapsedTime);
end
