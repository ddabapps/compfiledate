DelphiDabbler CompFileDate Readme
=================================


About The Program
-----------------

CompFileDate.exe compares the dates of two files whose names are passed on the
command line and returns an exit code that indicates the result.

The usage is:

  CompFileDate <filename1> <filename2> [options]

or

  CompFileDate -h | -? | --help

where

  <filename1> is the name of the first file to be compared.
  <filename2> is the name of the second file to be compared.

options are:

  -c <op> or --compare=<op>
    Defines the compare operation to use. <op> must be one of the following:
      eq, equal or same:
        Check if the dates of the files are the same.
      gt, newer or later:
        Check if the 1st file date is later than the 2nd file date.
      gte, not-older or not-earlier
        Check if the 1st file date is no earlier than the 2nd file date.
      lt, older or earlier
        Check if the 1st file date is earlier than the 2nd file date (default
        used if this option is not provided).
      lte, not-newer, not-later
        Check if the 1st file date is no later than the 2nd file date.
      neq, not-equal, not-same, different
        Check if the dates of the files are different.

  -d <type> or --datetype=<type>
    Determines whether the last modification or creation dates of the files are
    compared. <type> must be one of the following:
      m, modified, last-modified or modification:
        Use the date the files were last modified (default used if the option is
        not provided).
      c, created or creation:
        Use the date the files were created.

  -s or --followshortcuts
    Indicates that if either filename1 or filename2 is a shortcut file then the
    date of the shortcut's target file will be used in comparisons. If neither
    option is specified then shortcuts are not followed and the date of the
    shortcut file itself is used in the comparison.

  -v or --verbose
    Verbose: writes output to standard output. No output is generated if this
    option is not provided. Errors are always output regardless of this option.

  -h or -? or --help
    Displays a help screen. Any file names and other options are ignored.

The program's exit code is 1 if the comparison is true and 0 if it is false.
If an error occurs then an error code >= 100 is returned and an error message
is written to standard output, regardless of whether the -v or --verbose
commands were used. The error codes are:

  100 - unknown error
  101 - invalid command or option
  102 - incorrect number of files specified (two required)
  103 - both file names are the same
  104 - one or both files cannot be found
  105 - no comparison type was specified for the -c or --compare option
  106 - an invalid comparison type was specified for the -c or --compare option
  107 - no date type was specified for the -t or --datetype option
  108 - an invalid date type was specified for the -t or --datetype option


Installation
------------

Copy the provided executable file to the required location. No further
installation is required.

You may want to modify the Windows PATH environment variable to include the
location of the program.

To uninstall simply delete the program. It makes no changes to the system.


Source Code
-----------

The program's source code is available on GitHub. See delphidabbler/compfiledate
at https://github.com/delphidabbler/compfiledate


Copyright and License
---------------------

See the file `LICENSE.txt` provided with this download for copyright and
licensing information.


Change Log
----------

The change log is provided in the file `ChangeLog.txt` provided with this
download.


Web page
--------

The program has a web page at http://www.delphidabbler.com/software/compfiledate
