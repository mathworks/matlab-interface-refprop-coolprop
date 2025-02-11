%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MLCoolProp                                                                              
%   From MATLAB:                                                                          
%        output = MLCoolProp(outputVars, Input1, Input1Val, Input2, Input2Val, Fluid, FluidComposition,...
%                            CoolPropDLLpath, libMethod)                
%                                                                                         
%   Where (see: http://www.coolprop.org/coolprop/HighLevelAPI.html#user-defined-mixtures) 
%                                                                                         
%       output  = DOUBLE (array of size MxN or scalar) output from CoolProp for the desired Property from outputVars. 
%                                                      M is the size of Value1 and N is the size of Value2                                                          
%    outputVars = CHAR value accepted by CoolProp as output property                      
%       Input1  = CHAR value accepted by CoolProp as first input pair property            
%    Input1Val  = DOUBLE (array of size 1xM or scalar) of values related to the first input property                                                          
%       Input2  = CHAR value accepted by CoolProp as second input pair property           
%    Input2Val  = DOUBLE (array of size 1xN or scalar) of values related to the second input property                                                          
%       Fluid   = CHAR value accepted by CoolProp as fluid values for multi-species, list species 1 to numSpec 
%                      (where numSpec is specified by the Composition variable) separated by semicolons (;)                                             
%  FluidComposition = DOUBLE (1xnumSpec array) of species fractions where (1 < numSpec <= 20) and values must sum to 1                                  
%  CoolPropDLLpath = CHAR path to CoolProp directory with the DLL (e.g. C:\\ProgramFiles (x86)\CoolProp)                          
%  libMethod    = CHAR with the CoolProp library method to call - almost always it should be PropsSI                                                         
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
%    h1 = MLCoolProp('Hmolar', 'T', 293.15, 'P', 101.325, 'Nitrogen;Oxygen;Hydrogen;Water', [0.71, 0.16, 0.1, 0.03],...        
%                    dllPath, 'PropsSI')                        
%    Output is given as a 1x1 array: h1 = 9374.9875                                       
%                                                                                         
%    Get sepcific enthalpy for Oxygen/Nitrogen mixture at STP in J/mol (debug flag is ON) 
%    h1 = MLCoolProp('Hmolar', 'T', [293.15 300.00 310.0], 'P', [101.325 104.1], 'Nitrogen;Oxygen;Hydrogen;Water',...
%                    [0.71, 0.16, 0.1, 0.03], dllPath, 'PropsSI')                        
%    Output is given as a 3x2 array: h1 = [ 9374.9875,  9343.7779;                        
%                                           9762.2208,  9762.0559;                        
%                                          10055.4953, 10055.3424]                        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright 2019 - 2025 The MathWorks, Inc.

% History:
%
% Rev 1: Original version
% K. McGarrity
% 29 JAN 2025

function outVals = MLCoolProp(outputVars, Input1, Input1Val, Input2, Input2Val, Fluid, FluidComposition,...
                              CoolPropDLLpath, libMethod)
    arguments
        outputVars       (1, :) string = "Hmass";
        Input1           (1, :) char   = "P";
        Input1Val        (1, :) double = 101325; % Pa
        Input2           (1, :) char   = "T";
        Input2Val        (1, :) double = 300; % K
        Fluid            (1, :) string = "Nitrogen;Oxygen;Hydrogen;Water";
        FluidComposition (1, :) double = [0.71, 0.16, 0.1, 0.03];
        CoolPropDLLpath  (1, :) char   = 'C:\Program Files\CoolProp\';
        libMethod        (1, :) char   = 'PropsSI';
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Checking CoolPropDLLpath validity %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~exist(CoolPropDLLpath, 'dir')
        error(CoolPropDLLpath + " does not exist. Please specify the path to your CoolProp installation.");
    else
        cpDir = struct2table(dir(CoolPropDLLpath));
        if ~any(strcmp(cpDir.name, "CoolPropLib.h"))
            error(Path2CoolProp + " does not contain ""CoolPropLib.h"". Please specify the path to your CoolProp installation.")
        end % end if the directory does not contain CoolProp.EXE
    end % end if not, else, CoolProp directory exists
  
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
                   + "Currently, you have specified " + num2str(numel(Fluid)) + " Fluids: " + strjoin(Fluid, ", ")...
                   + " and " + num2str(numel(FluidComposition)) + " compositions: " + string(FluidComposition));
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

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % if the library DLL is open, close it now and set up the cleanup %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cleanupDLL('CoolProp');
    cleanup = onCleanup(@() cleanupDLL('CoolProp'));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % load the coolprop library %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~contains(path, CoolPropDLLpath)
        addpath(CoolPropDLLpath);
    end
    loadlibrary('CoolProp', 'CoolPropLib.h', 'includepath', CoolPropDLLpath);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % set up the output value array %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    outVals = zeros(numel(Input1Val), numel(Input2Val));

    %%%%%%%%%%%%%%%%%%%%%%%%%
    % set up the input pair %
    %%%%%%%%%%%%%%%%%%%%%%%%%
    inputPair = [Input1, ';', Input2];

    if strcmp(libMethod, 'PropsSI')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % loop through the two input values %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for ix1 = 1:numel(Input1Val)
            for ix2 = 1:numel(Input2Val)
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % get the value from CoolProp %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                outVals(ix1, ix2) = getCoolPropValue(libMethod, outputVars, inputPair=inputPair, input1=Input1Val(ix1),...
                                                     input2=Input2Val(ix2), Species=Fluid);
            end % end loop over input property 2 values (ix2)
        end % end loop over input property 1 values (ix1)
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
        %         outVals = getCoolPropValue(libMethod, outputVars, inputPair=inputPair, input1=Input1Val(ix1),...
        %                                              input2=Input2Val(ix2), Species=Fluid, CoolPropFluidHandle=fluidHandle);
        %     end % end loop over input property 2 values (ix2)
        % end % end loop over input property 1 values (ix1)
    end % end if high-, else low-, level interface
