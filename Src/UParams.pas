{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at https://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2009-2026, Peter Johnson (gravatar.com/delphidabbler).
 *
 * Class that parses command line and exposes results in properties.
}


unit UParams;


interface


uses
  // Delphi
  System.Classes,
  // Project
  UDateComparer,
  UDateExtractor,
  USysDate;


type

  ///  <summary>Class that parses the command line and exposes the results as
  ///  properties.</summary>
  TParams = class(TObject)
  strict private
    const
      // Valid values of date type command
      DateTypeCreateValues: array of string = [
        // Values that existed a v2.4.0: generate warning on Linux
        'c', 'created', 'creation'
        // Value added after v2.4.0: error on Linux
        {$IF Defined(MSWINDOWS)}, 'create'{$ENDIF}
      ];
      DateTypeModifyValues: array of string = [
        'm', 'modify', 'modified', 'last-modified', 'modification', 'update',
        'updated', 'last-updated', 'write', 'written', 'last-written'
      ];
      DateTypeAccessValues: array of string = [
        'a', 'accessed', 'last-accessed', 'access', 'read', 'last-read'
      ];
      DateTypeStatusChangeValues: array of string = [
        's', 'status', 'status-change', 'last-status-change', 'status-changed',
        'metadata', 'metadata-change', 'last-metadata-change',
        'metadata-changed'
      ];
      // Valid values of compare command
      CompareEQValues: array of string = [
        '=', '==', 'eq', 'eql', 'equal', 'same'
      ];
      CompareGTValues: array of string = [
        '>', 'gt', 'newer', 'later', 'after'
      ];
      CompareGTEValues: array of string = [
        '>=', 'gte', 'ge', 'goe', 'no-older', 'not-older', 'no-earlier',
        'not-earlier', 'not-before'
      ];
      CompareLTValues: array of string = [
        '<', 'lt', 'older', 'earlier', 'before'
      ];
      CompareLTEValues: array of string = [
        '<=', 'lte', 'le', 'loe', 'no-newer', 'not-newer', 'no-later',
        'not-later', 'not-after'
      ];
      CompareNEQValues: array of string = [
        '<>', '!=', '~=', 'neq', 'ne', 'not-equal', 'not-same', 'different'
      ];
  strict private
    var
      // List of command line parameters
      fParams: TStringList;
      // Property values
      fVerbose: Boolean;
      fExtraVerbose: Boolean;
      fHelp: Boolean;
      fShortHelp: Boolean;
      fVersion: Boolean;
      fComparisonOp: TDateComparer.TOp;
      fDateType: TDateExtractor.TDateType;
      fDateBasis: TSysDate.TDateBasis;
      fDateFormat: TSysDate.TDateFormat;
      fFollowShortcuts: Boolean;
      fFileName2: string;
      fFileName1: string;
      // List of warnings
      fWarnings: TStrings;
    ///  <summary>Parses the command at a given index on the command line.
    ///  </summary>
    ///  <param name="Idx">[in/out] When called <c>Idx</c> is set to the index
    ///  of the command to be parsed. On return <c>Idx</c> is updated to
    ///  reference the next command.</param>
    ///  <exception><c>EApplication</c> raised if the command is not valid.
    ///  </exception>
    procedure ParseCommand(var Idx: Integer);
    ///  <summary>Parses a comparison type from the command line and updates the
    ///  <c>ComparisonOp</c> property accordingly.</summary>
    ///  <param name="CT">[in] Parameter that names the comparison type.</param>
    ///  <exception><c>EApplication</c> raised if <c>CT</c> is not a valid
    ///  comparison name.</exception>
    procedure ParseCompareType(CT: string);
    ///  <summary>Parses a date type from the command line and updates the
    ///  <c>DateType</c> property accordingly.</summary>
    ///  <param name="DT">[in] Parameter that names the date type.</param>
    ///  <exception><c>EApplication</c> raised if <c>DT</c> is not a valid
    ///  date type name.</exception>
    procedure ParseDateType(DT: string);
    ///  <summary>Checks if a given value is contained in a given array of valid
    ///  values.</summary>
    ///  <param name="AValue">[in] Value to be tested.</param>
    ///  <param name="AValidValues">[in] Array containing the valid values.
    ///  </param>
    ///  <returns><c>Boolean</c>. <c>True</c> if <c>AValue</c> is valid,
    ///  <c>False</c> if not.</returns>
    ///  <remarks>The test for validity is case insensitive.</remarks>
    class function IsValidValue(const AValue: string;
      const AValidValues: array of string): Boolean;
    ///  <summary>Read accessor for <c>Warnings</c> property.</summary>
    function GetWarnings: TArray<string>;
  public
    ///  <summary>Object constructor.</summary>
    constructor Create;
    ///  <summary>Object destructor.</summary>
    destructor Destroy; override;
    ///  <summary>Parses the command line.</summary>
    ///  <exception><c>EApplication</c> raised if any command line parameters
    ///  are not valid.</exception>
    procedure Parse;
    ///  <summary>Specifies whether the program is to be run in verbose mode.
    ///  </summary>
    ///  <remarks><c>True</c> if either the -v or --verbose command has been
    ///  specified, <c>False</c> if not.</remarks>
    property Verbose: Boolean read fVerbose;
    ///  <summary>Specifies whether the program is to be run in extra verbose
    ///  mode.</summary>
    ///  <remarks><c>True</c> if any of the -x, -vv or --extra-verbose command
    ///  has been specified, <c>False</c> if not.</remarks>
    property ExtraVerbose: Boolean read fExtraVerbose;
    ///  <summary>Specifies whether help text is to be displayed.</summary>
    ///  <remarks><c>True</c> if either the -h, -? or --help command has been
    ///  specified, <c>False</c> if not.</remarks>
    property Help: Boolean read fHelp;
    ///  <summary>Specifies whether short help text is to be displayed.
    ///  </summary>
    ///  <remarks><c>True</c> if the program started with no file names provided
    ///  on the command line, <c>False</c> otherwise.</remarks>
    property ShortHelp: Boolean read fShortHelp;
    ///  <summary>Specifies whether the program's version information is to be
    ///  displayed.</summary>
    ///  <remarks><c>True</c> if either the -V or --version command has been
    ///  specified, <c>False</c> otherwise.</remarks>
    property Version: Boolean read fVersion;
    ///  <summary>Type of comparison to be applied to dates.</summary>
    ///  <remarks>Defaults to <c>TDateComparer.TOp.LT</c> unless either the -c
    ///  or --compare commands are used to override this value.</remarks>
    property ComparisonOp: TDateComparer.TOp read fComparisonOp;
    ///  <summary>Specifies whether to compare files' last-modified or creation
    ///  dates.</summary>
    ///  <remarks>Defaults to <c>TDateExtractor.TDateType.LastModified</c>
    ///  unless either the -d or --datetype command are used to override this
    ///  value.</remarks>
    property DateType: TDateExtractor.TDateType read fDateType;
    ///  <summary>Specifies the date format to be used when displaying file
    ///  dates.</summary>
    ///  <remarks>Defaults to the locale specific date format unless the
    ///  <c>--iso-dates</c> or <c>-i</c> command is specified when ISO 8601 date
    ///  format is used instead.</remarks>
    property DateFormat: TSysDate.TDateFormat read fDateFormat;
    ///  <summary>Specifies the time zone to be used as the basis when
    ///  displaying file dates.</summary>
    ///  <remarks>Default to displaying dates in UTC unless the
    ///  <c>--local-time</c> or <c>-l</c> is specified when dates are displayed
    ///  in local time.</remarks>
    property DateBasis: TSysDate.TDateBasis read fDateBasis;
    ///  <summary>Specifies if shortcut files are to be expanded before
    ///  comparing dates.</summary>
    ///  <remarks>When <c>True</c> the files targeted by any shortcut are used
    ///  in the date comparison; when <c>False</c> the date of the shortcut file
    ///  itself is used. Defaults to <c>False</c> unless the -s or
    ///  --followshortcuts command has been specified.</remarks>
    property FollowShortcuts: Boolean read fFollowShortcuts;
    ///  <summary>Name of the 1st file on the command line.</summary>
    property FileName1: string read fFileName1;
    ///  <summary>Name of the 2nd file on the command line.</summary>
    property FileName2: string read fFileName2;
    ///  <summary>Array of any warnings generated while parsing parameters
    property Warnings: TArray<string> read GetWarnings;
  end;


