function findCriticalStates(obj)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % if using REFPROP, else CoolProp %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if contains(obj.Fluid_lib_install_path, 'refprop', 'IgnoreCase', true)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % find critical temperature and pressure %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        T_crit = getFluidProperty(obj.Fluid_lib_install_path, 'T', 'CRIT', 1, '', 1, obj.Fluid, 1, 1, 'MASS BASE SI');
        P_crit = getFluidProperty(obj.Fluid_lib_install_path, 'P', 'CRIT', 1, '', 1, obj.Fluid, 1, 1, 'MASS BASE SI');
        T_trip = getFluidProperty(obj.Fluid_lib_install_path, 'T', 'TRIP', 1, '', 1, obj.Fluid, 1, 1, 'MASS BASE SI');
        P_trip = getFluidProperty(obj.Fluid_lib_install_path, 'P', 'TRIP', 1, '', 1, obj.Fluid, 1, 1, 'MASS BASE SI');

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % find critical input 1 properties %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if startsWith(obj.LUT_x_axis_name, "T")
            x_crit = T_crit;
            x_trip = T_trip;
        elseif startsWith(obj.LUT_x_axis_name, "P")
            x_crit = P_crit;
            x_trip = P_trip;
        else
            x_crit = getFluidProperty(obj.Fluid_lib_install_path, obj.LUT_x_axis_name, 'T', T_crit, 'P', P_crit, obj.Fluid, 1, 1, 'MASS BASE SI');
            x_trip = getFluidProperty(obj.Fluid_lib_install_path, obj.LUT_x_axis_name, 'T', T_trip, 'P', P_trip, obj.Fluid, 1, 1, 'MASS BASE SI');
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % find critical input 2 properties %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if startsWith(obj.LUT_y_axis_name, "T")
            y_crit = T_crit;
            y_trip = T_trip;
        elseif startsWith(obj.LUT_y_axis_name, "P")
            y_crit = P_crit;
            y_trip = P_trip;
        else
            y_crit = getFluidProperty(obj.Fluid_lib_install_path, obj.LUT_y_axis_name, 'T', T_crit, 'P', P_crit, obj.Fluid, 1, 1, 'MASS BASE SI');
            y_trip = getFluidProperty(obj.Fluid_lib_install_path, obj.LUT_x_axis_name, 'T', T_trip, 'P', P_trip, obj.Fluid, 1, 1, 'MASS BASE SI');
        end
    else%if contains(obj.Fluid_lib_install_path, 'coolprop', 'IgnoreCase', true)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % find critical temperature and pressure %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        T_crit = getFluidProperty(obj.Fluid_lib_install_path, 'T_CRITICAL', 'Hmass', 1, 'P', 1, obj.Fluid, 1, keepLibraryLoaded=true);
        P_crit = getFluidProperty(obj.Fluid_lib_install_path, 'P_CRITICAL', 'Hmass', 1, 'P', 1, obj.Fluid, 1, keepLibraryLoaded=true);
        T_trip = getFluidProperty(obj.Fluid_lib_install_path, 'T_TRIPLE',   'Hmass', 1, 'P', 1, obj.Fluid, 1, keepLibraryLoaded=true);
        P_trip = getFluidProperty(obj.Fluid_lib_install_path, 'P_TRIPLE',   'Hmass', 1, 'P', 1, obj.Fluid, 1, keepLibraryLoaded=true);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % find critical input 1 properties %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if startsWith(obj.LUT_x_axis_name, "T")
            x_crit = T_crit;
            x_trip = T_trip;
        elseif startsWith(obj.LUT_x_axis_name, "P")
            x_crit = P_crit;
            x_trip = P_trip;
        else
            x_crit = getFluidProperty(obj.Fluid_lib_install_path, obj.LUT_x_axis_name, 'T', T_crit, 'P', P_crit, obj.Fluid, 1, 1, keepLibraryLoaded=true);
            x_trip = getFluidProperty(obj.Fluid_lib_install_path, obj.LUT_x_axis_name, 'T', T_trip, 'P', P_trip, obj.Fluid, 1, 1, keepLibraryLoaded=true);
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % find critical input 2 properties %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if startsWith(obj.LUT_y_axis_name, "T")
            y_crit = T_crit;
            y_trip = T_trip;
        elseif startsWith(obj.LUT_y_axis_name, "P")
            y_crit = P_crit;
            y_trip = P_trip;
        else
            y_crit = getFluidProperty(obj.Fluid_lib_install_path, obj.LUT_y_axis_name, 'T', T_crit, 'P', P_crit, obj.Fluid, 1, 1, keepLibraryLoaded=true);
            y_trip = getFluidProperty(obj.Fluid_lib_install_path, obj.LUT_y_axis_name, 'T', T_trip, 'P', P_trip, obj.Fluid, 1, 1, keepLibraryLoaded=true);
        end
    end % end if REFPROP, else CoolProp

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % save the critical and Triple Point values to the information structure %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    obj.Info_struct.T_crit = T_crit;
    obj.Info_struct.P_crit = P_crit;
    obj.Info_struct.(obj.LUT_x_axis_name + "_crit") = x_crit;
    obj.Info_struct.(obj.LUT_y_axis_name + "_crit") = y_crit;
    obj.Info_struct.T_trip = T_trip;
    obj.Info_struct.P_trip = P_trip;
    obj.Info_struct.(obj.LUT_x_axis_name + "_trip") = x_trip;
    obj.Info_struct.(obj.LUT_y_axis_name + "_trip") = y_trip;
end % end private method findCriticalStates