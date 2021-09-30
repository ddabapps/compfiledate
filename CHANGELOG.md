# Changelog

This is the change log for _DelphiDabbler CompFileDate_.

All notable changes to this project are documented in this file.

This change log begins with the first public release version of _CompFileDate_. Releases are listed in reverse version number order.

## Release v2.1.0 of 30 September 2021

* Replaced error message displayed when no files are provided on command line with a brief help message that prompts the use of the `--help` command. [[issue #6](https://github.com/delphidabbler/compfiledate/issues/6)]
* Updated application manifest. [[issue #7](https://github.com/delphidabbler/compfiledate/issues/7)]
* Converted change log and license files to markdown format. [[issue #8](https://github.com/delphidabbler/compfiledate/issues/8)] and [[issue #9](https://github.com/delphidabbler/compfiledate/issues/9)]
* Fixed problem in `Makefile` where it was failing to find `Zip.exe` when not on the system path. [[issue #10](https://github.com/delphidabbler/compfiledate/issues/10)]
* Updated many URLs in program and documentation.
* Documentation updated re changes.

## Release v2.0.0 of 20 July 2014

* Operator used in date comparison can now be specified using new --compare or -c commands. This enables user to choose whether date of 1st file is tested to be <, <=, >, >=, <> or = to date of second file. [[issue #1](https://github.com/delphidabbler/compfiledate/issues/1)]
* Comparison can now operate on either creation or last modification date of files. This is specified with new --datetype or -d commands. [[issue #2](https://github.com/delphidabbler/compfiledate/issues/2)]
* When comparing the dates of shortcut files the date of the shortcut's target file can now be compared by using the new --followshortcuts or -s commands. [[issue #3](https://github.com/delphidabbler/compfiledate/issues/3)]
* Program version number can now be displayed using the new --version or -V commands. Version is no longer displayed in normal program output. [[issue #5](https://github.com/delphidabbler/compfiledate/issues/5)]
* Long forms of -v and -h commands added: --verbose and --help respectively. [[issue #4](https://github.com/delphidabbler/compfiledate/issues/4)]
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
