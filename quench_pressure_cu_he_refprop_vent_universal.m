function results = quench_pressure_cu_he_refprop_vent_universal(cfg)
% Copper–Helium Quench Pressure Model (REFPROP-based, SI-internal)
% All internal units: J, Pa, kg, m^3, K. Print/plot in kJ and bar only.
% --- Config (classic style, no helpers) ---

if isfield(cfg,'libLoc') && ~isempty(cfg.libLoc)
 libLoc = cfg.libLoc;
else
 libLoc = 'C:\\Program Files (x86)\\REFPROP\\';
end

if isstring(libLoc), libLoc = char(libLoc); end

if isfield(cfg,'Fluid') && ~isempty(cfg.Fluid)
 Fluid = cfg.Fluid;
else
 Fluid = 'Helium';
end

if isstring(Fluid), Fluid = char(Fluid); end
if isfield(cfg,'Vtot'), Vtot = cfg.Vtot; else, Vtot = 0.34; end
if isfield(cfg,'T0'), T0 = cfg.T0; else, T0 = 4.0; end
if isfield(cfg,'phi_v0'), phi_v0 = cfg.phi_v0; else, phi_v0 = 0.05; end
if isfield(cfg,'m_Cu'), m_Cu = cfg.m_Cu; else, m_Cu = 600; end
if isfield(cfg,'T_Cu_initial'), T_Cu = cfg.T_Cu_initial; else, T_Cu = 4.0; end
if isfield(cfg,'cp_Cu_model'), cpModel = cfg.cp_Cu_model; else, cpModel = 'cryogenicFit'; end
if isfield(cfg,'cp_Cu_const_J'), cpConst = cfg.cp_Cu_const_J; else, cpConst = 385; end
if isfield(cfg,'hA_W_perK'), hA = cfg.hA_W_perK; else, hA = 50; end
if isfield(cfg,'beta_direct'), betaDir = cfg.beta_direct; else, betaDir = 0.25; end
if isfield(cfg,'I0'), I0 = cfg.I0; else, I0 = 240; end
if isfield(cfg,'If'), If = cfg.If; else, If = 24; end
if isfield(cfg,'t_final'), t_final = cfg.t_final; else, t_final = 5.0; end
if isfield(cfg,'E_quench_J'), E_quench = cfg.E_quench_J; else, E_quench = 3.3e6; end
if isfield(cfg,'Nt_out'), Nt_out = cfg.Nt_out; else, Nt_out = 200; end
if isfield(cfg,'Tcrit'), Tcrit = cfg.Tcrit; else, Tcrit = 5.20; end
if isfield(cfg,'Tmin'), Tmin = cfg.Tmin; else, Tmin = 2.1768; end
if isfield(cfg,'Tmax'), Tmax = cfg.Tmax; else, Tmax = 400; end
% if isfield(cfg,'T_eps'), T_eps = cfg.T_eps; else, T_eps = 1e-3; end
if isfield(cfg,'live_plot'), livePlot = cfg.live_plot; else, livePlot = true; end
if isfield(cfg,'verbose'), verbose = cfg.verbose; else, verbose = true; end
if isfield(cfg,'print_dt'), print_dt = cfg.print_dt; else, print_dt = 0.05; end

% --- Vent (simple choked-flow relief) defaults ---
if isfield(cfg,'vent_area_m2'), A_vent = cfg.vent_area_m2; else, A_vent = 1e-4; end % 1 cm^2
if isfield(cfg,'vent_set_bar'), p_set_bar = cfg.vent_set_bar; else, p_set_bar = 2.0; end
if isfield(cfg,'vent_delay_s'), t_vent_delay = cfg.vent_delay_s; else, t_vent_delay = 0.2; end
if isfield(cfg,'vent_Cd'), C_d = cfg.vent_Cd; else, C_d = 0.8; end
if isfield(cfg,'vent_p_amb_bar'), p_amb_bar = cfg.vent_p_amb_bar; else, p_amb_bar = 1.0; end
% gammaHe = 1.66; % monoatomic helium
% rcrit = (2/(gammaHe+1))^(gammaHe/(gammaHe-1)); % ~0.487; choked if p_down/p_up <= rcrit

