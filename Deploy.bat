:: Deploy script for CompFileDate.
::
:: This script compiles release versions of the 64 and 32 bit Windows builds and
:: and 64 bit Linux build of CompFileDate and creates compressed archives
:: containing the releases.
::
:: This script uses MSBuild, InfoZip's zip.exe, Windows 10/11's built in
:: tar.exe and DOS2Unix. MSBuild also requires that DelphiDabbler Version
:: Information Editor is installed.
::
:: Get zip.exe from https://delphidabbler.com/extras/info-zip
:: Get DOS2Unix from https://sourceforge.net/projects/dos2unix/
:: Get Version Information Editor from https://delphidabbler.com/software/vied
::
:: To use the script:
::    1) Start the Embarcadero RAD Studio Command Prompt to set the required
::       environment variables for MSBuild.
::    2) Set the BDSBIN variable to %BDS%\bin (required by MSBuild/Delphi).
::    3) Set the ZIPROOT environment variable to the directory where zip.exe is
::       installed.
::    4) Set the DOS2UNIXROOT environment variable to the directory where
::       DOS2Unix is installed.
::    5) Set the VIEDROOT environment variable to the directory where VIEd.exe 
::       is installed.
::    6) Change directory to that where this script is located.
::    7) Run the script, without parameters.

@echo off

echo ------------------------------
echo Deploying CompFileDate Release
echo ------------------------------

:: Check for required environment variables
if "%ZipRoot%"=="" goto envvarerror
if "%VIEdRoot%"=="" goto envvarerror
if "%DOS2UnixRoot%"=="" goto envvarerror

:: Get version info from Src\VERSION

:: Set path to file containing version information
set VerFile=.\Src\VERSION

:: Undefine the variables used to collect version information
set vernum=
set suffix=

:: Get the version number from the version info file - this MUST exist
for /f "tokens=2 delims==" %%A in (
  'findstr /rc:"^version" %VerFile%'
) do (
    set vernum=%%A
  )
)
if not defined vernum (
    goto badversionerror
)

:: Get the optional version number suffix from the version info file
for /f "tokens=2 delims==" %%A in (
  'findstr /rc:"^suffix" %VerFile%'
) do (
    set suffix=%%A
)

:: Record & report the build version
set Version=%vernum%%suffix%
echo Building release v%Version%

:: Set variables
set BuildRoot=.\_build
set Win32Dir=%BuildRoot%\Win32\Release\exe
set Win64Dir=%BuildRoot%\Win64\Release\exe
set Linux64Dir=%BuildRoot%\Linux64\Release\exe
set ReleaseDir=%BuildRoot%\release
set OutFileWin32=%ReleaseDir%\CompFileDate-win32-%Version%.zip
set OutFileWin64=%ReleaseDir%\CompFileDate-win64-%Version%.zip
set OutFileLinux64=CompFileDate-linux64-%Version%.tar.gz
set SrcDir=Src
set DocsDir=Docs
set PrgBaseName=CompFileDate
set ReadMeFileName=ReadMe.txt
set ReadMeFile=%DocsDir%\%ReadMeFileName%
set LicenseFile=LICENSE.md
set ChangeLogFile=CHANGELOG.md

:: Make a clean directory structure
if exist "%BuildRoot%" rmdir /S /Q "%BuildRoot%"

mkdir "%ReleaseDir%"

setlocal

:: Build Pascal
cd "%SrcDir%"

echo.
echo Building Windows 32 bit version
echo.
msbuild "%PrgBaseName%.dproj" /p:config=Release /p:platform=Win32
echo.

echo.
echo Building Windows 64 bit version
echo.
msbuild "%PrgBaseName%.dproj" /p:config=Release /p:platform=Win64
echo.

echo.
echo Building Linux 64 bit version
echo.
msbuild "%PrgBaseName%.dproj" /p:config=Release /p:platform=Linux64
echo.

endlocal

:: Create zip files for Windows builds
echo.
echo Creating zip files for Windows builds
"%ZipRoot%\zip.exe" -j -9 "%OutFileWin32%" "%Win32Dir%\%PrgBaseName%.exe"
"%ZipRoot%\zip.exe" -j -9 "%OutFileWin64%" "%Win64Dir%\%PrgBaseName%.exe"
"%ZipRoot%\zip.exe" -j -9 "%OutFileWin32%" "%ReadMeFile%"
"%ZipRoot%\zip.exe" -j -9 "%OutFileWin64%" "%ReadMeFile%"
"%ZipRoot%\zip.exe" -j -9 "%OutFileWin32%" "%LicenseFile%"
"%ZipRoot%\zip.exe" -j -9 "%OutFileWin64%" "%LicenseFile%"
"%ZipRoot%\zip.exe" -j -9 "%OutFileWin32%" "%ChangeLogFile%"
"%ZipRoot%\zip.exe" -j -9 "%OutFileWin64%" "%ChangeLogFile%"

:: Create tar.gz file for Linux build
echo.
echo Creating tar.gz file for Linux build
set LinuxTarDir=%ReleaseDir%\tmp
:: assemble release files in same temp directory
mkdir "%LinuxTarDir%"
copy "%Linux64Dir%\%PrgBaseName%" "%LinuxTarDir%"
copy "%ReadMeFile%" "%LinuxTarDir%"
copy "%LicenseFile%" "%LinuxTarDir%"
copy "%ChangeLogFile%" "%LinuxTarDir%"
setlocal
cd "%LinuxTarDir%"
:: convert line endings of text files from Windows (CRLF) to Unix (LF) format
"%DOS2UnixRoot%\dos2unix.exe" -b -k -e "%ReadMeFileName%" "%LicenseFile%" "%ChangeLogFile%"
:: create the tarball using files in temp directory
tar.exe -cvzf "..\%OutFileLinux64%" .
endlocal
:: remove temp directory
rmdir /S /Q "%LinuxTarDir%"

echo.
echo ---------------
echo Build completed
echo ---------------

goto end

:: Error messages

:envvarerror
echo.
echo ***ERROR: ZipRoot or VIEdRoot or DOS2UnixRoot environment variable not set
echo.
goto end

:badversionerror
echo.
echo ***ERROR: "version" field not set in %VerFile%
echo.
goto end

:: End
:end
