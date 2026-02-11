# Changelog

This is the change log for _DelphiDabbler CompFileDate_.

All notable changes to this project are documented in this file.

This change log begins with the first public release version of _CompFileDate_. Releases are listed in reverse version number order.

## Release v2.5.0 of 11 February

* Added support for comparing last access dates of the files being compared [[issue #37](https://github.com/ddabapps/compfiledate/issues/37)].
* Added support to the Linux build for comparing last status change events of file instead of creation dates, which Linux doesn't support. This option is not supported on Windows. Passing the `c`,  `created` or `creation` values to the `-d` / `--datetype` command on Linux results in a warning being issued and the last status change date being used instead [[issue #39](https://github.com/ddabapps/compfiledate/issues/39) & [issue #41](https://github.com/ddabapps/compfiledate/issues/41)].
* Added further aliases for the `-d` / `--datatype` command values [[issue #41](https://github.com/ddabapps/compfiledate/issues/41)]. New creation date aliases, beyond those noted above, are not supported on Linux.
* Added further aliases for the `-c` / `--compare` command values including arithmetic comparision operator symbols [[issue #42](https://github.com/ddabapps/compfiledate/issues/42)].
* Updated the help screen re the changes in this release. Note that the help screen now differs between Windows and Linux builds.
* Refactored code that checks for parameter values.
* Updated the `Docs/ReadMe.txt` usage section re the changes in this release.

## Release v2.4.0 of 5 February 2026

* Added 64 bit Linux support [[issue #28](https://github.com/ddabapps/compfiledate/issues/28)]. The Linux version works identically to the Windows versions except that the `--followshortcuts` (`-s`) command is not supported.
* Fixed typos in the program help screen [[issue #29](https://github.com/ddabapps/compfiledate/issues/29)]. Also updated re changes relating to the Linux release.
* Refactored code:
    * Extracted Windows specific code into a separate unit that is not compiled into the Linux build.
    * Change some static classes into records with methods [[issue #36](https://github.com/ddabapps/compfiledate/issues/36)].
* Archive files containing releases are now available in tar/gzip format in addition to zip format [[issue #35](https://github.com/ddabapps/compfiledate/issues/35)].
* Deploy script, `Deploy.bat`, was updated:
    * Fixed potential path errors that could occur if any path contains spaces [[issue #32](https://github.com/ddabapps/compfiledate/issues/32)].
    * Heavily revised to support generation of Linux releases.
    * Revised to generate tar/gzip release archive files [[issue #35](https://github.com/ddabapps/compfiledate/issues/35)].
    * Rationalised the use of environment variables [[issue #34](https://github.com/ddabapps/compfiledate/issues/34)].
* Added new helper script (`Tools\MakeAllTargets.bat`) that builds Debug releases for all supported target OSs.
* Added new script that is called as a Delphi build event (`Tools\VerExtractor`) that generates an include file containing the release version number.
* Updated documentation:
    * Read-me files and build documentation were updated re changes in this release.
    * Various corrections and clarifications were made in `Docs\ReadMe.txt` and `Build.txt`.
    * Corrected copyright date in `LICENSE.md` [[issue #30](https://github.com/ddabapps/compfiledate/issues/30)].

## Release v2.3.0 of 31 January 2026

* Error messages are now written to standard error instead of standard output [[issue #13](https://github.com/ddabapps/compfiledate/issues/13)].
* Modified the `--version` / `-V` command line option to so that, in addition to the program version number, information about whether the program was built as either a 32 bit or 64 bit Windows application is displayed [[issue #23](https://github.com/ddabapps/compfiledate/issues/23)].
* Updated the program to compile with Delphi 13 [[issue #22](https://github.com/ddabapps/compfiledate/issues/22)]. 
* Corrected errors in some error messages [[issue #26](https://github.com/ddabapps/compfiledate/issues/26)].
* Refactorings:
    * The source code was refactored and re-arranged, in large part to take advantage of modern compiler features [[issue #17](https://github.com/ddabapps/compfiledate/issues/17)] & [[issue #25](https://github.com/ddabapps/compfiledate/issues/25)].
    * The program release version is no longer hard coded in `VerInfo.vi` but is instead obtained from a new `VERSION` file.
    * Redundant code was removed [[issue #27](https://github.com/ddabapps/compfiledate/issues/27)].
* Updated the `Deploy.bat` release creation script:
    * Fixed a typo that was causing a potential bug [[issue #18](https://github.com/ddabapps/compfiledate/issues/18)].
    * The user no longer has to pass the program version as a parameter when calling `Deploy.bat`. The script now gets the information by reading the `VERSION` file [[issue #21](https://github.com/ddabapps/compfiledate/issues/21)].
* Updated documentation re the changes:
    * Fixed errors in the description of error codes in `Docs/ReadMe.txt` [[issue #24](https://github.com/ddabapps/compfiledate/issues/24)].
    * Source code commenting was changed to use the XMLDoc format [[issue #17](https://github.com/ddabapps/compfiledate/issues/17)].
    * The program's help screen and the help section of `Docs/ReadMe.txt` were updated re the change to writing error messages to standard error.
    * `Build.txt` was updated re the change to using Delphi 13.
    * Updated the URLs of issues in `CHANGELOG.md` to reference the `ddabapps/compfiledate` GitHub repo instead of the old `delphidabbler/compfiledate` repo.

## Release v2.2.0 of 27 August 2024

* Added 64 bit version of the program. [[issue #12](https://github.com/ddabapps/compfiledate/issues/12)]
* Fixed bug where no error code was returned by the program when a file name passed on the command line does not exist. [[issue #14](https://github.com/ddabapps/compfiledate/issues/14)]
* Refactoring: Delphi units are now referenced in source code by fully qualified unit scope names. [[issue #15](https://github.com/ddabapps/compfiledate/issues/15)]
* Changed build process:
    * Updated program to compile with Delphi 12.1. [[issue #11](https://github.com/ddabapps/compfiledate/issues/11)]
    * MSBuild replaces use of Embarcadero Make. `Makefile` and `CompFileDate.cfg` were removed.
    * A new `Deploy.bat` script is now used to create releases.
    * Binaries are now created in the `_build` directory instead of `Build`.
* Documentation updates:
    * `Build.txt` rewritten re new build process.
    * `Docs/ReadMe.txt` and `README.md` were revised re availability of 32 bit and 64 bit versions of the program along with other relevant changes.

## Release v2.1.0 of 30 September 2021

* Replaced error message displayed when no files are provided on command line with a brief help message that prompts the use of the `--help` command. [[issue #6](https://github.com/ddabapps/compfiledate/issues/6)]
* Updated application manifest. [[issue #7](https://github.com/ddabapps/compfiledate/issues/7)]
* Converted change log and license files to markdown format. [[issue #8](https://github.com/ddabapps/compfiledate/issues/8)] and [[issue #9](https://github.com/ddabapps/compfiledate/issues/9)]
* Fixed problem in `Makefile` where it was failing to find `Zip.exe` when not on the system path. [[issue #10](https://github.com/ddabapps/compfiledate/issues/10)]
* Updated many URLs in program and documentation.
* Documentation updated re changes.

## Release v2.0.0 of 20 July 2014

* Operator used in date comparison can now be specified using new --compare or -c commands. This enables user to choose whether date of 1st file is tested to be <, <=, >, >=, <> or = to date of second file. [[issue #1](https://github.com/ddabapps/compfiledate/issues/1)]
* Comparison can now operate on either creation or last modification date of files. This is specified with new --datetype or -d commands. [[issue #2](https://github.com/ddabapps/compfiledate/issues/2)]
* When comparing the dates of shortcut files the date of the shortcut's target file can now be compared by using the new --followshortcuts or -s commands. [[issue #3](https://github.com/ddabapps/compfiledate/issues/3)]
* Program version number can now be displayed using the new --version or -V commands. Version is no longer displayed in normal program output. [[issue #5](https://github.com/ddabapps/compfiledate/issues/5)]
* Long forms of -v and -h commands added: --verbose and --help respectively. [[issue #4](https://github.com/ddabapps/compfiledate/issues/4)]
* Help screen revised re changes.
* Now compiled with Delphi XE.
* Updated and rationalised documentation re changes.

## Release v1.0.1 of 24 March 2014

* Changed to use Unicode strings internally and to convert them to local ANSI encoding before output.
* Fixed typo in help screen.
* Now compiled with Delphi 2010.
* Re-licensed source code and executable program under Mozilla Public License v2.0.
* Updated documentation.

## Release v1.0.0 of 15 July 2009

* Original version (compiled with Delphi 2006).
