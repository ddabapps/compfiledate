@rem ---------------------------------------------------------------------------
@rem Script used to create zip file containing source code of CompFileDate.
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2009     
@rem
@rem $Rev$
@rem $Date$
@rem ---------------------------------------------------------------------------

@echo off

setlocal

cd ..

set OutFile=Release\dd-compfiledate-src.zip
set SrcDir=Src
set BinDir=Bin
set DocsDir=Docs

del %OutFile%

echo Creating %OutFile%

zip -r -9 %OutFile% %SrcDir%
zip %OutFile% -d %SrcDir%\CompFileDate.dsk
zip -r -9 %OutFile% %BinDir%\*.res
zip -j -9 %OutFile% %DocsDir%\ReadMe-Src.txt
zip -j -9 %OutFile% %DocsDir%\SourceCodeLicenses.txt
zip -j -9 %OutFile% %DocsDir%\MPL.txt

echo Done
echo.

endlocal