implementation


uses
  // Delphi
  System.SysUtils,
  // Project
  UAppException;


resourcestring
  // Error messages
  sBadSwitch = 'Invalid command "%s"';
  s2FilesNeeded = 'Exactly two file names must be specified';
  sFileNamesSame = 'File names must be different';
  sNoCompareType = 'No comparison type specified for -c or --compare command';
  sBadCompareType = 'Invalid comparison type in -c or --compare command';
  sNoDateType = 'No date type specified for -d or --datetype command';
  sBadDateType = 'Invalid date type in -d or --datetype command';
  sNoShortcutsOnLinux =
    'The -s or --followshortcuts command is not supported on Linux';
  sNoCTimeOnWindows = 'The "%s" date type is not supported on Windows';
  // Warning messages
  sNoCreationDate =
    'The "%s" date type is deprecated on Linux. '
    + 'Using "status-changed" instead.';


{ TParams }

constructor TParams.Create;
begin
  inherited Create;
  // Stores program parameters
  fParams := TStringList.Create;
  for var Idx := 1 to ParamCount do
    fParams.Add(Trim(ParamStr(Idx)));
  // Set defaults
  fHelp := False;
  fVersion := False;
  fVerbose := False;
  fExtraVerbose := False;
  fFileName1 := string.Empty;
  fFileName2 := string.Empty;
  fComparisonOp := TDateComparer.TOp.LT;
  fDateType := TDateExtractor.TDateType.LastModified;
  fDateBasis := TSysDate.TDateBasis.UTC;
  fDateFormat := TSysDate.TDateFormat.LocaleSpecific;
  fFollowShortcuts := False;
  fWarnings := TStringList.Create;