% --- Static plotting toggle (new) ---
if isfield(cfg,'plot'), staticPlot = cfg.plot; else, staticPlot = false; end
Nt_int = max(5000, Nt_out*20);
t = linspace(0, t_final, Nt_int).';
dt = t(2)-t(1);

% --- API switch (new) ---
if isfield(cfg,'use_refpropm'), use_refpropm = logical(cfg.use_refpropm); else, use_refpropm = false; end
getProp('__SET_API__', use_refpropm);

% --- REFPROP SI normalization (minimal scaling: fix to unity) ---
U_SCALE = 1; P_SCALE = 1;

% --- Electrical waveform ---
tau = -t_final / log(If/max(I0,eps));
I_t = I0 * exp(-t/tau);
Punit = I_t.^2;
Eunit = trapz(t, Punit);
R_required = E_quench / max(Eunit,eps);
P_t = Punit * R_required;
E_in_t = cumtrapz(t, P_t);

% --- Initial helium state ---
[rhoL0, rhoV0, uL0, uV0, p0_Pa] = sat_props_HP_SI(libLoc, Fluid, T0, U_SCALE, P_SCALE);
VL0 = (1-phi_v0) * Vtot; VV0 = phi_v0 * Vtot;
mL0 = rhoL0 * VL0; mV0 = rhoV0 * VV0;
mHe = mL0 + mV0;
rho_const = mHe / Vtot;

% --- Safety thresholds for REFPROP calls (single-phase gas branch) ---
R_He = 2077; % J/(kg K), helium specific gas constant
rho_min_call = 1e-5; % kg/m^3; below this, use ideal-gas fallback to avoid REFPROP
rho_end_sim = 1e-7; % kg/m^3; treat as empty vessel and stop simulation
T_eps_sp = 2e-3; % K; stay a hair above Tcrit in gas branch
T_hi_guard = Tmax - 1e-3; % K; stay a hair below Tmax
U0_twoPhase = mL0*uL0 + mV0*uV0;
twoPhase = (mL0 > 1e-12) & (mV0 > 1e-12);
U0_ref = U0_twoPhase; E_ref = 0.0;
E_Cu = m_Cu * Cu_E_from_0K(T_Cu, cpModel, cpConst);
E_he_direct = 0.0; % J
E_cond = 0.0; % J
E_vented = 0.0; % cumulative energy carried out by vent [J]
m_vented = 0.0; % cumulative vented mass [kg]

% Track helium internal energy (total, J) to avoid E(T,D) calls in gas phase
U_prev = U0_ref + (E_he_direct + E_cond - E_vented - E_ref); % starts at U0_ref
% --- Output storage ---
t_out = linspace(0, t_final, Nt_out).';

% Downsample cumulative deposited energy to the output time grid
E_in_out = interp1(t, E_in_t, t_out, 'linear', 'extrap'); % [J]
T_He_out = nan(Nt_out,1);
p_bar_out = nan(Nt_out,1);
x_v_out = nan(Nt_out,1);
phase_out = repmat({''},Nt_out,1);
T_Cu_out = nan(Nt_out,1);
P_out = nan(Nt_out,1);
I_out = nan(Nt_out,1);
m_dot_vent_out = nan(Nt_out,1); % [kg/s] vent mass flow (sampled on t_out)

if livePlot
 fig = figure('Name','Quench Pressure','NumberTitle','off');
 ax = axes(fig); hold(ax,'on'); grid(ax,'on');
 plt = plot(ax, 0, 0, 'b-', 'LineWidth',1.5);
 xlabel(ax,'t [s]'); ylabel(ax,'p [bar]');
 title(ax,'Helium pressure during quench');
 xlim(ax,[0 t_final]); ylim(ax,[0 max(10, p0_Pa*1e-5*2)]);
end

nextPrint = 0;
j = 1;
T_He = T0;
p_Pa = p0_Pa; p_bar = p_Pa*1e-5;
x = mV0/max(mHe,eps);
if twoPhase, phase_str = 'two-phase'; else, phase_str = 'gas'; end

