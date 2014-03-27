{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2009-2014, Peter Johnson (www.delphidabbler.com).
 *
 * Class that executes program.
}


unit UMain;


interface


uses
  // Delphi
  SysUtils, Classes,
  // Project
  UConsole, UParams;


type
  {
  TMain:
    Class that executes program.
  }
  TMain = class(TObject)
  strict private
    fConsole: TConsole;   // Writes to console
    fParams: TParams;     // Reads and parses parameters
    fSignedOn: Boolean;   // Flag true if program has been signed on
    procedure SignOn;
      {Writes sign on message to console.
      }
    procedure ShowHelp;
      {Writes help text to console.
      }
    procedure ReportError(const E: Exception);
      {Reports an error onto standard output.
        @param E [in] Exception containing error message.
      }
    ///  <summary>Compares modification dates of the two files passed on the
    ///  command line using the user's chosen comparison operation and returns
    ///  True if the comparison succeeds or False if not.</summary>
    function CompareFileDates: Boolean;
    class function GetProductVersionStr: string;
      {Gets the program's product version number from version information.
        @return Version number as a dot delimited string.
      }
  public
    constructor Create;
      {Class constructor. Sets up object.
      }
    destructor Destroy; override;
      {Class destructor. Tears down object.
      }
    procedure Execute;
      {Executes program.
      }
  end;


implementation


uses
  // Delphi
  Windows, DateUtils,
  // Project
  UAppException, UDateComparer;

const
  EOL = #13#10;

resourcestring
  // Messages written to console
  sSignOn = 'CompFileDate %s by DelphiDabbler (www.delphidabbler.com)';

  sError = 'Error: %s';

  sUsage =
      'Usage: CompFileDate filename1 filename2 [options]'
    + EOL
    + '  or   CompFileDate -h | -?';

  sHelp =
      'filename1' + EOL
    + '  Name of first file to be compared.' + EOL
    + 'filename2' + EOL
    + '  Name of second file to be compared.' + EOL
    + EOL
    + 'Options are:' + EOL
    + '  -c <op> or --compare=<op>' + EOL
    + '    Defines the compare operation to use. <op> is one of the following'
    + EOL
    + '      eq, equal or same:' + EOL
    + '        Check if dates of the files are the same.' + EOL
    + '      gt, newer or later:' + EOL
    + '        Check if 1st file date is later than 2nd file date.' + EOL
    + '      gte, not-older or not-earlier' + EOL
    + '        Check if 1st file date is no earlier than 2nd file date.' + EOL
    + '      lt, older or earlier' + EOL
    + '        Check if 1st file date is earlier than 2nd file date (default '
    + 'if option' + EOL
    + '        is not provided).' + EOL
    + '      lte, not-newer, not-later' + EOL
    + '        Check if 1st file date in no later than 2nd file date.' + EOL
    + '      neq, not-equal, not-same, different' + EOL
    + '        Check if dates of the files are different.' + EOL
    + '  -v' + EOL
    + '    Verbose: writes output to standard output. No output if -v not '
    + 'provided.' + EOL
    + '    Ignored on error.' + EOL
    + '  -h or -?' + EOL
    + '    Displays help screen. Rest of command line ignored.' + EOL
    + EOL
    + 'Exit code is 1 if filename1 is earlier than filename2 and zero if not.'
    + EOL
    + 'If an error occurs then an error code >= 100 is returned and an error '
    + 'message' + EOL
    + 'is written to standard output, regardless of the -v switch. See '
    + 'documentation' + EOL
    + 'for details of error codes.';

  sEQ = '%0:s has same date as %1:s';
  sNEQ = '%0:s has different date to %1:s';
  sLT = '%0:s is older than %1:s';
  sLTE = '%0:s is no newer than %1:s';
  sGT = '%0:s is newer than %1:s';
  sGTE = '%0:s is no older than %1:s';

  sSuccessReport = 'Comparison is true';
  sFailureReport = 'Comparison is false';

const
  TrueResponses: array[TDateComparisonOp] of string = (
    sEQ, sLT, sGT, sLTE, sGTE, sNEQ
  );
  FalseResponses: array[TDateComparisonOp] of string = (
    sNEQ, sGTE, sLTE, sGT, sLT, SEQ
  );


{ TMain }

function TMain.CompareFileDates: Boolean;
var
  FileDate1, FileDate2: TDateTime;  // modification dates of files
