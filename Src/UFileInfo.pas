{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at https://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2014-2026, Peter Johnson (gravatar.com/delphidabbler).
 *
 * Implements advanced record that stores information about a file and resolves
 * file shortcuts if required.
}


unit UFileInfo;


interface


uses
  // Delphi
  WinApi.ShlObj;


type
  ///  <summary>Advanced record that gets information about a file.</summary>
  ///  <remarks>*** This class depends on Windows specific code. ***</remarks>
  TFileInfo = record
  strict private
    var
      // Value of FileName property
      fFileName: string;
      // Value of ResolveShortcuts propery
      fResolveShortcuts: Boolean;
    ///  <summary>Returns the fully resolved name of the file associated with
    ///  the object.</summary>
    ///  <remarks>For normal files, the name itself is returned. For shell links
    ///  either the name itself or the name of the referenced file is returned,
    ///  depending on the value of the <c>ResolveShortcuts</c> property.
    ///  </remarks>
    function GetResolvedFileName: string;
    ///  <summary>Attempts to get a reference to any shell link object
    ///  associated with a file name.</summary>
    ///  <param name="LinkFileName">[in] Name of file for which shell link
    ///  object is requested.</param>
    ///  <returns><c>IShellLink</c>. Reference to a shell link object associated
    ///  with <c>LinkFileName</c> or <c>nil</c> if <c>LinkFileName</c> is not
    ///  a link file, or if an error occurs.</returns>
    ///  <remarks>*** This is a Windows specific method ***</remarks>
    class function LoadShellLink(const LinkFileName: string): IShellLink;
      static;
    ///  <summary>Attempts to get the name of a file referenced by a shell link.
    ///  </summary>
    ///  <param name="LinkFileName">[in] Name of condidate link file.</param>
    ///  <param name="TargetFileName">[out] Name of linked file if
    ///  <c>LinkFileName</c> is a valid shell link file. Undefined if
    ///  <c>LinkFileName</c> is not a shell link.</param>
    ///  <returns><c>Boolean</c>. <c>True</c> if <c>LinkFileName</c> is a shell
    ///  link file, <c>False</c> otherwise.</c>
    ///  <remarks>*** This is a Windows specific method ***</remarks>
    class function TryFileFromShellLink(const LinkFileName: string;
      out TargetFileName: string): Boolean; static;
  public
    ///  <summary>Object constructor.</summary>
    ///  <param name="FileName">[in] Name of the file on which to operate.
    ///  </param>
    ///  <param name="ResolveShortcuts">[in] Specifies whether or not the name
    ///  of a file associated with shortcut files should be resolved.</param>
    constructor Create(const FileName: string; const ResolveShortcuts: Boolean);
    ///  <summary>The name of the file for which information is required.
    ///  </summary>
    property FileName: string read fFileName;
    ///  <summary>Specifies whether shortcut files should be resolved.
    ///  </summary>
    property ResolveShortcuts: Boolean read fResolveShortcuts;
    ///  <summary>Same as <c>FileName</c> unless <c>FileName</c> is a shortcut
    ///  file and <c>ResolveShortcuts</c> is <c>True</c> when this property
    ///  stores the name of the file referenced by <c>FileName</c>.</summary>
    property ResolvedFileName: string read GetResolvedFileName;
  end;


implementation


uses
  // Delphi
  System.SysUtils,
  WinApi.ActiveX,
  WinApi.Windows;


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

class function TFileInfo.TryFileFromShellLink(const LinkFileName: string;
  out TargetFileName: string): Boolean;
begin
  // Assume can't get name of file
  Result := False;
  // Try to get interface to shell link: fails if file is not shell link
  var SL: IShellLink := LoadShellLink(LinkFileName);
  if not Assigned(SL) then
    Exit;
  // Get file path from link object and exit if this fails
  var ResolvedFileBuf: array[0..MAX_PATH] of Char;  // receives target file name
  var FindData: TWin32FindData; // dummy required for IShellLink.GetPath call
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