for k = 1:Nt_int
 tk = t(k);
 Pk = P_t(k);
 dE_direct = betaDir * Pk * dt;
 dQdt = hA * (T_Cu - T_He);
 dE_cond = dQdt * dt;
 E_he_direct = E_he_direct + dE_direct;
 E_cond = E_cond + dE_cond;
 dE_Cu = (1 - betaDir) * Pk * dt - dE_cond;
 E_Cu = E_Cu + dE_Cu;
 T_Cu = Cu_advance_T_from_dE(T_Cu, dE_Cu, m_Cu, cpModel, cpConst, Tmin, Tmax);
 E_he_added = E_he_direct + E_cond;
 
 %U_target = U0_ref + (E_he_added - E_ref);
 U_target = U0_ref + (E_he_added - E_vented - E_ref);
 
 if twoPhase
    T_guess = max(Tmin+1e-3, min(Tcrit-0.02, T_He));
    if k==1, T_guess = max(T0, Tmin+1e-3); end
    T_lo = max(Tmin+1e-3, T_guess);
    T_hi = min(Tcrit-0.02, T_guess + 1.5);
    fU = @(TT) U_of_T_twoPhase_HP_SI(TT, libLoc, Fluid, Vtot, mHe, U_SCALE, P_SCALE) - U_target;
    [T_lo, T_hi, ok] = bracket_root(fU, T_lo, T_hi, Tcrit - 0.02, +0.5, 8);

    if ok
        Tsol = fzero(fU, [T_lo, T_hi]);
        % [rhoL, rhoV, uL, uV, p_sat_Pa] = sat_props_HP_SI(libLoc, Fluid, Tsol, U_SCALE, P_SCALE);
        [rhoL, rhoV, ~, ~, p_sat_Pa] = sat_props_HP_SI(libLoc, Fluid, Tsol, U_SCALE, P_SCALE);
        vL = 1/rhoL; vV = 1/rhoV;
        mV = (Vtot - mHe*vL) / max(vV - vL, 1e-12);
        mV = min(max(mV, 0), mHe);
        x = mV / mHe;
        T_He = Tsol;
        p_Pa = p_sat_Pa;
        p_bar = p_Pa*1e-5;
        phase_str = 'two-phase';

        if x >= 1 - 1e-6 || Tsol >= Tcrit - 1e-3
            twoPhase = false;
            u_now = getProp(libLoc,'E','T',max(Tcrit+1e-3,Tsol),'D',mHe/Vtot,Fluid,1,1,'MASS BASE SI') * U_SCALE;
            U0_ref = mHe * u_now;
            E_ref = E_he_added;
        end
    else
        twoPhase = false;
        T_trans = max(Tcrit + 0.05, T_He);
        u_trans = getProp(libLoc,'E','T',T_trans,'D',mHe/Vtot,Fluid,1,1,'MASS BASE SI') * U_SCALE;
        U0_ref = mHe * u_trans;
        E_ref = E_he_added;
    end
 else
    % u_target = U_target / mHe;
    % Tprev = max(Tcrit + 0.1, T_He);

 % ---------------- Single-phase gas branch (cv-based; no E(T,D) calls) ----------------
    rho_now = mHe / Vtot;

% End sim gracefully if essentially empty
if rho_now <= rho_end_sim
 if verbose
 fprintf('Vessel empty (rho=%.3e kg/m^3). Ending simulation at t=%.3f s.\n', rho_now, tk);
 end
 while j <= Nt_out
 T_He_out(j) = T_He;
 p_bar_out(j) = p_bar;
 x_v_out(j) = NaN;
 phase_out{j} = 'gas';
 T_Cu_out(j) = T_Cu;
 P_out(j) = Pk;
 I_out(j) = I_t(k);
 m_dot_vent_out(j) = 0;
 j = j + 1;
 end
 break;
end

% Target helium energy at this instant (same as before)
U_target = U0_ref + (E_he_direct + E_cond - E_vented - E_ref);
% Energy increment this step
dU = U_target - U_prev; % [J]
Tprev = max(Tcrit + 0.1, T_He);
% Get cv at (Tprev, rho_now); guard & fallback to ideal gas if needed
cv_prev = NaN;
try
 cv_prev = getProp(libLoc,'CV','T',Tprev,'D',max(rho_now,rho_min_call), ...
 Fluid,1,1,'MASS BASE SI') * U_SCALE; % [J/(kg K)]
