/*=============================================================================================*
 *  hiLevelMexC.cpp - function written with MEX C api (rather than C++)                        *
 *                    but since REFPROP requires C++, the file is C++.                         *
 *                                                                                             *
 *  From MATLAB:                                                                               *
 *       output = hiLevelMexC(propReq, spec, Value1, Value2, fluid, MassOrMole)                *
 *                                                                                             *
 *  Where (see: https://refprop-docs.readthedocs.io/en/latest/DLL/high_level.html)             *
 *    output    = DOUBLE (array of size MxN) output from RefProp for the desired Property      *
 *                from propReq where M is the size of Value1 and N is the size of Value2       *
 *    propReq   = CHAR value accepted by REFPROP as 'hOut' values                              *
 *    specsum   = CHAR value accepted by REFPROP as 'hIn'  values                              *
 *    value1    = DOUBLE (array of size 1xM) of values related to the first character in spec  *
 *    value2    = DOUBLE (array of size 1xN) of values related to the second character in spec *
 *    fluid     = CHAR value accepted by REFPROP as 'hFld' values (for mulit-species,          *
 *                list numSpec fluids separated by a semicolon (;), where 1 < numSpec <= 20    *
 *    iMass     = INT value to determine input units: 0 -> Molar, 1 -> Mass (sets iMass)       *
 *    z         = DOUBLE (array of size 1x20) of species fractions where the number of         *
 *                speciecs numSpec matches the number of species listed in 'fluid' and         *
 *                1 < numSpec <= 20                                                            *
 *    unit_char = CHAR value to determine units to use (enum as expected by refprop.dll)       *
 *    path      = CHAR path to Refprop directory (e.g. C:\\ProgramFiles (x86)\\REFPROP)        *
 *    DebugOut  = DOUBLE value (0 to suppress, 1 to show) debug output in MATLAB console       *
 *=============================================================================================*/

// Copyright 2019 - 2025 The MathWorks, Inc.

#define REFPROP_IMPLEMENTATION
#define REFPROP_FUNCTION_MODIFIER
#undef UNICODE
#include "REFPROP_lib.h"
#undef REFPROP_FUNCTION_MODIFIER
#undef REFPROP_IMPLEMENTATION

#include <iostream>
#include <sstream>
#include <string>
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include "mex.h"

