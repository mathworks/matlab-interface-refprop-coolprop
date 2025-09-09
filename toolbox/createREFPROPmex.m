
% Copyright 2019 - 2025 The MathWorks, Inc.

origLoc = cd(fullfile('toolbox', 'internal'));

try
    includePath = ['-I' fullfile(pwd, 'include')];
    mex('hiLevelMexC.cpp', includePath);
catch ME
    cd(origLoc);
    clear origLoc;
    error(ME.message);
end
cd(origLoc);
clear origLoc;