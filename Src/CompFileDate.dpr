{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at https://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2009-2026, Peter Johnson (https://delphidabbler.com).
 *
 * Main project file.
}


program CompFileDate;

{$APPTYPE CONSOLE}

{$RESOURCE Resources.res}   // general program assets
{$RESOURCE VerInfo.res}     // version information

uses
  UAppException in 'UAppException.pas',
  UConsole in 'UConsole.pas',
  UMain in 'UMain.pas',
  UParams in 'UParams.pas',
  UDateComparer in 'UDateComparer.pas',
  UDateExtractor in 'UDateExtractor.pas',
  UAppInfo in 'UAppInfo.pas',
  UWinShellLink in 'UWinShellLink.pas';

begin
  var App := TMain.Create;
  try
    App.Execute;
  finally
    App.Free;
  end;
end.

