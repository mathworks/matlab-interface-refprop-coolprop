function createLUT(obj, installPath, substance, LUT_x_axis_range, LUT_y_axis_range, Num_cols, Num_rows_liq, Num_rows_vap, Num_rows_dome, Fluid_composition, REFPROP_mass_or_molar, REFPROP_desired_units)
    arguments
        obj                   (1, 1) {mustBeA(obj, "twoPhaseFluidLUT")} % twoPhaseFluidLUT class object
        installPath           (1, 1) string % path to REFPROP or CoolProp installation
        substance             (1, 1) string % name of substance
        LUT_x_axis_range      (1, 2) double {mustBeFinite, mustBeSorted(LUT_x_axis_range, "strictascend")} % first property [min, max] values
        LUT_y_axis_range      (1, 2) double {mustBeFinite, mustBeSorted(LUT_y_axis_range, "strictascend")} % second property [min, max] values
        Num_cols              (1, 1) double {mustBeFinite, mustBePositive, mustBeReal, mustBeGreaterThanOrEqual(Num_cols,     3)} = 50; % number of columns
        Num_rows_liq          (1, 1) double {mustBeFinite, mustBePositive, mustBeReal, mustBeGreaterThanOrEqual(Num_rows_liq, 3)} = 50; % number of rows to create on liquid side
        Num_rows_vap          (1, 1) double {mustBeFinite, mustBePositive, mustBeReal, mustBeGreaterThanOrEqual(Num_rows_vap, 3)} = 50; % number of rows to create on vapor side
        Num_rows_dome         (1, 1) double {mustBeFinite, mustBeNonnegative, mustBeReal, mustBeGreaterThanOrEqual(Num_rows_dome, 0)} = 0; % number of rows to create under the dome
        Fluid_composition     (1, :) double = 1;     % assume single species - only if numel(fluid) > 1 will user need to provide
        REFPROP_mass_or_molar (1, 1) double = 1;     % REFPROP only: 0 -> Molar, 1 -> Mass
        REFPROP_desired_units (1, 1) string = "MKS"; % REFPROP allows user to specify units - see REFPROP documentation for more information
    end % end arguments block

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % fill in the object properties %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if    ~contains(installPath, "REFPROP",  "IgnoreCase", true)...
       && ~contains(installPath, "CoolProp", "IgnoreCase", true)
        error('check library location')
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % set the required properties %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    obj.Fluid_lib_install_path = installPath;
    obj.Fluid                  = substance;
    obj.Fluid_composition      = Fluid_composition;
    obj.REFPROP_mass_or_molar  = REFPROP_mass_or_molar;
    obj.REFPROP_desired_units  = REFPROP_desired_units;
    obj.LUT_x_axis_range       = LUT_x_axis_range;
    obj.LUT_y_axis_range       = LUT_y_axis_range;
    obj.Num_rows_liq           = Num_rows_liq;
    obj.Num_rows_vap           = Num_rows_vap;
    obj.Num_rows_dome          = Num_rows_dome;
    obj.Num_cols               = Num_cols;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % get critical and triple states for the fluids %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    obj.findCriticalStates;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % set up a normalized vector for the liquid side and the vapor side  %
    % the liquid side goes from -1 to 0, the vapor side goes from 1 to 2 %
    % between 0 and 1 is the mixed liquid/vapor region                   %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    liqVecNorm  = linspace(-1, 0, obj.Num_rows_liq);
    vapVecNorm  = linspace( 1, 2, obj.Num_rows_vap);
    domeVecNorm = linspace( 0, 1, obj.Num_rows_dome + 2);
    obj.LUT.x_liq_norm  = liqVecNorm;
    obj.LUT.x_vap_norm  = vapVecNorm;
    obj.LUT.x_dome_norm = domeVecNorm(2:end-1);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Define y-axis vector of the lookup table %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    y_min_log = log10(obj.LUT_y_axis_range(1));
    y_max_log = log10(obj.LUT_y_axis_range(2));
    if (y_max_log - y_min_log) > 2
        yVarVec = logspace(log10(obj.LUT_y_axis_range(1)), log10(obj.LUT_y_axis_range(2)), obj.Num_cols);
        obj.Use_log_y_axis = true;
    else
        yVarVec = linspace(obj.LUT_y_axis_range(1), obj.LUT_y_axis_range(2), obj.Num_cols);
    end
    obj.LUT.y_vec = yVarVec;

    %%%%%%%%%%%%%%%%%%%%%%%%
    % find the phase lines %
    %%%%%%%%%%%%%%%%%%%%%%%%
    obj.findPhaseLine;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Preallocate arrays to build up (x-axis and output) %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    n_sub              = obj.Num_y_sub_crit;
    x_sat_liq          = zeros(1, Num_cols);
    x_sat_liq(1:n_sub) = obj.Info_struct.Phase_line.(obj.LUT_x_axis_name + "_liq");
    out_liq            = zeros(Num_rows_liq, Num_cols);
    x_sat_vap          = zeros(1, Num_cols);
    x_sat_vap(1:n_sub) = obj.Info_struct.Phase_line.(obj.LUT_x_axis_name + "_vap");
    out_vap            = zeros(Num_rows_vap, Num_cols);
    out_dome           = zeros(Num_rows_dome, Num_cols);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % loop through and align the pseudocritical region with 0 and 1 for the normalized vector %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    tolx    = 1e-6;
    opts    = optimset('Display', 'off', 'MaxFunEvals', 200, 'TolX', tolx);
    delta_x = max(x_sat_vap(1:n_sub) - x_sat_liq(1:n_sub));
    half_dx = delta_x * 0.5;
    x_last  = obj.Info_struct.(obj.LUT_x_axis_name + "_crit");

    if contains(obj.Fluid_lib_install_path, 'refprop', 'IgnoreCase', true)
        specificHeat = @(x, y) getFluidProperty(obj.Fluid_lib_install_path, 'CP', obj.LUT_x_axis_name, x,...
                                                obj.LUT_y_axis_name, y, obj.Fluid, obj.Fluid_composition,...
                                                obj.REFPROP_mass_or_molar, obj.REFPROP_desired_units);
    else%if contains(libLoc, 'coolprop', 'IgnoreCase', true)
        specificHeat = @(x, y) getFluidProperty(obj.Fluid_lib_install_path, 'CP', obj.LUT_x_axis_name, x,...
                                                obj.LUT_y_axis_name, y, obj.Fluid, obj.Fluid_composition,...
                                                keepLibraryLoaded=true);
    end % end if REFPROP, else CoolProp

    for cx = n_sub+1 : Num_cols
        % Midpoint of search interval
        x_mid = x_last;

        % Boundary of search interval, scaled to -1 and +1
        % Ensure that the search boundary is within uRange
        x_scaled_bnds = [-1 1];
        if ((x_scaled_bnds(1) * half_dx) + x_mid) < LUT_x_axis_range(1)
            x_scaled_bnds(1) = (LUT_x_axis_range(1) - x_mid)/(half_dx);
        end
        if ((x_scaled_bnds(2) * half_dx) + x_mid) > LUT_x_axis_range(2)
            x_scaled_bnds(2) = (LUT_x_axis_range(2) - x_mid)/(half_dx);
        end

        try
            % Search for specific internal energy at peak specific heat
            [x_scaled_check, ~, exitflag] = fminbnd(@(x_scaled) -specificHeat(((x_scaled * half_dx) + x_mid), ...
                                                                              yVarVec(cx)),...
                                                                x_scaled_bnds(1), x_scaled_bnds(2), opts);

            % If search fails, ignore this solution
            if exitflag ~= 1
                x_scaled_check = nan;
            end
        catch ME
            % If search fails, ignore this solution
            x_scaled_check = nan;
        end

        % Tolerance for checking if the solution is on interval boundary
        tol_bnd = 2*(tolx + 3*abs(x_scaled_check)*sqrt(eps));

        % Check if the solution is on the interval boundaries
        is_left  = x_scaled_check <= (x_scaled_bnds(1) + tol_bnd);
        is_right = x_scaled_check >= (x_scaled_bnds(2) - tol_bnd);

        % Check if the solution is in the interior
        is_interior = ~(is_left | is_right);

        % Solution is a peak only if it is in interior of interval
        % If peak is not found, then just extend upward from last point
        if is_interior
            x_sat_liq(cx) = (x_scaled_check * half_dx) + x_mid;
        else
            x_sat_liq(cx:Num_cols) = x_last;
            break
        end
        x_last = x_sat_liq(cx);
    end

    x_sat_vap(n_sub+1:Num_cols) = x_sat_liq(n_sub+1:Num_cols);

    % Transform grid back to original space
    x_liq  = ((liqVecNorm' + 1)      * (x_sat_liq - LUT_x_axis_range(1))) + LUT_x_axis_range(1);
    x_vap  = ((vapVecNorm' - 2)      * (LUT_x_axis_range(2) - x_sat_vap)) + LUT_x_axis_range(2);
    x_dome = ( domeVecNorm(2:end-1)' * (x_sat_vap - x_sat_liq))           + x_sat_liq;

    % Fill in arrays with fluid properties
    if contains(obj.Fluid_lib_install_path, 'refprop', 'IgnoreCase', true)
        for cx = 1 : Num_cols
            out_liq(:, cx)  = getFluidProperty(installPath, obj.LUT_out_prop_name, obj.LUT_x_axis_name, x_liq(:, cx),...
                                               obj.LUT_y_axis_name, yVarVec(cx), substance, obj.Fluid_composition,...
                                               obj.REFPROP_mass_or_molar, obj.REFPROP_desired_units);
            out_vap(:, cx)  = getFluidProperty(installPath, obj.LUT_out_prop_name, obj.LUT_x_axis_name, x_vap(:, cx),...
                                               obj.LUT_y_axis_name, yVarVec(cx), substance, obj.Fluid_composition,...
                                               obj.REFPROP_mass_or_molar1, obj.REFPROP_desired_units);
        end % end loop over columns (cx)
        if numel(out_dome) > 0
            for cx = 1 : Num_cols
                out_dome(:, cx) = getFluidProperty(installPath, obj.LUT_out_prop_name, obj.LUT_x_axis_name, x_dome(:, cx),...
                                                   obj.LUT_y_axis_name, yVarVec(cx), substance, obj.Fluid_composition,...
                                                   obj.REFPROP_mass_or_molar, obj.REFPROP_desired_units);
            end % end loop over columns (cx)
        end % end if user wants points inside the dome
    else%if contains(obj.Fluid_lib_install_path, 'coolprop', 'IgnoreCase', true)
        for cx = 1 : Num_cols
            out_liq(:, cx)  = getFluidProperty(installPath, obj.LUT_out_prop_name, obj.LUT_x_axis_name, x_liq(:, cx),...
                                               obj.LUT_y_axis_name, yVarVec(cx), substance, obj.Fluid_compositio,...
                                               keepLibraryLoaded=true);
            out_vap(:, cx)  = getFluidProperty(installPath, obj.LUT_out_prop_name, obj.LUT_x_axis_name, x_vap(:, cx),...
                                               obj.LUT_y_axis_name, yVarVec(cx), substance, obj.Fluid_compositio,...
                                               keepLibraryLoaded=true);
        end % end loop over columns (cx)
        if numel(out_dome) > 0
            for cx = 1 : Num_cols
                out_dome(:, cx) = getFluidProperty(installPath, obj.LUT_out_prop_name, obj.LUT_x_axis_name, x_dome(:, cx),...
                                                   obj.LUT_y_axis_name, yVarVec(cx), substance, obj.Fluid_compositio,...
                                                   keepLibraryLoaded=true);
            end % end loop over columns (cx)
        end % end if user wants points inside the dome
    end % end if REFPROP, else CoolProp

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % add the remaining vectors to the LUT %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    obj.LUT.x_sat_liq = x_sat_liq;
    obj.LUT.x_sat_vap = x_sat_vap;
    obj.LUT.x_liq     = x_liq;
    obj.LUT.x_vap     = x_vap;
    obj.LUT.x_dome    = x_dome;
    obj.LUT.y_vec     = yVarVec;
    obj.LUT.out_liq   = out_liq;
    obj.LUT.out_vap   = out_vap;
    obj.LUT.out_dome  = out_dome;
end % end method createLUT