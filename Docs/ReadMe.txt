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
  
      =, ==, eq, eql, equal, same

        Checks if the dates of the files are equal.
  
      >, gt, newer, later, after
    
        Checks if the 1st file date is greater than (i.e. later than) the 2nd
        file date.
  
      >=, gte, ge, goe, no-older, not-older, no-earlier, not-earlier, 
      not-before
    
        Checks if the 1st file date is greater than or equal to (i.e. no older
        than) the 2nd file date.
  
      <, lt, older, earlier, before
    
        Checks if the 1st file date is less than (i.e. earlier than) the 2nd
        file date. This is the default used if this option is not provided.
  
      <=, lte, le, loe, no-newer, not-newer, no-later, not-later, not-after
    
        Checks if the 1st file date is less than or equal to (i.e. no newer
        than) the 2nd file date.
  
      <>, !=, ~=, neq, ne, not-equal, not-same, different
    
        Checks if the dates of the files are not equal.

      If <op> contains either a '<' or '>' character then the value must be
      enclosed in double quotes. On Linux single quotes may also be used. For
      example --convert="<=" and -c "<>"
        

  -d <type> or --date-type=<type>
  
    Determines which date property of the files is used in the comparison.
    <type> must be one of the following:
    
      m, modify, modified, last-modified, modification, update, updated,
      last-updated, write, written, last-written
    
        Use the date the files were last modified. This is the default used if
        this option is not provided.
    
      a, accessed, last-accessed, access, read, last-read
    
        Use the date the files were last accessed.
    
      c, create, created, creation
    
        Windows:
          Use the date the files were created.
    
        Linux:
          Invalid. Linux does not support file creation dates. If any of these
          values are used then the program will fail with exit code 108.
    
      s, status, status-change, last-status-change, status-changed, metadata,
      metadata-change, last-metadata-change, metadata-changed
    
        Linux:
          Use the date that the status (metadata) of the files was last updated.
    
        Windows:
          Invalid. Windows files do not support status update dates. If any of
          these values are provided then the program fails with exit code 108.

  -i or --iso-dates

    Specifies that dates should be output in ISO8601 format. If this command
    is not used then dates are output in the correct format for the user's
    current locale.

  -l or --local-time

    Specifies that all file dates relate to the local time zone. If this
    command is not used then file dates are taken to be in UTC.

  -S, -sy or --follow-symlinks

    Indicates that if either filename1 or filename2 is a symlink then the date
    of the target file will be used in comparisons. If neither option is 
    specified then the symlinks are not followed and the date of the symlink 
    file itself is used.

  -s, -sh or --follow-shortcuts
    
    Windows:
      Indicates that if either filename1 or filename2 is a shortcut (.lnk)
      file then the date of the shortcut's target file will be used in
      comparisons. If neither option is specified then shortcuts are not
      followed and the date of the shortcut file itself is used in the
      comparison.
    
    Linux:
      Not supported because Linux does not support the Windows .lnk shortcut
      file format. The program fails with exit code 101 if any of these options
      are specified.

  -ss or --follow-all-links

    Windows:
      Indicates that if either filename1 or filename2 is a shortcut or a symlink
      file then the date of the target file will be used in comparisons. If this
      option is not specified then shortcuts are not followed and the date of
      the shortcut or symlink file itself is used.
    
    Linux:
      Not supported because Linux only supports symlinks and not shortcuts. The
      program fails with exit code 101 if either of these options are specified.

  -v or --verbose
    
    Verbose. Writes output to standard output. No output is written if the
    option is not provided. Output is always written to standard error when an
    error occurs or to standard output when help or the program's version number
    are requested.

  -vv, -x or --extra-verbose

    Extra verbose. Behaves as if -v or --verbose had been specified except
    that file date comparison results are output in more detail.

  -h, -? or --help
    
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
  106 - an invalid comparison type was specified for the -c or --compare option
  108 - an invalid date type was specified for the -d or --date-type option
  109 - date information can't be read from a file
  110 - file attributes can't be read from a file
  111 - failed to resolve a symlink to its target file 
  112 - failed to resolve a shortcut file to its target file*

* Windows only.


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
