function findPhaseLine(obj)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % the pressure vector is my Y variable for the lookup table %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    y_vec = obj.LUT.y_vec;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % find the sub-critical values of Pressure %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    y_vec_sub_crit = y_vec < obj.Info_struct.(obj.LUT_y_axis_name + "_crit");
    obj.Num_y_sub_crit = nnz(y_vec_sub_crit);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % liquid line is forward, vapor line is backward %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    y_liq_vec = y_vec(y_vec_sub_crit);
    y_vap_vec = y_liq_vec;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % get sub-critical values of property 2 for liquid and vapor phases %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if contains(obj.Fluid_lib_install_path, 'refprop', 'IgnoreCase', true)
        x_liq_vec = getFluidProperty(obj.Fluid_lib_install_path, obj.LUT_x_axis_name, 'Q', 0, obj.LUT_y_axis_name, y_liq_vec, obj.Fluid, 1, 1, obj.REFPROP_desired_units);
        x_vap_vec = getFluidProperty(obj.Fluid_lib_install_path, obj.LUT_x_axis_name, 'Q', 1, obj.LUT_y_axis_name, y_vap_vec, obj.Fluid, 1, 1, obj.REFPROP_desired_units);
    else%if contains(libLoc, 'coolprop', 'IgnoreCase', true)
        x_liq_vec = getFluidProperty(obj.Fluid_lib_install_path, obj.LUT_x_axis_name, 'Q', 0, obj.LUT_y_axis_name, y_liq_vec, obj.Fluid, 1, keepLibraryLoaded=true);
        x_vap_vec = getFluidProperty(obj.Fluid_lib_install_path, obj.LUT_x_axis_name, 'Q', 1, obj.LUT_y_axis_name, y_vap_vec, obj.Fluid, 1, keepLibraryLoaded=true);
    end % end if REFPROP, else CoolProp
    
    %%%%%%%%%%%%%%%%%%%%
    % save phase lines %
    %%%%%%%%%%%%%%%%%%%%
    obj.Info_struct.Phase_line.(obj.LUT_x_axis_name + "_liq")          = x_liq_vec;
    obj.Info_struct.Phase_line.(obj.LUT_x_axis_name + "_vap")          = x_vap_vec;
    obj.Info_struct.Phase_line.(obj.LUT_y_axis_name + "_liq")          = y_liq_vec;
    obj.Info_struct.Phase_line.(obj.LUT_y_axis_name + "_vap")          = y_vap_vec;
    obj.Info_struct.Phase_line.(obj.LUT_y_axis_name + "_vec_sub_crit") = y_vec_sub_crit;
end % end private method findPhaseLine