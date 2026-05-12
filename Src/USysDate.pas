{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at https://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2026, Peter Johnson (gravatar.com/delphidabbler).
 *
 * Maintains and formats a date to the maximum level of granularity for the
 * underlying OSs file dates.
}


unit USysDate;

interface

uses
  // Delphi
  System.Types
  {$IF Defined(MSWINDOWS)}
  , WinApi.Windows
  {$ENDIF MSWINDOWS}
  {$IF Defined(LINUX)}
  , Posix.SysTypes
  , Posix.Time
  {$ENDIF LINUX}
  ;

type

  ///  <summary>Record with methods that manipulate dates as accurately as
  ///  possible for file date on the underlying OS.</summary>
  ///  <remarks>
  ///  <para>On Windows file dates are recorded with an 100ns.</para>
  ///  <para>On Linux file dates are recorded with an accuracy of 1ns.</para>
  TSysDate = record
  strict private
    const
      {$IF Defined(MSWINDOWS)}
      // Windows FILETIME related constants
      FILETIME_TICKS_PER_SECOND = 10_000_000;     // 100 ns ticks
      FILETIME_TICKS_PER_DAY = 864_000_000_000.0; // 100 ns ticks
      FILETIME_EPOCH_TO_DELPHI_DAYS = 109_205.0;  // 1601-01-01 -> 1899-12-30
      {$ENDIF MSWINDOWS}

      {$IF Defined(LINUX)}
      // Linux timespec related constants
      NANO_SECONDS_PER_SECOND = 1_000_000_000;
      UNIX_EPOCH_TO_DELPHI_DAYS = 25_569.0; // 1970-01-01 -> 1899-12-30
      SECONDS_PER_DAY = 86_400.0;
      {$ENDIF LINUX}

    type
      // Placeholder type for the underlying date type used on either Windows
      // or Linux
      TSysDateType =
        {$IF Defined(MSWINDOWS)}
        // Windows type that records file date with 100ns resolution
        FILETIME;
        {$ELSEIF Defined(LINUX)}
        // Linux type that records file date with 1ns resolution
        timespec;
        {$ENDIF}
  public
    type
      {$SCOPEDENUMS ON}
      ///  <summary>Basis on which dates are reported in UI.</summary>
      ///  <remarks>
      ///  <para>Dates can be reported in various formats but are always stored
      ///  in UTC.</para>
      ///  <para>- <c>UTC</c> - report dates in UTC.</para>
      ///  <para>- <c>Local</c> - report dates user's local time.</para>
      ///  </remarks>
      TDateBasis = (UTC, Local);
      ///  <summary>Types of supported formats used for reporting dates.
      ///  </summary>
      ///  <remarks>
      ///  <para>- <c>ISO8601</c> - ISO 8601 compliant date format.</para>
      ///  <para>- <c>LocaleSpecific</c> - date format as specified by the
      ///  user's locale.</para>
      ///  </remarks>
      TDateFormat = (ISO8601, LocaleSpecific);
      {$SCOPEDENUMS OFF}
  strict private
    const
      // Number of decimal places to which fractional parts of seconds are
      // displayed on Windows and Linux. The numbers are chosen to be able to
      // fully display the maximum resolution for the file dates on each
      // platform.
      {$IF Defined(MSWINDOWS)}
      DateStrDecimalPlaces = 7;
      {$ELSEIF Defined(LINUX)}
      DateStrDecimalPlaces = 9;
      {$ENDIF}
    var
      ///  <summary>The date being operated upon.</summary>
      fDate: TSysDateType;

    ///  <summary>Converts the value of the <c>Date</c> property to a
    ///  <c>TDateTime</c> as accurately as possible.</summary>
    ///  <remarks>This method does not use any RTL functions because they can
    ///  loose accuracy when converting from <c>FILETIME</c> (Windows) or
    ///  <c>timespec</c> (Linux) to <c>TDateTime</c>.</remarks>
    function SysDateToDateTime: TDateTime;
    ///  <summary>Extracts and returns number of nano seconds of the fractional
    ///  number of seconds of the <c>Date</c> as accurately as possible.
    ///  </summary>
    ///  <remarks>The number of nano seconds is rounded to 100ns on Windows.
    ///  </remarks>
    function SysDateToFractionalNanoSeconds: Int64;
    ///  <summary>Renders the number of nano seconds of the fractional number of
    ///  seconds of the <c>Date</c> property as a string in a form that can be
    ///  used as the fractional part of a number of seconds.</summary>
    ///  <remarks>The number of digits of accuracy differs between operating
    ///  systems.</remarks>
    function NanoSecsToFmtStr: string;
  public

    {$IF Defined(MSWINDOWS)}
    ///  <summary>Object constructor used on Windows to set the <c>Date</c>
    ///  property to the date represented by a <c>FILETIME</c> structure.
    ///  </summary>
    constructor Create(const AValue: FILETIME);
    {$ENDIF MSWINDOWS}
    {$IF Defined(LINUX)}
    ///  <summary>Object constructor used on Linux to set the <c>Date</c>
    ///  property to the date represented by given number of seconds and
    ///  nanoseconds.</summary>
    constructor Create(const ASeconds: time_t; ANanoSeconds: Longint);
    {$ENDIF LINUX}

    ///  <summary>Compares two dates and returns an integer representing the
    ///  result of the comparison.</summary>
    ///  <param name="Left">[in] The date on the left hand side of the
    ///  comparison.</param>
    ///  <param name="Right">[in] The date on the right hand side of the
    ///  comparison.</param>
    ///  <returns><c>TValueRelationship</c>. <c>GreaterThanValue</c> if
    ///  <c>Left</c> &gt; <c>Right</c>, <c>LessThanValue</c> if <c>Left</c> &lt;
    ///  <c>Right</c> or <c>EqualsValue</c> if <c>Left</c> = <c>Right</c>.
    ///  </returns>
    class function Compare(const Left, Right: TSysDate): TValueRelationship;
      static;

    /// Comparison operator overloads for two TSysDate values.
    class operator Equal(const Left, Right: TSysDate): Boolean;
    class operator NotEqual(const Left, Right: TSysDate): Boolean;
    class operator GreaterThan(const Left, Right: TSysDate): Boolean;
    class operator GreaterThanOrEqual(const Left, Right: TSysDate): Boolean;
    class operator LessThan(const Left, Right: TSysDate): Boolean;
    class operator LessThanOrEqual(const Left, Right: TSysDate): Boolean;

    ///  <summary>Formats the wrapped date as a string.</summary>
    ///  <param name="AFormatType">[in] The desired string format.</param>
    ///  <param name="ADateBasis">[in] Whether the date is rendered in UTC or
    ///  local time.</param>
    ///  <returns><c>string</c>. The required string representation.</returns>
    function ToString(const AFormatType: TDateFormat;
      const ADateBasis: TDateBasis): string;

  end;