catch
 % leave as NaN
end
if ~isfinite(cv_prev) || cv_prev <= 0
 cv_prev = 1.5 * R_He; % ideal-gas cv for helium
end

% Explicit energy step for temperature (clamped away from boundaries)
Tsol = Tprev + dU / max(mHe*cv_prev, 1e-12);
Tsol = min(max(Tsol, Tcrit + T_eps_sp), T_hi_guard);
% Pressure from REFPROP at (Tsol, rho_now); fallback to ideal gas if needed
p_Pa = NaN;
try
 p_Pa = getProp(libLoc,'P','T',Tsol,'D',max(rho_now,rho_min_call), ...
 Fluid,1,1,'MASS BASE SI') * P_SCALE;
catch
 % leave NaN
end
if ~isfinite(p_Pa) || p_Pa <= 0
 p_Pa = rho_now * R_He * Tsol; % ideal-gas fallback
end
% Commit state
T_He = Tsol;
p_bar = 1e-5 * p_Pa;
x = NaN;
phase_str = 'gas';
% ---------------- end single-phase branch ----------------
 end

% % --- Simple venting (choked-only), uses state at this step ---
%  m_dot_vent_cur = 0.0; % [kg/s]
%  if tk >= t_vent_delay && A_vent > 0 && mHe > 0
%     p_up = p_Pa; % upstream absolute pressure [Pa]
%     p_down = max(1e3, p_amb_bar*1e5); % downstream/ambient [Pa], floor to avoid zero
%     if p_up >= max(p_set_bar*1e5, p_down) && (p_down/p_up) <= rcrit
%         if strcmp(phase_str,'two-phase')
%          % Use saturated vapor properties at current T_He
%             rho_out = getProp(libLoc,'D','T',T_He,'Q',1,Fluid,1,1,'MASS BASE SI'); % [kg/m^3]
%             a_out = getProp(libLoc,'W','T',T_He,'Q',1,Fluid,1,1,'MASS BASE SI'); % [m/s]
%             h_out = getProp(libLoc,'H','T',T_He,'Q',1,Fluid,1,1,'MASS BASE SI') * U_SCALE; % [J/kg]
%         else
%         % Single-phase gas at (T_He, rho=mHe/Vtot)
%             rho_out = max(mHe/Vtot, 1e-6);
%             a_out = getProp(libLoc,'W','T',T_He,'D',rho_out,Fluid,1,1,'MASS BASE SI'); % [m/s]
%             h_out = getProp(libLoc,'H','T',T_He,'D',rho_out,Fluid,1,1,'MASS BASE SI') * U_SCALE; % [J/kg]
%         end
%         %Choked mass flux approximation: G = C_d * rho * a
%         G = max(0, C_d * max(rho_out,0) * max(a_out,0)); % [kg/(m^2 s)]
%         dm = min(mHe, G * A_vent * dt); % [kg] limited by remaining mass
%         % new: ideal-gas choked mass flux (no 'W' call)
%         % Rg = 2077; gammaHe = 1.66;
%         % fact = (2/(gammaHe+1))^((gammaHe+1)/(2*(gammaHe-1)));
%         % mdot_choked = C_d * A_vent * p_Pa * sqrt(gammaHe/(Rg*max(T_He,2.0))) * fact;
%         % dm = min(mHe, mdot_choked * dt);
%  if dm > 0
%  mHe = mHe - dm; % reduce in-vessel mass
%  m_vented = m_vented + dm; % accumulate vented mass
%  E_vented = E_vented + h_out * dm; % subtract enthalpy carried out
%  m_dot_vent_cur = dm / dt; % report as kg/s for this step
%  end
%  end
%  end

% --- Venting (use G=rho*a for choked, nozzle equation for subcritical); uses state at this step ---
m_dot_vent_cur = 0.0; % [kg/s]

