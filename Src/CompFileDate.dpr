{
 * CompFileDate.dpr
 *
 * Main project file.
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
 * The Original Code is CompFileDate.dpr from the CompFileDate project.
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


program CompFileDate;

{$APPTYPE CONSOLE}

{$RESOURCE Resources.res}   // general program assets
{$RESOURCE VerInfo.res}     // version information

{%ToDo 'CompFileDate.todo'}

uses
  SysUtils,
  UAppException in 'UAppException.pas',
  UConsole in 'UConsole.pas',
  UMain in 'UMain.pas',
  UParams in 'UParams.pas',
  UStdOutput in 'UStdOutput.pas';

begin
  with TMain.Create do
    try
      Execute;
    finally
      Free;
    end;
end.

