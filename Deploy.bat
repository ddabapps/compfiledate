:: Deploy script for CompFileDate.
::
:: This script compiles CompFileDate for the following target platforms:
::
::   * Windows 64 bit
::   * Windows 32 bit
::   * Linux 64 bit
:: 
:: Each target is built using the Release build configuration. Executable files
:: are then bundled with relevant documentation and compressed into archive
:: files. There are separate archives for each target in both zip and tar/gzip
:: format.
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
:: The source code tree MUST have the same structure as downloaded, with this
:: script in the root of the source tree.
::
:: The script must be called from a terminal with a correctly configured
:: environment. Here's how to configure a terminal:
::
::   1) Open a terminal window that is configured to enable MSBuild to be run.
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
echo.

:: Check that required MSBuild environment has been set up

if "%BDS%"=="" goto missing_bds_env_var_error

:: Set paths to utility programs

echo +++ Setting paths to utility programs

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

echo.
echo +++ Reading version information

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
echo --- Version number read: %Version%

:: Set variables

echo.
echo +++ Setting variables

:: "Root" directory of project, absolute path stripped of any trailing backslash
set RootDir=%~dp0
if "%ROOTDIR:~-1%"=="\" (
  set RootDir=%RootDir:~0,-1%
)

:: Immediate subdirectories of project root
set BuildDir=%RootDir%\_build
set SrcDir=%RootDir%\Src
set DocsDir=%RootDir%\Docs

:: Release directory where all release files are gathered
set ReleaseDir=%BuildDir%\release

:: Base file names of release archives
set Win32ArchiveFileName=CompFileDate-win32-%Version%
set Win64ArchiveFileName=CompFileDate-win64-%Version%
set Linux64ArchiveFileName=CompFileDate-linux64-%Version%
:: Full paths of .zip released archives
set Win32ZipFilePath=%ReleaseDir%\%Win32ArchiveFileName%.zip
set Win64ZipFilePath=%ReleaseDir%\%Win64ArchiveFileName%.zip
set Linux64ZipFilePath=%ReleaseDir%\%Linux64ArchiveFileName%.zip
:: Full paths of .tar.gz released archives
set Win32TarFilePath=%ReleaseDir%\%Win32ArchiveFileName%.tar.gz
set Win64TarFilePath=%ReleaseDir%\%Win64ArchiveFileName%.tar.gz
set Linux64TarFilePath=%ReleaseDir%\%Linux64ArchiveFileName%.tar.gz

:: Temp directories where each target's release files are bundled
set BundleDir=%ReleaseDir%\_bundles
set Win32BundleDir=%BundleDir%\Win32
set Win64BundleDir=%BundleDir%\Win64
set Linux64BundleDir=%BundleDir%\Linux64

:: Project base name
set ProjectName=CompFileDate

:: Delphi project file name
set ProjectFileName=%ProjectName%.dproj

:: Exe file names for each target
set Win32ExeFileName=%ProjectName%.exe
set Win64ExeFileName=%ProjectName%.exe
set Linux64ExeFileName=%ProjectName%
:: Full paths of exe files for each target
set Win32ExeFilePath=%BuildDir%\Win32\Release\exe\%Win32ExeFileName%
set Win64ExeFilePath=%BuildDir%\Win64\Release\exe\%Win64ExeFileName%
set Linux64ExeFilePath=%BuildDir%\Linux64\Release\exe\%Linux64ExeFileName%

:: Name, directory and path of ReadMe file
set ReadMeFileName=ReadMe.txt
set ReadMeFilePath=%DocsDir%\%ReadMeFileName%
:: Names, directory and path of License file
set LicenseFileName=LICENSE.md
set LicenseFilePath=%RootDir%\%LicenseFileName%
:: Names, directory and path of change log file
set ChangeLogFileName=CHANGELOG.md
set ChangeLogFilePath=%RootDir%\%ChangeLogFileName%

:: Make a clean directory structure

echo.
echo +++ Making directories

if exist "%BuildDir%" rmdir /S /Q "%BuildDir%"
mkdir "%ReleaseDir%"

:: Build Pascal

setlocal

cd "%SrcDir%"

echo.
echo +++ Building Windows 32 bit version
echo.
msbuild "%ProjectFileName%" /p:config=Release /p:platform=Win32
echo.

echo.
echo +++ Building Windows 64 bit version
echo.
msbuild "%ProjectFileName%" /p:config=Release /p:platform=Win64
echo.

echo.
echo +++ Building Linux 64 bit version
echo.
msbuild "%ProjectFileName%" /p:config=Release /p:platform=Linux64
echo.

endlocal

:: Bundle up release files for each target

echo.
echo +++ Bundling release files
:: Windows 32
echo --- Bundling Windows 32 files
mkdir "%Win32BundleDir%"
copy "%Win32ExeFilePath%" "%Win32BundleDir%"
copy "%ReadMeFilePath%" "%Win32BundleDir%"
copy "%LicenseFilePath%" "%Win32BundleDir%"
copy "%ChangeLogFilePath%" "%Win32BundleDir%"

:: Windows 64
echo --- Bundling Windows 64 files
mkdir "%Win64BundleDir%"
copy "%Win64ExeFilePath%" "%Win64BundleDir%"
copy "%ReadMeFilePath%" "%Win64BundleDir%"
copy "%LicenseFilePath%" "%Win64BundleDir%"
copy "%ChangeLogFilePath%" "%Win64BundleDir%"

:: Linux 64
echo --- Bundling Linux 64 files
mkdir "%Linux64BundleDir%"
copy "%Linux64ExeFilePath%" "%Linux64BundleDir%"
copy "%ReadMeFilePath%" "%Linux64BundleDir%"
copy "%LicenseFilePath%" "%Linux64BundleDir%"
copy "%ChangeLogFilePath%" "%Linux64BundleDir%"
:: convert line endings of text files from Windows (CRLF) to Unix (LF) format
setlocal
echo ------ Converting text file EOL characters for Linux
cd "%Linux64BundleDir%"
"%DOS2UnixExe%" -b -k -e "%ReadMeFileName%" "%LicenseFile%" "%ChangeLogFile%"
endlocal

:: Create archive files for Windows builds

:: Windows 32
setlocal
cd "%Win32BundleDir%"
echo.
echo +++ Creating Win32 archives
echo --- Creating .zip archive: %Win32ZipFilePath%
"%ZipExe%" -j -9 "%Win32ZipFilePath%" *
echo --- Creating .tar.gz archive: %Win32TarFilePath%
tar.exe -zcvf "%Win32TarFilePath%" .
endlocal

:: Windows 64
setlocal
cd "%Win64BundleDir%"
echo.
echo +++ Creating Win64 archives
echo --- Creating .zip archive: %Win64ZipFilePath%
"%ZipExe%" -j -9 "%Win64ZipFilePath%" *
echo --- Creating .tar.gz archive: %Win64TarFilePath%
tar.exe -zcvf "%Win64TarFilePath%" .
endlocal

:: Linux 64
setlocal
cd "%Linux64BundleDir%"
echo.
echo +++ Creating Linux64 archives
echo --- Creating .zip archive: %Linux64ZipFilePath%
"%ZipExe%" -j -9 "%Linux64ZipFilePath%" *
echo --- Creating .tar.gz archive: %Linux64TarFilePath%
tar.exe -zcvf "%Linux64TarFilePath%" .
endlocal

:: Remove temp files

echo.
echo +++ Removing temporary files
rmdir /S /Q "%BundleDir%"

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
echo *** ERROR: "version" field not set in %VerFile%
echo.
goto end

:: Done

:end
