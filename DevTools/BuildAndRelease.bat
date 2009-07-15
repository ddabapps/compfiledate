@rem ---------------------------------------------------------------------------
@rem Script used to build all of CompFileDate and create release zip files
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2009
@rem
@rem $Rev$
@rem $Date$
@rem ---------------------------------------------------------------------------

@echo off

call Tidy.bat
call BuildAll.bat
call ReleaseExe.bat
call ReleaseSrc.bat

