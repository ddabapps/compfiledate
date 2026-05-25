{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at https://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2026, Peter Johnson (gravatar.com/delphidabbler).
 *
 * Implements advanced record that that expands any Windows .lnk shell link file
 * into the file it points to.
 *
 * NOTE:
 *   This unit only provides functionality when compiled for Windows targets.
}


unit UWinShellLink;

interface

{$IF Defined(MSWINDOWS)}

uses
  WinApi.ShlObj;

///  <summary>Checks if a file is a Windows shortcut file.</summary>
///  <param name="ALinkFileName">[in] Name of file to be checked.</param>
///  <returns><c>Boolean</c>. <c>True</c> if <c>ALinkFileName</c> is a shortcut
///  file or <c>False</c> otherwise.</returns>
function IsWinShellLink(const ALinkFileName: string): Boolean;

///  <summary>Calculates and returns the name of the file referenced by a
///  Windows shortcut file.</summary>
///  <param name="ALinkFileName">[in] Name of the shortcut file.</param>
///  <returns><c>string</c>. The name of the file referenced by the shortcut
///  file.</returns>
///  <exception><c>EApplication</c> is raised if an error occurs while
///  dereferencing the shortcut.</exception>
///  <remarks><c>ALinkFileName</c> is expected to be a valid Windows shortcut
///  file, with <c>.lnk</c<.</remarks>
function ResolveWinShellLink(const ALinkFileName: string): string;

{$ENDIF}

implementation

{$IF Defined(MSWINDOWS)}
uses
  System.SysUtils,
  System.IOUtils,
  WinApi.Windows,
  WinApi.ActiveX,
  UAppException;

function LoadShellLink(const ALinkFileName: string): IShellLink;
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
    // Try to load the shell link: succeeds only if the file is a shell link
    var PF := Result as IPersistFile;
    if Failed(
      PF.Load(PWideChar(WideString(ALinkFileName)), STGM_READ)
    ) then
      Result := nil;  // this frees the shell link object
  end
  else
    Result := nil;
end;

function IsWinShellLink(const ALinkFileName: string): Boolean;
begin
  if TPath.GetExtension(ALinkFileName).CompareTo('.lnk') <> 0 then
    Exit(False);
  var ShellLink: IShellLink := LoadShellLink(ALinkFileName);
  Result := Assigned(ShellLink);
end;

function ResolveWinShellLink(const ALinkFileName: string): string;
resourcestring
  sResolveError = 'Can''t resolve shortcut "%s"';
  sTargetError = 'Shortcut file "%s" has no valid target';
begin
  var ShellLink: IShellLink := LoadShellLink(ALinkFileName);
  Assert(Assigned(ShellLink), 'ResolveWinShellLink: Invalid shell link file');
  var ResolvedFileBuf: array[0..MAX_PATH] of Char;  // receives target file name
  var FindData: TWin32FindData; // dummy required for IShellLink.GetPath call
  if Failed(
    ShellLink.GetPath(ResolvedFileBuf, MAX_PATH, FindData, 0)
  ) then
    raise EApplication.Create(
      sResolveError, [ALinkFileName], EApplication.ErrCantResolveShortcut
    );
  // Return file name
  Result := ResolvedFileBuf;
  if Result.IsEmpty then
    raise EApplication.Create(
      sTargetError, [ALinkFileName], EApplication.ErrCantResolveShortcut
    );
end;

initialization

CoInitialize(nil);


finalization

CoUninitialize;

{$ENDIF}

end.