if tk >= t_vent_delay && A_vent > 0 && mHe > 0
    % Upstream/downstream pressures [Pa]
    p_up   = max(p_Pa, 1.0);                          % ensure >0
    p_down = max(1e3, p_amb_bar*1e5);                 % floor to avoid zero

    % Valve/rupture opens only when upstream >= setpoint and above ambient
    if p_up >= max(p_set_bar*1e5, p_down)

        % dm = 0.0;  % [kg] to be vented this step
        % mdot = 0.0; % [kg/s] instantaneous mass flow

        if strcmp(phase_str,'two-phase')
            % ---- TWO-PHASE (kept as choked-only with saturated vapor properties) ----
            % Use saturated vapor properties at current T_He
            rho_out = getProp(libLoc,'D','T',T_He,'Q',1,Fluid,1,1,'MASS BASE SI'); % [kg/m^3]
            a_out   = getProp(libLoc,'W','T',T_He,'Q',1,Fluid,1,1,'MASS BASE SI'); % [m/s]
            h_out   = getProp(libLoc,'H','T',T_He,'Q',1,Fluid,1,1,'MASS BASE SI') * U_SCALE; % [J/kg]

            % Choked mass flux approximation (real-gas aware): G = C_d * rho * a
            G   = max(0, C_d * max(rho_out,0) * max(a_out,0));   % [kg/(m^2 s)]
            mdot = G * A_vent;                                    % [kg/s]
            dm   = min(mHe, mdot * dt);                           % [kg]

        else
            % ---- SINGLE-PHASE GAS (choked uses G=rho*a, subcritical uses nozzle) ----

            % Upstream state from current inventory
            rho_out = max(mHe / max(Vtot,1e-12), 1e-9);  % [kg/m^3]
            a_out   = getProp(libLoc,'W','T',T_He,'D',rho_out,Fluid,1,1,'MASS BASE SI'); % [m/s]
            h_out   = getProp(libLoc,'H','T',T_He,'D',rho_out,Fluid,1,1,'MASS BASE SI') * U_SCALE; % [J/kg]

            % Gas properties for nozzle model
            cp_ = getProp(libLoc,'CP','T',T_He,'D',rho_out,Fluid,1,1,'MASS BASE SI'); % J/(kg K)
            cv_ = getProp(libLoc,'CV','T',T_He,'D',rho_out,Fluid,1,1,'MASS BASE SI'); % J/(kg K)
            if ~isfinite(cp_) || ~isfinite(cv_) || cv_ <= 0
                cp_ = 5193; cv_ = 3116; % robust fallback (He ~10 K)
            end
            gamma = max(1.01, min(1.70, cp_/cv_));      % clamp for He
            Rg    = 2077;                               % J/(kg K) helium specific gas constant

            % Pressure ratio and critical ratio
            PR         = min(0.999999, max(1e-6, p_down / max(p_up,1)));   % (0,1)
            rcrit_gas  = (2/(gamma+1))^(gamma/(gamma-1));

            % Real-gas aware choked mass flux via current state:
            %   G_choked = C_d * rho * a
            G_choked    = max(0, C_d * max(rho_out,0) * max(a_out,0)); % [kg/(m^2 s)]
            mdot_choked = G_choked * A_vent;                           % [kg/s]

            if PR <= rcrit_gas
                % ---- CHOKED: use G from current state ----
                mdot = mdot_choked;
            else
                % ---- SUBCRITICAL (unchoked): ideal-gas nozzle model ----
                % mdot/A = C_d * p_up * sqrt( (2*gamma)/(Rg*T) * ( PR^(2/gamma) - PR^((gamma+1)/gamma) ) / (gamma-1) )
                T_safe = max(T_He, 1e-3);
                term   = (PR)^(2/gamma) - (PR)^((gamma+1)/gamma);
                term   = max(term, 0);
                mdot_subcrit = C_d * A_vent * p_up ...
                              * sqrt( (2*gamma)/(Rg*T_safe*(gamma-1)) * term );

                % Optional safety cap to avoid any numerical overshoot past choked:
                % (uncomment if desired)
                % mdot_subcrit = min(mdot_subcrit, mdot_choked * 1.001);

                mdot = mdot_subcrit;
            end

            dm = min(mHe, max(0, mdot) * dt);
        end

        % Apply mass/energy bookkeeping if anything was vented
        if dm > 0
            mHe        = mHe - dm;            % reduce in-vessel mass
            m_vented   = m_vented + dm;       % accumulate vented mass
            E_vented   = E_vented + h_out*dm; % subtract enthalpy carried out
            m_dot_vent_cur = dm / dt;         % report as kg/s for this step
        end
    end
