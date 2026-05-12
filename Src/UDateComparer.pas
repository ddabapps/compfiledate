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


uses
  // Project
  USysDate;


type
  ///  <summary>Method only record that exposes a method that performs date
  ///  comparisons for all supported date comparison operations.</summary>
  TDateComparer = record
  public
    type
      {$SCOPEDENUMS ON}
      ///  <summary>Type of comparison operator to be used when comparing two
      ///  dates.</summary>
      ///  <remarks>
      ///  <para>Assuming dates Left and Right, the values are as follows:
      ///  </para>
      ///  <para>- <c>EQ</c>: check if the dates are equal.</para>
      ///  <para>- <c>LT</c>: check if Left is less than Right.</para>
      ///  <para>- <c>GT</c>: check if Left is greater than Right.</para>
      ///  <para>- <c>LTE</c>: check if Left is less than or equal to Right.
      ///  </para>
      ///  <para>- <c>GTE</c>: check if Left is greater than or equal to Right.
      ///  </para>
      ///  <para>- <c>NEQ</c>: check if the dates are not equal.</para>
      ///  </remarks>
      TOp = (EQ, LT, GT, LTE, GTE, NEQ);
      {$SCOPEDENUMS OFF}
  strict private
    type
      ///  <summary>Type of functions used to compare two <c>TDateTime</c>
      ///  values.</summary>
      TCompareFn = reference to function(const Left, Right: TSysDate): Boolean;
      ///  <summary>Type of array that maps each <c>TOp</c> value to a function
      ///  that implements the required comparison.</summary>
      TComparerMap = array[TOp] of TCompareFn;
    class var
      ///  <summary>Map of <c>TOp</c> values to their related comparison
      ///  functions.</summary>
      fMap: TComparerMap;
  public
    ///  <summary>Class constructor. Intialises the map of comparison types to
    ///  the implementing functions.</summary>
    class constructor Create;
    ///  <summary>Compares two <c>TSysDate</c> values using a given operator.
    ///  </summary>
    ///  <param name="Left">[in] Left hand operand.</param>
    ///  <param name="Right">[in] Right hand operand.</param>
    ///  <param name="Operation">[in] Boolean comparison operator applied to the
    ///  operands.</param>
    ///  <returns><c>Boolean</c>. The return value of applying <c>Operation</c>
    ///  to the operands.</returns>
    class function Compare(const Left, Right: TSysDate; const Operation: TOp):
      Boolean; static;
  end;


implementation


{ TDateComparer }

class function TDateComparer.Compare(const Left, Right: TSysDate;
  const Operation: TOp): Boolean;
begin
  Result := fMap[Operation](Left, Right);
end;

class constructor TDateComparer.Create;
begin
  fMap[TOp.EQ] := function (const Left, Right: TSysDate): Boolean
    begin
      Result := Left = Right;
    end;
  fMap[TOp.LT] := function (const Left, Right: TSysDate): Boolean
    begin
      Result := Left < Right;
    end;
  fMap[TOp.GT] := function (const Left, Right: TSysDate): Boolean
    begin
      Result := Left > Right;
    end;
  fMap[TOp.LTE] := function (const Left, Right: TSysDate): Boolean
    begin
      Result := Left <= Right;
    end;
  fMap[TOp.GTE] := function (const Left, Right: TSysDate): Boolean
    begin
      Result := Left >= Right;
    end;
  fMap[TOp.NEQ] := function (const Left, Right: TSysDate): Boolean
    begin
      Result := Left <> Right;
    end;
end;

end.

