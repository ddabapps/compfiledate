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
      {$SCOPEDENUMS ON}
      ///  <summary>Enumeration used to select whether the output is sent to
      ///  standard output (<c>StdOut</c>) or standard error (<c>StdErr</c>).
      ///  </summary>
      TChannel = (StdOut, StdErr);
      {$SCOPEDENUMS OFF}
  strict private
    var
      // Value of Silent property
      fSilent: Boolean;
    ///  <summary>Writes the given text to the given output channel using the
    ///  default text encoding.</summary>
    ///  <param name="AChannel">[in] The channel to be written to.</param>
    ///  <param name="AText">[in] Text to be written out.</param>
    ///  <remarks>
    ///  <para>This method converts the text into a byte stream using the system
    ///  default encoding then calls an OS specific class to write the byte
    ///  stream to the console.</para>
    ///  <para>The text if not written if the <c>Silent</c> property is
    ///  <c>True</c> AND <c>AChannel</c> = <c>TChannel.StdOut</c>.</para>
    ///  <para>All public methods of this class must ultimately call this
    ///  method.</para>
    ///  </remarks>
    procedure InternalWrite(const AChannel: TChannel; const AText: string);
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


type
  ///  <summary>Class that writes bytes to a Windows console.</summary>
  TWinConsole = class(TObject)
  public
    ///  <summary>Writes a sequence of bytes to a console channel.</summary>
    ///  <param name="AChannel">[in] The channel to be written to.</param>
    ///  <param name="ABytes">[in] Array of byytes to be written out.</param>
    ///  <remarks>*** This is a Windows specific method ***</remarks>
    class procedure Write(const AChannel: TConsole.TChannel;
      const ABytes: TBytes);
  end;


{ TConsole }

constructor TConsole.Create;
begin
  inherited Create;
  fSilent := False;
end;

procedure TConsole.InternalWrite(const AChannel: TChannel; const AText: string);
begin
  if fSilent and (AChannel = TChannel.StdOut) then
    Exit;
  var Bytes := TEncoding.Default.GetBytes(AText);
  if Length(Bytes) = 0 then
    Exit;
  TWinConsole.Write(AChannel, Bytes);
end;

procedure TConsole.Write(const AChannel: TChannel; const Text: string);
begin
  InternalWrite(AChannel, Text);
end;

procedure TConsole.WriteLn(const AChannel: TChannel; const Text: string);
begin
  InternalWrite(AChannel, Text + sLineBreak);
end;

procedure TConsole.WriteLn(const AChannel: TChannel);
begin
  WriteLn(AChannel, '');
end;

{ TWinConsole }

class procedure TWinConsole.Write(const AChannel: TConsole.TChannel;
  const ABytes: TBytes);
const
  ChannelMap: array[TConsole.TChannel] of WinApi.Windows.DWORD = (
    WinApi.Windows.STD_OUTPUT_HANDLE, WinApi.Windows.STD_ERROR_HANDLE
  );
begin
  var BytesWritten: WinApi.Windows.DWORD; // number of bytes written (unused)
  WinApi.Windows.WriteFile(
    WinApi.Windows.GetStdHandle(ChannelMap[AChannel]),
    Pointer(ABytes)^,
    Length(ABytes),
    BytesWritten,
    nil
  );
end;

end.

