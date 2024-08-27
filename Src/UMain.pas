{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at https://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2009-2024, Peter Johnson (gravatar.com/delphidabbler).
 *
 * Class that executes program.
}


unit UMain;


interface


uses
  // Delphi
  System.SysUtils,
  System.Classes,
  // Project
  UConsole, UFileInfo, UParams;


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
    ///  <summary>Write short-form of help text to console.</summary>
    procedure ShowShortHelp;
    procedure ShowVersion;
      {Writes program version to console.
      }
    procedure ReportError(const E: Exception);
      {Reports an error onto standard output.
        @param E [in] Exception containing error message.
      }
    ///  <summary>Compares modification dates of the two files passed on the
    ///  command line using the user's chosen comparison operation and returns
    ///  True if the comparison succeeds or False if not.</summary>
    function CompareFileDates(const File1, File2: TFileInfo): Boolean;
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
  WinApi.Windows,
  System.DateUtils,
  // Project
  UAppException, UDateComparer, UDateExtractor;

const
  EOL = #13#10;

resourcestring
  // Messages written to console
  sSignOn = 'CompFileDate by DelphiDabbler (https://delphidabbler.com)';

  sError = 'Error: %s';

  sUsage =
      'Usage: CompFileDate filename1 filename2 [options]'
    + EOL
    + '  or   CompFileDate -h | -? | --help'
    + EOL
    + '  or   CompFileDate -V | --version';

  sHelp =
      'filename1' + EOL
    + '  Name of first file to be compared.' + EOL
    + 'filename2' + EOL
    + '  Name of second file to be compared.' + EOL
    + EOL
    + 'Options are:' + EOL
    + '  -c <op> or --compare=<op>' + EOL
    + '    Defines the compare operation to use. <op> must be one of the '
    + 'following:' + EOL
    + '      eq, equal, same:' + EOL
    + '        Check if file dates are the same.' + EOL
    + '      gt, newer, later:' + EOL
    + '        Check if 1st file date is later than 2nd file date.' + EOL
    + '      gte, not-older, not-earlier' + EOL
    + '        Check if 1st file date is no earlier than 2nd file date.' + EOL
    + '      lt, older, earlier' + EOL
    + '        Check if 1st file date is earlier than 2nd file date (default '
    + 'if option' + EOL
    + '        is not provided).' + EOL
    + '      lte, not-newer, not-later' + EOL
    + '        Check if 1st file date is no later than 2nd file date.' + EOL
    + '      neq, not-equal, not-same, different' + EOL
    + '        Check if file dates are different.' + EOL
    + '  -d <type> or --datetype=<type>' + EOL
    + '    Determines whether last modification or creation dates are '
    + 'compared. <type>' + EOL
    + '    must be one of the following:' + EOL
    + '      m, modified, last-modified, modification:' + EOL
    + '        Use date files were last modified (default if option is not '
    + 'provided).' + EOL
    + '      c, created, creation:' + EOL
    + '        Use date files were created.' + EOL
    + '  -s or --followshortcuts' + EOL
    + '    Indicates that if either filename1 or filename2 is a shortcut file '
    + 'then the' + EOL
    + '    date of the target file will be used in comparisons. If neither '
    + 'option is' + EOL
    + '    specified then shortcuts are not followed and the date of '
    + 'the shortcut file' + EOL
    + '    itself is used.' + EOL
    + '  -v or --verbose' + EOL
    + '    Verbose: writes output to standard output. No output if option is '
    + 'not' + EOL
    + '    provided. Output is always written when an error occurs or when '
    + 'help or' + EOL
    + '    version number are requested.' + EOL
    + '  -h or -? or --help' + EOL
    + '    Displays help screen. Rest of command line ignored.' + EOL
    + '  -V or --version' + EOL
    + '    Displays program version number. Rest of command line ignored.' + EOL
    + EOL
    + 'The program''s exit code is 1 if the comparison is true and 0 if it is '
    + 'false.' + EOL
    + EOL
    + 'If an error occurs then an error code >= 100 is returned and an error '
    + 'message' + EOL
    + 'is written to standard output. See documentation for details of error '
    + 'codes.';

  sShortHelp = 'For further help use CompFileDate --help';

  sEQ = '%0:s has same date as %1:s';
  sNEQ = '%0:s has different date to %1:s';
  sLT = '%0:s is older than %1:s';
  sLTE = '%0:s is no newer than %1:s';
  sGT = '%0:s is newer than %1:s';
  sGTE = '%0:s is no older than %1:s';

  sSuccessReport = 'Comparison using %s is true';
  sFailureReport = 'Comparison using %s is false';

  sDateTypeModified = 'last modification dates';
  sDateTypeCreated = 'creation dates';

const
  TrueResponses: array[TDateComparisonOp] of string = (
    sEQ, sLT, sGT, sLTE, sGTE, sNEQ
  );
  FalseResponses: array[TDateComparisonOp] of string = (
    sNEQ, sGTE, sLTE, sGT, sLT, SEQ
  );
  DateTypeResponses: array[TDateType] of string = (
    sDateTypeModified, sDateTypeCreated
  );

{ TMain }

function TMain.CompareFileDates(const File1, File2: TFileInfo): Boolean;
var
  FileDate1, FileDate2: TDateTime;  // required file dates
begin
  FileDate1 := TDateExtractor.GetDate(File1.ResolvedFileName, fParams.DateType);
  FileDate2 := TDateExtractor.GetDate(File2.ResolvedFileName, fParams.DateType);
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
var
  File1, File2: TFileInfo;
begin
  try
    fParams.Parse;
    if fParams.Help then
      ShowHelp
    else if fParams.ShortHelp then
      ShowShortHelp
    else if fParams.Version then
      ShowVersion
    else
    begin
      // Normal execution
      fConsole.Silent := not fParams.Verbose;
      SignOn;
      File1 := TFileInfo.Create(fParams.FileName1, fParams.FollowShortcuts);
      File2 := TFileInfo.Create(fParams.FileName2, fParams.FollowShortcuts);
      if CompareFileDates(File1, File2) then
      begin
        fConsole.WriteLn(
          Format(sSuccessReport, [DateTypeResponses[fParams.DateType]])
        );
        fConsole.WriteLn(
          Format(
            TrueResponses[fParams.ComparisonOp],
            [File1.ResolvedFileName, File2.ResolvedFileName]
          )
        );
        ExitCode := 1;
      end
      else
      begin
        fConsole.WriteLn(
          Format(sFailureReport, [DateTypeResponses[fParams.DateType]])
        );
        fConsole.WriteLn(
          Format(
            FalseResponses[fParams.ComparisonOp],
            [File1.ResolvedFileName, File2.ResolvedFileName]
          )
        );
        ExitCode := 0;
      end;
    end;
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

procedure TMain.ShowShortHelp;
begin
  fConsole.Silent := False;
  SignOn;
  fConsole.WriteLn;
  fConsole.WriteLn(sUsage);
  fConsole.WriteLn;
  fConsole.WriteLn(sShortHelp);
end;

procedure TMain.ShowVersion;
begin
  fConsole.Silent := False;
  fConsole.WriteLn('v' + GetProductVersionStr);
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
  fConsole.WriteLn(sSignOn);
  fConsole.WriteLn(StringOfChar('-', Length(Msg)));
  // Record that we've signed on
  fSignedOn := True;
end;

end.

