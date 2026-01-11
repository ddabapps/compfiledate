{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at https://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2014-2026, Peter Johnson (gravatar.com/delphidabbler).
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
  ///  <para>Assuming dates Left and Right, the values are as follows:</para>
  ///  <para>- EQ: check if the dates are equal.</para>
  ///  <para>- LT: check if Left is less than Right.</para>
  ///  <para>- GT: check if Left is greater than Right.</para>
  ///  <para>- LTE: check if Left is less than or equal to Right.</para>
  ///  <para>- GTE: check if Left is greater than or equal to Right.</para>
  ///  <para>- NEQ: check if the dates are not equal.</para>
  ///  </remarks>
  TDateComparisonOp = (EQ, LT, GT, LTE, GTE, NEQ);
  {$SCOPEDENUMS OFF}

  ///  <summary>Static class that exposes a method that performs date
  ///  comparisons for all <c>TDateComparisonOp</c> values.</summary>
  TDateComparer = class
  strict private
    type
      ///  <summary>Type of functions used to compare two <c>TDateTime</c>
      ///  values.</summary>
      TCompareFn = reference to function(const Left, Right: TDateTime): Boolean;
      ///  <summary>Type of array that maps each <c>TDateComparisonOp</c> value
      ///  to a function that implements the required comparison.</summary>
      TComparerMap = array[TDateComparisonOp] of TCompareFn;
    class var
      ///  <summary>Map of <c>TDateComparisonOp</c> values to their related
      ///  comparison functions.</summary>
      fMap: TComparerMap;
  public
    ///  <summary>Class constructor. Intialises the map of comparison types to
    ///  the implementing functions.</summary>
    class constructor Create;
    ///  <summary>Object constructor that prevents object instances from being
    ///  created.</summary>
    ///  <exception><c>ENoConstructException</c> is always raised if the
    ///  constructor is called.</exception>
    constructor Create;
    ///  <summary>Compares two <c>TDataTime</c> values using a given operator.
    ///  </summary>
    ///  <param name="Left">[in] Left hand operand.</param>
    ///  <param name="Right">[in] Right hand operand.</param>
    ///  <param name="Operation">[in] Boolean comparison operator applied to the
    ///  operands.</param>
    ///  <returns><c>Boolean</c>. The return value of applying <c>Operation</c>
    ///  to the operands.</returns>
    class function Compare(const Left, Right: TDateTime;
      const Operation: TDateComparisonOp): Boolean;
  end;


implementation


uses
  // Delphi
  System.SysUtils,
  System.RTLConsts,
  System.Types,
  System.DateUtils;


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
  fMap[TDateComparisonOp.NEQ] := function (const Left, Right: TDateTime):
    Boolean
    begin
      Result := CompareDateTime(Left, Right) <> EqualsValue;
    end;
end;

constructor TDateComparer.Create;
begin
  raise ENoConstructException.CreateFmt(sNoConstruct, [ClassName]);
end;

end.

