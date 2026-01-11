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

  {
  EApplication:
    Application error exception object. Contains an error code.
  }
  EApplication = class(Exception)
  strict private
    fExitCode: Integer; // Value of ExitCode property
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
    constructor Create(const Msg: string; const ExitCode: Integer); overload;
      {Class constructor. Sets up exception object.
        @param Msg [in] Error message.
        @param ExitCode [in] Program exit code associated with error.
      }
    constructor Create(const Msg: string; const Args: array of const;
      const ExitCode: Integer); overload;
      {Class constructor. Sets up exception object.
        @param Msg [in] Format template for error message.
        @param Args [in] Values to be included in format template.
        @param ExitCode [in] Program exit code associated with error.
      }
    property ExitCode: Integer read fExitCode;
      {Program exit code associated with error}
  end;


implementation


{ EApplication }

constructor EApplication.Create(const Msg: string; const ExitCode: Integer);
  {Class constructor. Sets up exception object.
    @param Msg [in] Error message.
    @param ExitCode [in] Program exit code associated with error.
  }
begin
  inherited Create(Msg);
  fExitCode := ExitCode;
end;

constructor EApplication.Create(const Msg: string; const Args: array of const;
  const ExitCode: Integer);
  {Class constructor. Sets up exception object.
    @param Msg [in] Format template for error message.
    @param Args [in] Values to be included in format template.
    @param ExitCode [in] Program exit code associated with error.
  }
begin
  Create(Format(Msg, Args), ExitCode);
end;

end.