end

 % After vent updates (so E_vented includes this step), refresh the helium energy state
 U_prev = U0_ref + (E_he_direct + E_cond - E_vented - E_ref);
 while j <= Nt_out && tk >= t_out(j) - 1e-12
 T_He_out(j) = T_He;
 p_bar_out(j) = p_bar;
 x_v_out(j) = x;
 phase_out{j} = phase_str;
 T_Cu_out(j) = T_Cu;
 P_out(j) = Pk;
 I_out(j) = I_t(k);
 m_dot_vent_out(j) = m_dot_vent_cur; % [kg/s]
 j = j + 1;
 if livePlot && exist('plt','var') && isgraphics(plt)
 set(plt, 'XData', t_out(~isnan(p_bar_out)), ...
 'YData', p_bar_out(~isnan(p_bar_out)));
 drawnow limitrate
 end
 end
 % Create a textual venting status for console reporting
 % if m_dot_vent_cur > 0
 %     vent_status_str = 'venting on';
 % else
 %     vent_status_str = 'venting off';
 % end

 if verbose && tk >= nextPrint
    if m_dot_vent_cur > 0
        vent_status_str = 'venting on';
    else
        vent_status_str = 'venting off'; 
    end
    fprintf('t=%.3f s | T_He=%.3f K | p=%.3f bar | T_Cu=%.1f K | %s | %s\n', tk, T_He, p_bar, T_Cu, phase_str, vent_status_str);
    nextPrint = nextPrint + print_dt;
end
end

% Cumulative mass vented on t_out grid (from sampled mass flow)
m_vented_out = cumtrapz(t_out, max(m_dot_vent_out,0)); % [kg]
results = struct();
results.t = t_out;
results.T_He = T_He_out;
results.p_bar = p_bar_out;
results.x_v = x_v_out;
results.phase = phase_out;
results.T_Cu = T_Cu_out;
results.P_t = P_out;
results.I_t = I_out;
results.R_required = R_required;
results.m_dot_vent = m_dot_vent_out; % [kg/s] on t_out grid
results.m_vented = m_vented; % [kg] total vented mass
results.m_vented_out = m_vented_out; % [kg] cumulative vs time on t_out
results.E_in_J = E_in_out; % cumulative deposited energy [J] on t_out
results.E_in_kJ = 1e-3*E_in_out; % convenience [kJ]
results.flags = struct('ended_twoPhase', any(strcmp(phase_out,'gas')), ...
 'rho_const', rho_const, 'mHe', mHe);
results.meta = struct('libLoc', libLoc, 'Fluid', Fluid, ...
 'Vtot', Vtot, 'Tcrit', Tcrit, 'cfg', cfg);
results.meta = struct('libLoc', libLoc, 'Fluid', Fluid, ...
 'Vtot', Vtot, 'Tcrit', Tcrit, 'cfg', cfg);

if exist('staticPlot','var') && staticPlot
    figure('Name','Helium: pressure & temperature','NumberTitle','off'); yyaxis left; plot(t_out, p_bar_out, 'b-','LineWidth',1.5); grid on; ylabel('p_{He} [bar]');
    yyaxis right; plot(t_out, T_He_out, 'r-','LineWidth',1.2); ylabel('T_{He} [K]'); xlabel('t [s]'); title('Helium pressure and temperature vs. time'); legend('p_{He}','T_{He}','Location','best');
    figure('Name','Deposited energy & current','NumberTitle','off'); yyaxis left; plot(t_out, 1e-3*E_in_out, 'b-','LineWidth',1.5); grid on; ylabel('E_{in} [kJ]');
    yyaxis right; plot(t_out, I_out, 'r-','LineWidth',1.2); ylabel('I(t) [A]'); xlabel('t [s]'); title('Deposited energy and current vs. time'); legend('E_{in}','I(t)','Location','best');
    figure('Name','Venting: mass & flow','NumberTitle','off'); yyaxis left; plot(t_out, m_vented_out, 'b-','LineWidth',1.6); grid on; ylabel('m_{vented}(t) [kg]');
    yyaxis right; plot(t_out, m_dot_vent_out, 'r-','LineWidth',1.2); ylabel('dm/dt [kg/s]'); xlabel('t [s]'); title('Helium venting activity'); legend('m_{vented}','dm/dt','Location','best');