end % end function MLCoolProp

function outData = getCoolPropValue(libMethod, outputParam, opts)
% GETCOOLPROPVALUE calls the CoolProp library method given by libMethod. It returns the specified output parameter based
% on the given input values
% 
% INPUTS:
% obj - (REQUIRED) GasMixtureProperties class object
% libMethod - (REQUIRED) char with the library method to be used to find the output
% outputParam - (REQUIRED) an array of strings or chars listing the names of the desired output parameters
% opts.inputPair - (OPTIONAL) char indicating the parameters to which the input values belong
% opts.input1 - (OPTIONAL) double indicating the first input value of the opts.inputPair
% opts.input2 - (OPTIONAL) double indicating the second input value of the opts.inputPair
% libName - (OPTIONAL) char indicating the library used: 'CoolProp';
% opts.Species - (OPTIONAL) string indicating the fluid species to consider: "Water";
% opts.CoolPropBackend - (OPTIONAL) char indicating the backend calculator: 'HEOS'; 
%                        must be one of: http://www.coolprop.org/_static/doxygen/html/class_cool_prop_1_1_abstract_state.html#a826eea057f75e37f1d5e7bce176f3fa0
% opts.CoolPropSpeciesHandle - (OPTIONAL) CoolProp fluid species handle - required if libMethod is NOT PropSI;

    arguments
        libMethod            (1, :) char
        outputParam          (1, :) {mustBeA(outputParam, ["string", "char"])}
        opts.inputPair       (1, :) char   = '';
        opts.input1          (1, 1) double = 0;
        opts.input2          (1, 1) double = 0;
        opts.Species         (1, :) char   = 'Water';
        opts.CoolPropBackend (1, :) char   = 'HEOS'; % must be one of: http://www.coolprop.org/_static/doxygen/html/class_cool_prop_1_1_abstract_state.html#a826eea057f75e37f1d5e7bce176f3fa0
        opts.CoolPropFluidHandle;
    end % end input arguments

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % variables needed for error messaging %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    sizeErr = 1000;
    iErr    = 0;
    hErr    = char(1:1:sizeErr);
    libName = 'CoolProp';

    switch libMethod
        case 'AbstractState_factory'
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % setup the AbstractState and return the handle to the fluid %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [outData, ~, ~, iErr, hErr] = calllib(libName, libMethod, opts.CoolPropBackend,...
                                                  opts.Species, iErr, hErr, sizeErr);
        case 'AbstractState_phase'
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % force the phase to be the specified by the outputParam - abuse of this variable %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [outData, iErr, hErr] = calllib(libName, libMethod,...
                                            opts.CoolPropFluidHandle, iErr, hErr, sizeErr);
        case 'AbstractState_specify_phase'
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % force the phase to be the specified by the outputParam - abuse of this variable %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [outData, iErr, hErr] = calllib(libName, libMethod,...
                                            opts.CoolPropFluidHandle, outputParam,...
                                            iErr, hErr, sizeErr);

        case {'AbstractState_update_and_1_out', 'AbstractState_update_and_5_out'}
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % need to know input length %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            len = numel(opts.input1);

            %%%%%%%%%%%%%%%%%%%%%%%%
            % get input pair index %
            %%%%%%%%%%%%%%%%%%%%%%%%
            inputPairIdx = calllib(libName, 'get_input_pair_index', opts.inputPair);

            if isstring(outputParam)
                outputIdx = zeros(size(outputParam));
                for ox = 1:numel(outputParam)
                    outputIdx(ox) = calllib(libName, 'get_param_index', outputParam{ox});
                end
            else
                outputIdx = calllib(libName, 'get_param_index', outputParam);
            end


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % make pointers from the inputs and outputs %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            input1Ptr = libpointer('doublePtr', opts.input1);
            input2Ptr = libpointer('doublePtr', opts.input2);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % call the CoolProp library and check for any errors %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if endsWith(libMethod, "1_out")
                outputPtr = libpointer('doublePtr', 0);
                [~, ~, outData, iErr, hErr] = calllib(libName, libMethod,...
                                                      opts.CoolPropFluidHandle,...
                                                      inputPairIdx, input1Ptr, input2Ptr, len, outputIdx,...
                                                      outputPtr, iErr, hErr, sizeErr);
            elseif endsWith(libMethod, "5_out")
                out1Ptr = libpointer('doublePtr', 0);
                out2Ptr = libpointer('doublePtr', 0);
                out3Ptr = libpointer('doublePtr', 0);
                out4Ptr = libpointer('doublePtr', 0);
                out5Ptr = libpointer('doublePtr', 0);
                [~, ~, ~, outData(1), outData(2),...
                          outData(3), outData(4),...
                          outData(5), iErr, hErr] = calllib(libName, libMethod,...
                                                            opts.CoolPropFluidHandle,...
                                                            inputPairIdx, input1Ptr, input2Ptr, len, outputIdx,...
                                                            out1Ptr, out2Ptr, out3Ptr, out4Ptr, out5Ptr, iErr, hErr,...
                                                            sizeErr);
            else
                [outData, iErr, hErr] = calllib(libName, libMethod,...
                                                opts.CoolPropFluidHandle, inputPairIdx,...
                                                input1Ptr, input2Ptr, iErr, hErr, sizeErr);
            end
        case'Props1SI'
            outData = calllib(libName, libMethod, opts.Species, outputParam);
        case'PropsSI'
            if isstring(outputParam)
                outputParam = outputParam{:};
            end
            inputPair = strsplit(opts.inputPair, ";");
            outData   = calllib(libName, libMethod, outputParam, inputPair{1}, opts.input1,...
                                inputPair{2}, opts.input2, opts.Species);
        otherwise
            error("Time to handle the requested library method: " + libMethod);
    end % ene switch over library method
    coolpropErrorCheck(iErr, hErr, opts.Species, libMethod)
end % end function makeLibCall

function cleanupDLL(libName)
    if libisloaded(libName)
        unloadlibrary(libName)
    end % if library is currently loaded
end % function cleanupCoolPropDLL

function coolpropErrorCheck(iErr, errTxt, substance, subroutine)
    if iErr ~= 0
        ME = MException("GasMixtureProperties:CoolProp:" + subroutine, "CoolProp:%s call error for %s",...
                        subroutine, substance);
        errMsg = replace(char(errTxt(:)'), '\', '\\');
        if (strlength(errMsg) > 0) && ~all(errMsg == ' ')
            ME = addCause(ME, MException("CoolProp:DLL", errMsg));
        end
        throwAsCaller(ME);
    end % end if there is a non-zero error code returned
end % function coolpropErrorCheck
