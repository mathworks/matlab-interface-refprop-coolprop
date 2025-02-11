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