implementation


uses
  // Delphi
  System.SysUtils,
  System.DateUtils,
  System.TimeSpan {for inlining};


{ TSysDate }

{$IF Defined(MSWINDOWS)}
constructor TSysDate.Create(const AValue: FILETIME);
begin
  fDate := AValue;
end;
{$ENDIF MSWINDOWS}

{$IF Defined(LINUX)}
constructor TSysDate.Create(const ASeconds: time_t; ANanoSeconds: Longint);
begin
  fDate.tv_sec := ASeconds;
  fDate.tv_nsec := ANanoSeconds;
end;
{$ENDIF LINUX}

class function TSysDate.Compare(const Left, Right: TSysDate):
  TValueRelationship;
begin
  {$IF Defined(MSWINDOWS)}
  var FTLeft64: UInt64 := (UInt64(Left.fDate.dwHighDateTime) shl 32) or
     UInt64(Left.fDate.dwLowDateTime);
  var FTRight64: UInt64 := (UInt64(Right.fDate.dwHighDateTime) shl 32) or
     UInt64(Right.fDate.dwLowDateTime);
  if FTLeft64 > FTRight64 then
    Result := GreaterThanValue
  else if FTLeft64 < FTRight64 then
    Result := LessThanValue
  else // FTLeft64 = FTRight64
    Result := EqualsValue;
  {$ENDIF MSWINDOWS}
  {$IF Defined(LINUX)}
  {$IF Defined(POSIX)}
  // We're relying on the POSIX implementation of time_t, which guarantees that
  // the value is an integer containing the number of seconds since
  // 1970-01-01 00:00:00 UTC. Since this value is ordered the normal arithmetic
  // comparison operators can be used. Therefore there is no need to call
  // difftime(3).
  if Left.fDate.tv_sec > Right.fDate.tv_sec then
    Result := GreaterThanValue
  else if Left.fDate.tv_sec > Right.fDate.tv_sec then
    Result := LessThanValue
  else
  begin
    if Left.fDate.tv_nsec > Right.fDate.tv_nsec then
      Result := GreaterThanValue
    else if Left.fDate.tv_nsec < Right.fDate.tv_nsec then
      Result := LessThanValue
    else // Left.Date.tv_nsec = Right.Date.tv_nsec
      Result := EqualsValue;
  end;
  {$ELSE}
  {$MESSAGE Fatal 'POSIX compliant Linux is required'}
  {$ENDIF POSIX}
  {$ENDIF LINUX}
end;

class operator TSysDate.Equal(const Left, Right: TSysDate): Boolean;
begin
  Result := Compare(Left, Right) = EqualsValue;
end;

class operator TSysDate.GreaterThan(const Left, Right: TSysDate): Boolean;
begin
  Result := Compare(Left, Right) = GreaterThanValue;
