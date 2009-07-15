@rem ---------------------------------------------------------------------------
@rem Script used to build CompFileDate executable from Pascal source and other
@rem binaries.
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2009
@rem
@rem $Rev$
@rem $Date$
@rem ---------------------------------------------------------------------------

@echo off

setlocal

cd ..\Src
call Build.bat pas

endlocal