end;

destructor TParams.Destroy;
begin
  fWarnings.Free;
  fParams.Free;
  inherited;
end;

function TParams.GetWarnings: TArray<string>;
begin
  Result := fWarnings.ToStringArray;
end;

class function TParams.IsValidValue(const AValue: string;
  const AValidValues: array of string): Boolean;
begin
  Result := False;
  for var ValidValue in AValidValues do
    if string.Compare(ValidValue, AValue, True) = 0 then
      Exit(True);
end;

procedure TParams.Parse;
begin
  // Loop through all commands on command line
  var Idx: Integer := 0;
  while Idx < fParams.Count do
  begin
    // Check we have a command
    if not fParams[Idx].StartsWith('-') then
    begin
      if fFileName1.IsEmpty then
        fFileName1 := fParams[Idx]
      else if fFileName2.IsEmpty then
        fFileName2 := fParams[Idx]
      else
        raise EApplication.Create(s2FilesNeeded, EApplication.Err2FilesNeeded);
    end
    else
      ParseCommand(Idx);
    // Next parameter
    Inc(Idx);
  end;
  if not Help and not Version then
  begin
    if fFileName1.IsEmpty and fFileName2.IsEmpty then
      fShortHelp := True
    else
    begin
      if fFileName1.IsEmpty or fFileName2.IsEmpty then
        raise EApplication.Create(s2FilesNeeded, EApplication.Err2FilesNeeded);
      if fFileName1.CompareTo(fFileName2) = 0 then
        raise EApplication.Create(
          sFileNamesSame, EApplication.ErrFileNamesSame
        );
    end;
  end;
end;

