
% Copyright 2019 - 2025 The MathWorks, Inc.

origLoc = cd("utilities\");

try
    mex hiLevelMexC.cpp
catch ME
    cd(origLoc);
    clear origLoc;
    error(ME.message);
end
cd(origLoc);
clear origLoc;