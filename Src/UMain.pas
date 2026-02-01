{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at https://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2009-2026, Peter Johnson (gravatar.com/delphidabbler).
 *
 * Class that executes program.
}


unit UMain;


interface


uses
  // Delphi
  System.SysUtils,
  // Project
  UConsole,
  UFileInfo,
  UParams;


type
  ///  <summary>Class that executes program.</summary>
  TMain = class(TObject)
  strict private
    var
      // Writes to console
      fConsole: TConsole;
      // Reads and parses parameters
      fParams: TParams;
      // Flag true if program has been signed on
      fSignedOn: Boolean;
    ///  <summary>Writes a sign on message to standard output.</summary>
    procedure SignOn;
    ///  <summary>Writes help text to standard output.</summary>
    procedure ShowHelp;
    ///  <summary>Writes short-form help text to standard output.</summary>
    procedure ShowShortHelp;
    ///  <summary>Writes the program version to standard output.</summary>
    procedure ShowVersion;
    ///  <summary>Writes an error message to standard error. In verbosity mode
    ///  the sign on message is written to standard output.</summary>
    ///  <param name="E">[in] Exception whose message is to be reported.</param>
    procedure ReportError(const E: Exception);
    ///  <summary>Compares modification dates of the two files passed on the
    ///  command line using the user's chosen comparison operation and returns
    ///  True if the comparison succeeds or False if not.</summary>
    ///  <param name="File1">[in] Information about the file that is the left
    ///  hand operand of the comparison.</param>
    ///  <param name="File2">[in] Information about the file that is the right
    ///  hand operand of the comparison.</param>
    ///  <returns><c>Boolean</c>. <c>True</c> if the operation succeeds or
    ///  <c>False</c> if not.</returns>
    function CompareFileDates(const File1, File2: TFileInfo): Boolean;
  public
    ///  <summary>Object constructor.</summary>
    constructor Create;
    ///  <summary>Object destructor.</summary>
    destructor Destroy; override;
    ///  <summary>Executes the program.</summary>
    procedure Execute;
  end;


implementation


uses
  // Delphi
  System.DateUtils,
  // Project
  UAppException,
  UAppInfo,
  UDateComparer,
  UDateExtractor;


resourcestring
  // Messages written to console
  sSignOn = 'CompFileDate by DelphiDabbler (https://delphidabbler.com)';

  sError = 'Error: %s';

  sUsage = '''
  Usage: CompFileDate filename1 filename2 [options]
    or   CompFileDate -h | -? | --help
    or   CompFileDate -V | --version
  ''';

  sHelpIntro = '''
  filename1
    Name of first file to be compared.
  filename2
    Name of second file to be compared.

  Options are:
  ''';

  sHelpCompareCmd = '''
    -c <op> or --compare=<op>'
      Defines the compare operation to use. <op> must be one of the
      following:
        eq, equal, same:
          Check if file dates are the same.
        gt, newer, later:
          Check if 1st file date is later than 2nd file date.
        gte, not-older, not-earlier:
          Check if 1st file date is no earlier than 2nd file date.
        lt, older, earlier:
          Check if 1st file date is earlier than 2nd file date (default if
          option is not provided).
        lte, not-newer, not-later:
          Check if 1st file date is no later than 2nd file date.
        neq, not-equal, not-same, different:
          Check if file dates are different.
  ''';

  sHelpDateTypeCmd = '''
    -d <type> or --datetype=<type>
      Determines whether last modification or creation dates are compared.
      <type> must be one of the following:
        m, modified, last-modified, modification:
          Use date files were last modified (default if option is not provided).
        c, created, creation:
          Use date files were created.
  ''';

  {$IF Defined(MSWINDOWS)}
  sHelpFollowShortcutsCmd = '''
    -s or --followshortcuts
      Indicates that if either filename1 or filename2 is a shortcut file then
      the date of the target file will be used in comparisons. If neither option
      is specified then shortcuts are not followed and the date of the shortcut
      file itself is used.
  ''';
  {$ELSEIF Defined(LINUX)}
  sHelpFollowShortcutsCmd = '''
    -s or --followshortcuts
      <<Not supported on Linux>>. Reports an error if used.
  ''';
  {$ENDIF}

  sHelpVerboseCmd = '''
    -v or --verbose
      Verbose: writes output to standard output. No output is written if the
      option is not provided. Output is always written to standard error when an
      error occurs or to standard output when help or the program's version
      number are requested.
  ''';

  sHelpHelpCmd = '''
    -h or -? or --help
      Displays help screen. Rest of command line ignored.
  ''';

  sHelpVersionCmd = '''
    -V or --version
      Displays program version number and platform. Rest of command line
      ignored.
  ''';

  sHelpOutro = '''

  The program's exit code is 1 if the comparison is true and 0 if it is false.

  If an error occurs then an error code >= 100 is returned and an error message
  is written to standard error. See documentation for details of error codes.
  ''';

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
  TrueResponses: array[TDateComparer.TOp] of string = (
    sEQ, sLT, sGT, sLTE, sGTE, sNEQ
  );
  FalseResponses: array[TDateComparer.TOp] of string = (
    sNEQ, sGTE, sLTE, sGT, sLT, SEQ
  );
  DateTypeResponses: array[TDateExtractor.TDateType] of string = (
    sDateTypeModified, sDateTypeCreated
  );


