@echo off
REM  RGL windows setup build tool
REM This file is part of the RGL software
REM (c) 2003 D.Adler

set SRC=src

REM === SETUP build tool =====================================================

set TARGET=x%1
if %TARGET% == xmingw goto mingw
if %TARGET% == xvc    goto vc
goto usage

REM === dump usage ===========================================================

:usage
echo usage: %0 [tool]
echo supported build tools:
echo   mingw    MinGW
echo   vc       Microsoft Visual C++
goto return

REM === build tool: mingw ====================================================

:mingw
echo include build/mingw/Makefile >%SRC%\Makefile.win
copy src\build\mingw\configure.win configure.win
goto done

REM === build tool: vc =======================================================

:vc
echo include build/vc/Makefile >%SRC%\Makefile.win
copy src\build\vc\configure.win configure.win
goto done


REM === SETUP DONE ===========================================================

:done
echo setup.bat: configured for build tool '%1'

:return
