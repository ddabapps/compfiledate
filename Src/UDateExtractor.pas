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


type

  ///  <summary>Method only record that exposes a method that gets either the
  ///  creation or last-modified date from a file.</summary>
  TDateExtractor = record
  public
    type
      {$SCOPEDENUMS ON}
      ///  <summary>Type of date to be extracted from a file.</summary>
      ///  <remarks>
      ///  <para>- LastModified - get date file was last modified.</para>
      ///  <para>- Created - get date file was created.</para>
      ///  </remarks>
      TDateType = (LastModified, Created);
      {$SCOPEDENUMS OFF}
  public
    ///  <summary>Gets either the creation or last-modified date from a file.
    ///  </summary>
    ///  <param name="FileName">[in] Name of the file to be examined.</param>
    ///  <param name="DateType">[in] Specifies whether the last-modified or
    ///  creation date is to be returned.</param>
    ///  <returns><c>TDateTime</c>. The required file date.</returns>
    class function GetDate(const FileName: string; const DateType: TDateType):
      TDateTime; static;
  end;


implementation


uses
  // Delphi
  System.SysUtils,
  System.RTLConsts,
  System.IOUtils,
  // Project
  UAppException;


resourcestring
  // Error messages
  sFileNameNotFound = 'File "%s" not found';


{ TDateExtractor }

class function TDateExtractor.GetDate(const FileName: string;
  const DateType: TDateType): TDateTime;
begin
  if not TFile.Exists(FileName) then
    raise EApplication.Create(
      sFileNameNotFound, [FileName], EApplication.ErrFileNameNotFound
    );
  case DateType of
    TDateType.LastModified:
      Result := TFile.GetLastWriteTime(FileName);
    TDateType.Created:
      Result := TFile.GetCreationTime(FileName);
  else
    raise Exception.Create('Invalid TDateExtractor.TDateType value');
  end;
end;

end.

