{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at https://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2009-2014, Peter Johnson (www.delphidabbler.com).
 *
 * Exception class for application errors. Stores error message and associated
 * error exit code.
}


unit UAppException;


interface


uses
  // Delphi
  SysUtils;


const
  // Error exit codes
  cAppErrUnknown = 100;
  cAppErrBadSwitch = 101;
  cAppErr2FilesNeeded = 102;
  cAppErrFileNamesSame = 103;
  cAppErrFileNameNotFound = 104;
  cAppErrNoCompareType = 105;
  cAppErrBadCompareType = 106;
  cAppErrNoDateType = 107;
  cAppErrBadDateType = 108;

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
  Create(Format(Msg, Args), fExitCode);
end;

end.

