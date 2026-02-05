:: A script that is designed to be called from Delphi as a pre-build event.
:: It creates a Pascal include file containing the program's version number by
:: parsing another file that defines the version number.
::
:: Usage:
::   VerExtractor input-file-name output-file-name
:: where
::   input-file-name is the name and path of a text file that MUST contain a 
::   string, on its own line, in the form
::     version=<version-number>
::   and an optional string, on its own line, in the form
::     suffix=<version-suffix>
::   where <version-number> is a dotted triple containing the version number
::   (e.g. 1.2.3) and <version-suffix> is an optional string, beginning with a
::   dash (e.g. -beta-1).
:: and
::   output-file-name is the name and path of the generated Pascal include file.
::
:: The generated include file contains only the definition of a string constant 
:: that is set to the version number.
::
:: The script returns the following exit codes:
::   0 - success
::   1 - less than two parameters were specified
::   2 - the input file specified as parameter #1 does not exist
::   3 - the output file specified as parameter #2 cannot be created
::   4 - the input file does not contain data in the required format 
::
:: WARNING: This script should not be run directly from the command line as this
:: can cause the command shell to crash.

@echo off

:: Check both required parameters exist
if "%1" == "" exit 1
if "%2" == "" exit 1

:: Set file and directory paths
set VerFile=%1
set IncFile=%2
set IncDir=%~dp2

:: Check input file exists
if not exist "%VerFile%" exit 2

:: Undefine variables used to collect version information
set vernum=
set suffix=

:: Get version number from input file - this MUST exist
for /f "tokens=2 delims==" %%A in (
  'findstr /rc:"^version" "%VerFile%"'
) do (
    set vernum=%%A
  )
)

:: Check that version number was read successfully
if not defined vernum exit 4

:: Get optional version number suffix from input info file
for /f "tokens=2 delims==" %%A in (
  'findstr /rc:"^suffix" "%VerFile%"'
) do (
  set suffix=%%A
)

:: Build the full program version string
set Version=%vernum%%suffix%

:: Create the directory that receives the include file if it doesn't exist
if not exist "%IncDir%" (
  mkdir "%IncDir%"
)

:: Delete any existing copy of the include file
if exist "%IncFile%" (
  del "%IncFile%"
)

:: Write the include file
echo const VERSION_STRING = '%Version%'; >"%IncFile%"

:: Check include file was written successfully
if not exist "%IncFile%" exit 3

:: Success
exit 0
