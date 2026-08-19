function T = getTofHandP(obj, H, P)
    arguments
        obj (1, 1) {mustBeA(obj, "twoPhaseFluidLUT")} % twoPhaseFluidLUT class object
        H   (1, 1) double
        P   (1, 1) double
    end % end input argument blocks

    x_liq = (liqVecNorm' + 1)*(x_sat_liq - LUT_x_axis_range(1)) + LUT_x_axis_range(1);
    x_vap = (vapVecNorm' - 2)*(LUT_x_axis_range(2) - x_sat_vap) + LUT_x_axis_range(2);

    T = interp2(H, P, LUT_T, H_vec, P_vec);
end % end private method getTofHandP