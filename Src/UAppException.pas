{
 * UAppException.pas
 * Revision $Rev$ of $Date$
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
  cAppErrTooManyFiles = 101;
  cAppErrBadSwitch = 102;
  cAppErr2FilesNeeded = 103;
  cAppErrFileNamesSame = 104;
  cAppErrFileNameNotFound = 105;


resourcestring
  // Error messages
  sAppErrBadSwitch = 'Invalid switch "%s"';
  sAppErrTooManyFiles = 'Too many file names supplied: two expected';
  sAppErr2FilesNeeded = 'Two file names must be specified';
  sAppErrFileNamesSame = 'File names must be different';
  sAppErrFileNameNotFound = 'Date for file "%s" not found';


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
        @param Msg [in] Format template for error messaqe.
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
    @param Msg [in] Format template for error messaqe.
    @param Args [in] Values to be included in format template.
    @param ExitCode [in] Program exit code associated with error.
  }
begin
  Create(Format(Msg, Args), fExitCode);
end;

end.

