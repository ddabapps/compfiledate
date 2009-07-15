{
 * UConsole.pas
 *
 * Class that writes text to console using standard output unless output is
 * inhibited.
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
      {Write text to standard output unless slient.
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
  {Write text to standard output unless slient.
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

