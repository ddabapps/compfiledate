{
 * CompFileDate.dpr
 * Revision $Rev$ of $Date$
 *
 * Main project file.
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

