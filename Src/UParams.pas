{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at https://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2009-2021, Peter Johnson (gravatar.com/delphidabbler).
 *
 * Class that parses command line and exposes results in properties.
}


unit UParams;


interface


uses
  // Delphi
  System.Classes,
  // Project
  UDateComparer, UDateExtractor;


type

  {
  TParams:
    Class that parses command line and exposes results in properties.
  }
  TParams = class(TObject)
  private
    fParams: TStringList;             // List of command line parameters
    fVerbose: Boolean;                // Value of Verbose property
    fHelp: Boolean;                   // Value of Help property
    fShortHelp: Boolean;              // Value of ShortHelp property
    fVersion: Boolean;                // Value of Version property
    fComparisonOp: TDateComparisonOp; // Value of ComparisonType property
    fDateType: TDateType;             // Value of DateType property
    fFollowShortcuts: Boolean;        // Value of FollowShortcuts property
    fFileName2: string;               // Value of FileName1 property
    fFileName1: string;               // Value of FileName2 property
    procedure ParseCommand(var Idx: Integer);
    procedure ParseCompareType(CT: string);
    procedure ParseDateType(DT: string);
  public
    constructor Create;
      {Constructs object instance.
      }
    destructor Destroy; override;
      {Destroys object instance.
      }
    procedure Parse;
      {Parses the command line.
        @except Exception raised if error in command line.
      }
    property Verbose: Boolean read fVerbose;
      {Flag true if -v or --verbose command has been provided on command line}
    property Help: Boolean read fHelp;
      {Flag true if -h, -? or --help command has been provided on command line}
    property ShortHelp: Boolean read fShortHelp;
      {Flag true if program is started with no file names provided on command
      line}
    property Version: Boolean read fVersion;
      {Flag true if -V or --version command has been provided on command line}
    property ComparisonOp: TDateComparisonOp read fComparisonOp;
      {Type of comparison to be applied to file dates}
    property DateType: TDateType read fDateType;
      {Specifies which file date to read: last modified or creation date}
    property FollowShortcuts: Boolean read fFollowShortcuts;
      {Specifies if shortcut files are to be followed. When True the files
      targeted by any shortcut are used in the date comparison, otherwise the
      date of the shortcut file itself is used}
    property FileName1: string read fFileName1;
      {First file name on command line}
    property FileName2: string read fFileName2;
      {Second file name on command line}
  end;


implementation


uses
  // Delphi
  System.StrUtils,
  System.SysUtils,
  WinApi.Windows {for inlining},
  // Project
  UAppException;


{ TParams }

constructor TParams.Create;
var
  Idx: Integer; // loops through all parameters
begin
  inherited Create;
  // Stores program parameters
  fParams := TStringList.Create;
  for Idx := 1 to ParamCount do
    fParams.Add(Trim(ParamStr(Idx)));
  // Set defaults
  fHelp := False;
  fVersion := False;
  fVerbose := False;
  fFileName1 := '';
  fFileName2 := '';
  fComparisonOp := TDateComparisonOp.LT;
  fDateType := TDateType.LastModified;
  fFollowShortcuts := False;
end;

destructor TParams.Destroy;
begin
  fParams.Free;
  inherited;
end;

procedure TParams.Parse;
var
  Idx: Integer;         // loops through all parameters on command line
begin
  // Loop through all switches on command line
  Idx := 0;
  while Idx < fParams.Count do
  begin
    // Check we have a switch
    if not AnsiStartsStr('-', fParams[Idx]) then
    begin
      if fFileName1 = '' then
        fFileName1 := fParams[Idx]
      else if fFileName2 = '' then
        fFileName2 := fParams[Idx]
      else
        raise EApplication.Create(sAppErr2FilesNeeded, cAppErr2FilesNeeded);
    end
    else
      ParseCommand(Idx);
    // Next parameter
    Inc(Idx);
  end;
  if not Help and not Version then
  begin
    if (fFileName1 = '') and (fFileName2 = '') then
      fShortHelp := True
    else
    begin
      if (fFileName1 = '') or (fFileName2 = '') then
        raise EApplication.Create(sAppErr2FilesNeeded, cAppErr2FilesNeeded);
      if AnsiSameText(fFileName1, fFileName2) then
        raise EApplication.Create(sAppErrFileNamesSame, cAppErrFileNamesSame);
    end;
  end;
end;

procedure TParams.ParseCommand(var Idx: Integer);
var
  Command: string;
  EqualsPos: Integer;
begin
  Command := fParams[Idx];
  Assert(AnsiStartsStr('-', Command));
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
  else if (Command = '-s') or (Command = '--followshortcuts') then
    fFollowShortcuts := True
  else if (Command = '-c') then
  begin
    Inc(Idx);
    if Idx < fParams.Count then
      ParseCompareType(fParams[Idx])
    else
      ParseCompareType('');   // reports error
  end
  else if (Command = '-d') then
  begin
    Inc(Idx);
    if Idx < fParams.Count then
      ParseDateType(fParams[Idx])
    else
      ParseDateType('');      // reports error
  end
  else if AnsiStartsStr('--compare', Command) then
  begin
    EqualsPos := AnsiPos('=', Command);
    if EqualsPos > 0 then
      ParseCompareType(AnsiRightStr(Command, Length(Command) - EqualsPos))
    else
      ParseCompareType('');   // reports error
  end
  else if AnsiStartsStr('--datetype', Command) then
  begin
    EqualsPos := AnsiPos('=', Command);
    if EqualsPos > 0 then
      ParseDateType(AnsiRightStr(Command, Length(Command) - EqualsPos))
    else
      ParseDateType('');   // reports error
  end
  else
    raise EApplication.CreateFmt(
      sAppErrBadSwitch, [fParams[Idx], cAppErrBadSwitch]
    );
end;

procedure TParams.ParseCompareType(CT: string);
begin
  if CT = '' then
    raise EApplication.Create(sAppErrNoCompareType, cAppErrNoCompareType);
  CT := AnsiLowerCase(CT);
  if (CT = 'eq') or (CT = 'equal') or (CT = 'same') then
    fComparisonOp := TDateComparisonOp.EQ
  else if (CT = 'gt') or (CT = 'newer') or (CT = 'later') then
    fComparisonOp := TDateComparisonOp.GT
  else if (CT = 'gte') or (CT = 'not-older') or (CT = 'not-earlier') then
    fComparisonOp := TDateComparisonOp.GTE
  else if (CT = 'lt') or (CT = 'older') or (CT = 'earlier') then
    fComparisonOp := TDateComparisonOp.LT
  else if (CT = 'lte') or (CT = 'not-newer') or (CT = 'not-later') then
    fComparisonOp := TDateComparisonOp.LTE
  else if (CT = 'neq') or (CT = 'not-equal') or (CT = 'not-same')
    or (CT = 'different') then
    fComparisonOp := TDateComparisonOp.NEQ
  else
    raise EApplication.Create(sAppErrBadCompareType, cAppErrBadCompareType);
end;

procedure TParams.ParseDateType(DT: string);
begin
  if DT = '' then
    raise EApplication.Create(sAppErrNoDateType, cAppErrNoDateType);
  DT := AnsiLowerCase(DT);
  if (DT = 'm') or (DT = 'modified') or (DT = 'last-modified')
    or (DT = 'modification') then
    fDateType := TDateType.LastModified
  else if (DT = 'c') or (DT = 'created') or (DT = 'creation') then
    fDateType := TDateType.Created
  else
    raise EApplication.Create(sAppErrBadDateType, cAppErrBadDateType);
end;

end.

