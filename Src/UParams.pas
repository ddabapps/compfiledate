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
  System.Types,
  System.Classes,
  System.Generics.Collections,
  // Project
  UDateComparer,
  UDateExtractor,
  USysDate;


type

  ///  <summary>Class that parses the command line and exposes the results as
  ///  properties.</summary>
  TParams = class(TObject)
  strict private
    type
      {$SCOPEDENUMS ON}
      // IDs for all supported commands
      TCommandID = (
        // DO NOT assign values to this enumeration - following code assumes
        // Ord(first-value) = 0 and Ord(last-value) = Pred(number of elements)
        Help
        , Version
        , Verbose
        , ExtraVerbose
        {$IF Defined(MSWINDOWS)}
        , FollowShortcuts
        {$ENDIF}
        , ComparisonOp
        , DateType
        , LocalTime
        , ISODates
        , FollowSymlinks
        {$IF Defined(MSWINDOWS)}
        , FollowAllLinks
        {$ENDIF}
      );
      {$SCOPEDENUMS OFF}

      // Container for a command's ID, an array of text commands (keys) that
      // represent the command and a flag that indicates whether the command
      // has an associated value.
      TCommandInfo = record
        ID: TCommandID;
        Keys: array of string;
        ExpectsValue: Boolean;
      end;

    const
      // Lookup table listing information about all supported commands
      CommandLookup: array[0..Ord(High(TCommandID))] of TCommandInfo = (
        (
          ID: TCommandID.Help;
          Keys: ['-h', '-?', '--help'];
          ExpectsValue: False
        )
        ,
        (
          ID: TCommandID.Version;
          Keys: ['-V', '--version'];
          ExpectsValue: False
        )
        ,
        (
          ID: TCommandID.Verbose;
          Keys: ['-v', '--verbose'];
          ExpectsValue: False
        )
        ,
        (
          ID: TCommandID.ExtraVerbose;
          Keys: ['-x', '-vv', '--extra-verbose'];
          ExpectsValue: False
        )
        {$IF Defined(MSWINDOWS)}
        ,
        (
          ID: TCommandID.FollowShortcuts;
          Keys: ['-sh', '-s', '--follow-shortcuts'];
          ExpectsValue: False
        )
        {$ENDIF}
        ,
        (
          ID: TCommandID.ComparisonOp;
          Keys: ['-c', '--compare'];
          ExpectsValue: True
        )
        ,
        (
          ID: TCommandID.DateType;
          Keys: ['-d', '--date-type'];
          ExpectsValue: True
        )
        ,
        (
          ID: TCommandID.LocalTime;
          Keys: ['-l', '--local-time'];
          ExpectsValue: False
        )
        ,
        (
          ID: TCommandID.ISODates;
          Keys: ['-i', '--iso-dates'];
          ExpectsValue: False
        )
        ,
        (
          ID: TCommandID.FollowSymlinks;
          Keys: ['-sy', '-S', '--follow-symlinks'];
          ExpectsValue: False
        )
        {$IF Defined(MSWINDOWS)}
        ,
        (
          ID: TCommandID.FollowAllLinks;
          Keys: ['-ss', '--follow-all-links'];
          ExpectsValue: False
        )
        {$ENDIF}
      );
    const
      // Map of date types to valid values
      DateTypeMap: array[TDateExtractor.TDateType] of TStringDynArray = (
        [ // LastModified
          'm', 'modify', 'modified', 'last-modified', 'modification', 'update',
          'updated', 'last-updated', 'write', 'written', 'last-written'
        ],
        {$IF Defined(MSWINDOWS)}
        [ // Created
          'c', 'created', 'creation', 'create'
        ],
        {$ENDIF}
        {$IF Defined(LINUX)}
        [ // StatusChanged
          's', 'status', 'status-change', 'last-status-change',
          'status-changed', 'metadata', 'metadata-change',
          'last-metadata-change', 'metadata-changed'
        ],
        {$ENDIF}
        [ // LastAccessed
          'a', 'accessed', 'last-accessed', 'access', 'read', 'last-read'
        ]
      );

      // Map of compare operators to valid values
      CompareMap: array[TDateComparer.TOp] of TStringDynArray = (
        [ // TOp.EQ
          '=', '==', 'eq', 'eql', 'equal', 'same'
        ],
        [ // TOp.LT
          '<', 'lt', 'older', 'earlier', 'before'
        ],
        [ // TOp.GT
          '>', 'gt', 'newer', 'later', 'after'
        ],
        [ // TOp.LTE
          '<=', 'lte', 'le', 'loe', 'no-newer', 'not-newer', 'no-later',
          'not-later', 'not-after'
        ],
        [ // TOp.GTE
          '>=', 'gte', 'ge', 'goe', 'no-older', 'not-older', 'no-earlier',
          'not-earlier', 'not-before'
        ],
        [ // TOp.NEQ
          '<>', '!=', '~=', 'neq', 'ne', 'not-equal', 'not-same', 'different'
        ]
      );
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
      fFollowSymlinks: Boolean;
      fFileName2: string;
      fFileName1: string;
      // List of warnings
      fWarnings: TStrings;

    ///  <summary>Checks if string <c>AStr</c> is contained in string array
    ///  <c>AArr</c>, ignoring case.</summary>
    class function IsStrInArray(const AStr: string; const AArr: array of string;
      const AIgnoreCase: Boolean): Boolean;
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
    ///  <summary>Attempts to look up information about a command.</summary>
    ///  <param name="ACommand">[in] Command to look up.</param>
    ///  <param name="AID">[out] Set to the command's ID. Undefined if the
    ///  command is not found.</param>
    ///  <param name="AExpectsValue">[out] Set to a flag the indicates if the
    ///  command has an associated value. Undefined if the command is not found.
    ///  </param>
    ///  <returns><c>Boolean</c>. <c>True</c> if the command is found or
    ///  <c>False</c> if not.</returns>
    class function TryLookupCommandInfo(const ACommand: string;
      out AID: TCommandID; out AExpectsValue: Boolean): Boolean;
    ///  <summary>Checks if a parameter represents a correctly formatted long
    ///  form command.</summary>
    ///  <param name="AParam">[in] Parameter to be checked</param>
    ///  <returns><c>Boolean</c>. <c>True</c> if the parameter begins with a
    ///  long form command, <c>False</c> otherwise.</returns>
    ///  <remarks>This method only checks for a command in the correct format
    ///  (i.e. <c>--xxx</c>) but doesn't check that the command is supported.
    ///  </remarks>
    class function IsLongCommand(const AParam: string): Boolean;
    ///  <summary>Checks if a parameter represents a correctly formatted short
    ///  form command.</summary>
    ///  <param name="AParam">[in] Parameter to be checked.</param>
    ///  <returns><c>Boolean</c>. <c>True</c> if the parameter begins with a
    ///  short form command, <c>False</c> otherwise.</returns>
    ///  <remarks>This method only checks for a command in the correct format
    ///  (i.e. <c>-x</c>) but doesn't check that the command is supported.
    ///  </remarks>
    class function IsShortCommand(const AParam: string): Boolean;
    ///  <summary>Checks if the parameter contains a correctly formatted command
    ///  in either long or short format.</summary>
    ///  <param name="AParam">[in] Parameter to be checked.</param>
    ///  <returns><c>Boolean</c>. <c>True</c> if the parameter begins with a
    ///  correctly formatted command, <c>False</c> otherwise.</returns>
    ///  <remarks>This method only checks for a command in the correct format
    ///  but doesn't check that the command is supported.</remarks>
    class function IsCommand(const AParam: string): Boolean;
    ///  <summary>Checks if a given command is contained in a given array of
    ///  valid commands.</summary>
    ///  <param name="AParam">[in] Command to be tested.</param>
    ///  <param name="AValidParams">[in] Array containing the valid commands.
    ///  </param>
    ///  <returns><c>Boolean</c>. <c>True</c> if <c>AParam</c> is valid,
    ///  <c>False</c> if not.</returns>
    ///  <remarks>The test for validity is case sensitive. Commands that differ
    ///  only in case are treated as different commands.</remarks>
    class function IsValidCommand(const ACommand: string;
      const AValidCommands: array of string): Boolean;
    ///  <summary>Checks if a given value is contained in a given array of valid
    ///  values.</summary>
    ///  <param name="AValue">[in] Value to be tested.</param>
    ///  <param name="AValidValues">[in] Array containing the valid values.
    ///  </param>
    ///  <returns><c>Boolean</c>. <c>True</c> if <c>AValue</c> is valid,
    ///  <c>False</c> if not.</returns>
    ///  <remarks>The test for validity is case insensitive. Values that differ
    ///  only in case are treated as the same values.</remarks>
    class function IsValidValue(const AValue: string;
      const AValidValues: array of string): Boolean;
    ///  <summary>Gets the command and any associated value starting at the
    ///  given index in the parameter list.</summary>
    ///  <param name="AParamIdx">[in/out]. The index where the command begins in
    ///  the parameter list. On return this value may be incremented by <c>1</c>
    ///  if any value is in the next item on the command line.</param>
    ///  <returns><c>TPair&lt;string,string&gt;</c>. A key/value pair of strings
    ///  where the command is stored in the <c>Key</c> field and any value is
    ///  stored in the <c>Value</c> field. If the command has no associated
    ///  value then <c>Value</c> is set to the empty string.</returns>
    ///  <exception><c>EApplication</c> is raised if the referenced parameter is
    ///  not a correctly formatted command.</exception>
    ///  <remarks>This method only checks for correctly formatted commands and
    ///  values. It does not check if the commands or values are supported.
    ///  </remarks>
    function GetCommandAndValue(var AParamIdx: Integer): TPair<string,string>;
    ///  <summary>Gets the ID and any associated value of a supported command
    ///  tarting at the given index in the parameter list.</summary>
    ///  <param name="AParamIdx">[in/out]. The index where the command begins in
    ///  the parameter list. On return this value may be incremented by <c>1</c>
    ///  if any value is in the next item on the command line.</param>
    ///  <returns><c>TPair&lt;TCommandID,string&gt;</c>. A key/value pair
    ///  representing the ID of the command and any value associated with the
    ///  command. The command ID is stored in the <c>Key</c> field and any
    ///  value is stored in the <c>Value</c> field. If the command has no
    ///  associated value then <c>Value</c> is set to the empty string.
    ///  </returns>
    ///  <exception><c>EApplication</c> is raised if the referenced parameter is
    ///  not a correctly formatted command, not a supported command, if a value
    ///  is present for a command that expects no value or if a value is not
    ///  present for a command that expects one.</exception>
    function GetCommandIDAndValue(var AParamIdx: Integer):
      TPair<TCommandID,string>;
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
    ///  unless either the -d or --date-type command are used to override this
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
    ///  itself is used. Defaults to <c>False</c> unless the -s, -sh or
    ///  --follow-shortcuts command has been specified.</remarks>
    property FollowShortcuts: Boolean read fFollowShortcuts;
    ///  <summary>Specifies if symbolic links are to be expanded before
    ///  comparing dates.</summary>
    ///  <remarks>When <c>True</c> the files targeted by any symlink are used
    ///  in the date comparison; when <c>False</c> the date of the symlink file
    ///  itself is used. Defaults to <c>False</c> unless the -S, -sy or
    ///  --follow-symlinks command has been specified.</remarks>
    property FollowSymlinks: Boolean read fFollowSymlinks;
    ///  <summary>Name of the 1st file on the command line.</summary>
    property FileName1: string read fFileName1;
    ///  <summary>Name of the 2nd file on the command line.</summary>
    property FileName2: string read fFileName2;
    ///  <summary>Array of any warnings generated while parsing parameters.
    ///  </summary>
    property Warnings: TArray<string> read GetWarnings;
  end;


