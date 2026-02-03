:: Deploy script for CompFileDate.
::
:: This script compiles CompFileDate for the following target platforms:
::
::   * Windows 64 bit
::   * Windows 32 bit
::   * Linux 64 bit
:: 
:: Each target is built using the Release build configuration. Executable files
:: are then bundled with relevant documentation and compressed into an archive
:: file. There is a separate archive file for each target.
::
:: The archives containing the Windows releases are packaged using zip while the
:: Linux release is packaged and gzip compressed using tar.
::
:: Delphi's version of MSBuild is used to create the builds.
::
:: **** Before using this script make sure that the program can be compiled from
::      within the IDE. Some configuration is required to achieve this. See the
::      "Step 2: Configure the Build Environment" section of Build.txt for
::      details.
::
:: The script calls the following utilities:
::
::   * tar.exe 
::     - Installed by default with Windows 10 & 11 and available on the path.
::     
::   * zip.exe (InfoZip version) 
::     - Download from https://delphidabbler.com/extras/info-zip
::
::   * dos2unix.exe
::     - Download from https://sourceforge.net/projects/dos2unix/
::
:: The script must be called from a terminal with a correctly configured
:: environment. Here's how to configure a terminal:
::
::   1) Open a terminal window that is configured to enabled MSBuild to be run.
::      There are two ways to do this:
::
::      a) Start the Embarcadero RAD Studio Command Prompt from the Windows
::         Start menu. This opens a terminal window that is pre-configured to 
::         run MSBuild.
::
::      b) Open a new terminal window. CD to the directory where RAD Studio is
::         installed. Now CD into the Bin sub-directory. Run rsvars.bat.
::
::   2) If zip.exe is not on the path then create an environment variable named
::      ZipRoot and set its value to the directory where zip.exe is installed.
::
::   3) If dos2unix.exe is not on the path then create an environment variable
::      named DOS2UnixRoot and set its value to the directory where dos2unit.exe
::      is installed.
::
::   4) In the terminal window CD to the directory where this script is located.
::
::   5) Run the script, without parameters. 

@echo off

echo ------------------------------
echo Deploying CompFileDate Release
echo ------------------------------

:: Check that required MSBuild environment has been set up

if "%BDS%"=="" goto missing_bds_env_var_error

:: Set paths to utility programs:

set ZipExe=zip.exe
if defined ZipRoot (
  :: Prepend install directory stored in ZipRoot env var if set
  set ZipExe=%ZipRoot%\%ZipExe%
)

set DOS2UnixExe=dos2unix.exe
if defined DOS2UnixRoot (
  :: Prepend install directory stored in DOS2UnixExe env var if set
  set DOS2UnixExe=%DOS2UnixRoot%\%DOS2UnixExe%
)

:: Get version info from Src\VERSION

:: Set path to file containing version information
set VerFile=.\Src\VERSION

:: Undefine the variables used to collect version information
set vernum=
set suffix=

:: Get the version number from the version info file - this MUST exist
for /f "tokens=2 delims==" %%A in (
  'findstr /rc:"^version" "%VerFile%"'
) do (
    set vernum=%%A
  )
)
if not defined vernum (
    goto badversionerror
)

:: Get the optional version number suffix from the version info file
for /f "tokens=2 delims==" %%A in (
  'findstr /rc:"^suffix" "%VerFile%"'
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
"%ZipExe%" -j -9 "%OutFileWin32%" "%Win32Dir%\%PrgBaseName%.exe"
"%ZipExe%" -j -9 "%OutFileWin64%" "%Win64Dir%\%PrgBaseName%.exe"
"%ZipExe%" -j -9 "%OutFileWin32%" "%ReadMeFile%"
"%ZipExe%" -j -9 "%OutFileWin64%" "%ReadMeFile%"
"%ZipExe%" -j -9 "%OutFileWin32%" "%LicenseFile%"
"%ZipExe%" -j -9 "%OutFileWin64%" "%LicenseFile%"
"%ZipExe%" -j -9 "%OutFileWin32%" "%ChangeLogFile%"
"%ZipExe%" -j -9 "%OutFileWin64%" "%ChangeLogFile%"

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
"%DOS2UnixExe%" -b -k -e "%ReadMeFileName%" "%LicenseFile%" "%ChangeLogFile%"

:: create the tarball using files in temp directory
tar.exe -cvzf "..\%OutFileLinux64%" .
endlocal

:: remove temp directory
rmdir /S /Q "%LinuxTarDir%"

:: Done

echo.
echo ---------------
echo Build completed
echo ---------------

goto end

:: Error messages

:missing_bds_env_var_error

echo.
echo *** ERROR: BDS environment variable is not set.
echo ***        Run rsvars.bat from the bin subdirectory of the Delphi install
echo ***        directory.
echo.
goto end

:badversionerror
echo.
echo ***ERROR: "version" field not set in %VerFile%
echo.
goto end

:: Done

:end