procedure TParams.ParseCommand(var Idx: Integer);
begin
  var Command := fParams[Idx];
  Assert(Command.StartsWith('-'));
  if (Command = '-h') or (Command = '-?') or (Command = '--help') then
  begin
    if not fVersion then
      fHelp := True;
  end
  else if (Command = '-V') or (Command = '--version') then
  begin
    if not fHelp then
      fVersion := True
  end
  else if (Command = '-v') or (Command = '--verbose') then
    fVerbose := True
  else if (Command = '-x') or (Command = '-vv')
    or (Command = '--extra-verbose') then
  begin
    fVerbose := True;
    fExtraVerbose := True;
  end
  else if (Command = '-s') or (Command = '--followshortcuts') then
    {$IF Defined(MSWINDOWS)}
    fFollowShortcuts := True
    {$ENDIF}
    {$IF Defined(LINUX)}
    raise EApplication.Create(sNoShortcutsOnLinux, EApplication.ErrBadSwitch)
    {$ENDIF}
  else if (Command = '-c') then
  begin
    Inc(Idx);
    ParseCompareType(
      if Idx < fParams.Count then fParams[Idx] else string.Empty
    );
  end
  else if (Command = '-d') then
  begin
    Inc(Idx);
    ParseDateType(if Idx < fParams.Count then fParams[Idx] else string.Empty);
  end
  else if Command.StartsWith('--compare') then
  begin
    var EqualsPos := Command.IndexOf('=') + 1;
    ParseCompareType(
      if EqualsPos > 0 then Command.Substring(EqualsPos) else string.Empty
    );
  end
  else if Command.StartsWith('--datetype') then
  begin
    var EqualsPos := Command.IndexOf('=') + 1;
    ParseDateType(
      if EqualsPos > 0 then Command.Substring(EqualsPos) else string.Empty
    );
  end
  else if (Command = '-i') or (Command = '--iso-dates') then
    fDateFormat := TSysDate.TDateFormat.ISO8601
  else if (Command = '-l') or (Command = '--local-time') then
    fDateBasis := TSysDate.TDateBasis.Local
  else
    raise EApplication.CreateFmt(
      sBadSwitch, [fParams[Idx], EApplication.ErrBadSwitch]
    );
end;

procedure TParams.ParseCompareType(CT: string);
begin
  if CT.IsEmpty then
    raise EApplication.Create(sNoCompareType, EApplication.ErrNoCompareType);
  if IsValidValue(CT, CompareEQValues) then
    fComparisonOp := TDateComparer.TOp.EQ
  else if IsValidValue(CT, CompareGTValues) then
    fComparisonOp := TDateComparer.TOp.GT
  else if IsValidValue(CT, CompareGTEValues) then
    fComparisonOp := TDateComparer.TOp.GTE
  else if IsValidValue(CT, CompareLTValues) then
    fComparisonOp := TDateComparer.TOp.LT
  else if IsValidValue(CT, CompareLTEValues) then
    fComparisonOp := TDateComparer.TOp.LTE
  else if IsValidValue(CT, CompareNEQValues) then
    fComparisonOp := TDateComparer.TOp.NEQ
  else
    raise EApplication.Create(sBadCompareType, EApplication.ErrBadCompareType);
end;

procedure TParams.ParseDateType(DT: string);
begin
  if DT.IsEmpty then
    raise EApplication.Create(sNoDateType, EApplication.ErrNoDateType);
  if IsValidValue(DT, DateTypeModifyValues) then
    fDateType := TDateExtractor.TDateType.LastModified
  else if IsValidValue(DT, DateTypeCreateValues) then
  begin
    {$IF Defined(MSWINDOWS)}
    fDateType := TDateExtractor.TDateType.Created;
    {$ELSEIF Defined(LINUX)}
    fDateType := TDateExtractor.TDateType.StatusChanged;
    fWarnings.Add(string.Format(sNoCreationDate, [DT]));
    {$ENDIF}
  end
  else if IsValidValue(DT, DateTypeAccessValues) then
    fDateType := TDateExtractor.TDateType.LastAccessed
  else if IsValidValue(DT, DateTypeStatusChangeValues) then
  begin
    {$IF Defined(MSWINDOWS)}
    raise EApplication.Create(
      sNoCTimeOnWindows, [DT], EApplication.ErrBadDateType
    );
    {$ELSEIF Defined(LINUX)}
    fDateType := TDateExtractor.TDateType.StatusChanged;
    {$ENDIF}
  end
  else
    raise EApplication.Create(sBadDateType, EApplication.ErrBadDateType);
end;

end.