implementation


uses
  // Delphi
  System.SysUtils,
  System.Character,
  // Project
  UAppException;


resourcestring
  // Error messages
  sUnknownCommand = 'Unknown command "%s"';
  sBadCommandFormat = 'Invalid command format: "%s"';
  sValueExpected = 'Value expected for command "%s"';
  sNoValueExpected = 'Command "%s" does not expect a value';
  s2FilesNeeded = 'Exactly two file names must be specified';
  sFileNamesSame = 'File names must be different';
  sBadCompareType = 'Invalid comparison type in -c or --compare command';
  sBadDateType = 'Invalid date type in -d or --date-type command';


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
  fFileName1 := string.Empty;
  fFileName2 := string.Empty;
  fComparisonOp := TDateComparer.TOp.LT;
  fDateType := TDateExtractor.TDateType.LastModified;
  fDateBasis := TSysDate.TDateBasis.UTC;
  fDateFormat := TSysDate.TDateFormat.LocaleSpecific;
  fFollowShortcuts := False;
  fFollowSymlinks := False;
  fWarnings := TStringList.Create;
end;

destructor TParams.Destroy;
begin
  fWarnings.Free;
  fParams.Free;
  inherited;
end;

function TParams.GetCommandAndValue(var AParamIdx: Integer):
  TPair<string, string>;
