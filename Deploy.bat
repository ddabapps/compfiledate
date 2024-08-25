:: Deploy script for CompFileDate.
::
:: This script compiles release versions of the 64 and 32 bit builds of
:: CompFileDate and places then into a single zip file ready for release.
::
:: This script uses MSBuild and InfoZip's zip.exe. The MSBuild project also
:: requires DelphiDabbler Version Information Editor to be installed.
::
:: Get zip.exe from https://delphidabbler.com/extras/info-zip
:: Get Version Information Editor from https://delphidabbler.com/software/vied

:: To use the script:
::   1) Start the Embarcadero RAD Studio Command Prompt to set the required
::      environment variables for MSBuild.
::   2) Set the ZIPROOT environment variable to the directory where zip.exe is
::      installed.
::   3) Set the VIEDROOT environment variable to the directory where VIEd.exe is
::      installed.
::   3) Change directory to that where this script is located.
::   4) Run the script.
::
:: Usage:
::   Deploy <version>
:: where
::   <version> is the version number of the release, e.g. 2.2.0 or 3.1.0-beta.

@echo off

echo ------------------------------
echo Deploying CompFileDate Release
echo ------------------------------

:: Check for required parameter
if "%1"=="" goto paramerror

:: Check for required environment variables
if "%ZipRoot%"=="" goto envvarerror
if "%VIEdRoot"=="" goto envvarerror

:: Set variables
set Version=%1
set BuildRoot=.\_build
set Win32Dir=%BuildRoot%\Win32\Release\exe
set Win64Dir=%BuildRoot%\Win64\Release\exe
set ReleaseDir=%BuildRoot%\release
set OutFile32=%ReleaseDir%\CompFileDate-exe32-%Version%.zip
set OutFile64=%ReleaseDir%\CompFileDate-exe64-%Version%.zip
set SrcDir=Src
set DocsDir=Docs
set PrgBaseName=CompFileDate
set ReadMeFile=%DocsDir%\ReadMe.txt
set LicenseFile=LICENSE.md
set ChangeLogFile=CHANGELOG.md

:: Make a clean directory structure
if exist %BuildRoot% rmdir /S /Q %BuildRoot%
mkdir %BuildExeRoot%
mkdir %BuildExeRoot%\Win32
mkdir %Win32Dir%
mkdir %BuildExeRoot%\Win64
mkdir %Win64Dir%
mkdir %ReleaseDir%

setlocal

:: Build Pascal
cd %SrcDir%

echo.
echo Building 32 bit version
echo.
msbuild %PrgBaseName%.dproj /p:config=Release /p:platform=Win32
echo.

echo.
echo Building 64 bit version
echo.
msbuild %PrgBaseName%.dproj /p:config=Release /p:platform=Win64
echo.

endlocal

:: Create zip files
echo.
echo Creating zip files
%ZipRoot%\zip.exe -j -9 %OutFile32% %Win32Dir%\%PrgBaseName%.exe
%ZipRoot%\zip.exe -j -9 %OutFile64% %Win64Dir%\%PrgBaseName%.exe
%ZipRoot%\zip.exe -j -9 %OutFile32% %ReadMeFile%
%ZipRoot%\zip.exe -j -9 %OutFile64% %ReadMeFile%
%ZipRoot%\zip.exe -j -9 %OutFile32% %LicenseFile%
%ZipRoot%\zip.exe -j -9 %OutFile64% %LicenseFile%
%ZipRoot%\zip.exe -j -9 %OutFile32% %ChangeLogFile%
%ZipRoot%\zip.exe -j -9 %OutFile64% %ChangeLogFile%

echo.
echo ---------------
echo Build completed
echo ---------------

goto end

:: Error messages

:paramerror
echo.
echo ***ERROR: Please specify a version number as a parameter
echo.
goto end

:envvarerror
echo.
echo ***ERROR: ZipRoot environment variable not set
echo.
goto end

:: End
:end