{ TMain }

function TMain.CompareFileDates(const File1, File2: TFileInfo): Boolean;
begin
  var FileDate1 := TDateExtractor.GetDate(
    File1.ResolvedFileName, fParams.DateType
  );
  var FileDate2 := TDateExtractor.GetDate(
    File2.ResolvedFileName, fParams.DateType
  );
  Result := TDateComparer.Compare(FileDate1, FileDate2, fParams.ComparisonOp);
end;

constructor TMain.Create;
begin
  fConsole := TConsole.Create;
  fParams := TParams.Create;
  inherited;
end;

destructor TMain.Destroy;
begin
  fParams.Free;
  fConsole.Free;
  inherited;
end;

procedure TMain.Execute;
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
      var File1 := TFileInfo.Create(fParams.FileName1, fParams.FollowShortcuts);
      var File2 := TFileInfo.Create(fParams.FileName2, fParams.FollowShortcuts);
      if CompareFileDates(File1, File2) then
      begin
        fConsole.WriteLn(
          TConsole.TChannel.StdOut,
          string.Format(sSuccessReport, [DateTypeResponses[fParams.DateType]])
        );
        fConsole.WriteLn(
          TConsole.TChannel.StdOut,
          string.Format(
            TrueResponses[fParams.ComparisonOp],
            [File1.ResolvedFileName, File2.ResolvedFileName]
          )
        );
        ExitCode := 1;
      end
      else
      begin
        fConsole.WriteLn(
          TConsole.TChannel.StdOut,
          string.Format(sFailureReport, [DateTypeResponses[fParams.DateType]])
        );
        fConsole.WriteLn(
          TConsole.TChannel.StdOut,
          string.Format(
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
      ExitCode := EApplication.ErrUnknown;
    end;
  end;
end;

procedure TMain.ReportError(const E: Exception);
begin
  // Sign on to stdout only if the verbosity flag is on
  SignOn;
  // Errors always written to stderr regardless of verbosity flag
  fConsole.Silent := False;
  fConsole.WriteLn(
    TConsole.TChannel.StdErr, string.Format(sError, [E.Message])
  );
end;

procedure TMain.ShowHelp;
begin
  fConsole.Silent := False;
  SignOn;

  fConsole.WriteLn(TConsole.TChannel.StdOut);
  fConsole.WriteLn(TConsole.TChannel.StdOut, sUsage);
  fConsole.WriteLn(TConsole.TChannel.StdOut);

  fConsole.WriteLn(TConsole.TChannel.StdOut, sHelpIntro);
  fConsole.WriteLn(TConsole.TChannel.StdOut, sHelpCompareCmd);
  fConsole.WriteLn(TConsole.TChannel.StdOut, sHelpDateTypeCmd);
  fConsole.WriteLn(TConsole.TChannel.StdOut, sHelpFollowShortcutsCmd);
  fConsole.WriteLn(TConsole.TChannel.StdOut, sHelpVerboseCmd);
  fConsole.WriteLn(TConsole.TChannel.StdOut, sHelpHelpCmd);
  fConsole.WriteLn(TConsole.TChannel.StdOut, sHelpVersionCmd);
  fConsole.WriteLn(TConsole.TChannel.StdOut, sHelpOutro);
end;

procedure TMain.ShowShortHelp;
begin
  fConsole.Silent := False;
  SignOn;
  fConsole.WriteLn(TConsole.TChannel.StdOut);
  fConsole.WriteLn(TConsole.TChannel.StdOut, sUsage);
  fConsole.WriteLn(TConsole.TChannel.StdOut);
  fConsole.WriteLn(TConsole.TChannel.StdOut, sShortHelp);
end;

procedure TMain.ShowVersion;
begin
  fConsole.Silent := False;
  fConsole.WriteLn(
    TConsole.TChannel.StdOut,
    string.Format(
      'v%0:s (%1:s)',
      [TAppInfo.Version, TAppInfo.OSPlatform])
  );
end;

procedure TMain.SignOn;
begin
  if fSignedOn then
    Exit;
  // Write underlined sign on message
  fConsole.WriteLn(TConsole.TChannel.StdOut, sSignOn);
  fConsole.WriteLn(
    TConsole.TChannel.StdOut, StringOfChar('-', Length(sSignOn))
  );
  // Record that we've signed on
  fSignedOn := True;
end;

end.

