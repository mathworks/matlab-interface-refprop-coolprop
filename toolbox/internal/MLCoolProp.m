classdef MLCoolProp < handle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % MLCoolProp
    %   From MATLAB(R):
    %        output = MLCoolProp(outputVars, Input1, Input1Val, Input2, Input2Val, Fluid, FluidComposition,...
    %                            CoolPropDLLpath, libMethod)
    %
    %   Where (see: http://www.coolprop.org/coolprop/HighLevelAPI.html#user-defined-mixtures)
    %
    %       output  = DOUBLE (array of size MxN or scalar) output from CoolProp for the desired Property from outputVars
    %                                                      M is the size of Value1 and N is the size of Value2
    %    outputVars = CHAR value accepted by CoolProp as output property
    %       Input1  = CHAR value accepted by CoolProp as first input pair property
    %    Input1Val  = DOUBLE (array of size 1xM or scalar) of values related to the first input property
    %       Input2  = CHAR value accepted by CoolProp as second input pair property
    %    Input2Val  = DOUBLE (array of size 1xN or scalar) of values related to the second input property
    %       Fluid   = CHAR value accepted by CoolProp as fluid values for multi-species, list species 1 to numSpec
    %                      (where numSpec is specified by the Composition variable) separated by semicolons (;)
    %  FluidComposition  = DOUBLE (1xnumSpec array) of species fractions where (1 < numSpec <= 20), values must sum to 1
    %  CoolPropDLLpath   = CHAR path to CoolProp directory with the DLL (e.g. C:\\ProgramFiles (x86)\CoolProp)
    %  libMethod         = CHAR with the CoolProp library method to call - almost always it should be PropsSI
    %  keepLibraryLoaded = [CoolProp optional (name, value) pair] (logical) defaults to false -> load and unload
    %                                                                                             CoolProp library with 
    %                                                                                             every funciton call
    %                                                                                    true -> keep library loaded for
    %                                                                                            multiple funciton calls
    %                       NOTE: user should unload the library when finished: in the MATLAB command line type
    %                                                                           unloadlibrary('CoolProp')
    %
    %
    %  Examples:
    %    dllPath = 'C:\Program Files (x86)\CoolProp\';
    %
    %    Get the specific enthalpy of water at STP in J/mol (debug flag is ON):
    %    h1 = MLCoolProp('Hmass', 'T', 293.15, 'P', 101325, 'Water', 1, dllPath, 'PropsSI')
    %    Output is given as a 1x1 array: h1 = 84007.3009
    %
    %    Get specific enthalpy of water at STP in J/mol (debug flag is ON) at three different
    %       temperatures for a single pressure:
    %    h1 = MLCoolProp('Hmass', 'T', [293.15 400.0 542.0], 'P', 101325, 'Water', 1, dllPath, 'PropsSI')
    %    Output is given as a 3x1 column vector: h1 = [  84007.3009
    %                                                  2730301.3859
    %                                                  3012047.8685]
    %
    %    Get specific enthalpy of water at STP in J/mol (debug flag is ON) at 1 temperature
    %       and two different pressures:
    %    h1 = MLCoolProp('Hmass', 'T', [293.15], 'P', [101325 104100], 'Water', 1, dllPath, 'PropsSI')
    %    Output is given as a 1x2 row vector: h1 = [1513.4140, 1513.4611]
    %
    %    Get specific enthalpy of water at STP in J/mol (debug flag is ON) at three different temperatures and
    %        two different pressures:
    %    h1 = MLCoolProp('Hmolar', 'T', [293.15 400.00 542.0], 'P', [101325 104100], 'Water', 1, dllPath, 'PropsSI')
    %    Output is given as a 3x2 array: h1 = [ 1513.4140,  1513.4611
    %                                          49187.1112, 49182.3587
    %                                          54262.8496, 54261.3874]
    %
    %    Get specific enthalpy for Oxygen/Nitrogen mixture at STP in J/mol (debug flag is ON)
    %    h1 = MLCoolProp('Hmolar', 'T', 293.15, 'P', 101.325, 'Nitrogen;Oxygen;Hydrogen;Water',...
    %                    [0.71, 0.16, 0.1, 0.03], dllPath, 'PropsSI')                        
    %    Output is given as a 1x1 array: h1 = 9374.9875
    %
    %    Get sepcific enthalpy for Oxygen/Nitrogen mixture at STP in J/mol (debug flag is ON)
    %    h1 = MLCoolProp('Hmolar', 'T', [293.15 300.00 310.0], 'P', [101.325 104.1],...
    %                    'Nitrogen;Oxygen;Hydrogen;Water', [0.71, 0.16, 0.1, 0.03], dllPath, 'PropsSI')                        
    %    Output is given as a 3x2 array: h1 = [ 9374.9875,  9343.7779;
    %                                           9762.2208,  9762.0559;
    %                                          10055.4953, 10055.3424]
    %
    %    Get the minimum and maximum temperatures in K for a specific fluid - no inputs required
    %    Tmin_val = getFluidProperty(CoolProp_path,'Tmin', "", [], "", [], "Water", 1);
    %    Tmax_val = getFluidProperty(CoolProp_path,'Tmax', "", [], "", [], "Water", 1);
    %
    %    keep the CoolProp library loaded when making multiple calls - specify optional value keepLibraryLoaded as true
    %    T_min = getFluidProperty(coolPropLib,'Tmin', "", [], "", [], 'R410A', 1, keepLibraryLoaded=true);
    %    T_max = getFluidProperty(coolPropLib,'Tmax', "", [], "", [], 'R410A', 1, keepLibraryLoaded=true);
    %    h_min = getFluidProperty(coolPropLib,'H', 'T', T_min, 'P', 800000, 'R410A', 1, keepLibraryLoaded=true);
    %    h_max = getFluidProperty(coolPropLib,'H', 'T', T_max, 'P', 800000, 'R410A', 1, keepLibraryLoaded=true);
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Copyright 2019 - 2025 The MathWorks, Inc.
    
    % History:
    %
    % Rev 1: Original version
    % K. McGarrity
    % 29 JAN 2025
    
    properties
        libMethod     (1, :) char    = 'PropsSI';
        sizeErr       (1, 1) double  = 1000;
        iErr          (1, 1) double  = 0;
        hErr          (1, :) char    = char(1:1:1000);
        libName       (1, :) char    = 'CoolProp';
        keepLibLoaded (1, 1) logical = false;
    end

    methods
        function obj = MLCoolProp(CoolPropDLLpath, keepLibraryLoaded)
            arguments
                CoolPropDLLpath   (1, :) char
                keepLibraryLoaded (1, 1) logical
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % set the value in the object - needed for destructor %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            obj.keepLibLoaded = keepLibraryLoaded;

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Check CoolPropDLLpath validity %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if ~exist(CoolPropDLLpath, 'dir')
                error(CoolPropDLLpath + " does not exist. Please specify the path to your CoolProp installation.");
            else
                cpDir = struct2table(dir(CoolPropDLLpath));
                if ~any(strcmp(cpDir.name, "CoolPropLib.h"))
                    error(CoolPropDLLpath + " does not contain ""CoolPropLib.h""."...
                                          + " Please specify the path to your CoolProp installation.")
                end % end if the directory does not contain CoolProp.EXE
            end % end if not, else, CoolProp directory exists
          
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % if the library DLL is open, close it now and set up the cleanup %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if keepLibraryLoaded == false
                obj.cleanupDLL;
            end
        
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % load the coolprop library %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if ~contains(path, CoolPropDLLpath)
                addpath(CoolPropDLLpath);
            end
            if ~libisloaded(obj.libName)
                loadlibrary(obj.libName, 'CoolPropLib.h', 'includepath', CoolPropDLLpath);
            end
        end % end class constructor

        function delete(obj)
            if obj.keepLibLoaded == false
                obj.cleanupDLL;
            end
        end

        function outVals = getCoolPropValues(obj, outputVars, Input1, Input1Val, Input2, Input2Val, Fluid,...
                                             FluidComposition)
            arguments
                obj
                outputVars       (1, :) char
                Input1           (1, :) char
                Input1Val        (1, :) double
                Input2           (1, :) char
                Input2Val        (1, :) double
                Fluid            (1, :) string
                FluidComposition (1, :) double
            end
        
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % ensure Fluid Composition sums to 1 %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if ~isbetween(sum(FluidComposition), 0.99999999, 1.000000001)
                error(   "Composition must contain positive values between 0 and 1, which sum to 1. "...
                       + "Currently, your composition [" + num2str(FluidComposition) + "] sums to " ...
                       + num2str(sum(FluidComposition)));
            end % end if sum of fluid composition not equal to 1
        
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % put the user-defined fluid together in the required format %
            % e.g., given the default fluid and fluidComposition         %
            % the CoolProp fluid should be:                              %
            % "Nitrogen[0.71]&Oxygen[0.16]&Hydrogen[0.1]&Water[0.03]"    %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if numel(FluidComposition) > 1
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % split the Fluid into its consituent parts %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                Fluid = strsplit(Fluid, ";");
        
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % convert composition to strings %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                FluidComposition = string(FluidComposition);
        
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % make sure the number of species in the fluid matches the number of fluid composition values %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if (numel(Fluid) ~= numel(FluidComposition))
                    error(   "Fluid must have the same number of elements as the specified composition. "...
                           + "Currently, you have specified " + num2str(numel(Fluid)) + " Fluids: "...
                           + strjoin(Fluid, ", ") + " and " + num2str(numel(FluidComposition))...
                           + " compositions: " + strjoin(FluidComposition, ", "));
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % CoolProp expects user-defined fluids to be a string of the form:        %
                % Species1[species1Frac]&Species2[species2Frac]&...SpeciesN[speciesNFrac] %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                tmpFluid = repmat("", size(Fluid));
                for fx = 1:numel(Fluid)
                    tmpFluid(fx) = Fluid(fx) + "[" + FluidComposition(fx) + "]";
                end % end loop over fluids
                Fluid = strjoin(tmpFluid, "&");
            end % end if user-defined fluid
        
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % set up the output value array %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            outVals = zeros(numel(Input1Val), numel(Input2Val));
        
            %%%%%%%%%%%%%%%%%%%%%%%%%
            % set up the input pair %
            %%%%%%%%%%%%%%%%%%%%%%%%%
            inputPair = [Input1, ';', Input2];
        
            if strcmp(inputPair, ";")
                obj.libMethod = 'Props1SI';
            end
        
            if strcmp(obj.libMethod, 'PropsSI')
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % loop through the two input values %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                for ix1 = 1:numel(Input1Val)
                    for ix2 = 1:numel(Input2Val)
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        % get the value from CoolProp %
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        outVals(ix1, ix2) = obj.getOutputValue(outputVars, inputPair=inputPair,...
                                                               input1=Input1Val(ix1), input2=Input2Val(ix2),...
                                                               Species=Fluid);
                    end % end loop over input property 2 values (ix2)
                end % end loop over input property 1 values (ix1)
            elseif strcmp(obj.libMethod, 'Props1SI')
                outVals = obj.getOutputValue(outputVars, Species=Fluid);
            else
                error("Time to figure this out!")
                % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % % we need this here if we are ever going to use anything other than PropSI %
                % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % fluidHandle = getCoolPropValue('AbstractState_factory', 'handle', Species=Fluid);
                % 
                % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % % loop through the two input values %
                % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % for ix1 = 1:numel(Input1Val)
                %     for ix2 = 1:numel(Input2Val)
                %         outVals(ix1, ix2) = obj.getOutputValue(outputVars, inputPair=inputPair,...
                %                                                input1=Input1Val(ix1), input2=Input2Val(ix2),...
                %                                                Species=Fluid);
                %     end % end loop over input property 2 values (ix2)
                % end % end loop over input property 1 values (ix1)
            end % end if high-, else low-, level interface
        end % end method getCoolPropValues
        
        function outData = getOutputValue(obj, outputParam, opts)
        % GETOUTPUTVALUE calls the CoolProp library method given by libMethod. It returns the specified output parameter
        %                based on the given input values
        % 
        % INPUTS:
        % obj - (REQUIRED) GasMixtureProperties class object
        % outputParam - (REQUIRED) an array of strings or chars listing the names of the desired output parameters
        % opts.inputPair - (OPTIONAL) char indicating the parameters to which the input values belong
        % opts.input1 - (OPTIONAL) double indicating the first input value of the opts.inputPair
        % opts.input2 - (OPTIONAL) double indicating the second input value of the opts.inputPair
        % libName - (OPTIONAL) char indicating the library used: 'CoolProp';
        % opts.Species - (OPTIONAL) string indicating the fluid species to consider: "Water";
        % opts.CoolPropBackend - (OPTIONAL) char indicating the backend calculator: 'HEOS'; 
        %                        must be one of: http://www.coolprop.org/_static/doxygen/html/class_cool_prop_1_1_abstract_state.html#a826eea057f75e37f1d5e7bce176f3fa0
        % opts.CoolPropSpeciesHandle - (OPTIONAL) CoolProp fluid species handle - required if libMethod is NOT PropsSI;
        
            arguments
                obj
                outputParam          (1, :) {mustBeA(outputParam, ["string", "char"])}
                opts.inputPair       (1, :) char
                opts.input1          (1, 1) double
                opts.input2          (1, 1) double
                opts.Species         (1, :) char
                opts.CoolPropBackend (1, :) char = 'HEOS';
                opts.CoolPropFluidHandle;
            end % end input arguments
        
            switch obj.libMethod
                case 'AbstractState_factory'
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % setup the AbstractState and return the handle to the fluid %
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    [outData, ~, ~, obj.iErr, obj.hErr] = calllib(obj.libName, obj.libMethod, opts.CoolPropBackend,...
                                                                  opts.Species, obj.iErr, obj.hErr, obj.sizeErr);
                case 'AbstractState_phase'
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % force the phase to be the specified by the outputParam - abuse of this variable %
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    [outData, obj.iErr, obj.hErr] = calllib(obj.libName, obj.libMethod,...
                                                            opts.CoolPropFluidHandle, obj.iErr, obj.hErr, obj.sizeErr);
                case 'AbstractState_specify_phase'
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % force the phase to be the specified by the outputParam - abuse of this variable %
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    [outData, obj.iErr, obj.hErr] = calllib(obj.libName, obj.libMethod,...
                                                            opts.CoolPropFluidHandle, outputParam,...
                                                            obj.iErr, obj.hErr, obj.sizeErr);
        
                case {'AbstractState_update_and_1_out', 'AbstractState_update_and_5_out'}
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % need to know input length %
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    len = numel(opts.input1);
        
                    %%%%%%%%%%%%%%%%%%%%%%%%
                    % get input pair index %
                    %%%%%%%%%%%%%%%%%%%%%%%%
                    inputPairIdx = calllib(obj.libName, 'get_input_pair_index', opts.inputPair);
        
                    if isstring(outputParam)
                        outputIdx = zeros(size(outputParam));
                        for ox = 1:numel(outputParam)
                            outputIdx(ox) = calllib(obj.libName, 'get_param_index', outputParam{ox});
                        end
                    else
                        outputIdx = calllib(obj.libName, 'get_param_index', outputParam);
                    end
        
        
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % make pointers from the inputs and outputs %
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    input1Ptr = libpointer('doublePtr', opts.input1);
                    input2Ptr = libpointer('doublePtr', opts.input2);
        
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % call the CoolProp library and check for any errors %
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    if endsWith(obj.libMethod, "1_out")
                        outputPtr = libpointer('doublePtr', 0);
                        [~, ~, outData, obj.iErr, obj.hErr] = calllib(obj.libName, obj.libMethod,...
                                                                      opts.CoolPropFluidHandle,...
                                                                      inputPairIdx, input1Ptr, input2Ptr, len,...
                                                                      outputIdx, outputPtr, obj.iErr, obj.hErr,...
                                                                      obj.sizeErr);
                    elseif endsWith(obj.libMethod, "5_out")
                        out1Ptr = libpointer('doublePtr', 0);
                        out2Ptr = libpointer('doublePtr', 0);
                        out3Ptr = libpointer('doublePtr', 0);
                        out4Ptr = libpointer('doublePtr', 0);
                        out5Ptr = libpointer('doublePtr', 0);
                        [~, ~, ~, outData(1), outData(2),...
                                  outData(3), outData(4),...
                                  outData(5), obj.iErr, obj.hErr] = calllib(obj.libName, obj.libMethod,...
                                                                            opts.CoolPropFluidHandle,...
                                                                            inputPairIdx, input1Ptr, input2Ptr, len,...
                                                                            outputIdx, out1Ptr, out2Ptr, out3Ptr,...
                                                                            out4Ptr, out5Ptr, obj.iErr, obj.hErr,...
                                                                            obj.sizeErr);
                    else
                        [outData, obj.iErr, obj.hErr] = calllib(obj.libName, obj.libMethod,...
                                                                opts.CoolPropFluidHandle, inputPairIdx,...
                                                                input1Ptr, input2Ptr, obj.iErr, obj.hErr, obj.sizeErr);
                    end
                case'Props1SI'
                    outData = calllib(obj.libName, obj.libMethod, opts.Species, outputParam);
                case'PropsSI'
                    if isstring(outputParam)
                        outputParam = outputParam{:};
                    end
                    inputPair = strsplit(opts.inputPair, ";");
                    outData   = calllib(obj.libName, obj.libMethod, outputParam, inputPair{1}, opts.input1,...
                                        inputPair{2}, opts.input2, opts.Species);
                otherwise
                    error("Time to handle the requested library method: " + obj.libMethod);
            end % ene switch over library method
            obj.coolpropErrorCheck(opts.Species)
        end % end method makeLibCall
        
        function cleanupDLL(obj)
            if libisloaded(obj.libName)
                unloadlibrary(obj.libName)
            end % if library is currently loaded
        end % method cleanupCoolPropDLL
        
        function coolpropErrorCheck(obj, substance)
            if obj.iErr ~= 0
                ME = MException("GasMixtureProperties:CoolProp:" + obj.libMethod, "CoolProp:%s call error for %s",...
                                obj.libMethod, substance);
                errMsg = replace(char(obj.hErr(:)'), '\', '\\');
                if (strlength(errMsg) > 0) && ~all(errMsg == ' ')
                    ME = addCause(ME, MException("CoolProp:DLL", errMsg));
                end
                throwAsCaller(ME);
            end % end if there is a non-zero error code returned
        end % method coolpropErrorCheck
    end % end public methods
end % end class def MLCoolProp
