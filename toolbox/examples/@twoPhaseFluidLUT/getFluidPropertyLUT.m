function outProp = getFluidPropertyLUT(obj, x, y)
    arguments
        obj (1, 1) {mustBeA(obj, "twoPhaseFluidLUT")} % twoPhaseFluidLUT class object
        x   (1, 1) double
        y   (1, 1) double
    end % end input argument blocks

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % get lookup table and vectors %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    x_vec_norm = [obj.LUT.x_liq_Norm, obj.LUT.x_vap_Norm];
    y_vec      = obj.LUT.y_vec;
    LUT_out    = [obj.LUT.out_liq; obj.LUT.out_vap];

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % find the nearest y vector points to y %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    yLT = min(find(obj.LUT.y_vec <  y, 1, "last"),  obj.Num_y_sub_crit);
    yGT = min(find(obj.LUT.y_vec >= y, 1, "first"), obj.Num_y_sub_crit);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % find the values on the liquid and vapor phase lines for x given the y bounds %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    x_liq = obj.Info_struct.Phase_line.(obj.LUT_x_axis_name + "_liq")([yLT, yGT]);
    x_vap = obj.Info_struct.Phase_line.(obj.LUT_x_axis_name + "_vap")([yLT, yGT]);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % find the saturated liquid and vapor values for x at the given y %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    x_sat_liq = interp1(obj.Info_struct.Phase_line.(obj.LUT_y_axis_name + "_liq"), obj.Info_struct.Phase_line.(obj.LUT_x_axis_name + "_liq"), y);
    x_sat_vap = interp1(obj.Info_struct.Phase_line.(obj.LUT_y_axis_name + "_vap"), obj.Info_struct.Phase_line.(obj.LUT_x_axis_name + "_vap"), y);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % figure out whether it is saturated liquid, else saturated vapor, else mixture and calculate the normalized vector %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if any(x < x_liq)
        x_norm = ((x - obj.LUT_x_axis_range(1)) / (x_sat_liq - obj.LUT_x_axis_range(1))) - 1;
    elseif any(x > x_vap)
        x_norm = ((x - obj.LUT_x_axis_range(2)) / (x_sat_vap - obj.LUT_x_axis_range(2))) + 2;
    else
        x_norm = ((x - x_sat_liq) / (x_sat_vap - x_sat_liq));
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % use the 2D lookup table to find the desired fluid property %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    outProp = interp2(x_vec_norm, y_vec, LUT_out, x_norm, y);
end % end private method getFluidPropertyLUT