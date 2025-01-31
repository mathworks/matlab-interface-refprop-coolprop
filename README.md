# MATLAB interface to REFPROP and CoolProp

## Name
MATLAB interface to REFPROP and CoolProp

## Description
REFPROP is a fluids property program that calcuates thermodynamic and transport properties, which is created and maintained by NIST.

CoolProp is a fluids property program that calculates thermodynamic and transport properties, which is created and maintained as freeware by Ian Bell.

This repository contains a single MATLAB interface to extract the properties of interest from either program for use in models and simulation.

## System Requirements

For the functions in this repository to work properly, the suer must have the following installed on their computer:

1. MATLAB - we recommend the latest release of MATLAB, but it should work for R2020a or later, and it may work in even older releases.
2. REFPROP version [10.x](https://www.nist.gov/srd/refprop)
3. CoolProp version [6.6.0] (http://www.coolprop.org/coolprop/wrappers/Installers/index.html)
4. A C/C++ compiler - [Current MATLAB Release compiler support](https://www.mathworks.com/support/requirements/supported-compilers.html) [Previous MATLAB Releases compiler support](https://www.mathworks.com/support/requirements/previous-releases.html)

## Repository Contents

This repository contains the following directories and files.

1. documents directory - this directory is intended for any documentation created around this interface
    1. RequirementsDoc.docx - this file contains a rough outline of the requirements used to create the MATLAB interface for REFPROP and CoolProp.
2. resources directory - this directory is connected to the MATLAB project and should not be touched except through the MATLAB project file
3. utlities directory - this directory contains all the files necessary to interface with REFPROP and CoolProp but should not be exposed to the user
    1. hiLevelMexC.cpp - this file was originally part of the mlrefprop repository and interface to REFPROP. If the user wants to interface with REFPROP, they will need to create a mex file (instructions given below) from this.
    2. MLrefprop.m - this file is the MATLAB script which is called by getFluidProperties.m and which calls the mex function to interface with REFPROP.
    3. REFPROP_lib.h - this file is required by hiLIevelMexC.cpp in order to interface with REFPROP.
    4. MLCoolProp.m - this file is the MATLAB script which is called by getfluidProperties.m to interface with CoolProp. It uses calllib rather than mex to interface with the CoolProp library.
4. getFluidProper.m - this function is the user interface to REFPROP or CoolProp.
5. MATLABInterfaceREFPROPCoolProp.prj - this file is the MATLAB project file which sets all the necessary paths and provides the user git interface through MATLAB.