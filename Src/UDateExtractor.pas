{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at https://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2014-2021, Peter Johnson (gravatar.com/delphidabbler).
 *
 * Static class that extracts a supported file date from a file.
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

  TDateExtractor = class
  public
    constructor Create;
    class function GetDate(const FileName: string; const DateType: TDateType):
      TDateTime;
  end;


implementation


uses
  // Delphi
  SysUtils, RTLConsts,
  // Project
  UAppException;

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
      sAppErrFileNameNotFound, [FileName], cAppErrFileNameNotFound
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
