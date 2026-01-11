{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at https://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2009-2026, Peter Johnson (gravatar.com/delphidabbler).
 *
 * Class that writes text to console using standard output unless output is
 * inhibited.
}


unit UConsole;


interface


type

  {
  TConsole:
    Class that writes text to console using standard output unless told to be
    silent when all output is swallowed.
  }
  TConsole = class(TObject)
  public
    type
      TChannel = (StdOut, StdErr);
  strict private
    var
      fSilent: Boolean; // Value of Silent property
    function WinGetHandle(const AChannel: TChannel): THandle;
    procedure WinWrite(const AChannel: TChannel; const AText: string);
  public
    constructor Create;
      {Class constructor. Sets up object.
      }
    procedure Write(const AChannel: TChannel; const Text: string);
      {Write text to standard output unless silent.
        @param Text [in] Text to be written.
      }
    procedure WriteLn(const AChannel: TChannel; const Text: string); overload;
      {Write text followed by new line to standard output unless silent.
        @param Text [in] Text to be written.
      }
    procedure WriteLn(const AChannel: TChannel); overload;
      {Write a new line to standard output unless silent.
      }
    property Silent: Boolean read fSilent write fSilent default False;
      {Whether to be silent, i.e. write no output}
  end;


implementation


uses
  // Delphi
  System.SysUtils,
  WinApi.Windows;


{ TConsole }

constructor TConsole.Create;
  {Class constructor. Sets up object.
  }
begin
  inherited Create;
  fSilent := False;
end;

function TConsole.WinGetHandle(const AChannel: TChannel): THandle;
begin
  case AChannel of
    TChannel.StdOut:
      Result := WinApi.Windows.GetStdHandle(WinApi.Windows.STD_OUTPUT_HANDLE);
    TChannel.StdErr:
      Result := WinApi.Windows.GetStdHandle(WinApi.Windows.STD_ERROR_HANDLE);
    else
      raise EAssertionFailed.Create(
        ClassName + '.GetHandle: Invalid value for AChannel'
      );
  end;
end;

procedure TConsole.WinWrite(const AChannel: TChannel; const AText: string);
var
  Dummy: Cardinal;  // Unused param for Windows.WriteFile
  Bytes: TBytes;    // Bytes of Text in default ANSI encoding
begin
  Bytes := TEncoding.Default.GetBytes(AText);
  if Length(Bytes) = 0 then
    Exit;
  WinApi.Windows.WriteFile(
    WinGetHandle(AChannel), Pointer(Bytes)^, Length(Bytes), Dummy, nil
  );
end;

procedure TConsole.Write(const AChannel: TChannel; const Text: string);
  {Write text to standard output unless silent.
    @param Text [in] Text to be written.
  }
begin
  if not fSilent or (AChannel <> TChannel.StdOut) then
    WinWrite(AChannel, Text);
end;

procedure TConsole.WriteLn(const AChannel: TChannel; const Text: string);
  {Write text followed by new line to standard output unless silent.
    @param Text [in] Text to be written.
  }
begin
  Write(AChannel, Text + sLineBreak);
end;

procedure TConsole.WriteLn(const AChannel: TChannel);
  {Write a new line to standard output unless silent.
  }
begin
  WriteLn(AChannel, '');
end;

end.