begin
  if not FileAge(fParams.FileName1, FileDate1) then
    raise EApplication.Create(
      sAppErrFileNameNotFound, [fParams.FileName1], cAppErrFileNameNotFound
    );
  if not FileAge(fParams.FileName2, FileDate2) then
    raise EApplication.Create(
      sAppErrFileNameNotFound, [fParams.FileName2], cAppErrFileNameNotFound
    );
  Result := TDateComparer.Compare(FileDate1, FileDate2, fParams.ComparisonOp);
end;

constructor TMain.Create;
  {Class constructor. Sets up object.
  }
begin
  fConsole := TConsole.Create;
  fParams := TParams.Create;
  inherited;
end;

destructor TMain.Destroy;
  {Class destructor. Tears down object.
  }
begin
  FreeAndNil(fParams);
  FreeAndNil(fConsole);
  inherited;
end;

procedure TMain.Execute;
  {Executes program.
  }
begin
  try
    fParams.Parse;
    if not fParams.Help then
    begin
      // Normal execution
      fConsole.Silent := not fParams.Verbose;
      SignOn;
      if CompareFileDates then
      begin
        fConsole.WriteLn(sSuccessReport);
        fConsole.WriteLn(
          Format(
            TrueResponses[fParams.ComparisonOp],
            [fParams.FileName1, fParams.FileName2]
          )
        );
        ExitCode := 1;
      end
      else
      begin
        fConsole.WriteLn(sFailureReport);
        fConsole.WriteLn(
          Format(
            FalseResponses[fParams.ComparisonOp],
            [fParams.FileName1, fParams.FileName2]
          )
        );
        ExitCode := 0;
      end;
    end
    else
      // Display help
      ShowHelp;
  except
    // Report any errors
    on E: EApplication do
    begin
      ReportError(E);
      ExitCode := E.ExitCode;
    end;
    on E: Exception do
    begin
      ReportError(E);
      ExitCode := cAppErrUnknown;
    end;
  end;
end;

class function TMain.GetProductVersionStr: string;
  {Gets the program's product version number from version information.
    @return Version number as a dot delimited string.
  }
var
  Dummy: DWORD;           // unused variable required in API calls
  VerInfoSize: Integer;   // size of version information data
  VerInfoBuf: Pointer;    // buffer holding version information
  ValPtr: Pointer;        // pointer to a version information value
  FFI: TVSFixedFileInfo;  // fixed file information from version info
begin
  Result := '';
  // Get fixed file info from program's version info
  // get size of version info
  VerInfoSize := GetFileVersionInfoSize(PChar(ParamStr(0)), Dummy);
  if VerInfoSize > 0 then
  begin
    // create buffer and read version info into it
    GetMem(VerInfoBuf, VerInfoSize);
    try
      if GetFileVersionInfo(
        PChar(ParamStr(0)), Dummy, VerInfoSize, VerInfoBuf
      ) then
      begin
        // get fixed file info from version info (ValPtr points to it)
        if VerQueryValue(VerInfoBuf, '\', ValPtr, Dummy) then
        begin
          FFI := PVSFixedFileInfo(ValPtr)^;
          // Build version info string from product version field of FFI
          Result := Format(
            '%d.%d.%d',
            [
              HiWord(FFI.dwProductVersionMS),
              LoWord(FFI.dwProductVersionMS),
              HiWord(FFI.dwProductVersionLS)
            ]
          );
        end
      end;
    finally
      FreeMem(VerInfoBuf);
    end;
  end;
end;

procedure TMain.ReportError(const E: Exception);
  {Reports an error onto standard output.
    @param E [in] Exception containing error message.
  }
begin
  // Errors always written to stdout regardless of verbosity flag
  fConsole.Silent := False;
  SignOn;
  fConsole.WriteLn(Format(sError, [E.Message]));
end;

procedure TMain.ShowHelp;
  {Writes help text to console.
  }
begin
  fConsole.Silent := False;
  SignOn;
  fConsole.WriteLn;
  fConsole.WriteLn(sUsage);
  fConsole.WriteLn;
  fConsole.WriteLn(sHelp);
end;

procedure TMain.SignOn;
  {Writes sign on message to console.
  }
var
  Msg: string;  // sign on message text
begin
  if fSignedOn then
    Exit;
  // Write underlined sign on message
  Msg := Format(sSignOn, [GetProductVersionStr]);
  fConsole.WriteLn(Msg);
  fConsole.WriteLn(StringOfChar('-', Length(Msg)));
  // Record that we've signed on
  fSignedOn := True;
end;

end.