begin
  Assert(AParamIdx < fParams.Count);
  var Param := fParams[AParamIdx];
  if IsShortCommand(Param) then
  begin
    Result.Key := Param;
    if AParamIdx < Pred(fParams.Count) then
    begin
      var NextParam := fParams[Succ(AParamIdx)];
      if not IsCommand(NextParam) then
      begin
        Result.Value := NextParam;
        Inc(AParamIdx);
      end
      else
        Result.Value := string.Empty;
    end
    else
      Result.Value := string.Empty;
  end
  else if IsLongCommand(Param) then
  begin
    var EqualsPos := Param.IndexOf('=');
    if EqualsPos > 0 then
    begin
      Result.Key := Param.Substring(0, EqualsPos);
      Result.Value := Param.Substring(EqualsPos + 1);
    end
    else
      Result := TPair<string,string>.Create(Param, string.Empty);
  end
  else
    raise EApplication.Create(
      sBadCommandFormat, [Param], EApplication.ErrBadSwitch
    );
end;

function TParams.GetCommandIDAndValue(var AParamIdx: Integer):
  TPair<TCommandID, string>;
begin
  var Param := GetCommandAndValue(AParamIdx);
  var ExpectsValue: Boolean;
  if not TryLookupCommandInfo(Param.Key, Result.Key, ExpectsValue) then
    raise EApplication.Create(
      sUnknownCommand, [Param.Key], EApplication.ErrBadSwitch
    );
  Result.Value := Param.Value;
  if ExpectsValue and Result.Value.IsEmpty then
    raise EApplication.Create(
      sValueExpected, [Param.Key], EApplication.ErrBadSwitch
    );
  if not ExpectsValue and not Result.Value.IsEmpty then
    raise EApplication.Create(
      sNoValueExpected, [Param.Key], EApplication.ErrBadSwitch
    );
