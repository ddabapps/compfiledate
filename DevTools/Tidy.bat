@rem ---------------------------------------------------------------------------
@rem Script used to delete temporary files and history folders in CompFileDate
@rem source tree.
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2009
@rem
@rem $Rev$
@rem $Date$
@rem ---------------------------------------------------------------------------

@echo off
set SrcDir=..\Src
set DocsDir=..\Docs

echo Deleting *.~*
del %SrcDir%\*.~* /F /S
del %DocsDir%\*.~* /F /S

echo Deleting __history directories
rmdir %DocsDir%\__history
rmdir %SrcDir%\__history
rmdir %SrcDir%\Assets\__history

echo Done.
echo.

