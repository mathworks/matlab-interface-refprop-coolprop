%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MLrefprop                                                                               
%   hiLevelMexC.cpp - function written with MEX C api (rather than C++) but since REFPROP requires C++, the file is C++.                    
%                                                                                         
%   From MATLAB(R):                                                                          
%        output = MLrefprop(propReq, spec, Value1, Value2, fluid, MassOrMole, DesiredUnits, Path2Refprop, DebugOutput)                    
%                                                                                         
%   Where (see: https://refprop-docs.readthedocs.io/en/latest/DLL/high_level.html)        
%                                                                                         
%       output  = DOUBLE (array of size MxN or scalar) output from RefProp for the desired Property from propReq. M is 
%                         the size of Value1 and N is the size of Value2                                                          
%       propReq = CHAR value accepted by REFPROP as 'hOut' values                         
%       spec    = CHAR value accepted by REFPROP as 'hIn'  values                         
%       Value1  = DOUBLE (array of size 1xM or scalar) of values related to the first character in spec                                                       
%       Value2  = DOUBLE (array of size 1XN or scalar) of values related to the second character in spec                                                       
%       Fluid   = CHAR value accepted by CoolProp as fluid values for multi-species, list species 1 to numSpec 
%                      (where numSpec is specified by the Composition variable) separated by semicolons (;)                                             
%  Composition  = DOUBLE (1xnumSpec array) of species fractions where (1 < numSpec <= 20) and values must sum to 1                                  
%  MassOrMolar  = INT value to determine input composition units: 0 -> Molar, 1 -> Mass   
%  DesiredUnits = CHAR value to determine units to use (enum as expected by refprop.dll)  
%  Path2Refprop = CHAR path to Refprop directory (e.g. C:\\ProgramFiles (x86)\\REFPROP)   
%  DebugOutput  = DOUBLE value (0 to suppress, 1 to show) debug output in MATLAB console  
%                                                                                         
%  Examples:     
%    refpropPath = 'C:\Program Files (x86)\REFPROP\';
%    Get the specific enthalpy of water at STP in J/mol (debug flag is ON):               
%    h1 = MLrefprop('H', 'TP', 293.15, 101.325, 'Water', 1, 1, 'MKS', refpropPath, 1)                                
%    Output is given as a 1x1 array: h1 = 84.0073                                         
%                                                                                         
%    Get specific enthalpy of water at STP in J/mol (debug flag is ON) at three different 
%       temperatures for a single pressure:                                               
%    h1 = MLrefprop('H', 'TP', [293.15 400.0 542.0], 101.325, 'Water', 1, 1, 'MKS', refpropPath, 1)                                 
%    Output is given as a 3x1 column vector: h1 = [84.0073                                
%                                                  2730.3014                              
%                                                  3012.0479]                             
%                                                                                         
%    Get specific enthalpy of water at STP in J/mol (debug flag is ON) at 1 temperature and two different pressures:                                                      
%    h1 = MLrefprop('H', 'TP', [293.15], [101.325 104.1], 'Water', 1, 1, 'MKS', refpropPath, 1)                                 
%    Output is given as a 1x2 row vector: h1 = [84.0073, 84.0099]                         
%                                                                                         
%    Get specific enthalpy of water at STP in J/mol (debug flag is ON) at three different 
%       temperatures and two different pressures:                                         
%    h1 = MLrefprop('H', 'TP', [293.15 400.00 542.0], [101.325 104.1], 'Water', 1, 1, 'MKS', refpropPath, 1)           
%    Output is given as a 3x2 array: h1 = [84.0073    84.0099                             
%                                          2730.3014  2730.0376                           
%                                          3012.0479  3011.9667]                          
%                                                                                         
%    Get specific enthalpy for Oxygen/Nitrogen mixture at STP in J/mol (debug flag is ON) 
%    h1 = MLrefprop('H', 'TP', 293.15, 101.325, 'Oxygen;Nitrogen', [0.2, 0.8], 1, 'MKS', refpropPath, 1)                          
%    Output is given as a 1x1 array: h1 = 295.6969                                        
%                                                                                         
%    Get sepcific enthalpy for Oxygen/Nitrogen mixture at STP in J/mol (debug flag is ON) 
%    h1 = MLrefprop('H', 'TP', [293.15 400.00 542.0], [101.325 104.1], 'Oxygen;Nitrogen', [0.2 0.8], 1, 'MKS',...                            
%                   refpropPath, 1)                                 
%    Output is given as a 3x2 array: h1 = [295.6969  295.6903                             
%                                          404.3641  404.3910                             
%                                          551.0786  551.0777]                            
%                                                                                         
%    Get specific enthalpy for Gulf Coast predefined mixture. Code detects .mix extension 
%    in the input species string.                                                         
%    h = MLrefprop('H', 'TP', 300, 101.325, 'GLFCOAST.MIX', 1, 1, 'MASS BASE SI', refpropPath, 1)                                      
%                                                                                         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright 2019 - 2025 The MathWorks, Inc.

% History:
%
% Rev 7: Use arguements to ensure the correct data type is coming through 
% K. McGarrity
% 29 JAN 2025
%
% Rev 6: Try/catch and error hanldling. Add mixture capability.
%
% Rev 5: Updating documentation typos
% K. McGarrity
% 25 FEB 2020
%
% Rev 4: Updating multi-species query capability. Checking that number of fluids
% listed in Fluid entry matches the number of Composition entries. Updating 
% documentation.
% K. McGarrity
% 24 FEB 2020
%
% Rev 3: Adding multi-species query capability.
% K. McGarrity
% 12 FEB 2020
%
% Rev 2: Adding documentation examples. Fix checks for requested props and
% specs to allow for molar mass, triple points, etc.
% E. McGarrity
% 30 JAN 2020
%
% Rev 1: Original version
% K. McGarrity
% 16 JAN 2020

function output = MLrefprop(PropReq, Spec, Value1, Value2, Fluid, MassOrMolar, Composition, DesiredUnits, Path2Refprop, DebugOutput)
    arguments
        PropReq       (1, :)char;
        Spec          (1, :)char;
        Value1        (1, :)double;
        Value2        (1, :)double;
        Fluid         (1, :)char;
        MassOrMolar   (1, 1)double;
        Composition   (1, :)double;
        DesiredUnits  (1, :)char;
        Path2Refprop  (1, :)char;
        DebugOutput   (1, 1)double;
    end
    
    PossibleSpecs  = {'T', 'P', 'D', 'E', 'H', 'S', 'Q'};   % Temperature, Pressure, Density, Energy, Enthalpy, Entropy, Quality
    AddonsAfter1   = {'MELT', 'SUBL'};                      % Melting or sublimation point given the input properties
    AddonsAfter2   = {'L', '>', '<', 'V'};                  % Single phase liquid (L, >), Single Phase Vaopor (<, V)

    SupportedSpecFlags   = {'NBP', 'CRIT', 'TRIP', 'DSAT', 'HSAT', 'HSAT2', 'SSAT', 'SSAT2', 'SSAT3'};
    UnsupportedSpecFlags = {'FLAGS', 'EOSMIN', 'EOSMAX', 'SETREF', 'SETREFOFF', 'PATH', 'SATSPLN'};

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Checking ProprReq Validity %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % UnsupportedPropFlags = {'ALTID', 'CAS#', 'CHEMFORM', 'SYNONYM', 'FAMILY', 'FLDNAME', 'HASH', 'INCHI',...
    %                         'INCHIKEY', 'LONGNAME', 'SAFETY', 'NAME', 'NCOMP', 'UNNUMBER', 'DOI_EOS', 'DOI_VIS',...
    %                         'DOI_TCX', 'DOI_STN', 'DOI_DIE', 'DOI_MLT', 'DOI_SBL', 'WEB_EOS', 'WEB_VIS', 'WEB_TCX',...
    %                         'WEB_STN', 'WEB_DIE', 'WEB_MLT', 'WEB_SBL', 'REFSTATE', 'GWP', 'ODP', 'FDIR', 'UNITSTRING',...
    %                         'UNITNUMB', 'UNITS', 'UNITCONV', 'UNITUSER', 'UNITUSER2', 'DLL#', 'PHASE', 'FULLCHEMFORM',...
    %                         'HEATINGVALUE', 'LIQUIDFLUIDSTRING', 'VAPORFLUIDSTRING', 'QMOLE', 'QMASS', 'XMASS', 'XLIQ',...
    %                         'XVAP', 'XMOLELIQ', 'XMOLEVAP', 'XMASSLIQ', 'XMASSVAP', 'LIQ', 'VAP', 'FIJMIX'};
    % 
    % if ~(any(strcmpi(PropReq, PossibleSpecs)) || any(strcmpi(PropReq, UnsupportedPropFlags)))
    %     error('PropReq was given as %s, but must be given as one of the following: T, P, D, E, H, S, Q.', PropReq);
    % elseif any(strcmpi(PropReq, UnsupportedPropFlags))
    %     error('PropReq was given as %s, but MLrefprop does not support use of these flags at this time.', PropReq);
    % end

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Checking Spec Validity %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    mainMessage = 'it should be a pair of unique letters from the following: T, P, D, E, H, S, Q.';
    enhcMessage = 'It may be enhanced with one of the following: L, <, >, V, MELT, SUBL.';
    flagMessage = 'it may be one of the following supported flags: CRIT, TRIP, DSAT, NBP, HSAT, HSAT2, SSAT, SSAT2, SSAT3.';

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Checking Path2Refprop validity %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~exist(Path2Refprop, 'dir')
        error(Path2Refprop + " does not exist. Please specify the path to your RefProp installation.");
    else
        rpDir = struct2table(dir(Path2Refprop));
        if ~any(strcmp(rpDir.name, "REFPRP64.DLL"))
            error(Path2Refprop + " does not contain ""REFPRP64.DLL"". Please specify the path to your RefProp installation.")
        end % end if the directory does not contain REFPROP.EXE
    end % end if not, else, refprop directory exists
  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Must have at least two characters %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if (size(Spec, 2) < 2) 
        error('Spec was given as %s, but %s\n%s\nOr %s', Spec, mainMessage, enhcMessage, flagMessage)
    elseif (size(Spec, 2) == 2)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % if there are two characters,                      %
        % they must both be from the allowed character list %
        % and must be different from each other             %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if strcmp(Spec, '  ')
           % noop (Two blank spaces allows for critical and triple point reqs.)
        elseif (    (~(    any(strcmpi(Spec(1), PossibleSpecs))    ...
                    && any(strcmpi(Spec(2), PossibleSpecs)) ) )...
             || (          strcmpi(Spec(1), Spec(2)      )    ) )
            error('Spec was given as %s, but %s\n%s\nOr %s', Spec, mainMessage, enhcMessage, flagMessage)
        end
    elseif (size(Spec, 2) == 3) 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % if there are three characters,                                              %
        %   Either: the first two characters must be from the allowed character list  %
        %           and the third character must be from the add-on character list    %
        %           and the first two characters must be different from each other    %
        %     OR    it can be "NBP" -> one of the supported flags                     %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if(    (    (~(    any(strcmpi(Spec(1), PossibleSpecs  ))     ...
                        && any(strcmpi(Spec(2), PossibleSpecs  ))     ...
                        && any(strcmpi(Spec(3), AddonsAfter2   ))) )  ...
                || (           strcmpi(Spec(1), Spec(2)        )   ) )...
            && (          ~any(strcmpi(Spec, SupportedSpecFlags))    ) )
            error('Spec was given as %s, but %s\n%s\nOr %s', Spec, mainMessage, enhcMessage, flagMessage)
        end
    else % (size(Spec, 2)  > 3)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % if there are four or more characters,                                       %
        %   Either: the first character must be from the allowed character list       %
        %           and the rest of the entry must be from the add-on character list  %
        %     OR    it can one of the supported flags (NOT one of the unsupported)    %
        %    ELSE   if it is of the supported flags, send a message about it          %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if(    (~(    any(strcmpi(Spec(1),     PossibleSpecs))    ...
                   && any(strcmpi(Spec(2:end), AddonsAfter1 ))) ) ...
            && (     ~any(strcmpi(Spec, SupportedSpecFlags  ))  ) ...
            && (     ~any(strcmpi(Spec, UnsupportedSpecFlags))  ) )
            error('Spec was given as %s, but %s\n%s\nOr %s', Spec, mainMessage, enhcMessage, flagMessage)
        elseif any(strcmpi(Spec, UnsupportedSpecFlags))
            error('Spec was given as %s, but MLrefprop does not support use of this flag at this time.', Spec);
        end 
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Checking validity of Composition and Fluid since there must be one fluid for every  %
    % composition entry, we want to make sure they match in size. Also, Composition must  %
    % have at least one and no more than twenty elements, and the elements must sum to 1. %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    nelCmp = numel(Composition);
    nelFld = numel(strsplit(Fluid, ';'));
    if nelCmp ~= nelFld
        error('Fluid must contain the same number of elements as the specified composition. Currently, you have specified %d fluids: %s, and %d compositions', nelFld, Fluid, nelCmp);
    end
    if (sum(Composition) < (1 - 0.0001)) || (sum(Composition) > (1 + 0.0001)) || any(Composition < 0)
        error('Composition must contain positive values between 0 and 1, which sum to 1. Currently, your composition sums to %d', sum(Composition));
    end
    if nelCmp > 20
        error('Composition and Fluid cannot have more than 20 elements. Currently, your Composition and Fluid arrays contains %d elements.', nelCmp);
    end
    Composition = [Composition, zeros(1, (20 - nelCmp))];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % call to the mex function that queries refprop %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    try
      output = hiLevelMexC(PropReq, Spec, Value1, Value2, Fluid, MassOrMolar, Composition, DesiredUnits, Path2Refprop, DebugOutput);
    catch ME
        %%%%%%%%%%%%%%%%%%%%%%%%%
        % Get the error message %
        %%%%%%%%%%%%%%%%%%%%%%%%%
        msg = string(ME.message);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Get the files and the lines and add them to the message %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for sx = 1:numel(ME.stack)
            fileName  = ME.stack(sx).file;
            fx        = strfind(fileName, "\");
            if ~isempty(fx)
                fileName  = fileName(fx(end)+1:end);
            end
            msg = msg + newline + fileName + ": line " + num2str(ME.stack(sx).line);
        end % end loop over message stack

        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        % display message to user %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        warning('Error in REFPROP call. Check message below.');
        disp(msg)
        output = [];
    end % end try/catch block
end % end function MLrefprop