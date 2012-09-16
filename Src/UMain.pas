{
 * UMain.pas
 *
 * Class that executes program.
 *
 * $Rev$
 * $Date$
 *
 * ***** BEGIN LICENSE BLOCK *****
 *
 * Version: MPL 1.1/GPL 2.0/LGPL 2.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with the
 * License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/MPL-1.1
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 *
 * The Original Code is UConsole.pas from the CompFileDate project.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2009 by
 * the Initial Developer. All Rights Reserved.
 *
 * Contributors:
 *   None.
 *
 * Alternatively, the contents of this file may be used under the terms of
 * either the GNU General Public License Version 2 or later (the "GPL"), or the
 * GNU Lesser General Public License Version 2.1 or later (the "LGPL"), in which
 * case the provisions of the GPL or the LGPL are applicable instead of those
 * above. If you wish to allow use of your version of this file only under the
 * terms of either the GPL or the LGPL, and not to allow others to use your
 * version of this file under the terms of the MPL, indicate your decision by
 * deleting the provisions above and replace them with the notice and other
 * provisions required by the LGPL or the GPL. If you do not delete the
 * provisions above, a recipient may use your version of this file under the
 * terms of any one of the MPL, the GPL or the LGPL.
 *
 * ***** END LICENSE BLOCK *****
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
    function IsFile1EarlierThanFile2(const File1, File2: string): Boolean;
      {Checks if a file has an earlier modification date than a second file.
        @param File1 [in] Name of first file to be compared.
        @param File2 [in] Name of second file to be compared.
        @return True if File1 has earlier modification date than File2.
      }
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
  UAppException;


resourcestring
  // Messages written to console
  sSignOn = 'CompFileDate %s by DelphiDabbler (www.delphidabbler.com)';
  sError = 'Error: %s';
  sUsage = 'Usage: CompFileDate filename1 filename2 [-v]'#13#10
         + '  or   CompFileDate -h | -?';
  sHelp =
      '  filename1 | Name of first file to be compared.'#13#10
    + '  filename2 | Name of second file to be compared.'#13#10
    + '  -v        | Verbose: writes output to standard output. No output if '
    + '- v not'#13#10'            | provided. Ignored on error.'#13#10
    + '  -h or -?  | Displays help screen. Rest of command line ignored.'#13#10
    + #13#10
    + 'Exit code is 1 if filename1 is earlier than filename2 and zero if not.'
    + #13#10
    + 'If an error occurs then an error code >= 100 is returned and an error '
    + 'message'#13#10'is written to standard output, regardless of the -v '
    + 'switch. See documentation'#13#10'for details of error codes.';
  sFile1Older = '"%0:s" is older than "%1:s"';
  sFile1NotOlder = '"%0:s" is not older than "%1:s"';


{ TMain }

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
      if IsFile1EarlierThanFile2(fParams.FileName1, fParams.FileName2) then
      begin
        fConsole.WriteLn(
          Format(sFile1Older, [fParams.FileName1, fParams.FileName2])
        );
        ExitCode := 1;
      end
      else
      begin
        fConsole.WriteLn(
          Format(sFile1NotOlder, [fParams.FileName1, fParams.FileName2])
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

function TMain.IsFile1EarlierThanFile2(const File1, File2: string): Boolean;
  {Checks if a file has an earlier modification date than a second file.
    @param File1 [in] Name of first file to be compared.
    @param File2 [in] Name of second file to be compared.
    @return True if File1 has earlier modification date than File2.
  }
var
  FileDate1, FileDate2: TDateTime;  // modification dates of files
begin
  if not FileAge(File1, FileDate1) then
    raise EApplication.Create(
      sAppErrFileNameNotFound, [File1], cAppErrFileNameNotFound
    );
  if not FileAge(File2, FileDate2) then
    raise EApplication.Create(
      sAppErrFileNameNotFound, [File2], cAppErrFileNameNotFound
    );
  Result := CompareDateTime(FileDate1, FileDate2) < 0;
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

