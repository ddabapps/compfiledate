
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
DelphiDabbler CompFileDate Source Code Readme
________________________________________________________________________________

Source code for the current version of DelphiDabbler CompFileDate is always
available from http://www.delphidabbler.com/download?id=compfiledate&type=src.

The source code is provided in a zip file, dd-compfiledate-src.zip. This file
includes all CompFileDate's original code. Files should be extracted from the
zip file and the directory structure should be preserved.

The directory structure is:

  Bin      : Binary resource files (*1)
  Src      : Pascal and other source code and build batch file (*2)
    Assets : Files that are compiled into resources

  Notes:
    (*1) - See below for details of how to recompile these files
    (*2) - The build batch file is described below

To compile the program you need to create a "Exe" directory at the same level as
the "Bin" and "Src" directories.

The Delphi 2006 VCL is needed to compile CompFileDate successfully.

The program also requires two binary resource files in order to compile
(provided):

1) VerInfo.res - the program's version information.
2) Resources.res - other resources.


¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
Build Tools
________________________________________________________________________________

A batch file - Build.bat - is provided in the "Src" directory. It can be used to
automate full or partial builds. It must be called with a command line
switch. Supported switches are:

  all   - Builds everything.
  res   - Builds binary resource files only. Requires VIEd and BRCC32. Creates
          VerInfo.res and Resources.res from VerInfo.vi and Resources.rc
          respectively.
  pas   - Builds the Delphi Pascal project. Requires DCC32 provided with Delphi
          2006.

The programs required by the build process are:

+ VIEd    - DelphiDabbler Version Information Editor, available from
            www.delphidabbler.com. Requires v2.11.2 or later.
+ BRCC32  - Borland Resource Compiler, supplied with Delphi 2006.
+ DCC32   - Delphi Command Line Compiler, supplied with Delphi 2006.

Build.bat also requires the following environment variable to be defined:
+ DELPHI2006  - To be set to the install directory of Delphi 2006, which must
                also contain BRCC32.

VIEd is expected to be on the path. If it is not, add the program to the PATH
environment variable.
        

¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
Licensing
________________________________________________________________________________

Please see LICENSE.txt for information about source code licenses.


¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