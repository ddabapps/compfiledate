{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2009-2014, Peter Johnson (www.delphidabbler.com).
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
  strict private
    fSilent: Boolean; // Value of Silent property
  public
    constructor Create;
      {Class constructor. Sets up object.
      }
    procedure Write(const Text: string);
      {Write text to standard output unless silent.
        @param Text [in] Text to be written.
      }
    procedure WriteLn(const Text: string); overload;
      {Write text followed by new line to standard output unless silent.
        @param Text [in] Text to be written.
      }
    procedure WriteLn; overload;
      {Write a new line to standard output unless silent.
      }
    property Silent: Boolean read fSilent write fSilent default False;
      {Whether to be silent, i.e. write no output}
  end;


implementation


uses
  // Project
  UStdOutput;


{ TConsole }

constructor TConsole.Create;
  {Class constructor. Sets up object.
  }
begin
  inherited Create;
  fSilent := False;
end;

procedure TConsole.Write(const Text: string);
  {Write text to standard output unless silent.
    @param Text [in] Text to be written.
  }
begin
  if not fSilent then
    TStdOutput.Write(Text);
end;

procedure TConsole.WriteLn(const Text: string);
  {Write text followed by new line to standard output unless silent.
    @param Text [in] Text to be written.
  }
begin
  Write(Text + #13#10);
end;

procedure TConsole.WriteLn;
  {Write a new line to standard output unless silent.
  }
begin
  WriteLn('');
end;

end.

