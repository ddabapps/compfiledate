{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at https://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2014-2026, Peter Johnson (gravatar.com/delphidabbler).
 *
 * Implements advanced record that stores information about a file.
 *
 * When compiled for Windows any shell link shortcuts are optionally resolved.
 * When compiled for Linux, which doesn't support such shortcuts, the record is
 * simply a wrapper for a file name
 *
}


unit UFileInfo;


interface


type
  ///  <summary>Advanced record that gets information about a file.</summary>
  ///  <remarks>*** This class depends on Windows specific code. ***</remarks>
  TFileInfo = record
  strict private
    var
      // File name operated upon by this record, as passed to constructor.
      fFileName: string;
      // Flag indicating whether shell link shortcuts are to be resolved (when
      // compiled for Windows only).
      fResolveShortcuts: Boolean;
    ///  <summary>Returns the fully resolved name of the file whose name was
    ///  passed to the constructor.</summary>
    ///  <remarks>
    ///  <para>On Windows: for normal files, the name itself is returned. For
    ///  shell links either the name itself or the name of the referenced file
    ///  is returned, depending on the value of <c>fResolveShortcuts</c>.</para>
    ///  <para>On Linux: always returns the unchanged name of the associated
    ///  file.</para>
    ///  </remarks>
    function GetResolvedFileName: string;
  public
    ///  <summary>Object constructor.</summary>
    ///  <param name="FileName">[in] Name of the file on which to operate.
    ///  </param>
    ///  <param name="ResolveShortcuts">[in] Specifies whether or not the name
    ///  of a file associated with shortcut files should be resolved. This
    ///  parameter is ignored when not compiled for Windows targets.</param>
    constructor Create(const FileName: string; const ResolveShortcuts: Boolean);
    ///  <summary>The fully resolved name of the file whose name was passed to
    ///  the constructor.</summary>
    ///  <remarks>
    ///  <para>On Windows: for normal files, the file name itself is returned.
    ///  For shell links either the name itself or the name of the referenced
    ///  file is returned, depending on the value of the <c>ResolveShortcuts</c>
    ///  parameter passed to the constructor.</para>
    ///  <para>On Linux: always returns the unchanged name of the associated
    ///  file.</para>
    ///  </remarks>
    property ResolvedFileName: string read GetResolvedFileName;
  end;


implementation


uses
  // Delphi
  System.SysUtils
  , System.IOUtils
  {$IF Defined(MSWINDOWS)}
  // Project
  , UWinShellLink
  {$ENDIF}
  ;


{ TFileInfo }

constructor TFileInfo.Create(const FileName: string;
  const ResolveShortcuts: Boolean);
begin
  fFileName := FileName;
  fResolveShortcuts := ResolveShortcuts;
end;

function TFileInfo.GetResolvedFileName: string;
begin
  {$IF Defined(MSWINDOWS)}
  if not fResolveShortcuts then
    Exit(fFileName);
  if TPath.GetExtension(fFileName).CompareTo('.lnk') <> 0 then
    Exit(fFileName);
  if not TWinShellLink.TryResolveShortcut(fFileName, Result) then
    Exit(fFileName);
  {$ELSE}
  Result := fFileName;
  {$ENDIF}
end;

end.

