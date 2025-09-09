% Copyright 2025 The MathWorks, Inc.

function [p_critical, h_critical, t_critical, s_critical] = find_critical_states(fluid, libLoc)
% Return p,h,T,s at critical point

    if contains(libLoc, 'refprop', 'IgnoreCase', true)
        t_critical = getFluidProperty(libLoc, 'TC', 'H', 1,          'P', 1,          fluid, 1, 1, 'MASS BASE SI');
        p_critical = getFluidProperty(libLoc, 'PC', 'H', 1,          'P', 1,          fluid, 1, 1, 'MASS BASE SI');
        h_critical = getFluidProperty(libLoc, 'H',  'T', t_critical, 'P', p_critical, fluid, 1, 1, 'MASS BASE SI');
        s_critical = getFluidProperty(libLoc, 'S',  'T', t_critical, 'P', p_critical, fluid, 1, 1, 'MASS BASE SI');
    elseif contains(libLoc, 'coolprop', 'IgnoreCase', true)
        t_critical = getFluidProperty(libLoc, 'T_CRITICAL', 'Hmass', 1,        'P', 1,          fluid, 1, keepLibraryLoaded=true);
        p_critical = getFluidProperty(libLoc, 'P_CRITICAL', 'Hmass', 1,        'P', 1,          fluid, 1, keepLibraryLoaded=true);
        h_critical = getFluidProperty(libLoc, 'Hmass',      'T',    t_critical,'P', p_critical, fluid, 1, keepLibraryLoaded=true);
        s_critical = getFluidProperty(libLoc, 'Smass',      'T',    t_critical,'P', p_critical, fluid, 1, keepLibraryLoaded=true);
    else
        error('check library location')
    end % end if REFPROP, else CoolProp
end % end find_critical_states