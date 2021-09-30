{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at https://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2009-2014, Peter Johnson (https://delphidabbler.com).
 *
 * Main project file.
}


program CompFileDate;

{$APPTYPE CONSOLE}

{$RESOURCE Resources.res}   // general program assets
{$RESOURCE VerInfo.res}     // version information

uses
  SysUtils,
  UAppException in 'UAppException.pas',
  UConsole in 'UConsole.pas',
  UMain in 'UMain.pas',
  UParams in 'UParams.pas',
  UStdOutput in 'UStdOutput.pas',
  UDateComparer in 'UDateComparer.pas',
  UDateExtractor in 'UDateExtractor.pas',
  UFileInfo in 'UFileInfo.pas';

begin
  with TMain.Create do
    try
      Execute;
    finally
      Free;
    end;
end.

