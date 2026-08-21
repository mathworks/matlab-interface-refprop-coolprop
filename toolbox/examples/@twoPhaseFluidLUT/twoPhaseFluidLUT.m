classdef twoPhaseFluidLUT < handle
    properties(Access = public)
        LUT_x_axis_name
        LUT_y_axis_name
        LUT_out_prop_name
        REFPROP_desired_units
    end % end public properties

    properties (GetAccess = public, SetAccess = private)
        Fluid
        Fluid_lib_install_path
        Fluid_table_file_path
        Show_contour_labels = false;
        LUT
        Info_struct
        LUT_x_axis_range
        LUT_y_axis_range
        Num_rows_liq
        Num_rows_vap
        Num_rows_dome
        Num_cols
        Num_y_sub_crit
        Use_log_y_axis = false;
    end % end private properties

    methods
        function obj = twoPhaseFluidLUT(LUT_out_prop_name, LUT_x_axis_name, LUT_y_axis_name, REFPROP_desired_units)
            arguments
                LUT_out_prop_name     (1, 1) string = "";       % Property desired as a function of Prop_in_1 and Prop_in_2
                LUT_x_axis_name       (1, 1) string = "";       % First input property 
                LUT_y_axis_name       (1, 1) string = "";       % Second input property
                REFPROP_desired_units (1, 1) string = "MKS";    % REFPROP allows user to specify units - see REFPROP documentation for more information
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % store the property names - this will be used to create structure field names %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.LUT_x_axis_name       = LUT_x_axis_name;
            obj.LUT_y_axis_name       = LUT_y_axis_name;
            obj.LUT_out_prop_name     = LUT_out_prop_name;
            obj.REFPROP_desired_units = REFPROP_desired_units;
        end % end constructor of twoPhaseFluidLUT class

        function saveLUT(obj, outFile)
            arguments
                obj     (1, 1) {mustBeA(obj, "twoPhaseFluidLUT")} % twoPhaseFluidLUT class object
                outFile (1, 1) string {mustBeNonempty};
            end % end arguments block

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % add output file to the class %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.Fluid_table_file_path = outFile;

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % turn off the warning that occurs when converting object parameters to a structure %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            warning("off", 'MATLAB:structOnObject');

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % save the parameters to a structure %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj_params = struct(obj);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % turn the warning back on %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            warning("on", 'MATLAB:structOnObject');

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % save the structure to a .mat file %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            save(outFile, "obj_params");
        end % end function saveLUT

        function loadTable(obj, fileName)
            arguments
                obj      (1, 1) {mustBeA(obj, "twoPhaseFluidLUT")} % twoPhaseFluidLUT class object
                fileName (1, 1) string {mustBeNonempty, mustBeFile};
            end % end arguments block

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % load the structure from the file %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj_params = load(fileName);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % we assume the file was created by the saveLUT method, if not, it will error %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            try
                obj_params = obj_params.obj_params;
            catch ME
                disp("You must load a lookup table that has come from the twoPhaseFluidLUT createTable method.")
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % get all the names of the fields in the structure %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            fNames = string(fieldnames(obj_params));

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % fill the object properties with the values in the structure %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            for fx = 1:numel(fNames)
                obj.(fNames(fx)) = obj_params.(fNames(fx));
            end % end loop over field names (fx)

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % make sure the file name is up to date %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.Fluid_table_file_path = fileName;
        end % end function loadTable
    end % end public methods
end % end classdef twoPhaseFluidLUT