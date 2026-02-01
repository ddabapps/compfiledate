:: Helper script to build CompFileDate for all target platforms.
::
:: This script compiles DEBUG versions of the Windows 64 and 32 bit builds and
:: Linux 64 bit build of CompFileDate into the directories specified in project
:: options.
::
:: This script uses MSBuild. The MSBuild project also requires DelphiDabbler
:: Version Information Editor to be installed.
::
:: Get Version Information Editor from https://delphidabbler.com/software/vied
::
:: To use the script:
::    1) Start the Embarcadero RAD Studio Command Prompt to set the required
::       environment variables for MSBuild.
::    2) Set the BDSBIN variable to %BDS%\bin (required by MSBuild/Delphi).
::    4) Set the VIEDROOT environment variable to the directory where VIEd.exe 
::       is installed.
::    5) Change directory to that where this script is located.
::    6) Run the script, without parameters

@echo off

echo ----------------------------------
echo Creating CompFileDate Debug Builds
echo ----------------------------------

:: Check for required environment variables
if "%VIEdRoot%"=="" goto envvarerror

:: Set variables
set SrcDir=..\Src
set ProjFileName=CompFileDate.dproj

setlocal

:: Build Pascal
cd %SrcDir%

echo.
echo Building Windows 32 bit version
echo -------------------------------
echo.
msbuild %ProjFileName% /p:config=Debug /p:platform=Win32
echo.

echo.
echo Building Windows 64 bit version
echo -------------------------------
echo.
msbuild %ProjFileName% /p:config=Debug /p:platform=Win64
echo.

echo.
echo Building Linux 64 bit version
echo -----------------------------
echo.
msbuild %ProjFileName% /p:config=Debug /p:platform=Linux64
echo.

goto end

endlocal

:envvarerror
echo.
echo ***ERROR: VIEdRoot environment variable not set
echo.
goto end

:: End
:end
