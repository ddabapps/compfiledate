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
  {$SCOPEDENUMS ON}
  ///  <summary>Type of date to be extracted from a file.</summary>
  ///  <remarks>
  ///  <para>- LastModified - get date file was last modified.</para>
  ///  <para>- Created - get date file was created.</para>
  ///  </remarks>
  TDateType = (LastModified, Created);
  {$SCOPEDENUMS OFF}

  ///  <summary>Static class that exposes a method that gets either the creation
  ///  or last-modified date from a file.</summary>
  TDateExtractor = class
  public
    ///  <summary>Object constructor that prevents object instances from being
    ///  created.</summary>
    ///  <exception><c>ENoConstructException</c> is always raised if the
    ///  constructor is called.</exception>
    constructor Create;
    ///  <summary>Gets either the creation or last-modified date from a file.
    ///  </summary>
    ///  <param name="FileName">[in] Name of the file to be examined.</param>
    ///  <param name="DateType">[in] Specifies whether the last-modified or
    ///  creation date is to be returned.</param>
    ///  <returns><c>TDateTime</c>. The required file date.</returns>
    class function GetDate(const FileName: string; const DateType: TDateType):
      TDateTime;
  end;


implementation


uses
  // Delphi
  System.SysUtils,
  System.RTLConsts,
  // Project
  UAppException;


resourcestring
  // Error messages
  sFileNameNotFound = 'File "%s" not found';


{ TDateExtractor }

constructor TDateExtractor.Create;
begin
  raise ENoConstructException.CreateFmt(sNoConstruct, [ClassName]);
end;

class function TDateExtractor.GetDate(const FileName: string;
  const DateType: TDateType): TDateTime;
var
  DTI: TDateTimeInfoRec;
begin
  if not FileGetDateTimeInfo(FileName, DTI, False) then
    raise EApplication.Create(
      sFileNameNotFound, [FileName], EApplication.ErrFileNameNotFound
    );
  case DateType of
    TDateType.LastModified:
      Result := DTI.TimeStamp;
    TDateType.Created:
      Result := DTI.CreationTime;
  else
    raise Exception.Create('Invalid TDateType value');
  end;
end;

end.