end



end % ======= end main function =======

% function [U_SCALE, P_SCALE] = detect_refprop_scales_SI(libLoc, Fluid, Tref) %#ok<INUSD>
% % minimized scaling: fix to unity (P returned by getProp is already Pa)
% U_SCALE = 1;
% P_SCALE = 1;
% end

function [rhoL, rhoV, uL_Jkg, uV_Jkg, p_sat_Pa] = sat_props_HP_SI(libLoc, Fluid, T, U_SCALE, P_SCALE) % #ok<INUSD,INUSL>
rhoL = getProp(libLoc,'D','T',T,'Q',0,Fluid,1,1,'MASS BASE SI');
rhoV = getProp(libLoc,'D','T',T,'Q',1,Fluid,1,1,'MASS BASE SI');
uL_Jkg = getProp(libLoc,'E','T',T,'Q',0,Fluid,1,1,'MASS BASE SI') * U_SCALE;
uV_Jkg = getProp(libLoc,'E','T',T,'Q',1,Fluid,1,1,'MASS BASE SI') * U_SCALE;
p_sat_Pa = getProp(libLoc,'P','T',T,'Q',0,Fluid,1,1,'MASS BASE SI') * P_SCALE;
end

function U = U_of_T_twoPhase_HP_SI(T, libLoc, Fluid, V, m, U_SCALE, P_SCALE) %#ok<INUSD>
[rhoL, rhoV, uL, uV, ~] = sat_props_HP_SI(libLoc, Fluid, T, U_SCALE, 1);
vL = 1/rhoL; vV = 1/rhoV;
mV = (V - m*vL) / max(vV - vL, 1e-12);
mV = min(max(mV, 0), m);
U = (m - mV)*uL + mV*uV;
end

function [lo, hi, ok] = bracket_root(fun, lo, hi, hi_cap, step, maxGrow)
flo = fun(lo); fhi = fun(hi);
ok = isfinite(flo) && isfinite(fhi) && flo*fhi <= 0;
grows = 0;
while ~ok && grows < maxGrow && hi < hi_cap - 1e-9
 hi = min(hi + step, hi_cap);
 fhi = fun(hi);
 ok = isfinite(flo) && isfinite(fhi) && flo*fhi <= 0;
 grows = grows + 1;
end
end

function cp = Cu_cp(T, model, cp_c)
switch lower(model)
 case 'constant'
 cp = cp_c * ones(size(T));
 case 'cryogenicfit'
 a = 0.6; b = 2.0e-3;
 cp_low = a*T + b*T.^3;
 Tsw = 80; w = 0.5*(1 + tanh((T - Tsw)/15));
 cp = (1-w).*cp_low + w.*385;
 cp = max(cp, 0.05);
 otherwise
 error('cp_Cu_model must be ''cryogenicFit'' or ''constant''.');
end
end

function E = Cu_E_from_0K(T, model, cp_c)
T = max(0, T);
E = zeros(size(T));
for i=1:numel(T)
 Ti = T(i);
 if Ti==0, E(i)=0; continue; end
 xi = [0.0, 0.25, 0.5, 0.75, 1.0];
 wi = [1, 1, 1, 1, 1]/5;
 cp_samp = Cu_cp(xi*Ti, model, cp_c);
 E(i) = Ti * sum(wi .* cp_samp);
end
end

