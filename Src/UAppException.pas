{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at https://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2009-2026, Peter Johnson (gravatar.com/delphidabbler).
 *
 * Exception class for application errors. Stores error message and associated
 * error exit code.
}


unit UAppException;


interface


uses
  // Delphi
  System.SysUtils;


resourcestring
  // Error messages
  sAppErrBadSwitch = 'Invalid command "%s"';
  sAppErr2FilesNeeded = 'Exactly two file names must be specified';
  sAppErrFileNamesSame = 'File names must be different';
  sAppErrFileNameNotFound = 'File "%s" not found';
  sAppErrNoCompareType = 'No comparison type specified for -c or --compare '
    + 'command';
  sAppErrBadCompareType = 'Invalid comparison type in -c or --compare command';
  sAppErrNoDateType = 'No date type specified for -t or --datetype command';
  sAppErrBadDateType = 'Invalid date type in -t or --datetype command';


type
  ///  <summary>Application error exception object.</summary>
  ///  <remarks>Contains an error code.</remarks>
  EApplication = class(Exception)
  strict private
    var
      // Value of ExitCode property
      fExitCode: Integer;
  public
    const
      // Error exit codes
      ErrUnknown = 100;
      ErrBadSwitch = 101;
      Err2FilesNeeded = 102;
        ErrFileNamesSame = 103;
      ErrFileNameNotFound = 104;
      ErrNoCompareType = 105;
      ErrBadCompareType = 106;
      ErrNoDateType = 107;
      ErrBadDateType = 108;
  public
    ///  <summary>Object constructor.</summary>
    ///  <param name="Msg">[in] Error message.</param>
    ///  <param name="ExitCode">[in] Program exit code associated with the
    ///  exception.</param>
    constructor Create(const Msg: string; const ExitCode: Integer); overload;
    ///  <summary>Object constructor.</summary>
    ///  <param name="Msg">[in] Format template for error message.</param>
    ///  <param name="Args">[in] Values to include in formatted string.</param>
    ///  <param name="ExitCode">[in] Program exit code associated with the
    ///  exception.</param>
    constructor Create(const Msg: string; const Args: array of const;
      const ExitCode: Integer); overload;
    ///  <summary>Program exit code associated with the object.</summary>
    property ExitCode: Integer read fExitCode;
  end;


implementation


{ EApplication }

constructor EApplication.Create(const Msg: string; const ExitCode: Integer);
begin
  inherited Create(Msg);
  fExitCode := ExitCode;
end;

constructor EApplication.Create(const Msg: string; const Args: array of const;
  const ExitCode: Integer);
begin
  Create(Format(Msg, Args), ExitCode);
end;

end.

