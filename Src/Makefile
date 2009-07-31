# ------------------------------------------------------------------------------
# Makefile
#
# Makefile for the project.
#
# $Rev$
# $Date$
#
# Usage:
#   Run one of the following Make commands on the same directory as this file:
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
#
# ***** BEGIN LICENSE BLOCK *****
#
# Version: MPL 1.1/GPL 2.0/LGPL 2.1
#
# The contents of this file are subject to the Mozilla Public License Version
# 1.1 (the "License")# * you may not use this file except in compliance with the
# License. You may obtain a copy of the License at
# http://www.mozilla.org/MPL/MPL-1.1
#
# Software distributed under the License is distributed on an "AS IS" basis,
# WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
# the specific language governing rights and limitations under the License.
#
# The Original Code is Build.bat from the CompFileDate project.
#
# The Initial Developer of the Original Code is Peter Johnson
# (http://www.delphidabbler.com/).
#
# Portions created by the Initial Developer are Copyright (C) 2009 by the
# Initial Developer. All Rights Reserved.
#
# Contributors:
#    None.
#
# Alternatively, the contents of this file may be used under the terms of either
# the GNU General Public License Version 2 or later (the "GPL"), or the GNU
# Lesser General Public License Version 2.1 or later (the "LGPL"), in which case
# the provisions of the GPL or the LGPL are applicable instead of those above.
# If you wish to allow use of your version of this file only under the terms of
# either the GPL or the LGPL, and not to allow others to use your version of
# this file under the terms of the MPL, indicate your decision by deleting the
# provisions above and replace them with the notice and other provisions
# required by the LGPL or the GPL. If you do not delete the provisions above, a
# recipient may use your version of this file under the terms of any one of the
# MPL, the GPL or the LGPL.
# ------------------------------------------------------------------------------


# DELPHIROOT must point to the install directory for Delphi 2006. The preferred
# option is for user to define this in the DELPHI2006 environment variable or to
# directly define DELPHIROOT. If neither DELPHIROOT nor DELPHI2006 is defined
# the directory is calculated from Make's directory. In this latter case it is
# important to ensure it is the Delphi 2006 version of Make that is used.
!ifndef DELPHIROOT
!ifdef DELPHI2006
DELPHIROOT = $(DELPHI2006)
!else
DELPHIROOT = $(MAKEDIR)\..
!endif
!endif

# Define macros that access required programs
# DCC32 and BRCC32 should be in same sub-directory of Delphi 2006
DCC32 = "$(DELPHIROOT)\Bin\DCC32.exe"
BRCC32 = "$(DELPHIROOT)\Bin\BRCC32.exe"
# VIED is expected to be on the path or its install directory must be specified
# in the VIEDINST macro.
!ifdef VIEDINST
VIED = "$(VIEDINST)\VIEd.exe" -makerc
!else
VIED = "VIEd.exe" -makerc
!endif

# Define macros for paths
BIN = ..\Bin

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
  -@del *.~* /S 2>nul
  -@rd /Q /S Doc\__history 2>nul
  -@rd /Q /S Src\__history 2>nul
  -@rd /Q /S Src\Assets\__history 2>nul
  -@cd Src
  @echo Done.
  
# Create executable and source released zip files
release: clean releaseexe releasesrc

# Create release zip file for executable
EXEFILE = Release\dd-compfiledate.zip
releaseexe:
  @echo.
  @echo Release executable
  @echo ------------------
  -@cd ..
  -@if exist $(EXEFILE) del $(EXEFILE)
  @zip -j -9 $(EXEFILE) Exe\CompFileDate.exe
  @zip -j -9 $(EXEFILE) Docs\ReadMe.txt
  @zip -j -9 $(EXEFILE) Docs\License.txt
  @zip -j -9 $(EXEFILE) Docs\changelog.txt
  -@cd Src

# Create release zip file for source
SRCFILE = Release\dd-compfiledate-src.zip
releasesrc:
  @echo.
  @echo Release source code
  @echo -------------------
  -@cd ..
  -@if exist $(SRCFILE) del $(SRCFILE)
  @zip -r -9 $(SRCFILE) Src
  @zip $(SRCFILE) -d Src\CompFileDate.dsk
  @zip -r -9 $(SRCFILE) Bin\*.res
  @zip -j -9 $(SRCFILE) Docs\ReadMe-Src.txt
  @zip -j -9 $(SRCFILE) Docs\SourceCodeLicenses.txt
  @zip -j -9 $(SRCFILE) Docs\MPL.txt

# Implicit rules
# Delphi projects are assumed to contain all required output and search path
# info in project options .cfg file.
.dpr.exe:
  @echo +++ Compiling Delphi Project $< +++
  @$(DCC32) $< -B

# Resource files are compiled to directory specified by BIN macro, which must
# have been set by caller
.rc.res:
  @echo +++ Compiling Resource file $< +++
  @$(BRCC32) $< -fo$(BIN)\$(@F)

# Version info filea are compiled by VIEd: a temporary .rc file is left behind
.vi.rc:
  @echo +++ Compiling Version Info file $< +++
  @$(VIED) $<