% function u = local_u_from_T_rho_safe(Tin, rho, libLoc, Fluid, U_SCALE, Tcrit, Tmax, ...
%  R_He, rho_min_call, T_eps_sp, T_hi_guard) %#ok<INUSL,INUSD,INUSD,INUSD,INUSD>
%  % Clamp temperature to a safe single-phase window
%  T = min(max(Tin, Tcrit + T_eps_sp), T_hi_guard);
%  % For ultra-low densities, skip REFPROP and use ideal-gas for helium
%  if rho <= rho_min_call || ~isfinite(rho)
%  u = 1.5 * R_He * T; % u ≈ (3/2) R T for monatomic He
%  return;
%  end
%  % Primary REFPROP call; if anything looks off, fall back to ideal gas
%  try
%  u = getProp(libLoc,'E','T',T,'D',rho,Fluid,1,1,'MASS BASE SI') * U_SCALE;
%  if ~isfinite(u)
%  u = 1.5 * R_He * T;
%  end
%  catch
%  % Any exception: ideal-gas fallback to avoid crashing MATLAB
%  u = 1.5 * R_He * T;
%  end
% end

function Tnew = Cu_advance_T_from_dE(Told, dE, mcu, model, cp_c, Tmin_, Tmax_)
% Advance copper temperature given energy increment dE [J].
% Solves m*∫_Told^Tnew cp(T)dT = dE with a few damped Newton iterations.
 if abs(dE) < 1e-12
 Tnew = Told;
 return
 end
 % Initial guess: explicit step using cp at Told
 cp0 = max(Cu_cp(Told, model, cp_c), 1);
 T = Told + dE / (mcu * cp0);
 T = min(max(T, Tmin_), Tmax_);
 % 2–3 Newton iterations are ample here
 for it = 1:3
 E_now = Cu_E_from_0K(T, model, cp_c);
 E_old = Cu_E_from_0K(Told, model, cp_c);
 F = mcu*(E_now - E_old) - dE; % residual [J]
 dF = mcu*max(Cu_cp(T, model, cp_c), 1e-3); % derivative [J/K]
 T = T - F/dF;
 T = min(max(T, Tmin_), Tmax_);
 end
 Tnew = T;
end

% ===== Shim that switches between getFluidProperty and refpropm with minimal scaling =====
function val = getProp(varargin)
% Usage (normal): getProp(libLoc,out,in1,v1,in2,v2,Fluid,~,~,units)
% Usage (switch): getProp('__SET_API__', true/false)
persistent USE_REFP
if nargin==2 && ischar(varargin{1}) && strcmp(varargin{1},'__SET_API__')
 USE_REFP = logical(varargin{2});
 val = [];
 return
end
libLoc = varargin{1}; % #ok<NASGU>
out = varargin{2};
in1 = varargin{3};
v1 = varargin{4};
in2 = varargin{5};
v2 = varargin{6};
Fluid = varargin{7};
FluidComp = varargin{8};
MassOrMolar = varargin{9};
Units = varargin{10};

if isempty(USE_REFP) || ~USE_REFP
 % New API pass-through (expects P inputs in Pa; returns P in Pa)
 val = getFluidProperty(libLoc, out, in1, v1, in2, v2, Fluid, FluidComp, MassOrMolar, Units, rapidMode=true);
 return
end

% Legacy API path (refpropm): expects P inputs in kPa and returns P in kPa
% Map output property codes
switch upper(out)
 case 'E', out_rp = 'U';
 case 'W', out_rp = 'A';
 case 'CV', out_rp = 'O';
 case 'CP', out_rp = 'C';
 otherwise, out_rp = upper(out);
end
in1_rp = upper(in1);
in2_rp = upper(in2);
v1_rp = v1;
v2_rp = v2;
% Convert input pressures (Pa -> kPa) for refpropm
if strcmp(in1_rp,'P'), v1_rp = v1/1000; end
if strcmp(in2_rp,'P'), v2_rp = v2/1000; end
% Call refpropm (mass-based SI for non-pressure properties; P in kPa)
val = refpropm(out_rp, in1_rp, v1_rp, in2_rp, v2_rp, Fluid);
% Convert pressure output to Pa (only scaling we do)
if strcmpi(out,'P')
    val = val*1000; 
end
end
