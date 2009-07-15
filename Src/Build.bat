@rem Build.bat
@rem
@rem Script used to build the DelphiDabbler CompFileDate project.
@rem
@rem $Rev$
@rem $Date$
@rem
@rem Requires:
@rem    Borland Delphi 2006
@rem    Borland BRCC32 from Delphi 2006 installation
@rem    DelphiDabbler Version Information Editor v2.11.2
@rem
@rem Also requires the following environment variables:
@rem    DELPHI2006 to be set to the install directory of Delphi 2006
@rem
@rem  Switches: exactly one of the following must be provided
@rem    all - build everything
@rem    res - build binary resource files only
@rem    pas - build Delphi Pascal project only
@rem
@rem ***** BEGIN LICENSE BLOCK *****
@rem
@rem Version: MPL 1.1/GPL 2.0/LGPL 2.1
@rem
@rem The contents of this file are subject to the Mozilla Public License
@rem Version 1.1 (the "License")@rem * you may not use this file except in
@rem compliance with the License. You may obtain a copy of the License at
@rem http://www.mozilla.org/MPL/MPL-1.1
@rem
@rem Software distributed under the License is distributed on an "AS IS"
@rem basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
@rem License for the specific language governing rights and limitations under
@rem the License.
@rem
@rem The Original Code is Build.bat from the CompFileDate project.
@rem
@rem The Initial Developer of the Original Code is Peter Johnson
@rem (http://www.delphidabbler.com/).
@rem
@rem Portions created by the Initial Developer are Copyright (C) 2009 by
@rem the Initial Developer. All Rights Reserved.
@rem
@rem Contributors:
@rem    None.
@rem
@rem Alternatively, the contents of this file may be used under the terms of
@rem either the GNU General Public License Version 2 or later (the "GPL"), or
@rem the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
@rem in which case the provisions of the GPL or the LGPL are applicable
@rem instead of those above. If you wish to allow use of your version of this
@rem file only under the terms of either the GPL or the LGPL, and not to allow
@rem others to use your version of this file under the terms of the MPL,
@rem indicate your decision by deleting the provisions above and replace them
@rem with the notice and other provisions required by the LGPL or the GPL. If
@rem you do not delete the provisions above, a recipient may use your version
@rem of this file under the terms of any one of the MPL, the GPL or the LGPL.
@rem
@rem ***** END LICENSE BLOCK *****


rem ----------------------------------------------------------------------------
rem Initialise
rem ----------------------------------------------------------------------------

@echo off
setlocal


rem ----------------------------------------------------------------------------
rem Sign on
rem ----------------------------------------------------------------------------

title DelphiDabbler CompFileDate Build Script

echo DelphiDabbler CompFileDate Build Script
echo ---------------------------------------

goto Config


rem ----------------------------------------------------------------------------
rem Configure script per command line parameter
rem ----------------------------------------------------------------------------

:Config
echo Configuring script

rem Reset all config variables
set BuildAll=
set BuildResources=
set BuildPascal=

rem Sheck switch
if "%~1" == "all" goto Config_BuildAll
if "%~1" == "res" goto Config_BuildResources
if "%~1" == "pas" goto Config_BuildPascal
set ErrorMsg=Unknown switch "%~1"
if "%~1" == "" set ErrorMsg=No switch specified
goto Error

rem Set config variables

:Config_BuildAll
set BuildResources=1
set BuildPascal=1
goto Config_OK

:Config_BuildResources
set BuildResources=1
goto Config_OK

:Config_BuildPascal
set BuildPascal=1
goto Config_OK

:Config_OK
echo Done.
goto CheckEnvVars


rem ----------------------------------------------------------------------------
rem Check that required environment variables exist
rem ----------------------------------------------------------------------------

:CheckEnvVars

echo Checking predefined environment environment variables
if not defined DELPHI2006 goto BadDELPHI2006Env
echo Done.
echo.
goto SetEnvVars

:BadDELPHI2002006Env
set ErrorMsg=DELPHI2006 Environment variable not defined
goto Error


rem ----------------------------------------------------------------------------
rem Set up required environment variables
rem ----------------------------------------------------------------------------

:SetEnvVars
echo Setting Up Environment

rem source directory
set SrcDir=.\

rem binary files directory
set BinDir=..\Bin\

rem executable files directory
set ExeDir=..\Exe\

rem Delphi 2006 - use full path since maybe multple installations
set DCC32Exe="%DELPHI2006%\Bin\DCC32.exe"

rem Borland Resource Compiler - use full path since maybe multple installations
set BRCC32Exe="%DELPHI2006%\Bin\BRCC32.exe"

rem DelphiDabbler Version Information Editor - assumed to be on the path
set VIEdExe=VIEd.exe

echo Done.
echo.


rem ----------------------------------------------------------------------------
rem Start of build process
rem ----------------------------------------------------------------------------

:Build
echo BUILDING ...
echo.

goto Build_Resources


rem ----------------------------------------------------------------------------
rem Build resource files
rem ----------------------------------------------------------------------------

:Build_Resources
if not defined BuildResources goto Build_Pascal
echo Building Resources
echo.

rem Set required env vars

rem Ver info resource
set VerInfoBase=VerInfo
set VerInfoSrc=%SrcDir%%VerInfoBase%.vi
set VerInfoTmp=%SrcDir%%VerInfoBase%.rc
set VerInfoRes=%BinDir%%VerInfoBase%.res

rem Main resource
set ResourcesBase=Resources
set ResourcesSrc=%SrcDir%%ResourcesBase%.rc
set ResourcesRes=%BinDir%%ResourcesBase%.res

rem Compile version information resource
rem VIedExe creates temp resource .rc file from .vi file
rem BRCC32Exe compiles temp resource .rc file to required .res

echo Compiling %VerInfoSrc% to %VerInfoRes%
set ErrorMsg=
%VIEdExe% -makerc %VerInfoSrc%
if errorlevel 1 set ErrorMsg=Failed to compile %VerInfoSrc%
if not "%ErrorMsg%"=="" goto VerInfoRes_End
%BRCC32Exe% %VerInfoTmp% -fo%VerInfoRes%
if errorlevel 1 set ErrorMsg=Failed to compile %VerInfoTmp%
if not "%ErrorMsg%"=="" goto VerInfoRes_End
echo Done
echo.

:VerInfoRes_End
if exist %VerInfoTmp% del %VerInfoTmp%
if not "%ErrorMsg%"=="" goto Error

rem Compile Resources.rc resource

echo Compiling %ResourcesSrc% to %ResourcesRes%
%BRCC32Exe% %ResourcesSrc% -fo%ResourcesRes%
if errorlevel 1 goto ResourcesRes_Error
echo Done
echo.
goto ResourcesRes_End

:ResourcesRes_Error
set ErrorMsg=Failed to compile %ResourcesSrc%
goto Error

:ResourcesRes_End

rem End of resource compilation

goto Build_Pascal


rem ----------------------------------------------------------------------------
rem Build Pascal project
rem ----------------------------------------------------------------------------

:Build_Pascal
if not defined BuildPascal goto Build_End

rem Set up required env vars
set PascalBase=CompFileDate
set PascalSrc=%SrcDir%%PascalBase%.dpr
set PascalExe=%ExeDir%%PascalBase%.exe

echo Building Pascal Project
%DCC32Exe% -B %PascalSrc%
if errorlevel 1 goto Pascal_Error
goto Pascal_End

:Pascal_Error
set ErrorMsg=Failed to compile %PascalSrc%
if exist %PascalExe% del %PascalExe%
goto Error

:Pascal_End
echo Done.
echo.

rem End of Pascal compilation

goto Build_End


rem ----------------------------------------------------------------------------
rem Build completed
rem ----------------------------------------------------------------------------

:Build_End
echo BUILD COMPLETE
echo.

goto End


rem ----------------------------------------------------------------------------
rem Handle errors
rem ----------------------------------------------------------------------------

:Error
echo.
echo *** ERROR: %ErrorMsg%
echo.


rem ----------------------------------------------------------------------------
rem Finished
rem ----------------------------------------------------------------------------

:End
echo.
echo DONE.
endlocal