//////////////////////////////////////////////////////////////////////////////////////////
// function to check that the number and type of arguments, in and out, are as expected //
//////////////////////////////////////////////////////////////////////////////////////////
void checkArguments(int numOutArg, mxArray *outputs[], int numInArg, const mxArray *inputs[])
{
    int expectedOut =  1;   // expected number of output variables
    int expectedIn  = 10;   // expected number of input  variables
    int inputInt;
    double inputDouble;

    ///////////////////////////////////////////////////////////////
    // Checking output arguments. There should only ever be one? //
    ///////////////////////////////////////////////////////////////
    if(numOutArg != expectedOut)
    {
        mexErrMsgIdAndTxt("MyToolbox:arrayProduct:nlhs", "Incorrect number of outputs were given, only 1 output is allowed");
    }

    ////////////////////////////////////////////////////////////////
    // Checking input arguments. There should always only be six? //
    ////////////////////////////////////////////////////////////////
    if(numInArg != expectedIn)
    {
        mexErrMsgIdAndTxt("MyToolbox:arrayProduct:nrhs", "%i inputs were given, but %i are expected.", numInArg, expectedIn);
    }
    else
    {
        ////////////////////////////////////////////////////////////////
        // Checking that the variable type matches what is expected.  //
        ////////////////////////////////////////////////////////////////
        if(!mxIsChar(inputs[0]))
        {
            mexErrMsgIdAndTxt("MyToolbox:arrayProduct:prhs", "Input variable propReq expected to be of type CHAR.");
        }
        else if(!mxIsChar(inputs[1]))
        {
            mexErrMsgIdAndTxt("MyToolbox:arrayProduct:prhs", "Input variable spec expected to be of type CHAR.");
        }
        else if(!mxIsDouble(inputs[2]))
        {
            mexErrMsgIdAndTxt("MyToolbox:arrayProduct:prhs", "Input variable value1 expected to be of type DOUBLE.");
        }
        else if(!mxIsDouble(inputs[3]))
        {
            mexErrMsgIdAndTxt("MyToolbox:arrayProduct:prhs", "Input variable value2 expected to be of type DOUBLE.");
        }
        else if(!mxIsChar(inputs[4]))
        {
            mexErrMsgIdAndTxt("MyToolbox:arrayProduct:prhs", "Input variable substance (or mixture) expected to be of type CHAR.");
        }
        else if(!mxIsDouble(inputs[5]))
        {
            mexErrMsgIdAndTxt("MyToolbox:arrayProduct:prhs", "Input variable MassOrMolar expected to be of type DOUBLE with values of 0 or 1.");
        }
        else if(!mxIsDouble(inputs[6]))
        {
            mexErrMsgIdAndTxt("MyToolbox:arrayProduct:prhs", "Input variable Composition expected to be of type DOUBLE with values betwen 0 and 1.");
        }
        else if(!mxIsChar(inputs[7]))
        {
            mexErrMsgIdAndTxt("MyToolbox:arrayProduct:prhs", "Input variable DesiredUnits expected to be of type CHAR.");
        }
        else if(!mxIsChar(inputs[8]))
        {
            mexErrMsgIdAndTxt("MyToolbox:arrayProduct:prhs", "Input variable PathToRefPropDll expected to be of type CHAR.");
        }
        else if(!mxIsDouble(inputs[9]))
        {
            mexErrMsgIdAndTxt("MyToolbox:arrayProduct:prhs", "Input variable DebugOutput expected to be of type DOUBLE with values of 0 or 1.");
        }
        else
        {
            ////////////////////////////////////////////////////////////////////////////////////////////
            // Checking that the value of MassOrMolar is properly set to either 0 (molar) or 1 (mass) //
            ////////////////////////////////////////////////////////////////////////////////////////////
            inputDouble = mxGetScalar(inputs[5]);
            inputInt    = int(inputDouble);
            if (double(inputInt) < (inputDouble - 0.01))
            {
                mexErrMsgIdAndTxt("MyToolbox:arrayProduct:prhs", 
                                  "Decimal values of MassOrMolar are invalid: %f. Acceptable values are integer values of 0 for Molar and 1 for Mass to select desired units.", inputDouble);
            } // end if MassOrMolar is invalid
            if ((inputInt != 0) && (inputInt != 1))
            {
                mexErrMsgIdAndTxt("MyToolbox:arrayProduct:prhs", 
                                  "MassOrMolar input of %d is invalid. Acceptable values are 0 for Molar and 1 for Mass to select desired units.", inputInt);
            } // end if MassOrMolar is invalid
            
            ////////////////////////////////////////////////////////////////////////////////////////////
            // Checking that the value of DebugOutput is properly set to either 0 (false) or 1 (true) //
            ////////////////////////////////////////////////////////////////////////////////////////////
            inputDouble = mxGetScalar(inputs[9]);
            inputInt    = int(inputDouble);
            if (double(inputInt) < (inputDouble - 0.01))
            {
                mexErrMsgIdAndTxt("MyToolbox:arrayProduct:prhs", 
                                  "Decimal values of DebugOutput are invalid: %f. Acceptable values are integer values of 0 for false and 1 for true to print debug output to the MATLAB Console.", inputDouble);
            } // end if MassOrMolar is invalid
            if ((inputInt != 0) && (inputInt != 1))
            {
                mexErrMsgIdAndTxt("MyToolbox:arrayProduct:prhs", 
                                  "DebugOutput input of %d is invalid. Acceptable values are 0 for false and 1 for true to print debug output to the MATLAB Console.", inputDouble);
            } // end if MassOrMolar is invalid
        } // end if input types not as expected, else they are as expected so check other requirements
    } // end if too few, elseif too many, else exactly the number of, input values expected
} // end function checkArguments

