%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [OUTPUT]:                                                                                                        
% requestedPropertyValue = (double) (MxN) array of values for the requested thermodynamic property as calculated by the 
%                                   library where M is the number of values for inputProperty1 and N is the number of
%                                   values for inputProperty2
% [INPUTS]:                                                                                                        
% libraryLocation     = (string) the location of the REFPROP or CoolProp library files (dll, exe, etc.)            
% requestedProperty   = (string) the thermodynamic property name for which the value will be returned              
% inputProperty1      = (string) name of the 1st property used as the state point                                  
% inputProperty1Value = (double) (1xM) array of values of the 1st property used as the state point in the library’s 
%                                expected units 
% inputProperty2      = (string) name of the 2nd property used as the state point                                  
% inputProperty2Value = (double) (1xN) array of values of the 2nd property used as the state point in the library’s 
%                                expected units 
% fluid               = (string) indicating the fluid for which the requested property should be calculated
%                                e.g., "Water", "Ethanol", "Nitrogen;Oxygen;Hydrogen;Water"
%                                NOTE: if the user defines their own fluid, the species should be listed out as in the
%                                      last example above using only a semicolon (;) to separate the species
% fluidComposition    = (double) array of size 1 x numSpec species fraction where 1 <= numSpec <= 20, whose values must 
%                                sum to 1; numSpec must match the number of species in the fluid
%                                e.g., if fluid = "Water", (numSpec = 1)
%                                         fluidComposition = 1;
%                                      if fluid = "Nitrogen;Oxygen;Hydrogen;Water", (numSpec = 4)
%                                         fluidComposition = [0.71, 0.16, 0.1, 0.03]
% massOrMolar         = [REFPROP only] (int) value to determine input composition units: 0 -> Molar, 1 -> Mass     
% desiredUnits        = [REFPROP only] (char) enum as expected by refprop.dll to determine the units to use        
%                                             e.g., MKS, MASS BASE SI, etc.          
% keepLibraryLoaded   = [CoolProp optional (name, value) pair] (logical) defaults to false -> load and unload CoolProp 
%                                                                                             library with every 
%                                                                                             function call
%                                                                                    true -> keep library loaded for
%                                                                                            multiple function calls
%                       NOTE: user should unload the library when finished: in the MATLAB command line type
%                                                                           unloadlibrary('CoolProp')
% outputAsStruct      = [optional (name value) pair] (boolean) defaults to false -> require a number of output 
%                                                                                   variables equal to the number of 
%                                                                                   properties specified in 
%                                                                                   requestedProperty value 
%                                                                          true  -> single output variable which is a
%                                                                                   structure whose fields are the same
%                                                                                   name as each property specified in 
%                                                                                   requestedProperty.
% referenceState     = [REFPROP optional (name, value) pair] (char) Reference state definition - if this is unspecified
%                                                                   REFPROP uses the default definition in the fluid 
%                                                                   file. Accepted options for reference states by
%                                                                   REFPROP: 'ASH' for ASHRE convention h,s=0 @ -40C, 
%                                                                            'NBP' h,s=0 at normal boiling point(s)
%                                                                            'IIR' for IRR convention h=200kJ/kg, 
%                                                                                  s=1 kJ/kg-K for sat. liquid @ 0C 
%                                                                            'DEF' for default values in fluid file
%                                                                            'OTH;H0;S0;T0;P0' for real gas state
%                                                                            'OT0;H0;S0;T0;P0' for ideal-gas state
%                                                                                   where H0, S0, T0, P0 are the 
%                                                                                   actual numbers specified by user
%                                                                                   e.g. 'OTH;10.0;1.0;323.15;101.325'
%                                                                                   H0 in J/mol, S0 in J/mol-K, T0 in K
%                                                                                   P0 in kPa
% equationOfState    = [REFPROP optional (name, value) pair] (char) Equation of State definition - if this is unspecified
%                                                                   REFPROP uses the default definition in the fluid 
%                                                                   file. Accepted options for reference states by
%                                                                   REFPROP: 'PRx' for Peng-Robinson
%                                                                                      where x = 0 (turn off)
%                                                                                            x = 2 (use for all calculations)
%                                                                                            x = 3 (use with translation term deactivated)
%                                                                            'AGA8x' for AGA8 (American Gas Association) equation of state
%                                                                                      where x = 0 (turn off)
%                                                                                            x = 1 (turn on)
%                                                                            'GERGx' for GERG-2008 equation of state
%                                                                                      where x = 0 (turn off)
%                                                                                      where x = 1 (turn on)
% RapidMode           = LOGICAL value (false to suppress, true to show) Rapid mode - when true, skip input checks and only
%                                                                                load REFPROP DLL once, do not unload it
%                               CAUTION!!!! The user needs to take care with their inputs!!!
%                               If your inputs to REFPROP or not correct, MATLAB will crash!
%                               Suppress rapid mode to debug issues.
%
% See REFPROP documentation (https://trc.nist.gov/refprop/REFPROP.PDF) and CoolProp documentation 
% (http://www.coolprop.org/coolprop/HighLevelAPI.html#table-of-string-inputs-to-propssi-function) for allowed values 
% for requested and input properties.
%
% EXAMPLES for REFPROP:                                                                                                 
%    libLoc = 'C:\Program Files (x86)\REFPROP\';                                                                   
%                                                                                                                  
%    Get the specific enthalpy of water at STP in J/mol (debug flag is ON):                                        
%    h1 = getFluidProperty(libLoc, 'H', 'T', 293.15, 'P', 101.325, 'Water', 1, 1, 'MKS')                           
%    Output is given as a 1x1 array: h1 = 84.0073                                                                  
%                                                                                                                  
%    Get specific enthalpy of water at STP in J/mol (debug flag is ON) at three different                          
%       temperatures for a single pressure:                                                                        
%    h1 = getFluidProperty(libLoc, 'H', 'T', [293.15 400.0 542.0], 'P', 101.325, 'Water', 1, 1, 'MKS')             
%    Output is given as a 3x1 column vector: h1 = [84.0073                                                         
%                                                  2730.3014                                                       
%                                                  3012.0479]                                                      
%                                                                                                                  
%    Get specific enthalpy of water at STP in J/mol (debug flag is ON) at 1 temperature and 2 different pressures: 
%    h1 = getFluidProperty(libLoc, 'H', 'T', [293.15], 'P', [101.325 104.1], 'Water', 1, 1, 'MKS')                 
%    Output is given as a 1x2 row vector: h1 = [84.0073, 84.0099]                                                  
%                                                                                                                  
%    Get specific enthalpy of water at STP in J/mol (debug flag is ON) at three different temperatures and         
%       two different pressures:                                                                                   
%    h1 = getFluidProperty(libLoc, 'H', 'T', [293.15 400.0 542.0], 'P', [101.325 104.1], 'Water', 1, 1, 'MKS')     
%    Output is given as a 3x2 array: h1 = [84.0073    84.0099                                                      
%                                          2730.3014  2730.0376                                                    
%                                          3012.0479  3011.9667]                                                   
%                                                                                                                  
%    Get specific enthalpy for Oxygen/Nitrogen mixture at STP in J/mol (debug flag is ON)                          
%    h1 = getFluidProperty(libLoc, 'H', 'T', 293.15, 'P', 101.325, 'Oxygen;Nitrogen', [0.2, 0.8], 1, 'MKS')        
%    Output is given as a 1x1 array: h1 = 295.6969                                                                 
%                                                                                                                  
%    Get specific enthalpy for Oxygen/Nitrogen mixture at STP in J/mol (debug flag is ON)                          
%    h1 = getFluidProperty(libLoc, 'H', 'T', [293.15 400.00 542.0], 'P', [101.325 104.1], ...                      
%                          'Nitrogen;Oxygen;Hydrogen;Water', [0.71, 0.16, 0.1, 0.03], 1, 'MKS')                    
%    Output is given as a 3x2 array: h1 = [295.6969  295.6903                                                      
%                                          404.3641  404.3910                                                      
%                                          551.0786  551.0777]                                                     
%                                                                                                                  
%    Get specific enthalpy for Gulf Coast predefined mixture. Code detects .mix extension                          
%    in the input species string.                                                                                  
%    h = getFluidProperty(libLoc, 'H', 'T', 300, 'P', 101.325, 'GLFCOAST.MIX', 1, 1, 'MASS BASE SI')               
%    Output is given as a 1x1 array: h1 = 888684.3501     
%
%    Get multiple properties for a give fluid:
%       Enthalpy, Entropy, and Density of Water at three different temperatures and one pressure
%       Separate the output properties using commas and no spaces
%    [h1, s1, d1] = getFluidProperty(libLoc, 'H,S,D', 'T', [293.15 400.0 542.0], 'P', 101.325, 'Water', 1, 1, 'MKS')
% 
%    output is given as three 3x1 arrays: h1 = [  84.0073008508034
%                                               2730.30138592574
%                                               3012.04786856515]
%                                         s1 = [   0.29646283622616
%                                                  7.49620215239088
%                                                  8.09900566147266]
%                                         d1 = [ 998.20715046745
%                                                  0.554943903490502
%                                                  0.406296343124391]
%
%    Get multiple properties for a give fluid:
%       Enthalpy, Entropy, and Density of Water at three different temperatures and one pressure
%       Separate the output properties using commas and no spaces
%       use outputAsStruct flag to receive the output as a struct whose field names match the output properties
%       requested - this option will also put the input values as fields in the structure
%    outVal = getFluidProperty(libLoc, 'H,S,D', 'T', [293.15 400.0 542.0], 'P', 101.325, 'Water', 1, 1, 'MKS', outputAsStruct=true)
%
%    output is given a struct with fields: outVal = 
%                                                    H: [3×1 double]
%                                                    S: [3×1 double]
%                                                    D: [3×1 double]
%                                                    T: [293.15 400 542]
%                                                    P: 101.325
%
%    Set the reference state to the ASHRE state where h,s = 0 at -40C
%    [h1, s1, d1] = getFluidProperty(libLoc, 'H,S,D', 'T', [293.15 400.0 542.0], 'P', 101.325, 'Water', 1, 1, 'MKS',...
%                                    referenceState='ASH');
%
%    output is given as 3 3x1 arrays: h1 = [ -12.1779688679777
%                                           2634.11611620696
%                                           2915.86259884637]
%                                     s1 = [  16.5559971813317
%                                             23.7557364974964
%                                             24.3585400065782]
%                                     d1 = [ 998.20715046745
%                                              0.554943903490502
%                                              0.406296343124391]
%
%    Use parenthetical options for hOut
%    fluidString = 'R32;R125;R1234yf;R134a;R1234ze(E)';
%    composition = [0.26; 0.26; 0.2; 0.21; 0.07];
%    x_R32       = getFluidProperty(libLoc, 'xmassvap(1)', 'p', 74, 'Q', 0.2, fluidString, composition, 1, "MKS");
%    Output is given as a 1x1 array: x_R32 = 0.23941
%
%    [x_R32, x_R125, x_R1234yf, x_R134a, x_R1234zeE] = getFluidProperty(libLoc,...
%                                                      'xmassliq(1),xmassliq(2),xmassliq(3),xmassliq(4),xmassliq(5)',...
%                                                      'p', 74, 'Q', 0.2, fluidString, composition, 1, "MKS");
%    Output is given as 5 1x1 arrays:
%    x_R32      = 0.11455
%    x_R125     = 0.29849
%    x_R1234yf  = 0.24806
%    x_R134a    = 0.24543
%    x_R1234zeE = 0.093463
%    
%    To change the equation of state used:
%    h1 = getFluidProperty(libLoc, 'H', 'T', 293.15, 'P', 101.325, 'Water', 1, 1, 'MKS', equationOfState='PR2')
%    h1 = -12.7539
%    h1 = getFluidProperty(libLoc, 'H', 'T', 293.15, 'P', 101.325, 'Water', 1, 1, 'MKS', equationOfState='PR3')
%    h1 = -12.7518
%
% EXAMPLES for CoolProp:                                                                                                
%    libLoc = 'C:\Program Files\CoolProp\';                                                                        
%                                                                                                                  
%    Get the specific enthalpy of water at STP in J/mol:                                                           
%    h1 = getFluidProperty(libLoc, 'Hmass', 'T', 293.15, 'P', 101325, 'Water', 1)                                  
%    Output is given as a 1x1 array: h1 = 84007.3009                                                               
%                                                                                                                  
%    Get specific enthalpy of water at STP in J/mol at three different temperatures for a single pressure:         
%    NOTE: COOLPROP REQUIRES PRESSURE UNITS TO BE Pa NOT kPa LIKE REFPROP                                          
%    h1 = getFluidProperty(libLoc, 'Hmass', 'T', [293.15 400.0 542.0], 'P', 101325, 'Water', 1)                    
%    Output is given as a 3x1 column vector: h1 = [  84007.3009                                                    
%                                                  2730301.3859                                                    
%                                                  3012047.8685]                                                   
%                                                                                                                  
%    Get specific enthalpy of water at STP in J/mol at 1 temperature and 2 different pressures:                    
%    h1 = getFluidProperty(libLoc, 'Hmolar', 'T', [293.15], 'P', [101325 104100], 'Water', 1 )                     
%    Output is given as a 1x2 row vector: h1 = [1513.4140, 1513.4611]                                              
%                                                                                                                  
%    Get specific enthalpy of water at STP in J/mol at 3 different temperatures and 2 different pressures:         
%    h1 = getFluidProperty(libLoc, 'Hmolar', 'T', [293.15 400.0 542.0], 'P', [101325 104100], 'Water', 1)          
%    Output is given as a 3x2 array: h1 = [ 1513.4140,  1513.4611                                                  
%                                          49187.1112, 49182.3587                                                  
%                                          54262.8496, 54261.3874]                                                 
%                                                                                                                  
%    Get specific enthalpy for Oxygen/Nitrogen mixture at STP in J/mol                                             
%    h1 = getFluidProperty(libLoc, 'Hmolar', 'T', 293.15, 'P', 101325, 'Nitrogen;Oxygen;Hydrogen;Water',...        
%                          [0.71, 0.16, 0.1, 0.03])                                                                
%    Output is given as a 1x1 array: h1 = 9374.9875                                                                
%                                                                                                                  
%    Get specific enthalpy for Oxygen/Nitrogen mixture at STP in J/mol                                             
%    h1 = getFluidProperty(libLoc, 'Hmolar', 'T', [293.15 300.00 310.0], 'P', [101325 104100],...                  
%                         'Nitrogen;Oxygen;Hydrogen;Water', [0.71, 0.16, 0.1, 0.03])                               
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
%
%    Get multiple properties for a given fluid:
%       Enthalpy, Entropy, and Density of Water at three different temperatures and one pressure
%       Separate the output properties using commas and no spaces
%    [h1, s1, d1] = getFluidProperty(libLoc, 'H,S,D', 'T', [293.15 400.0 542.0], 'P', 101325, 'Water',...
%                                    keepLibraryLoaded=true)
% 
%    output is given as three 3x1 arrays: h1 = [  84007.3008506628
%                                               2730301.38592019
%                                               3012047.86854244]
%                                         s1 = [    296.46283622518
%                                                  7496.20215237541
%                                                  8099.00566142102]
%                                         d1 = [    998.207150467928
%                                                     0.554943903490499
%                                                     0.40629634312439]
%
%    Get multiple properties for a given fluid:
%       Enthalpy, Entropy, and Density of Water at three different temperatures and one pressure
%       Separate the output properties using commas and no spaces
%       use outputAsStruct flag to receive the output as a struct whose field names match the output properties
%       requested - this option will also put the input values as fields in the structure
%    outVal = getFluidProperty(libLoc, 'H,S,D', 'T', [293.15 400.0 542.0], 'P', 101325, 'Water',...
%                              keepLibraryLoaded=true, outputAsStruct=true)
%
%    output is given a struct with fields: outVal = 
%                                                    H: [3×1 double]
%                                                    S: [3×1 double]
%                                                    D: [3×1 double]
%                                                    T: [293.15 400 542]
%                                                    P: 101.325
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright 2019 - 2025 The MathWorks, Inc.

% History:
%
% Rev 1: Original version
% K. McGarrity
% 29 JAN 2025
%
% Rev 2: Added multi-outputs 
%        Added referenceState for REFPROP calls
% 9 SEP 2025

function requestedPropertyValue = getFluidProperty(libraryLocation, requestedProperty,... 
                                                   inputProperty1, inputProperty1Value,...
                                                   inputProperty2, inputProperty2Value, fluid,...
                                                   fluidComposition, massOrMolar, desiredUnits,...
                                                   opts)
    arguments (Input)
        libraryLocation        (1, :) char
        requestedProperty      (1, :) char
        inputProperty1         (1, :) char
        inputProperty1Value    (1, :) double
        inputProperty2         (1, :) char
        inputProperty2Value    (1, :) double
        fluid                  (1, :) char
        fluidComposition       (1, :) double  = 1;     % assume single species - only if numel(fluid) > 1 will user need to provide
        massOrMolar            (1, 1) double  = 0;     % REFPROP ONLY
        desiredUnits           (1, :) char    = 'MKS'; % REFPROP ONLY
        opts.outputAsStruct    (1, 1) logical = false; % both
        opts.keepLibraryLoaded (1, 1) logical = false; % CoolProp ONLY
        opts.referenceState    (1, :) char    = '';    % REFPROP ONLY
        opts.equationOfState   (1, :) char    = '';    % REFPROP ONLY
        opts.rapidMode         (1, 1) logical = false; % REFPROP ONLY - set to true to skip input checks - this will significantly speed up iterations
    end

    arguments (Output, Repeating)
        requestedPropertyValue
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % get the number of requested properties %
    % properties are comma separated         %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    numReqProps = numel(regexp(requestedProperty, ',')) + 1;

    %%%%%%%%%%%%%%%%%%%%%%
    % if checking inputs %
    %%%%%%%%%%%%%%%%%%%%%%
    if ~opts.rapidMode
        tmpOut = char(regexprep(requestedProperty, '\w+(\(\d+\))?,?', ''));
        if ~isempty(tmpOut)
            error("Please specify requested properties as a comma separated list without any spaces, e.g., 'H,S,D'.")
        end
    
        if (opts.outputAsStruct == false) && ((nargout ~= numReqProps))
            error(  "You specified " + numel(requestedProperty) + " properties to output but "...
                  + "only provided " + nargout + " output variables. Please specify one output variable per property "...
                  + "or set the output to be an array.");
        end
    end % end if checking inputs

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % if using REFPROP, else CoolProp %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if contains(libraryLocation, "REFPROP", "IgnoreCase", true)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % REFPROP expects as single input string %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        inputProps = [inputProperty1 inputProperty2];

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % MLrefprop takes care of all the input value checks, we shouldn't have to do anything %
        % unless we want the user to be able to specify multiple output properties or fluids   %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        tmpReqPropVal = MLrefprop(requestedProperty, inputProps, inputProperty1Value, inputProperty2Value,...
                                  fluid, massOrMolar, fluidComposition, desiredUnits, libraryLocation,...
                                  opts.referenceState, opts.equationOfState, opts.rapidMode, false);
    else
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % shape the output to match REFPROP when given input property value arrays, we shouldn't have to do %
        % anything else unless we want the user to be able to specify multiple output properties or fluids  %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        cpObj = MLCoolProp(libraryLocation, opts.keepLibraryLoaded);

        tmpReqPropVal = cpObj.getCoolPropValues(requestedProperty, inputProperty1, inputProperty1Value,...
                                                inputProperty2, inputProperty2Value, fluid, fluidComposition);

    end % end if REFPROP, else CoolProp

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % reshape the output as a structure or independent variables for each of the output properties requested %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if opts.outputAsStruct == true
        propIx = string(strsplit(requestedProperty, ","));
        propIx = strrep(strrep(propIx, ")", ""), "(", "_");
        for nx = 1:numReqProps
            RPV.(propIx(nx)) = tmpReqPropVal(:, :, nx);
        end % end loop over requested properties (nx)
        
        RPV.(inputProperty1) = inputProperty1Value;
        RPV.(inputProperty2) = inputProperty2Value;
        requestedPropertyValue = {RPV};
    else
        requestedPropertyValue = cell(numReqProps, 1);
        for nx = 1:numReqProps
            requestedPropertyValue{nx} = tmpReqPropVal(:, :, nx);
        end % end loop over requested properties (nx)
    end % end if outputting as struct, else individual variables
end % end function getFluidProperty