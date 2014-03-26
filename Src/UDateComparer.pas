{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2014, Peter Johnson (www.delphidabbler.com).
 *
 * Static class for comparing dates using various equality operators.
}


unit UDateComparer;


interface


type
  {$SCOPEDENUMS ON}
  ///  <summary>Type of comparison operator to be used when comparing two dates.
  ///  </summary>
  ///  <remarks>
  ///  <para>- EQ: check if both dates are equal.</para>
  ///  <para>- LT: check if date1 is less than date2.</para>
  ///  <para>- GT: check if date1 is greater than date2.</para>
  ///  <para>- LTE: check if date1 is less than or equal to date2.</para>
  ///  <para>- GTE: check if date1 is greater than or equal to date2.</para>
  ///  </remarks>
  TDateComparisonOp = (EQ, LT, GT, LTE, GTE);
  {$SCOPEDENUMS OFF}

  ///  <summary>
  TDateComparer = class
  strict private
    type
      TCompareFn = reference to function(const Left, Right: TDateTime): Boolean;
      TComparerMap = array[TDateComparisonOp] of TCompareFn;
    class var
      fMap: TComparerMap;
  public
    class constructor Create;
    constructor Create;
    class function Compare(const Left, Right: TDateTime;
      const Operation: TDateComparisonOp): Boolean;
  end;


implementation


uses
  // Delphi
  SysUtils, RTLConsts, Types, DateUtils;


{ TDateComparer }

class function TDateComparer.Compare(const Left, Right: TDateTime;
  const Operation: TDateComparisonOp): Boolean;
begin
  Result := fMap[Operation](Left, Right);
end;

class constructor TDateComparer.Create;
begin
  fMap[TDateComparisonOp.EQ] := function (const Left, Right: TDateTime): Boolean
    begin
      Result := CompareDateTime(Left, Right) = EqualsValue;
    end;
  fMap[TDateComparisonOp.LT] := function (const Left, Right: TDateTime): Boolean
    begin
      Result := CompareDateTime(Left, Right) = LessThanValue;
    end;
  fMap[TDateComparisonOp.GT] := function (const Left, Right: TDateTime): Boolean
    begin
      Result := CompareDateTime(Left, Right) = GreaterThanValue;
    end;
  fMap[TDateComparisonOp.LTE] := function (const Left, Right: TDateTime):
    Boolean
    begin
      Result := CompareDateTime(Left, Right) <> GreaterThanValue;
    end;
  fMap[TDateComparisonOp.GTE] := function (const Left, Right: TDateTime):
    Boolean
    begin
      Result := CompareDateTime(Left, Right) <> LessThanValue;
    end;
end;

constructor TDateComparer.Create;
begin
  raise ENoConstructException.CreateFmt(sNoConstruct, [ClassName]);
end;

end.
