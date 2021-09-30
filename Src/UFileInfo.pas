{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at https://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2014, Peter Johnson (www.delphidabbler.com).
 *
 * Implements advanced record that stores information about a file and resolves
 * file shortcuts if required.
}


unit UFileInfo;

interface

uses
  ShlObj;

type
  TFileInfo = record
  strict private
    var
      fFileName: string;
      fResolveShortcuts: Boolean;
    function GetResolvedFileName: string;
    class function LoadShellLink(const LinkFileName: string): IShellLink;
      static;
    class function TryFileFromShellLink(const LinkFileName: string;
      out TargetFileName: string): Boolean; static;
  public
    constructor Create(const FileName: string; const ResolveShortcuts: Boolean);
    property FileName: string read fFileName;
    property ResolveShortcuts: Boolean read fResolveShortcuts;
    property ResolvedFileName: string read GetResolvedFileName;
  end;

implementation

uses
  SysUtils, ActiveX, Windows;

{ TFileInfo }

constructor TFileInfo.Create(const FileName: string;
  const ResolveShortcuts: Boolean);
begin
  fFileName := FileName;
  fResolveShortcuts := ResolveShortcuts;
end;

function TFileInfo.GetResolvedFileName: string;
begin
  if not ResolveShortcuts then
    Exit(FileName);
  if not AnsiSameStr(ExtractFileExt(FileName), '.lnk') then
    Exit(FileName);
  if not TryFileFromShellLink(FileName, Result) then
    Exit(FileName);
end;

class function TFileInfo.LoadShellLink(const LinkFileName: string): IShellLink;
var
  PF: IPersistFile; // persistent file interface to shell link object
begin
  // Create shell link object
  if Succeeded(
    CoCreateInstance(
      CLSID_ShellLink,
      nil,
      CLSCTX_INPROC_SERVER,
      IShellLink,
      Result
    )
  ) then
  begin
    // Try to load the shell link: succeeds only of file is shell link
    PF := Result as IPersistFile;
    if Failed(
      PF.Load(PWideChar(WideString(LinkFileName)), STGM_READ)
    ) then
      Result := nil;  // this frees the shell link object
  end
  else
    Result := nil;
end;

class function TFileInfo.TryFileFromShellLink(const LinkFileName: string;
  out TargetFileName: string): Boolean;
var
  SL: IShellLink;            // shell link object
  ResolvedFileBuf: array[0..MAX_PATH] of Char;
                             // buffer to receive linked file name
  FindData: TWin32FindData;  // dummy required for IShellLink.GetPath()
begin
  // Assume can't get name of file
  Result := False;
  // Try to get interface to shell link: fails if file is not shell link
  SL := LoadShellLink(LinkFileName);
  if not Assigned(SL) then
    Exit;
  // Get file path from link object and exit if this fails
  if Failed(
    SL.GetPath(ResolvedFileBuf, MAX_PATH, FindData, 0)
  ) then
    Exit;
  // Return file name
  TargetFileName := ResolvedFileBuf;
  Result := True;
end;

initialization

CoInitialize(nil);

finalization

CoUninitialize;

end.
