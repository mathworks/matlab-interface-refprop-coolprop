function outProp = getFluidPropertyLUT(obj, x, y)
    arguments
        obj (1, 1) {mustBeA(obj, "twoPhaseFluidLUT")} % twoPhaseFluidLUT class object
        x   (1, 1) double
        y   (1, 1) double
    end % end input argument blocks

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % get lookup table and vectors %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    x_vec_norm = [obj.LUT.x_liq_norm, obj.LUT.x_dome_norm, obj.LUT.x_vap_norm];
    y_vec      =  obj.LUT.y_vec;
    LUT_out    = [obj.LUT.out_liq; obj.LUT.out_dome; obj.LUT.out_vap];

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % find the saturated liquid and vapor values for x at the given y %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    x_sat_liq = interp1(y_vec, obj.LUT.x_sat_liq, y);
    x_sat_vap = interp1(y_vec, obj.LUT.x_sat_vap, y);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % calculate the normal based on whether x is in liquid, vapor, or VLE state %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if (x < x_sat_liq)
        x_norm = ((x - obj.LUT_x_axis_range(1)) / (x_sat_liq - obj.LUT_x_axis_range(1))) - 1;
    elseif (x > x_sat_vap)
        x_norm = ((x - obj.LUT_x_axis_range(2)) / (obj.LUT_x_axis_range(2) - x_sat_vap)) + 2;
    else
        x_norm = ((x - x_sat_liq) / (x_sat_vap - x_sat_liq));
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % use the 2D lookup table to find the desired fluid property   %
    % Take transpose of LUT because it was built up row-wise and   %
    % it needs to be column wise in order to match x,y expectation %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    outProp = interp2(x_vec_norm, y_vec, LUT_out', x_norm, y);
end % end private method getFluidPropertyLUT