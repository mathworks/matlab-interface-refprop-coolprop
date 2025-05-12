# MATLAB interface to REFPROP and CoolProp

## Name
MATLAB&reg; interface to REFPROP and CoolProp

## Description
REFPROP is a fluids property program that calcuates thermodynamic and transport properties, which is created and maintained by NIST.

CoolProp is a fluids property program that calculates thermodynamic and transport properties, which is created and maintained as freeware by Ian Bell.

This repository contains a single MATLAB interface to extract the properties of interest from either program for use in models and simulation.

## System Requirements

For the functions in this repository to work properly, the user must have the following installed on their computer:
**_NOTE: The user only needs either REFPROP or CoolProp. It is not necessary to install both programs._**

1. MATLAB - we recommend the latest release of MATLAB, but it should work for R2020a or later, and it may work in even older releases.
2. REFPROP version [10.x](https://www.nist.gov/srd/refprop)
3. CoolProp version [6.6.0](http://www.coolprop.org/coolprop/wrappers/Installers/index.html) (This will likely be installed in C:\users\<userName>\AppData\Roaming\CoolProp)
4. A C/C++ compiler - [Current MATLAB Release compiler support](https://www.mathworks.com/support/requirements/supported-compilers.html) [Previous MATLAB Releases compiler support](https://www.mathworks.com/support/requirements/previous-releases.html)

## Repository Contents

This repository contains the following directories and files.

1. documents directory - this directory is intended for any documentation created around this interface
    1. RequirementsDoc.docx - this file contains a rough outline of the requirements used to create the MATLAB interface for REFPROP and CoolProp.
2. resources directory - this directory is connected to the MATLAB project and should not be touched except through the MATLAB project file
3. utlities directory - this directory contains all the files necessary to interface with REFPROP and CoolProp but should not be exposed to the user
    1. hiLevelMexC.cpp - this file was originally part of the mlrefprop repository and interface to REFPROP. If the user wants to interface with REFPROP, they will need to create a mex file (instructions given below) from this.
    2. MLrefprop.m - this file is the MATLAB script which is called by getFluidProperty.m and which calls the mex function to interface with REFPROP.
    3. REFPROP_lib.h - this file is required by hiLIevelMexC.cpp in order to interface with REFPROP.
    4. MLCoolProp.m - this file is the MATLAB script which is called by getfluidProperties.m to interface with CoolProp. It uses calllib rather than mex to interface with the CoolProp library.
4. createREFPROPmex.m - this file should be run by the user the first time they want to use REFPROP. This script will create the mexw64 executable from the hiLevelMexC.cpp file.
5. getFluidProperty.m - this function is the user interface to REFPROP or CoolProp.
6. MATLABInterfaceREFPROPCoolProp.prj - this file is the MATLAB project file which sets all the necessary paths and provides the user git interface through MATLAB.

## For REFPROP Users - one-time setup

Once the user has all requirements fulfilled, they must run the createREFPROPmex.m script. This will compile the C++ file using [MEX](https://www.mathworks.com/help/matlab/ref/mex.html). The user only needs to complete this step once. If someone makes changes to the header or C++ file this step must be repeated.

1. open MATLABInterfaceREFPROPCoolProp.prj
2. run createREFPROPmex.m

## Using getFluidProperty

Now the user is ready to get fluid properties.

Whether the user wants to access REFPROP or CoolProp, the interface through the getFluidProperty function is the same.

### Inputs

The inputs to getFluidProperty are:

1. libraryLocation - (string) the location of the REFPROP or CoolProp library files (dll, exe, etc.)            
2. requestedProperty - (string) the thermodynamic property name for which the value will be returned 
3. inputProperty1 - (string) name of the 1st property used as the state point
4. inputProperty1Value - (double) 1xM array of values of the 1st property used as the state point in the library's expected units 
5. inputProperty2 - (string) name of the 2nd property used as the state point
6. inputProperty2Value - (double) 1xN array of values of the 2nd property used as the state point in the library's expected units 
7. fluid - (string) indicating the fluid for which the requested property should be calculated e.g., 
    1. Use standard fluids already available in the library: "Water", "Ethanol", etc.  
    2. User defined fluids: "Nitrogen;Oxygen;Hydrogen;Water"

        _**NOTE: if the user defines their own fluid, the species should be listed out as in the last example above using only a semicolon (;\) to separate the species**_
8. fluidComposition - (double) array of size 1xP species fraction where 1 <= P <= 20, whose values must sum to 1, P must match the number of species in the fluid e.g., 
    1. if fluid = "Water", (numSpec = 1) and fluidComposition = 1;
    2. if fluid = "Nitrogen;Oxygen;Hydrogen;Water", (numSpec = 4) and fluidComposition = [0.71, 0.16, 0.1, 0.03]
9. massOrMolar - [REFPROP only] (int) value to determine input composition units: 0 -> Molar, 1 -> Mass
10. desiredUnits - [REFPROP only] (char) enum as expected by refprop.dll to determine the units to use e.g., MKS, MASS BASE SI, etc.

See [REFPROP documentation](https://trc.nist.gov/refprop/REFPROP.PDF) and [CoolProp documentation](http://www.coolprop.org/coolprop/HighLevelAPI.html#table-of-string-inputs-to-propssi-function) for allowed values for requested and input properties.
### Output

requestedPropertyValue = (double) (MxN) array of values for the requested thermodynamic property as calculated by the library in the library's expected units where M is the number of values for the first input property and N is the number of values for the second input property.

### Examples for REFPROP

[Calling REFPROP](https://github.com/mathworks/matlab-interface-refprop-coolprop/blob/main/toolbox/examples/callingREFPROP.m)

[Design Cycle REFPROP](https://github.com/mathworks/matlab-interface-refprop-coolprop/blob/main/toolbox/examples/designCycleSingle_REFPROP.m)

### Examples for CoolProp

[Calling CoolProp](https://github.com/mathworks/matlab-interface-refprop-coolprop/blob/main/toolbox/examples/callingCoolProp.m)

[Design Cycle CoolProp](https://github.com/mathworks/matlab-interface-refprop-coolprop/blob/main/toolbox/examples/designCycleSingle_CoolProp.m)

Copyright 2025 The MathWorks, Inc.