{
 * UStdOutput.pas
 * Revision $Rev$ of $Date$
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
      {Writes text to standard output.
        @param Text [in] Text to be written.
      }
  end;


implementation


uses
  // Delphi
  Windows;


{ TStdOutput }

class function TStdOutput.GetHandle: THandle;
  {Gets Windows handle of stdout.
    @return Required Windows handle.
  }
begin
  Result := GetStdHandle(STD_OUTPUT_HANDLE);
end;

class procedure TStdOutput.Write(const Text: string);
  {Writes text to standard output.
    @param Text [in] Text to be written.
  }
var
  Dummy: Cardinal;  // Unused param for Windows.WriteFile
begin
  // Write the data
  Windows.WriteFile(GetHandle, Text[1], Length(Text), Dummy, nil);
end;

end.

