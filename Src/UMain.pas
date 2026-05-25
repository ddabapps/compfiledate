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
  UParams,
  USysDate;


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
    ///  <summary>Adjusts the given file name if necessary according to target
    ///  OS and command line options and return the adjusted file name or the
    ///  unchanged file name if no adjustment is necessary.</summary>
    ///  <remarks>The ONLY case where a file name is adjusted is when ALL of the
    ///  following conditions apply: (1) Windows is the target OS, (2) the user
    ///  has specified the follow shortcuts option, (3) the file is a shortcut
    ///  (.lnk) file and (4) the shortcut file references a valid file.
    ///  </remarks>
    function AdjustFileName(const AFileName: string): string;
    ///  <summary>Performs date comparison on the two files then reports the
    ///  outcome. If the comparison is <c>True</c> then the program's exit code
    ///  is set to <c>1</c>, otherwise the exit code is set to <c>0</c>.
    ///  </summary>
    procedure CompareFilesAndReport;
    ///  <summary>Briefly reports the result of the file date comparison.
    ///  </summary>
    procedure ReportStandardResults(const FileName1, FileName2: string;
      const CompareResult: Boolean);
    ///  <summary>Reports the result of the file date comparison in detail.
    ///  </summary>
    procedure ReportExtraVerboseResults(const FileName1, FileName2: string;
      const FileDate1, FileDate2: TSysDate; const CompareResult: Boolean);
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
  System.IOUtils,
  // Project
  UAppException
  , UAppInfo
  , UDateComparer
  , UDateExtractor
  , USymlinks
  {$IF Defined(MSWINDOWS)}
  , UWinShellLink
  {$ENDIF}
  ;


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
    -c <op> or --compare=<op>

      Defines the compare operation to use. <op> must be one of the
      following:
        =, ==, eq, eql, equal, same:
          Check if file dates are the same.
        >, gt, newer, later, after:
          Check if 1st file date is later than 2nd file date.
        >=, gte, ge, goe, no-older, not-older, no-earlier, not-earlier,
        not-before:
          Check if 1st file date is no earlier than 2nd file date.
        <, lt, older, earlier, before:
          Check if 1st file date is earlier than 2nd file date (default if
          option is not provided).
        <=, lte, le, loe, no-newer, not-newer, no-later, not-later, not-after:
          Check if 1st file date is no later than 2nd file date.
        <>, !=, ~=, neq, ne, not-equal, not-same, different:
          Check if file dates are different.

  '''
{$IF Defined(MSWINDOWS)}
  + '''
      If <op> contains either a '<' or '>' character then the value must be
      enclosed in double quotes.

  ''';
{$ELSEIF Defined(LINUX)}
  + '''
      If <op> contains either a '<' or '>' character then the value must be
      enclosed in single or double quotes.

  ''';
{$ENDIF}


  {$IF Defined(MSWINDOWS)}
  sHelpDateTypeCmd = '''
    -d <type> or --date-type=<type>

      Determines whether last modification, last accessed or creation dates are
      compared. <type> must be one of the following:
        m, modify, modified, last-modified, modification, update, updated,
        last-updated, write, written, last-written:
          Use date files were last modified (default if option is not provided).
        a, accessed, last-accessed, access, read, last-read:
          Use date files were last accessed.
        c, create, created, creation:
          Use date files were created.

  ''';
  {$ELSEIF Defined(LINUX)}
  sHelpDateTypeCmd = '''
    -d <type> or --date-type=<type>

      Determines whether last modification, last accessed or last status update
      dates are compared. <type> must be one of the following:
        m, modify, modified, last-modified, modification, update, updated,
        last-updated, write, written, last-written:
          Use date files were last modified (default if option is not provided).
        a, accessed, last-accessed, access, read, last-read:
          Use date files were last accessed.
        s, status, status-change, last-status-change, status-changed,
        metadata, metadata-change, last-metadata-change, metadata-changed:
          Use date files last had status updates.

  ''';
  {$ENDIF}

  sHelpDateFormatCmd = '''
    -i or --iso-dates

      Specifies that dates should be output in ISO8601 format. If this command
      is not used then dates are output in the correct format for the user's
      current locale.

  ''';

  sHelpDateBasisCmd = '''
    -l or --local-time

      Specifies that all file dates relate to the local time zone. If this
      command is not used then file dates are taken to be in UTC.

  ''';

  sHelpFollowSymlinksCmd = '''
    -S, -sy or --follow-symlinks

      Indicates that if either filename1 or filename2 is a symlink then the date
      of the target file will be used in comparisons. If neither option is
      specified then the symlinks are not followed and the date of the symlink
      file itself is used.

  ''';

  {$IF Defined(MSWINDOWS)}
  sHelpFollowShortcutsCmd = '''
    -s, -sh or --follow-shortcuts

      Indicates that if either filename1 or filename2 is a shortcut file then
      the date of the target file will be used in comparisons. If neither option
      is specified then shortcuts are not followed and the date of the shortcut
      file itself is used.

  ''';
  {$ENDIF}

  {$IF Defined(MSWINDOWS)}
  sHelpFollowAllLinksCmd = '''
    -ss or --follow-all-links

      Indicates that if either filename1 or filename2 is a shortcut or a symlink
      file then the date of the target file will be used in comparisons. If this
      option is not specified then shortcuts are not followed and the date of
      the shortcut or symlink file itself is used.

      Equivalent to using both --follow-shortcuts and --follow-symlinks, or -sh
      and -sy.

  ''';
  {$ENDIF}

  sHelpVerboseCmd = '''
    -v or --verbose

      Verbose. Writes output to standard output. No output is written if the
      option is not provided. Output is always written to standard error when an
      error occurs or to standard output when help or the program's version
      number are requested.

  ''';

  sHelpExtraVerboseCmd = '''
    -vv, -x or --extra-verbose

      Extra verbose. Behaves as if -v or --verbose had been specified except
      that file date comparison results are output in more detail.

  ''';

  sHelpHelpCmd = '''
    -h, -? or --help

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
  {$IF Defined(MSWINDOWS)}
  sDateTypeCreated = 'creation dates';
  {$ELSEIF Defined(LINUX)}
  sDateTypeStatusChanged = 'status change dates';
  {$ENDIF}
  sDateTypeAccessed = 'last access dates';

  sWarning = 'WARNING: %s';

