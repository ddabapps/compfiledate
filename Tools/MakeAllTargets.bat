:: Helper script to build CompFileDate for all target platforms.
::
:: This script compiles DEBUG versions of CompFileDate for the following target
:: platforms:
::
::   * Windows 64 bit
::   * Windows 32 bit
::   * Linux 64 bit
:: 
:: Delphi's version of MSBuild is used to create the builds.
::
:: **** Before using this script make sure that the program can be compiled from
::      within the IDE. Some configuration is required to achieve this. See the
::      "Step 2: Configure the Build Environment" section of Build.txt for
::      details.
::
:: The script must be called from a terminal with a correctly configured
:: environment. Proceed as follows:
::
::   1) Open and configure the terminal window. There are two ways to do this:
::
::      a) Start the Embarcadero RAD Studio Command Prompt from the Windows
::         Start menu. This opens a terminal window with the required
::         environment variables set.
::
::      b) Open a new terminal window. CD to the directory where RAD Studio is
::         installed. Now CD into the Bin sub-directory. Run rsvars.bat.
::
::   2) In the terminal window CD to the directory where this script is located.
::
::   3) Run the script, without parameters.

@echo off

echo ----------------------------------
echo Creating CompFileDate Debug Builds
echo ----------------------------------

:: Check that required MSBuild environment has been set up

if "%BDS%"=="" goto missing_bds_env_var_error

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

:: Error messages

:missing_bds_env_var_error

echo.
echo *** ERROR: BDS environment variable is not set.
echo ***        Run rsvars.bat from the bin subdirectory of the Delphi install
echo ***        directory.
echo.
goto end

:: Done

:end
