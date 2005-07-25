@echo off
REM RGL windows build tool setup
REM This file is part of the RGL software
REM (c) 2003 D.Adler
REM $Id: setup.bat,v 1.7 2005/02/08 21:18:01 dadler Exp $

set SRC=src

REM === SETUP build tool =====================================================

set TARGET=x%1
if %TARGET% == xmingw goto mingw
if %TARGET% == xvc    goto vc
if %TARGET% == xbjam  goto bjam
goto usage

REM === dump usage ===========================================================

:usage
echo usage: %0 [tool]
echo supported build tools:
echo   mingw    MinGW
echo   vc       Microsoft Visual C++
echo   bjam     Boost Jam
goto return

REM === build tool: mingw ====================================================

:mingw
echo include build/mingw/Makefile >%SRC%\Makefile.win
goto done

REM === build tool: vc =======================================================

:vc
echo include build/vc/Makefile >%SRC%\Makefile.win
goto done


REM === build tool: bjam =====================================================

:bjam
echo include build/win32/bjam.mk >%SRC%\Makefile.win
goto done                   

REM === SETUP DONE ===========================================================

:done
echo setup.bat: configured for build tool '%1'

:return
