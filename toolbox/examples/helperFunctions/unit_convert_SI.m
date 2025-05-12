% Copyright 2025 The MathWorks, Inc.

function value_out = unit_convert_SI(value_in,unit,type,nflag)
% convert pressure/temperature/specific enthalpy/specific entropy unit
%      value_in: value to be converted
%          unit: unit to be converted from or to
%          type: what type of unit it is (p,h,T,s)
%      nflag  1: from unit to SI unit
%            -1: from SI unit to unit
%
% Note: for specific entropy (s), this function needs to be called twice,
%       once with H unit and once with T unit.

switch lower(type) % 

    case "p"  % Pressure
        if nflag >= 0 % from unit to Pa
            switch lower(unit)
                case "pa"
                    value_out = value_in;
                case "kpa"
                    value_out = value_in * 1e3;
                case "mpa"
                    value_out = value_in * 1e6;
                case "bar"
                    value_out = value_in * 1e5;
                case "psi"
                    value_out = value_in * 6894.8;
                case "atm"
                    value_out = value_in * 101325;
                otherwise
                    error("pressure unit error?")
            end
        else % from Pa to unit
            switch lower(unit)
                case "pa"
                    value_out = value_in;
                case "kpa"
                    value_out = value_in / 1e3;
                case "mpa"
                    value_out = value_in / 1e6;
                case "bar"
                    value_out = value_in / 1e5;
                case "psi"
                    value_out = value_in / 6894.8;
                case "atm"
                    value_out = value_in / 101325;
                otherwise
                    error("pressure unit error?")
            end
        end
    case "h"  % specific enthalpy
        if nflag >= 0 % from unit to J/kg
            switch lower(unit)
                case "kj/kg"
                    value_out = value_in * 1e3;        
                case "j/kg"
                    value_out = value_in;
                case "j/g"
                    value_out = value_in * 1e3;        
                case "btu/lbm"
                    value_out = value_in * 2326.0;
                otherwise
                    error("enthalpy unit error?")
            end
        else % from J/kg to unit
            switch lower(unit)
                case "kj/kg"
                    value_out = value_in / 1e3;        
                case "j/kg"
                    value_out = value_in;
                case "j/g"
                    value_out = value_in / 1e3;        
                case "btu/lbm"
                    value_out = value_in / 2326.0;
                otherwise
                    error("enthalpy unit error?")
            end
        end
    case "t"  % temperature
        if nflag >= 0 % from unit to K
            switch lower(unit)
                case "k"
                    value_out = value_in;
                case "degc"
                    value_out = 273.15 + value_in;
                case "degf"
                    value_out = 273.15 + (value_in-32)*5/9;
                otherwise
                    error("temperature unit error?")
            end
        else % from K to unit
            switch lower(unit)
                case "k"
                    value_out = value_in;
                case "degc"
                    value_out = value_in - 273.15;
                case "degf"
                    value_out = (value_in-273.15)*9/5+32;
                otherwise
                    error("temperature unit error?")
            end
        end
    case "s"  % specific entropy
        if nflag >= 0 % from unit to J/(kg*K)
            switch lower(unit)
                case "kj/kg"
                    value_out = value_in * 1e3;        
                case "j/kg"
                    value_out = value_in;
                case "j/g"
                    value_out = value_in * 1e3;        
                case "btu/lbm"
                    value_out = value_in * 2326.0;
                case "k"
                    value_out = value_in;
                case "degc"
                    value_out = value_in;
                case "degf"
                    value_out = value_in*9/5;
                otherwise
                    error("specific entropy unit error?")
            end
        else % from J/(kg*K) to unit
            switch lower(unit)
                case "kj/kg"
                    value_out = value_in / 1e3;        
                case "j/kg"
                    value_out = value_in;
                case "j/g"
                    value_out = value_in / 1e3;        
                case "btu/lbm"
                    value_out = value_in / 2326.0;
                case "k"
                    value_out = value_in;
                case "degc"
                    value_out = value_in;
                case "degf"
                    value_out = value_in*5/9;
                otherwise
                    error("specific entropy unit error?")
            end
        end
    otherwise  % catch input error
        error("check unit type. P/H/T/S allowed.")
end

end