DelphiDabbler CompFileDate Readme
=================================


Contents
--------

1. About CompFileDate
2. Installation
3. Program Usage
4. Source Code
5. Copyright and License
6. Change Log
7. Web page


1. About CompFileDate
---------------------

CompFileDate is a console application that compares the dates of two files whose
names are passed on the command line. The result of the comparison is given by
the program's exit code.

Versions of the program are available for Windows and Linux.

For Windows the program is available in 64 and 32 bit versions. Users of 64 bit
Windows SHOULD use the 64 bit version but the 32 bit version will work. 32 bit
Windows users MUST use the 32 bit version.

Only 64 bit Linux is supported.


2. Download & Installation
--------------------------

CompFileDate can be downloaded from
https://github.com/ddabapps/compfiledate/releases. You should always download
the latest version.

All downloads are compressed archives that contain the CompFileDate executable
along with some documentation files. There are separate archives for each
target operating system. All archive files are available in both zip and
tar/gzip format.

Make sure you download the correct file for your operating system. Files names
have the following format:

    CompFileDate-<os>-<version>.<ext>

where

    <os>
      Specifies the operating system. It will be "linux64", "win32" or "win64".
    <version>
      The release version number, for example "2.4.0".
    <ext>
      The archive file type. This will either be "zip" or "tar.gz"

Extract the files from the archive then copy the provided executable file
to the directory from which you wish to execute it. There is no installation
program. For Windows the executable is named CompFileDate.exe and for Linux it
is CompFileDate.

On Windows no further installation is required.

On Linux you need make the program executable using the Bash command:

    chmod u+x CompFileDate

To uninstall simply delete the program.

CompFileDate makes no changes to your system.


3. Program Usage
----------------

The usage is:

  CompFileDate <filename1> <filename2> [options]
    or
  CompFileDate -h | -? | --help
    or
  CompFileDate -V | --version

where

  <filename1> is the name of the first file to be compared.
  <filename2> is the name of the second file to be compared.

options are:

  -c <op> or --compare=<op>
    Defines the compare operation to use. <op> must be one of the following:
      eq, equal, same:
        Checks if the dates of the files are equal.
      gt, newer, later:
        Checks if the 1st file date is greater than (i.e. later than) the 2nd
        file date.
      gte, not-older, not-earlier
        Checks if the 1st file date is greater than or equal to (i.e. no older
        than) the 2nd file date.
      lt, older, earlier
        Checks if the 1st file date is less than (i.e. earlier than) the 2nd
        file date. This is the default used if this option is not provided.
      lte, not-newer, not-later
        Checks if the 1st file date is less than or equal to (i.e. no newer
        than) the 2nd file date.
      neq, not-equal, not-same, different
        Checks if the dates of the files are not equal.

  -d <type> or --datetype=<type>
    Determines whether the last modification or creation dates of the files are
    compared. <type> must be one of the following:
      m, modified, last-modified, modification:
        Use the date the files were last modified. This is the default used if
        this option is not provided.
      c, created, creation:
        Use the date the files were created.

  -s or --followshortcuts
    Windows:
      Indicates that if either filename1 or filename2 is a shortcut (.lnk)
      file then the date of the shortcut's target file will be used in
      comparisons. If neither option is specified then shortcuts are not
      followed and the date of the shortcut file itself is used in the
      comparison.
    Linux:
      Not supported because Linux does not support the Windows .lnk shortcut
      file format. The program fails with exit code 101 if either of the options
      is specified.

  -v or --verbose
    Verbose: writes output to standard output. No output is written if the
    option is not provided. Output is always written to standard error when an
    error occurs or to standard output when help or the program's version number
    are requested.

  -h or -? or --help
    Displays a help screen on standard output and halts. Any file names and
    other options are ignored.

  -V or --version.
    Displays the program's version number and platform on standard output and
    halts. Any file names and other options are ignored.

If no file names are provided on the command line and neither the help nor
version commands are specified then a brief help message is displayed.

File names are case sensitive on Linux and case insensitive on Windows.

The program's exit code is 1 if the comparison is true and 0 if it is false.
If an error occurs then an error code >= 100 is returned and an error message
is written to standard error. The error codes are:

  100 - unknown error
  101 - invalid command or option
  102 - incorrect number of files specified (two required)
  103 - both file names are the same
  104 - one or both files cannot be found
  105 - no comparison type was specified for the -c or --compare option
  106 - an invalid comparison type was specified for the -c or --compare option
  107 - no date type was specified for the -d or --datetype option
  108 - an invalid date type was specified for the -d or --datetype option


4. Source Code
--------------

The program's source code is available on GitHub. See ddabapps/compfiledate
at https://github.com/ddabapps/compfiledate


5. Copyright and License
------------------------

See the file `LICENSE.md` provided with the download for copyright and
licensing information.


6. Change Log
-------------

The change log is provided in the file `CHANGELOG.md` provided with the
download.


7. Web page
-----------

The program has a web page at https://delphidabbler.com/software/compfiledate
