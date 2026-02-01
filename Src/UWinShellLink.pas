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

type
  ///  <summary>Advanced method only record that expands any Windows .lnk shell
  ///  link file into the file it points to.</summary>
  ///  <remarks>*** Use when compiling for Windows only.***</remarks>
  TWinShellLink = record
  strict private
    ///  <summary>Attempts to get a reference to any shell link object
    ///  associated with a file name.</summary>
    ///  <param name="LinkFileName">[in] Name of file for which shell link
    ///  object is requested.</param>
    ///  <returns><c>IShellLink</c>. Reference to a shell link object associated
    ///  with <c>LinkFileName</c> or <c>nil</c> if <c>LinkFileName</c> is not
    ///  a link file, or if an error occurs.</returns>
    class function LoadShellLink(const LinkFileName: string): IShellLink;
      static;
    ///  <summary>Attempts to get the name of a file referenced by the given
    ///  shell link object.</summary>
    ///  <param name="SL">[in] Shell link object for which the referenced file
    ///  name is required.</param>
    ///  <param name="TargetFileName">[out] Name of linked file if <c>SL</c>
    ///  references a valid file. Undefined if <c>SL</c> does not reference such
    ///  a file.</param>
    ///  <returns><c>Boolean</c>. <c>True</c> if <c>SH</c> represents a shell
    ///  link file, <c>False</c> otherwise.</c>
    class function TryFileFromShellLink(const SL: IShellLink;
      out TargetFileName: string): Boolean; static;
  public
    ///  <summary>Attempts to get the name of a file referenced by a shell link
    ///  file.</summary>
    ///  <param name="LinkFileName">[in] Name of condidate link file.</param>
    ///  <param name="TargetFileName">[out] Name of linked file if
    ///  <c>LinkFileName</c> is a valid shell link file. Undefined if
    ///  <c>LinkFileName</c> is not a shell link file.</param>
    ///  <returns><c>Boolean</c>. <c>True</c> if <c>LinkFileName</c> is a shell
    ///  link file, <c>False</c> otherwise.</c>
    class function TryResolveShortcut(const LinkFileName: string;
      out TargetFileName: string): Boolean; static;
  end;
{$ENDIF}

implementation

{$IF Defined(MSWINDOWS)}
uses
  WinApi.Windows,
  WinApi.ActiveX;

{ TWinShellLink }

class function TWinShellLink.LoadShellLink(const LinkFileName: string):
  IShellLink;
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
      PF.Load(PWideChar(WideString(LinkFileName)), STGM_READ)
    ) then
      Result := nil;  // this frees the shell link object
  end
  else
    Result := nil;
end;

class function TWinShellLink.TryFileFromShellLink(const SL: IShellLink;
  out TargetFileName: string): Boolean;
begin
  // Get file path from link object and exit if this fails
  var ResolvedFileBuf: array[0..MAX_PATH] of Char;  // receives target file name
  var FindData: TWin32FindData; // dummy required for IShellLink.GetPath call
  if Failed(
    SL.GetPath(ResolvedFileBuf, MAX_PATH, FindData, 0)
  ) then
    Exit(False);
  // Return file name
  TargetFileName := ResolvedFileBuf;
  Result := True;
end;

class function TWinShellLink.TryResolveShortcut(const LinkFileName: string;
  out TargetFileName: string): Boolean;
begin
  // Try to get interface to shell link: fails if file is not shell link
  var SL: IShellLink := LoadShellLink(LinkFileName);
  if not Assigned(SL) then
    Exit(False);
  if not TryFileFromShellLink(SL, TargetFileName) then
    Exit(False);
  Result := True;
end;


initialization

CoInitialize(nil);


finalization

CoUninitialize;

{$ENDIF}

end.
