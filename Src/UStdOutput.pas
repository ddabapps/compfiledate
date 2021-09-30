{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at https://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2009-2014, Peter Johnson (gravatar.com/delphidabbler).
 *
 * Class that writes to console's standard output stream.
}


unit UStdOutput;


interface


type

  {
  TStdOutput:
    Static class that outputs to standard output.
  }
  TStdOutput = class(TObject)
  strict private
    class function GetHandle: THandle;
      {Gets Windows handle of stdout.
        @return Required Windows handle.
      }
  public
    class procedure Write(const Text: string);
      {Writes text to standard output in default ANSI encoding.
        @param Text [in] Text to be written.
      }
  end;


implementation


uses
  // Delphi
  SysUtils, Windows;


{ TStdOutput }

class function TStdOutput.GetHandle: THandle;
  {Gets Windows handle of stdout.
    @return Required Windows handle.
  }
begin
  Result := GetStdHandle(STD_OUTPUT_HANDLE);
end;

class procedure TStdOutput.Write(const Text: string);
  {Writes text to standard output in default ANSI encoding.
    @param Text [in] Text to be written.
  }
var
  Dummy: Cardinal;  // Unused param for Windows.WriteFile
  Bytes: TBytes;    // Bytes of Text in default ANSI encoding
begin
  Bytes := TEncoding.Default.GetBytes(Text);
  if Length(Bytes) = 0 then
    Exit;
  Windows.WriteFile(
    GetHandle, Pointer(Bytes)^, Length(Bytes), Dummy, nil);
end;

end.