end;

class operator TSysDate.GreaterThanOrEqual(const Left,
  Right: TSysDate): Boolean;
begin
  Result := Compare(Left, Right) <> LessThanValue;
end;

class operator TSysDate.LessThan(const Left, Right: TSysDate): Boolean;
begin
  Result := Compare(Left, Right) = LessThanValue;
end;

class operator TSysDate.LessThanOrEqual(const Left, Right: TSysDate): Boolean;
begin
  Result := Compare(Left, Right) <> GreaterThanValue;
end;

function TSysDate.NanoSecsToFmtStr: string;
begin
  Result := string.Format(
    '%.*d', [DateStrDecimalPlaces, SysDateToFractionalNanoSeconds]
  );
end;

class operator TSysDate.NotEqual(const Left, Right: TSysDate): Boolean;
begin
  Result := Compare(Left, Right) <> EqualsValue;
end;

function TSysDate.SysDateToDateTime: TDateTime;
begin
  //  --- Windows and Linux code is based on ChatGPT generated functions
  {$IF Defined(MSWINDOWS)}
  // Combine high/low parts of FILETIME structure into a 64-bit value
  var FT64: UInt64 := (UInt64(fDate.dwHighDateTime) shl 32)
    or UInt64(fDate.dwLowDateTime);
  // Convert directly to Delphi days (UTC)
  Result := (FT64 / FILETIME_TICKS_PER_DAY)
    - FILETIME_EPOCH_TO_DELPHI_DAYS;
  {$ENDIF MSWINDOWS}
  {$IF Defined(LINUX)}
  Result := UNIX_EPOCH_TO_DELPHI_DAYS
    + (fDate.tv_sec / SECONDS_PER_DAY)
    + (fDate.tv_nsec / NANO_SECONDS_PER_SECOND) / SECONDS_PER_DAY;
  {$ENDIF LINUX}
end;

function TSysDate.SysDateToFractionalNanoSeconds: Int64;
begin
  // --- Windows code is based on a ChatGPT generated function
  {$IF Defined(MSWINDOWS)}
  // Combine high/low parts of FILETIME structure into a 64-bit value
  var FT64: UInt64 := (UInt64(fDate.dwHighDateTime) shl 32) or
     UInt64(fDate.dwLowDateTime);
  // Remainder = fractional part of the second (in 100ns units)
  Result := FT64 mod FILETIME_TICKS_PER_SECOND;
  {$ENDIF MSWINDOWS}
  {$IF Defined(LINUX)}
  Result := fDate.tv_nsec;
  {$ENDIF LINUX}
end;

function TSysDate.ToString(const AFormatType: TDateFormat;
  const ADateBasis: TDateBasis): string;
const
  // Suffixes used when formatting UTC dates in both ISO 8601 and locale
  // specific formats.
  UTCSuffixes: array[TDateFormat] of string = ('Z', ' (UTC)');
  // Date formatting strings used to display time offsets from GMT in both ISO
  // 8601 and locale specific formats.
  TimeOffsetFmtStr = '%s%.2d:%.2d';
  NoneUTCSuffixes: array[TDateFormat] of string = (
    TimeOffsetFmtStr, ' (' + TimeOffsetFmtStr + ')'
  );
  // Date formatting strings used to display dates in whole second accuracy in
  // both ISO 8601 and locale specific formats
  ISO8601DateFmtStr = 'yyyy"-"mm"-"dd"T"hh":"mm":"ss';
  LocaleDateFmtStr = 'yyyy/mm/dd hh:mm:ss';
  DateFmtStrs: array[TDateFormat] of string = (
    ISO8601DateFmtStr, LocaleDateFmtStr
  );
begin
  var Date: TDateTime;
  var Suffix: string;
  case ADateBasis of
    TDateBasis.UTC:
    begin
      // date is returned in UTC format: no conversion is required
      Date := SysDateToDateTime;
      Suffix := UTCSuffixes[AFormatType];
    end;
    TDateBasis.Local:
    begin
      // date is returned in Local time zone: conversion from UTC is required
      Date := TTimeZone.Local.ToLocalTime(SysDateToDateTime);
      var UTCOffset := TTimeZone.Local.GetUtcOffset(SysDateToDateTime);
      Suffix := string.Format(
        NoneUTCSuffixes[AFormatType],
        [
          if UTCOffset.Hours >= 0 then '+' else '-',
          Abs(UTCOffset.Hours),
          UTCOffset.Minutes
        ]
      );
    end;
    else
      raise Exception.Create('Invalid TDateBasis value');
  end;

  Result := FormatDateTime(DateFmtStrs[AFormatType], Date)
    + TFormatSettings.Create.DecimalSeparator
    + NanoSecsToFmtStr
    + Suffix;
end;

end.
