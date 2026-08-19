function plotLUT(obj)
    arguments
        obj (1, 1) {mustBeA(obj, "twoPhaseFluidLUT")} % twoPhaseFluidLUT class object
    end % end arguments block
    
    x_liq   = obj.Info_struct.Phase_line.(obj.LUT_x_axis_name + "_liq");
    x_vap   = obj.Info_struct.Phase_line.(obj.LUT_x_axis_name + "_vap");
    y_liq   = obj.Info_struct.Phase_line.(obj.LUT_y_axis_name + "_liq");
    y_vap   = obj.Info_struct.Phase_line.(obj.LUT_y_axis_name + "_vap");
    x_crit  = obj.Info_struct.(obj.LUT_x_axis_name + "_crit");
    y_crit  = obj.Info_struct.(obj.LUT_y_axis_name + "_crit");
    out_liq = obj.LUT.out_liq;
    out_vap = obj.LUT.out_vap;

    if obj.Show_contour_labels == true
        showText = 'on';
    else
        showText = 'off';
    end
    
    [~, Y_grid] = meshgrid(obj.LUT.x_liq_Norm, obj.LUT.y_vec);

    hfig = figure(1);
    clf; 
    box on; 
    hold on;
    set(gcf, 'Visible', 'on')
    [~, c_tot] = contour([obj.LUT.x_liq; obj.LUT.x_vap], [Y_grid, Y_grid]', [out_liq; out_vap], "ShowText", showText);
    
    OutMin = min([round(min(out_liq, [], "all"), -1), round(min(out_vap, [], "all"), -1)]);
    OutMax = max([round(max(out_liq, [], "all"), -1), round(max(out_vap, [], "all"), -1)]);
    c_tot.LevelList = OutMin:10:OutMax;
    
    ax = gca;
    ax.YScale = "log";
    
    % Phase Line
    if strcmp(hfig.Theme.BaseColorStyle, "dark")
        colorMark = "w-";
    else
        colorMark = "b-";
    end
    plot([x_liq, x_crit, x_vap(end:-1:1)], [y_liq, y_crit, y_vap(end:-1:1)], colorMark, LineWidth=2)
    hold off
    xlabel(obj.LUT_x_axis_name)
    ylabel(obj.LUT_y_axis_name)
    title(obj.LUT_out_prop_name + "(" + obj.LUT_x_axis_name + ", " + obj.LUT_y_axis_name + ")")
end % end method plotLUT