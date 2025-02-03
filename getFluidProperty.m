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
% fluidComposition    = (double) array of size 1xnumSpec species fraction where 1 <= numSpec <= 20, whose values must 
%                                sum to 1; numSpec must match the number of species in the fluid
%                                e.g., if fluid = "Water", (numSpec = 1)
%                                         fluidComposition = 1;
%                                      if fluid = "Nitrogen;Oxygen;Hydrogen;Water", (numSpec = 4)
%                                         fluidComposition = [0.71, 0.16, 0.1, 0.03]
% massOrMolar         = [REFPROP only] (int) value to determine input composition units: 0 -> Molar, 1 -> Mass     
% desiredUnits        = [REFPROP only] (char) enum as expected by refprop.dll to determine the units to use        
%                                             e.g., MKS, MASS BASE SI, etc.                                        
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
%    Get sepcific enthalpy for Oxygen/Nitrogen mixture at STP in J/mol (debug flag is ON)                          
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
%    Get sepcific enthalpy for Oxygen/Nitrogen mixture at STP in J/mol                                             
%    h1 = getFluidProperty(libLoc, 'Hmolar', 'T', [293.15 300.00 310.0], 'P', [101325 104100],...                  
%                         'Nitrogen;Oxygen;Hydrogen;Water', [0.71, 0.16, 0.1, 0.03])                               
%    Output is given as a 3x2 array: h1 = [ 9374.9875,  9343.7779;                                                 
%                                           9762.2208,  9762.0559;                                                 
%                                          10055.4953, 10055.3424]                                                 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% History:
%
% Rev 1: Original version
% K. McGarrity
% 29 JAN 2025

function requestedPropertyValue = getFluidProperty(libraryLocation, requestedProperty,... 
                                                   inputProperty1, inputProperty1Value,...
                                                   inputProperty2, inputProperty2Value, fluid,...
                                                   fluidComposition, massOrMolar, desiredUnits)
    arguments
        libraryLocation     (1, :) {mustBeText} = "C:\Program Files (x86)\REFPROP"; %'C:\Program Files\CoolProp\';
        requestedProperty   (1, :) {mustBeText} = "H";
        inputProperty1      (1, :) {mustBeText} = "P";
        inputProperty1Value (1, :) double       = 101.325; % kPa (REFPROP uses kPa, CoolProp uses Pa!)
        inputProperty2      (1, :) {mustBeText} = "T";
        inputProperty2Value (1, :) double       = 300; % K
        fluid               (1, :) string       = "Nitrogen;Oxygen;Hydrogen;Water";
        fluidComposition    (1, :) double       = [0.71, 0.16, 0.1, 0.03];
        massOrMolar         (1, 1) double       = 0;
        desiredUnits        (1, :) {mustBeText} = "MKS";
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % if useing REFPROP, else CoolProp %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if contains(libraryLocation, "REFPROP", "IgnoreCase", true)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % REFPROP expects as single input string %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        inputProps = string(inputProperty1) + string(inputProperty2);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % we can probably remove this input from the function call someday %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        DebugOutput = false;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % MLrefprop takes care of all the input value checks, we shouldn't have to do anything %
        % unless we want the user to be able to specify multiple output properties or fluids   %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        requestedPropertyValue = MLrefprop(requestedProperty, inputProps, inputProperty1Value, inputProperty2Value,...
                                           fluid, massOrMolar, fluidComposition, desiredUnits, libraryLocation,...
                                           DebugOutput);
    else
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % shape the output to match REFPROP when given input proprty value arrays, we shouldn't have to do %
        % anything else unless we want the user to be able to specify multiple output properties or fluids %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        requestedPropertyValue = MLCoolProp(requestedProperty, inputProperty1, inputProperty1Value,...
                                                               inputProperty2, inputProperty2Value,...
                                                               fluid, fluidComposition);
    end % end if REFPROP, else CoolProp
end % end function getFluidProperty