# Changelog

This is the change log for _DelphiDabbler CompFileDate_.

All notable changes to this project are documented in this file.

This change log begins with the first public release version of _CompFileDate_. Releases are listed in reverse version number order.

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
