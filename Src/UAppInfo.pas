{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at https://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2026, Peter Johnson (gravatar.com/delphidabbler).
 *
 * Provides information about the application.
}


unit UAppInfo;

interface

type
  ///  <summary>Method-only advanced record that provides information about the
  ///  application.</summary>
  TAppInfo = record
  public
    ///  <summary>Returns a string that describes the OS platform for which the
    ///  program was compiled.</summary>
    class function OSPlatform: string; static;
    ///  <summary>Returns a string representation of the program's version
    ///  number.</summary>
    class function Version: string; static;
  end;

implementation

{ TAppInfo }

class function TAppInfo.OSPlatform: string;
begin
  // We currently support Windows 32 and 64 bit and Linux 64 bit platforms
  {$IF Defined(WIN32)}
  Result := 'Windows 32 bit';
  {$ELSEIF Defined(WIN64)}
  Result := 'Windows 64 bit';
  {$ELSEIF Defined(LINUX64)}
  Result := 'Linux 64 bit';
  {$ELSE}
  {$Message Fatal 'Unsupported platform'}
  {$IFEND}
end;

class function TAppInfo.Version: string;
  {$Include AutoGen\VERSION.inc}
  // The above $Include directive includes a file that contains the following:
  //   const VERSION_STRING = '<version-number>';
  // where <version-number> is the version number of the latest release.
  // The .inc file is automatically created during a full build.
begin
  Result := VERSION_STRING;
end;

end.
