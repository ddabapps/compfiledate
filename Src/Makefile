# This Source Code Form is subject to the terms of the Mozilla Public License,
# v. 2.0. If a copy of the MPL was not distributed with this file, You can
# obtain one at http://mozilla.org/MPL/2.0/
#
# Copyright (C) 2009-2014, Peter Johnson (www.delphidabbler.com).
#
# Makefile for the project.


# Usage:
#   Run one of the following Make commands on the same directory as this file:
#     Make config
#       Configures source tree ready for building program.
#     Make
#     Make exe
#       Builds CompFileDate.exe.
#     Make resources
#     Make res
#       Builds the program's resources.
#     Make pascal
#     Make pas
#       Builds exe from pascal files. Requires that resources have already been
#       compiled.
#     Make clean
#     Make tidy
#       Cleans up temporary files and directories.
#     Make release
#       Creates 2 zip files containing executable and source releases. Cleans
#       temporary files before creating zips.
#     Make releaseexe
#       Creates zip file containing executable release.
#     Make releasesrc
#       Creates zip file containing source release. Temporary files are not
#       cleaned.
#     Make everything
#       Builds program and creates release zip files.


# DELPHIROOT must point to the install directory for the version of Delphi being
# used to compile the program. NOTE: The program is targeted at Delphi XE but
# later compilers should be suitable with only minor changes.
!ifndef DELPHIROOT
# DELPHIROOT not set: make a guess
DELPHIROOT = $(MAKEDIR)\..
!endif

# Define macros that access required programs
# DCC32 and BRCC32 should be in same sub-directory of Delphi XE
DCC32 = "$(DELPHIROOT)\Bin\DCC32.exe"
BRCC32 = "$(DELPHIROOT)\Bin\BRCC32.exe"
# VIED is expected to be on the path or its install directory must be specified
# in the VIEDROOT macro.
!ifdef VIEDROOT
VIED = "$(VIEDROOT)\VIEd.exe" -makerc
!else
VIED = "VIEd.exe" -makerc
!endif

# Define macros for paths
RESOUTDIR = ..\Build\Bin

# Default is to build executables
exe: res pascal

# Synonyms
pas: pascal
tidy: clean
res: resources

# Builds everything: compiles program and creates release files
everything: exe release

# Build resources and delete intermediate file created by VIED
resources : Resources.res VerInfo.res
  -@del VerInfo.rc

# Build pascal source and link in resources
pascal: CompFileDate.exe

# Clean up unwanted files etc created by IDE
clean:
  @echo.
  @echo Clean unwanted files
  @echo --------------------
  -@cd ..
  # remove unwanted files: temps (~ or .~*), .dsk, .local, .identcache
  -@del /S *.~* 2>nul
  -@del /S ~* 2>nul
  -@del /S *.dsk 2>nul
  -@del /S *.local 2>nul
  -@del /S *.identcache 2>nul
  # remove __history folders
  -@for /F "usebackq" %i in (`dir /S /B /A:D ..\__history`) do @rmdir /S /Q %i
  -@cd Src
  @echo Done.

# Create executable and source release zip files
release: clean releaseexe releasesrc

# Create release zip file for executable
EXEFILE = Build\Release\dd-compfiledate.zip
releaseexe:
  @echo.
  @echo Release executable
  @echo ------------------
  -@cd ..
  -@if exist $(EXEFILE) del $(EXEFILE)
  @zip -j -9 $(EXEFILE) Build\Exe\CompFileDate.exe
  @zip -j -9 $(EXEFILE) Docs\ReadMe.txt
  @zip -j -9 $(EXEFILE) LICENSE.txt
  @zip -j -9 $(EXEFILE) Docs\changelog.txt
  -@cd Src

# Create release zip file for source
SRCFILE = Build\Release\dd-compfiledate-src.zip
releasesrc:
  @echo.
  @echo Release source code
  @echo -------------------
  -@cd ..
  -@if exist $(SRCFILE) del $(SRCFILE)
  @zip -r -9 $(SRCFILE) Src
  @zip -r -9 $(SRCFILE) Docs
  @zip -j -9 $(SRCFILE) .gitignore
  @zip -j -9 $(SRCFILE) Build.txt
  @zip -j -9 $(SRCFILE) LICENSE.txt
  -@cd Src

# Configure source tree for building
config:
  @echo Configuring
  # Create build folders
  @cd ..
  @if exist Build\Bin rmdir /S /Q Build\Bin
  @if exist Build\Exe rmdir /S /Q Build\Exe
  @if exist Build\Release rmdir /S /Q Build\Release
  @if exist Build rmdir /S /Q Build
  @mkdir Build
  @cd Build
  @mkdir Bin
  @mkdir Exe
  @mkdir Release
  @cd ..\Src

# Implicit rules
# Delphi projects are assumed to contain all required output and search path
# info in project options .cfg file.
.dpr.exe:
  @echo +++ Compiling Delphi Project $< +++
  @$(DCC32) $< -B

# Resource files are compiled to directory specified by RESOUTDIR macro
.rc.res:
  @echo +++ Compiling Resource file $< +++
  @$(BRCC32) $< -fo$(RESOUTDIR)\$(@F)

# Version info files are compiled by VIEd: a temporary .rc file is left behind
.vi.rc:
  @echo +++ Compiling Version Info file $< +++
  @$(VIED) .\$<