end;

function TParams.GetWarnings: TArray<string>;
begin
  Result := fWarnings.ToStringArray;
end;

class function TParams.IsCommand(const AParam: string): Boolean;
begin
  Result := IsLongCommand(AParam) or IsShortCommand(AParam);
end;

class function TParams.IsLongCommand(const AParam: string): Boolean;
begin
  Result := (AParam.Length >= 3) and (AParam[1] = '-') and (AParam[2] = '-')
    and AParam[3].IsLetterOrDigit;
end;

class function TParams.IsShortCommand(const AParam: string): Boolean;
begin
  Result := (AParam.Length >= 2) and (AParam[1] = '-')
    and AParam[2].IsLetterOrDigit;
end;

class function TParams.IsStrInArray(const AStr: string;
  const AArr: array of string; const AIgnoreCase: Boolean): Boolean;
begin
  Result := False;
  for var Item in AArr do
    if string.Compare(Item, AStr, AIgnoreCase) = 0 then
      Exit(True);
end;

class function TParams.IsValidCommand(const ACommand: string;
  const AValidCommands: array of string): Boolean;
begin
  Result := IsStrInArray(ACommand, AValidCommands, False);
end;

class function TParams.IsValidValue(const AValue: string;
  const AValidValues: array of string): Boolean;