const
  TrueResponses: array[TDateComparer.TOp] of string = (
    sEQ, sLT, sGT, sLTE, sGTE, sNEQ
  );
  FalseResponses: array[TDateComparer.TOp] of string = (
    sNEQ, sGTE, sLTE, sGT, sLT, SEQ
  );
  DateTypeResponses: array[TDateExtractor.TDateType] of string = (
    sDateTypeModified,
    {$IF Defined(MSWINDOWS)}
    sDateTypeCreated,
    {$ELSEIF Defined(LINUX)}
    sDateTypeStatusChanged,
    {$ENDIF}
    sDateTypeAccessed
  );


type
  TOpArray = array[TDateComparer.TOp] of string;

{ TMain }

function TMain.AdjustFileName(const AFileName: string): string;

  {$IF Defined(MSWINDOWS)}
  // TODO: Try to check validity using COM rather than file ext
  // TODO: Move to UWinShellLink unit
  function IsWinShellLink(const AFileName: string): Boolean;
  begin
    Result := TPath.GetExtension(AFileName).CompareTo('.lnk') = 0;
  end;
  {$ENDIF}

resourcestring
  sFileNotFound = 'File "%s" not found';

begin
  if not TFile.Exists(AFileName) then
    raise EApplication.Create(
      sFileNotFound, [AFileName], EApplication.ErrFileNameNotFound
    );
  if fParams.FollowSymlinks and IsSymLink(AFileName) then
    Result := ResolveSymlink(AFileName)
  {$IF Defined(MSWINDOWS)}
  else if fParams.FollowShortcuts and IsWinShellLink(AFileName) then
  begin
    if not TWinShellLink.TryResolveShortcut(AFileName, Result) then
      Exit(AFileName);
  end
  {$ENDIF}
  else
    Result := AFileName;
