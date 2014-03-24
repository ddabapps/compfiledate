File Date Comparison Utility
============================

CompFileDate is a simple command line utility for Windows that compares the modification dates of two files whose names are passed on the command line and returns an exit code that informs if the first named file has an earlier modification date than the second file.

Usage
-----

    CompFileDate <filename1> <filename2> [-v]

where `<filename1>` and `<filename2>` are the names of the files to compare. `0` is returned if `<filename1>` is newer than, or has the same date as `<filename2>` and `1` is returned if `<filename1>` is older than `<filename2>`. An error code >= 100 indicates an error: see Docs\ReadMe.txt for details.

Unless there is an error CompFileDate normally produces no output. To get the result of the comparison written to standard output specify the `-v` command.

To get help use:

    CompFileDate -?

Contributions
-------------

It's only a little utility, but any improvements are welcome. Just fork the repo
(the development branch is best), create a feature branch and submit a pull
request with your changes.

License
-------

Licensed under the [Mozilla Public License v2.0](http://www.mozilla.org/MPL/2.0/).