begin
  Result := IsStrInArray(AValue, AValidValues, True);
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
  Assert((Idx >= 0) and (Idx <= fParams.Count),
    ClassName + '.ParseCommand: Idx is out of range of fParams');

  if not IsCommand(fParams[Idx]) then
    raise EApplication.Create(
      sBadCommandFormat, [fParams[Idx]], EApplication.ErrBadSwitch
    );

  var CommandInfo := GetCommandIDAndValue(Idx);

  case CommandInfo.Key of
    TCommandID.Help:
      if not fVersion then
        fHelp := True;
    TCommandID.Version:
      if not fHelp then
        fVersion := True;
    TCommandID.Verbose:
      fVerbose := True;
    TCommandID.ExtraVerbose:
    begin
      fVerbose := True;
      fExtraVerbose := True;
    end;
    {$IF Defined(MSWINDOWS)}
    TCommandID.FollowShortcuts:
      fFollowShortcuts := True;
    {$ENDIF}
    TCommandID.ComparisonOp:
      ParseCompareType(CommandInfo.Value);
    TCommandID.DateType:
      ParseDateType(CommandInfo.Value);
    TCommandID.LocalTime:
      fDateBasis := TSysDate.TDateBasis.Local;
    TCommandID.ISODates:
      fDateFormat := TSysDate.TDateFormat.ISO8601;
    TCommandID.FollowSymlinks:
      fFollowSymlinks := True;
    {$IF Defined(MSWINDOWS)}
    TCommandID.FollowAllLinks:
    begin
      fFollowSymlinks := True;
      fFollowShortcuts := True;
    end;
    {$ENDIF}
  end;
end;

procedure TParams.ParseCompareType(CT: string);
begin
  Assert(not CT.IsEmpty, ClassName + '.ParseCompareType: CT is empty string');
  var Found: Boolean := False;
  for var Op := Low(CompareMap) to High(CompareMap) do
    if IsValidValue(CT, CompareMap[Op]) then
    begin
      fComparisonOp := Op;
      Found := True;
      Break;
    end;
  if not Found then
    raise EApplication.Create(sBadCompareType, EApplication.ErrBadCompareType);
end;

procedure TParams.ParseDateType(DT: string);
begin
  Assert(not DT.IsEmpty, ClassName + '.ParseDateType: DT is empty string');
  var Found: Boolean := False;
  for var DateType := Low(DateTypeMap) to High(DateTypeMap) do
    if IsValidValue(DT, DateTypeMap[DateType]) then
    begin
      fDateType := DateType;
      Found := True;
      Break;
    end;
  if not Found then
    raise EApplication.Create(sBadDateType, EApplication.ErrBadDateType);
end;

class function TParams.TryLookupCommandInfo(const ACommand: string;
  out AID: TCommandID; out AExpectsValue: Boolean): Boolean;
begin
  Result := False;
  for var Item in CommandLookup do
  begin
    if IsValidCommand(ACommand, Item.Keys) then
    begin
      AID := Item.ID;
      AExpectsValue := Item.ExpectsValue;
      Exit(True);
    end;
  end;
end;

end.