end;

procedure TMain.CompareFilesAndReport;
begin
  var FileName1 := AdjustFileName(fParams.FileName1);
  var FileName2 := AdjustFileName(fParams.FileName2);
  var FileDate1 := TDateExtractor.GetDate(FileName1, fParams.DateType);
  var FileDate2 := TDateExtractor.GetDate(FileName2, fParams.DateType);
  var CompareResult := TDateComparer.Compare(
    FileDate1, FileDate2, fParams.ComparisonOp
  );
  fConsole.Silent := not fParams.Verbose;
  SignOn;
  if fParams.ExtraVerbose then
    ReportExtraVerboseResults(
      FileName1, FileName2, FileDate1, FileDate2, CompareResult
    )
  else
    ReportStandardResults(
      FileName1, FileName2, CompareResult
    );
  ExitCode := if CompareResult then 1 else 0;
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
      CompareFilesAndReport;
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

procedure TMain.ReportExtraVerboseResults(const FileName1, FileName2: string;
  const FileDate1, FileDate2: TSysDate; const CompareResult: Boolean);
const
  Indent = '  ';
  Operators: TOpArray = ('=', '<', '>', '<=', '>=', '<>');

  procedure WriteFileInfo(const AFileName: string; const ADate: TSysDate);
  begin
    fConsole.WriteLn(TConsole.TChannel.StdOut, Indent + AFileName);
    fConsole.WriteLn(
      TConsole.TChannel.StdOut,
      Indent + ADate.ToString(fParams.DateFormat, fParams.DateBasis)
    );
  end;

begin
  fConsole.Write(TConsole.TChannel.StdOut, 'Comparing ');
  fConsole.WriteLn(
    TConsole.TChannel.StdOut, DateTypeResponses[fParams.DateType] + ' of:'
  );
  WriteFileInfo(FileName1, FileDate1);
  fConsole.WriteLn(TConsole.TChannel.StdOut, 'and:');
  WriteFileInfo(FileName2, FileDate2);
  fConsole.WriteLn(
    TConsole.TChannel.StdOut, 'Using comparision operator:'
  );
  fConsole.WriteLn(
    TConsole.TChannel.StdOut, Indent + Operators[fParams.ComparisonOp]
  );
  fConsole.WriteLn(TConsole.TChannel.StdOut, 'Result:');
  fConsole.WriteLn(
    TConsole.TChannel.StdOut, Indent + BoolToStr(CompareResult, True)
  );
end;

procedure TMain.ReportStandardResults(const FileName1, FileName2: string;
  const CompareResult: Boolean);
const
  Reports: array[Boolean] of string = (sFailureReport, sSuccessReport);
  Responses: array[Boolean] of TOpArray = (
    (sNEQ, sGTE, sLTE, sGT, sLT, SEQ),
    (sEQ, sLT, sGT, sLTE, sGTE, sNEQ)
  );
begin
  fConsole.WriteLn(
    TConsole.TChannel.StdOut,
    string.Format(
      Reports[CompareResult], [DateTypeResponses[fParams.DateType]]
    )
  );
  fConsole.WriteLn(
    TConsole.TChannel.StdOut,
    string.Format(
      Responses[CompareResult, fParams.ComparisonOp],
      [FileName1, FileName2]
    )
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
  fConsole.WriteLn(TConsole.TChannel.StdOut, sHelpDateFormatCmd);
  fConsole.WriteLn(TConsole.TChannel.StdOut, sHelpDateBasisCmd);
  fConsole.WriteLn(TConsole.TChannel.StdOut, sHelpFollowSymlinksCmd);
  {$IF Defined(MSWINDOWS)}
  fConsole.WriteLn(TConsole.TChannel.StdOut, sHelpFollowShortcutsCmd);
  fConsole.WriteLn(TConsole.TChannel.StdOut, sHelpFollowAllLinksCmd);
  {$ENDIF}
  fConsole.WriteLn(TConsole.TChannel.StdOut, sHelpVerboseCmd);
  fConsole.WriteLn(TConsole.TChannel.StdOut, sHelpExtraVerboseCmd);
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

