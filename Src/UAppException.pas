{
 * UAppException.pas
 *
 * Exception class for application errors. Stores error message and associated
 * error exit code.
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
 * The Original Code is UAppException.pas from the CompFileDate project.
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


unit UAppException;


interface


uses
  // Delphi
  SysUtils;


const
  // Error exit codes
  cAppErrUnknown = 100;
  cAppErrBadSwitch = 101;
  cAppErr2FilesNeeded = 102;
  cAppErrFileNamesSame = 103;
  cAppErrFileNameNotFound = 104;


resourcestring
  // Error messages
  sAppErrBadSwitch = 'Invalid switch "%s"';
  sAppErr2FilesNeeded = 'Exactly two file names must be specified';
  sAppErrFileNamesSame = 'File names must be different';
  sAppErrFileNameNotFound = 'Date for file "%s" not found';


type

  {
  EApplication:
    Application error exception object. Contains an error code.
  }
  EApplication = class(Exception)
  strict private
    fExitCode: Integer; // Value of ExitCode property
  public
    constructor Create(const Msg: string; const ExitCode: Integer); overload;
      {Class constructor. Sets up exception object.
        @param Msg [in] Error message.
        @param ExitCode [in] Program exit code associated with error.
      }
    constructor Create(const Msg: string; const Args: array of const;
      const ExitCode: Integer); overload;
      {Class constructor. Sets up exception object.
        @param Msg [in] Format template for error messaqe.
        @param Args [in] Values to be included in format template.
        @param ExitCode [in] Program exit code associated with error.
      }
    property ExitCode: Integer read fExitCode;
      {Program exit code associated with error}
  end;


implementation


{ EApplication }

constructor EApplication.Create(const Msg: string; const ExitCode: Integer);
  {Class constructor. Sets up exception object.
    @param Msg [in] Error message.
    @param ExitCode [in] Program exit code associated with error.
  }
begin
  inherited Create(Msg);
  fExitCode := ExitCode;
end;

constructor EApplication.Create(const Msg: string; const Args: array of const;
  const ExitCode: Integer);
  {Class constructor. Sets up exception object.
    @param Msg [in] Format template for error messaqe.
    @param Args [in] Values to be included in format template.
    @param ExitCode [in] Program exit code associated with error.
  }
begin
  Create(Format(Msg, Args), fExitCode);
end;

end.

