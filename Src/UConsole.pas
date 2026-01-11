{
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at https://mozilla.org/MPL/2.0/
 *
 * Copyright (C) 2009-2026, Peter Johnson (gravatar.com/delphidabbler).
 *
 * Class that writes text to standard output (unless output is inhibited) or
 * standard error.
}


unit UConsole;


interface


type
  ///  <summary>Class that writes text to the console using either standard
  ///  output or standard error unless told to be silent, when all output is
  ///  swallowed.</summary>
  TConsole = class(TObject)
  public
    type
      ///  <summary>Enumeration used to select whether the output is sent to
      ///  standard output (<c>StdOut</c>) or standard error (<c>StdErr</c>).
      ///  </summary>
      TChannel = (StdOut, StdErr);
  strict private
    var
      // Value of Silent property
      fSilent: Boolean;
    ///  <summary>Get Windows handle associated with the given output channel.
    ///  </summary>
    ///  <remarks>*** This is a Windows specific method ***</remarks>
    function WinGetHandle(const AChannel: TChannel): THandle;
    ///  <summary>Writes the given text to the Windows handle associated with
    ///  the given output channel.</summary>
    ///  <remarks>*** This is a Windows specific method ***</remarks>
    procedure WinWrite(const AChannel: TChannel; const AText: string);
  public
    ///  <summary>Object constructor.</summary>
    constructor Create;
    ///  <summary>Writes the given text to the given output channel.</summary>
    ///  <param name="AChannel">[in] The channel to be written to.</param>
    ///  <param name="Text">[in] Text to be written out.</param>
    procedure Write(const AChannel: TChannel; const Text: string);
    ///  <summary>Writes the given text to the given output channel followed by
    ///  a new line.</summary>
    ///  <param name="AChannel">[in] The channel to be written to.</param>
    ///  <param name="Text">[in] Text to be written out.</param>
    procedure WriteLn(const AChannel: TChannel; const Text: string); overload;
    ///  <summary>Writes a new line to the given output channel.</summary>
    ///  <param name="AChannel">[in] The channel to be written to.</param>
    procedure WriteLn(const AChannel: TChannel); overload;
    ///  <summary>Property that determines whether any text is to be output to
    ///  <c>TChannel.StdOut</c>. When the property is <c>False</c> text is
    ///  always written but when <c>True</c> no text is written. If the
    ///  specified channel is <c>TChannel.StdErr</c> then the property is
    ///  ignored and text is always written.</summary>
    property Silent: Boolean read fSilent write fSilent default False;
  end;


implementation


uses
  // Delphi
  System.SysUtils,
  WinApi.Windows;


{ TConsole }

constructor TConsole.Create;
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
begin
  if not fSilent or (AChannel <> TChannel.StdOut) then
    WinWrite(AChannel, Text);
end;

procedure TConsole.WriteLn(const AChannel: TChannel; const Text: string);
begin
  Write(AChannel, Text + sLineBreak);
end;

procedure TConsole.WriteLn(const AChannel: TChannel);
begin
  WriteLn(AChannel, '');
end;

end.

