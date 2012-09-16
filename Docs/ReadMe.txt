
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
DelphiDabbler CompFileDate Readme

$Rev$
$Date$
________________________________________________________________________________


¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
About The Program
________________________________________________________________________________

CompFileDate.exe compares the dates of two files whose names are passed on the
command line and returns an exit code that informs if the first named file has
an older modification date than the second file.

The usage is:

  CompFileDate <filename1> <filename2> [-v]
    or
  CompFileDate -h | -?

Here
  <filename1> - The name of the first file to be compared.
  <filename2> - The name of the second file to be compared.
  -v          - Causes the program to emit output to the console's standard
                output. If this switch is not specified the program emits no
                output, unless an error is detected when the switch is ignored.
  -h or -?    - Displays a help screen on standard output.

Exit codes are:

  0    - <filename1> is newer than, or has the same date as <filename2>.
  1    - <filename1> is older than <filename2>.
  100  - Unknown error detected.
  101  - An invalid switch was supplied.
  102  - Incorrect number of file names supplied.
  103  - Both file names were the same.
  104  - Date information couldn't be read from one or both files. It is
         possible that a file doesn't exist.


¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
Installation
________________________________________________________________________________

Copy the provided executable file to the required location. No further
installation is required.

You may want to modify the Windows PATH environment variable to include the
location of the program.

To uninstall simply delete the program. They make no changes to the system.


¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
Source Code
________________________________________________________________________________


Source code for much of the program is available from
http://www.delphidabbler.com/compfiledate/download. 

See the file SourceCodeLicenses.txt file provided with the source code download
for licensing information.


¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
Copyright and License
________________________________________________________________________________

See the file License.txt provided with this download for copyright and
licensing information.

The license is also available at
http://www.delphidabbler.com/software/bdiff/license


¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
Change Log
________________________________________________________________________________

The change log is provided in the file ChangeLog.txt provided with this
download.

________________________________________________________________________________
