function plotLUT(obj)
    arguments
        obj (1, 1) {mustBeA(obj, "twoPhaseFluidLUT")} % twoPhaseFluidLUT class object
    end % end arguments block
    
    x_liq    = obj.Info_struct.Phase_line.(obj.LUT_x_axis_name + "_liq");
    x_vap    = obj.Info_struct.Phase_line.(obj.LUT_x_axis_name + "_vap");
    y_liq    = obj.Info_struct.Phase_line.(obj.LUT_y_axis_name + "_liq");
    y_vap    = obj.Info_struct.Phase_line.(obj.LUT_y_axis_name + "_vap");
    x_crit   = obj.Info_struct.(obj.LUT_x_axis_name + "_crit");
    y_crit   = obj.Info_struct.(obj.LUT_y_axis_name + "_crit");
    out_liq  = obj.LUT.out_liq;
    out_vap  = obj.LUT.out_vap;
    out_dome = obj.LUT.out_dome;

    if obj.Show_contour_labels == true
        showText = 'on';
    else
        showText = 'off';
    end
    
    [~, Y_grid_liq]  = meshgrid(obj.LUT.x_liq_norm,  obj.LUT.y_vec);
    [~, Y_grid_dome] = meshgrid(obj.LUT.x_dome_norm, obj.LUT.y_vec);
    [~, Y_grid_vap]  = meshgrid(obj.LUT.x_vap_norm,  obj.LUT.y_vec);

    hfig = figure(1);
    clf; 
    box on; 
    hold on;
    set(gcf, 'Visible', 'on')
    [~, c_tot] = contour([obj.LUT.x_liq; obj.LUT.x_dome; obj.LUT.x_vap], [Y_grid_liq, Y_grid_dome, Y_grid_vap]', [out_liq; out_dome; out_vap], "ShowText", showText);
    
    OutMin = min([round(min(out_liq, [], "all"), -1), round(min(out_vap, [], "all"), -1)]);
    OutMax = max([round(max(out_liq, [], "all"), -1), round(max(out_vap, [], "all"), -1)]);
    c_tot.LevelList = OutMin:10:OutMax;
    
    if obj.Use_log_y_axis == true
        ax = gca;
        ax.YScale = "log";
    end % end if y axis should be logarithmic 
    
    % Phase Line
    if strcmp(hfig.Theme.BaseColorStyle, "dark")
        colorMark = "w-";
    else
        colorMark = "b-";
    end
    plot([x_liq, x_crit, x_vap(end:-1:1)], [y_liq, y_crit, y_vap(end:-1:1)], colorMark, LineWidth=2)
    plot([obj.Info_struct.(obj.LUT_x_axis_name + "_crit"), obj.LUT.x_sat_liq(obj.Num_y_sub_crit+1:end)],...
         [obj.Info_struct.(obj.LUT_y_axis_name + "_crit"), obj.LUT.y_vec(obj.Num_y_sub_crit+1:end)], colorMark,...
         LineWidth=2);

    xlabel(obj.LUT_x_axis_name)
    ylabel(obj.LUT_y_axis_name)
    title(obj.LUT_out_prop_name + "(" + obj.LUT_x_axis_name + ", " + obj.LUT_y_axis_name + ")")
end % end method plotLUT