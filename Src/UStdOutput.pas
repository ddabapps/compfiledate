{
 * UStdOutput.pas
 *
 * Class that writes to console's standard output stream.
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
 * The Original Code is UStdOutput.pas from the CompFileDate project.
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

