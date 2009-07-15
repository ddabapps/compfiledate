@rem ---------------------------------------------------------------------------
@rem Script used to create zip file containing binary release of CompFileDate.
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2009
@rem
@rem $Rev$                                           
@rem $Date$
@rem ---------------------------------------------------------------------------

@echo off

setlocal

cd ..

set OutFile=Release\dd-compfiledate.zip

del %OutFile%

echo Creating %OutFile%

zip -j -9 %OutFile% Exe\CompFileDate.exe
zip -j -9 %OutFile% Docs\ReadMe.txt
zip -j -9 %OutFile% Docs\License.txt
zip -j -9 %OutFile% Docs\changelog.txt

echo Done
echo.

endlocal

