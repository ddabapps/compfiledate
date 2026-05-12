{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at https://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2014-2026, Peter Johnson (gravatar.com/delphidabbler).
 *
 * Static class that extracts a file date from a file.
}


unit UDateExtractor;


interface

uses
  // Project
  USysDate;


type

  ///  <summary>Method only record that exposes a method that gets either the
  ///  creation, last-accessed or last-modified date from a file.</summary>
  TDateExtractor = record
  public
    type
      {$SCOPEDENUMS ON}
      ///  <summary>Type of date to be extracted from a file.</summary>
      ///  <remarks>
      ///  <para>- LastModified - get date file was last modified.</para>
      ///  <para>- Created - get date file was created (Windows only).</para>
      ///  <para>- StatusChanged - get date when the file's status was was
      ///  changed (Linux only).</para>
      ///  <para>- LastAccessed - get date file was last accessed.</para>
      ///  </remarks>
      TDateType = (
        LastModified,
        {$IF Defined(MSWINDOWS)}
        Created,
        {$ELSEIF Defined(LINUX)}
        StatusChanged,
        {$ENDIF}
        LastAccessed
      );
      {$SCOPEDENUMS OFF}
  public
    ///  <summary>Gets a given type of date from a file.</summary>
    ///  <param name="FileName">[in] Name of the file to be examined.</param>
    ///  <param name="DateType">[in] Specifies type of date is to be returned.
    ///  </param>
    ///  <returns><c>TSysDate</c>. The required file date.</returns>
    class function GetDate(const AFileName: string; const ADateType: TDateType):
      TSysDate; static;

  end;

implementation


uses
  // Delphi
  System.SysUtils,
  System.IOUtils,
  {$IF Defined(MSWINDOWS)}
  WinApi.Windows,
  {$ELSEIF Defined(LINUX)}
  Posix.SysStat,
  {$ENDIF}
  // Project
  UAppException;


resourcestring
  // Error messages
  sFileNameNotFound = 'File "%s" not found';
  sCantReadFileDate = 'Can''t read date information from "%s"';

{ TDateExtractor }

class function TDateExtractor.GetDate(const AFileName: string;
  const ADateType: TDateType): TSysDate;
begin
  if not TFile.Exists(AFileName) then
    raise EApplication.Create(
      sFileNameNotFound, [AFileName], EApplication.ErrFileNameNotFound
    );
  {$IF Defined(MSWINDOWS)}
  var Data: TWin32FindData;
  if not GetFileAttributesEx(
    PChar(AFileName), GetFileExInfoStandard, @Data
  ) then
    raise EApplication.Create(
      sCantReadFileDate, [AFileName], EApplication.ErrCantReadFileDate
    );
  case ADateType of
    TDateType.LastModified:
      Result := TSysDate.Create(Data.ftLastWriteTime);
    TDateType.Created:
      Result := TSysDate.Create(Data.ftCreationTime);
    TDateType.LastAccessed:
      Result := TSysDate.Create(Data.ftLastAccessTime);
  end;
  {$ELSEIF Defined(LINUX)}
  var M: TMarshaller;
  var P := M.AsAnsi(AFileName, CP_UTF8).ToPointer;
  var Data: _stat;
  if lstat(P, Data) <> 0 then
    raise EApplication.Create(
      sCantReadFileDate, [AFileName], EApplication.ErrCantReadFileDate
    );
  case ADateType of
    TDateType.LastModified:
      Result := TSysDate.Create(Data.st_mtime, Data.st_mtimensec);
    TDateType.StatusChanged:
      Result := TSysDate.Create(Data.st_ctime, Data.st_ctimensec);
    TDateType.LastAccessed:
      Result := TSysDate.Create(Data.st_atime, Data.st_atimensec);
  end;
  {$ENDIF}
end;

end.