void mexFunction(int numOutArg, mxArray *outputs[], int numInArg, const mxArray *inputs[])
{
    ///////////////////////////////////////////////////////////////////////
    // check that the input and output variables have the correct format //
    ///////////////////////////////////////////////////////////////////////
    checkArguments(numOutArg, outputs, numInArg, inputs);

    ///////////////////////////////
    // getting the actual inputs //
    ///////////////////////////////
    const char   *propReq   = mxArrayToString(inputs[0]);               // Property requested for output
    const char   *specSum   = mxArrayToString(inputs[1]);               // characters encoding spec variables
    const double *value1    = mxGetPr(        inputs[2]);               // value for first  spec variable
    const double *value2    = mxGetPr(        inputs[3]);               // value for second spec variable
    const char   *fluid     = mxArrayToString(inputs[4]);               // String for fluid type
          int     iMass     = int(mxGetScalar(inputs[5]));              // Specifies mole or mass based input composition -> 0 = mole, 1 = mass
          double *z         = mxGetPr(        inputs[6]);               // Composition on a mole or mass basis depending on iMass (array of max size 20)
          char   *unit_char = mxArrayToString(inputs[7]);               // Sets up which units to use -> molar or mass, SI or English
    std::string   path      = std::string(mxArrayToString(inputs[8]));  // location of reprop dll
          bool    DebugOut  = bool(mxGetScalar(inputs[9]));             // logical for printing debug info to the MATLAB console

    /////////////////////////////////////////////////////////////////// 
    // getting the size of all the char arrays passed through inputs // 
    /////////////////////////////////////////////////////////////////// 
    size_t  propReq_len = (mxGetM(inputs[0]) * mxGetN(inputs[0])) + 1;  // size of propReq
    size_t  spec_len    = (mxGetM(inputs[1]) * mxGetN(inputs[1])) + 1;  // size of first spec
    size_t  numelVal1   =  mxGetNumberOfElements(inputs[2]);            // number of values for the first spec
    size_t  numelVal2   =  mxGetNumberOfElements(inputs[3]);            // number of values for the second spec
    size_t  fluid_len   = (mxGetM(inputs[4]) * mxGetN(inputs[4])) + 1;  // size of fluid 
    
    /////////////////////////////////////////////
    // Allocate memory for the output variable //
    /////////////////////////////////////////////
    outputs[0] = mxCreateNumericMatrix(numelVal1, numelVal2, mxDOUBLE_CLASS, mxREAL); // [numelVal1 x numelVal2] array of real doubles

    ///////////////////////////
    // Setup local variables //
    ///////////////////////////
    size_t itr           =     0;               // iterator over rows
    size_t itc           =     0;               // iterator over columns
    size_t itrcmp        =     0;               // iterator over fluid composition
    int    herr_length   =   255;               // INPUT:  length of the error string   (  255 is default)
    int    hFld_length   = 10000;               // INPUT:  length of fluid name         (10000 is default)
    int    hIn_length    =   255;               // INPUT:  length of input string       (  255 is default)
    int    hOut_length   =   255;               // INPUT:  length of output flag string (  255 is default)
    int    hUnits_length =   255;               // INPUT:  length of units string       (  255 is default)
    int    ierr;                                // OUTPUT: error flag -> 0 = successful, !0 = unsuccessful
    int    iFlag         =     0;               // OUTPUT: enum for getenumdll function (see comments below for values)
    int    iUCode;                              // OUTPUT: Unit code representing the units of the first property in Output array
    int    iUnits        =     0;               // INPUT:  Enumeration to denote which unit system to use (SI, english, etc.)
    int    mixFlag       =     0;               // flag to determine whether input is mixture - same variable as "iFlag" in refprop.dll documentation (not iFlag enum above!)
    double a;                                   // INPUT:  First input property as specified by hIn
    double b;                                   // INPUT:  Second input property as specified by hIn
    double hOutput[200];                        // OUTPUT: Array of properties specified by hOut (should be size 200, double precision)
    double *propReqOut   = mxGetPr(outputs[0]); // creating a dummy pointer to fill with output values
    double q             =    1.0;              // OUTPUT: Vapor quality on a mole or mass basis (vapor -> 1, liquid -> 0)
    double x [20]        =   {1.0};             // OUTPUT: Composition of liquid phase (array of mole fractions of size 20) for 2-phase states
    double x3[20];                              // OUTPUT: Reserved for returning composition of a second liquid phase for LLE or VLLE
    double y [20]        =   {1.0};             // OUTPUT: Composition of vapor phase (array of mole fractions of size 20) for 2-phase states
    char   herr  [255];                         // OUTPUT: Error string
    char   hFld  [255];                         // INPUT:  Fluid string
    char   hIn   [255];                         // INPUT:  Input string of properties sent to the routine
    char   hOut  [255];                         // OUTPUT: Various flags to gain access to other features of Refprop
    char   hUnits[255];                         // OUTPUT: Units for the first property in the output array
    std::string DLL_name = "REFPRP64.DLL";      // Refprop dll used for this function
    std::string serr;                           // load_REFPROP requires the error variable to be a string
    
    /////////////////////////////
    // loading the Refprop dll //
    /////////////////////////////
    bool loaded_REFPROP = load_REFPROP(serr, path, DLL_name);

    //////////////////////////////////////////////////////////////////////////////////////////////////
    // try-catch like behavior, if it fails to load refprop, send an error and skip everything else //
    //////////////////////////////////////////////////////////////////////////////////////////////////
    if (!loaded_REFPROP)
    {
        printf("REFPROP failed to load from: %s\\%s", path, DLL_name);
    }
    else
    {
        /////////////////////////////////////
        // setting path to the refprop dll //
        /////////////////////////////////////
        SETPATHdll(const_cast<char*>(path.c_str()), 255);

        ////////////////////////////////////
        // setting the desired fluid type //
        // error checking - ierr set here //
        ////////////////////////////////////
        std::string mix_string_search(fluid);
        std::transform(mix_string_search.begin(), mix_string_search.end(), mix_string_search.begin(), [](unsigned char c){return tolower(c);});
        
        ////////////////////////////////////////////////////
        // check to see if the user passed in a .MIX file //
        ////////////////////////////////////////////////////
        std::size_t mixFound = mix_string_search.rfind(".mix");

        ////////////////////////////////////////////////////////////////////
        // if the user passed in a .MIX file, else manually defined fluid //
        ////////////////////////////////////////////////////////////////////
        if( (mix_string_search.length() > 4) && (mixFound + 4) == mix_string_search.length())
        {
            mexPrintf("Found Mixture from .MIX file\n");
            SETMIXTUREdll(const_cast<char*>(fluid), z, ierr, hFld_length);   
            mixFlag = 1;
        }
        else
        {
            ///////////////////////////////////////////////////////////
            // check to see if the user passed in a mixture manually //
            ///////////////////////////////////////////////////////////
            mixFound = mix_string_search.rfind(";");
            if (mixFound < mix_string_search.length())
            {
                mexPrintf("Found Mixture passed in as arguement\n");
                mixFlag = 1;
            } // end if mixture, else individual fluid
            SETFLUIDSdll(const_cast<char *>(fluid), ierr, hFld_length);
        } // end if .mix file, else manual fluid entry

        ////////////////////////////////////////////////////////////////////////////////////////////////////
        // try-catch like behaviour, if we couldn't set the fluid, send an error and skip everything else //
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        if(ierr != 0)
        {
            mexErrMsgIdAndTxt("MyToolbox:arrayProduct:prhs", "Fluid %s failed to set: Error %d", fluid, ierr);
        }
        else
        {
            //////////////////////////////////////////////////////////////////////////
            // Getting the enumeration value that goes with the desired unit type   //
            // iFlag = 0 -> Check all possible strings                              //
            // iFlag = 1 -> Check units only                                        //
            // iFlag = 2 -> Check property strings and those in #3 only             //
            // iFlag = 3 -> Check property strings not functions of T and D only    //
            //////////////////////////////////////////////////////////////////////////
            GETENUMdll(iFlag, unit_char, iUnits, ierr, herr, hUnits_length, herr_length);
            if(ierr != 0)
            {
                mexErrMsgIdAndTxt("MyToolbox:arrayProduct:prhs", "Converting %s to enum failed: Error %d -> %s", unit_char, ierr, herr);
            }
            
            ////////////////////////////////////////////////////////////////////////////////
            //                            Running the tests:                              //
            ////////////////////////////////////////////////////////////////////////////////
            // setting char variables with desired values //
            ////////////////////////////////////////////////
            strncpy(hFld, fluid,   fluid_len);      // change fluid string to change hFld
            strncpy(hIn,  specSum, spec_len);       // change hIn here directly
            strncpy(hOut, propReq, propReq_len);    // change hOut here directly
            
            ///////////////////////////////////////////
            //running the first set at itr = itc = 0 //
            ///////////////////////////////////////////
            a = value1[itr]; // set first spec entry
            b = value2[itc]; // set second spec entry
            REFPROPdll(hFld, hIn, hOut, iUnits, iMass, mixFlag, a, b, z, hOutput, hUnits, iUCode, x, y, x3, q, ierr, herr, hFld_length, hIn_length, hOut_length, hUnits_length, herr_length);
            if(ierr != 0)
            {
                mexErrMsgIdAndTxt("MyToolbox:arrayProduct:prhs", "1 Refprop call failed: Error %s -> %d %s", unit_char, ierr, herr);
                
                bool unloaded_REFPROP = unload_REFPROP(serr);
                if (!unloaded_REFPROP)
                {
                  printf("REFPROP failed to unload properly.");
                } // if REFPROP failed to unload

                return;
            }

            propReqOut[(numelVal1 * itc) + itr] = hOutput[0];
            
            if (DebugOut == TRUE)
            {
                printf("\n************************************\nValue %zu.%zu \nError             = (%d) %s\nFluid(s)          = %s\nInput properties  = %s = (%f, %f)\nOutput properties = %s\nOutput values     = %lf %s \n", itr+1, itc+1, ierr, herr, fluid, hIn, a, b, hOut, hOutput[0], hUnits);
                
                std::string parsed(fluid);
                size_t      bgn = 0;
                size_t      nnd = 0;

                itrcmp = 0;
                while (    (itrcmp    <  20)
                        && (z[itrcmp]  > 0.000000001))
                {
                    nnd = parsed.find(";", bgn);
                    
                    printf("\nFor: %s\n", parsed.substr(bgn, nnd).c_str());
                    printf("Liquid Phase Comp = %f\n", x[itrcmp]);
                    printf("Vapor  Phase Comp = %f\n", y[itrcmp]);
                    if(x3[itrcmp] > 0.000000001)
                    {
                        printf("2nd Liquid Phase  = %f\n", x3[itrcmp]);
                    }
                    
                    bgn = nnd + 1;
                    itrcmp++;
                } // end loop over Fluid Composition
            } // end if printing out debug statement

            /////////////////////////////////////////////////////////////////////////////////////
            // After the first iteration, we want to change the value of hFld from a string to //
            // an empty string. This tells the function to continue with the previously loaded //
            // dll rather than continuously reloading the dll related to the fluid name        //
            /////////////////////////////////////////////////////////////////////////////////////
            strncpy(hFld, " ", 2);  

            ////////////////////////////////////////////////////////////////////
            // loop over the rest of itc for itr = 0 (a remains the same too) //
            ////////////////////////////////////////////////////////////////////
            for (itc = 1; itc < numelVal2; itc++)
            {
                b = value2[itc]; // set second spec entry

                //////////////////////
                // Call RefProp dll //
                //////////////////////
                REFPROPdll(hFld, hIn, hOut, iUnits, iMass, mixFlag, a, b, z, hOutput, hUnits, iUCode, x, y, x3, q, ierr, herr, hFld_length, hIn_length, hOut_length, hUnits_length, herr_length);
                if(ierr != 0)
                {
                    mexErrMsgIdAndTxt("MyToolbox:arrayProduct:prhs", "2 Refprop call failed: Error %s -> %d %s", unit_char, ierr, herr);
                    
                    bool unloaded_REFPROP = unload_REFPROP(serr);
                    if (!unloaded_REFPROP)
                    {
                      printf("REFPROP failed to unload properly.");
                    } // if REFPROP failed to unload

                    return;
                }

                /////////////////////////////////
                // Fill in the output variable //
                /////////////////////////////////
                propReqOut[(numelVal1 * itc) + itr] = hOutput[0];
                
                //////////////////////////////////////////////////////////////////////////////////////////////////////
                // Print out to screen, mostly this is for debugging purposes and can be removed or condensed later //
                //////////////////////////////////////////////////////////////////////////////////////////////////////
                if (DebugOut == TRUE)
                {
                    printf("\n************************************\nValue %zu.%zu \nError             = (%d) %s\nFluid(s)          = %s\nInput properties  = %s = (%f, %f)\nOutput properties = %s\nOutput values     = %lf %s \n", itr+1, itc+1, ierr, herr, fluid, hIn, a, b, hOut, hOutput[0], hUnits);

                    std::string parsed(fluid);
                    size_t      bgn = 0;
                    size_t      nnd = 0;

                    itrcmp = 0;
                    while (    (itrcmp    <  20)
                            && (z[itrcmp]  > 0.000000001))
                    {
                        nnd = parsed.find(";", bgn);

                        printf("\nFor: %s\n", parsed.substr(bgn, nnd).c_str());
                        printf("Liquid Phase Comp = %f\n", x[itrcmp]);
                        printf("Vapor  Phase Comp = %f\n", y[itrcmp]);
                        if(x3[itrcmp] > 0.000000001)
                        {
                            printf("2nd Liquid Phase  = %f\n", x3[itrcmp]);
                        }

                        bgn = nnd + 1;
                        itrcmp++;
                    } // end loop over Fluid Composition
                } // end if printing debug info
            } // end loop over spec 2 (itc)
            
            ///////////////////////////////
            // continue looping over itr //
            ///////////////////////////////
            for (itr = 1; itr < numelVal1; itr++ )
            {
                a = value1[itr]; // set first spec entry
                
                ///////////////////////////
                // loop over second spec //
                ///////////////////////////
                for (itc = 0; itc < numelVal2; itc++)
                {
                    b = value2[itc]; // set second spec entry

                    //////////////////////
                    // Call RefProp dll //
                    //////////////////////
                    REFPROPdll(hFld, hIn, hOut, iUnits, iMass, mixFlag, a, b, z, hOutput, hUnits, iUCode, x, y, x3, q, ierr, herr, hFld_length, hIn_length, hOut_length, hUnits_length, herr_length);
                    if(ierr != 0)
                    {
                        mexErrMsgIdAndTxt("MyToolbox:arrayProduct:prhs", "3 Refprop call failed: Error %s -> %d %s", unit_char, ierr, herr);
                        
                        bool unloaded_REFPROP = unload_REFPROP(serr);
                        if (!unloaded_REFPROP)
                        {
                          printf("REFPROP failed to unload properly.");
                        } // if REFPROP failed to unload
                        
                        return;
                    }

                    /////////////////////////////////
                    // Fill in the output variable //
                    /////////////////////////////////
                    propReqOut[(numelVal1 * itc) + itr] = hOutput[0];

                    //////////////////////////////////////////////////////////////////////////////////////////////////////
                    // Print out to screen, mostly this is for debugging purposes and can be removed or condensed later //
                    //////////////////////////////////////////////////////////////////////////////////////////////////////
                    if (DebugOut == TRUE)
                    {
                        printf("\n************************************\nValue %zu.%zu \nError             = (%d) %s\nFluid(s)          = %s\nInput properties  = %s = (%f, %f)\nOutput properties = %s\nOutput values     = %lf %s \n", itr+1, itc+1, ierr, herr, fluid, hIn, a, b, hOut, hOutput[0], hUnits);

                        std::string parsed(fluid);
                        size_t      bgn = 0;
                        size_t      nnd = 0;

                        itrcmp = 0;
                        while (    (itrcmp    <  20)
                                && (z[itrcmp]  > 0.000000001))
                        {
                            nnd = parsed.find(";", bgn);

                            printf("\nFor: %s\n", parsed.substr(bgn, nnd).c_str());
                            printf("Liquid Phase Comp = %f\n", x[itrcmp]);
                            printf("Vapor  Phase Comp = %f\n", y[itrcmp]);
                            if(x3[itrcmp] > 0.000000001)
                            {
                                printf("2nd Liquid Phase  = %f\n", x3[itrcmp]);
                            }

                            bgn = nnd + 1;
                            itrcmp++;
                        } // end loop over Fluid Composition
                    } // end if printing debug info
                } // end loop over spec 2  (itc)
            } // end loop over spec 1 (itr)
            if (DebugOut == TRUE)
            {
                printf("\n************************************\n");
            } // end if printing debug info
            
            //////////////////////////////////////////
            // Unload refprop to release the memory //
            //////////////////////////////////////////
            bool unloaded_REFPROP = unload_REFPROP(serr);
            if (!unloaded_REFPROP)
            {
                printf("REFPROP failed to unload properly.");
            } // if REFPROP failed to unload
        } // end if fluid failed, else succeeded, to set
    } // end if refprop failed, else succeeded, to load
} // end function operator() -> entry point

