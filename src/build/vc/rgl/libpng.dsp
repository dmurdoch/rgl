# Microsoft Developer Studio Project File - Name="libpng" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Static Library" 0x0104

CFG=libpng - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "libpng.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "libpng.mak" CFG="libpng - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "libpng - Win32 Release" (based on "Win32 (x86) Static Library")
!MESSAGE "libpng - Win32 Debug" (based on "Win32 (x86) Static Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "libpng - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "libpng___Win32_Release"
# PROP BASE Intermediate_Dir "libpng___Win32_Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "libpng___Win32_Release"
# PROP Intermediate_Dir "libpng___Win32_Release"
# PROP Target_Dir ""
MTL=midl.exe
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_MBCS" /D "_LIB" /YX /FD /c
# ADD CPP /nologo /W3 /GX /O2 /I "../../../zlib" /D "WIN32" /D "NDEBUG" /D "_MBCS" /D "_LIB" /YX /FD /c
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LIB32=link.exe -lib
# ADD BASE LIB32 /nologo
# ADD LIB32 /nologo

!ELSEIF  "$(CFG)" == "libpng - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "libpng___Win32_Debug"
# PROP BASE Intermediate_Dir "libpng___Win32_Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "libpng___Win32_Debug"
# PROP Intermediate_Dir "libpng___Win32_Debug"
# PROP Target_Dir ""
MTL=midl.exe
# ADD BASE CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_MBCS" /D "_LIB" /YX /FD /GZ /c
# ADD CPP /nologo /W3 /Gm /GX /ZI /Od /I "../../../zlib" /D "WIN32" /D "_DEBUG" /D "_MBCS" /D "_LIB" /YX /FD /GZ /c
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LIB32=link.exe -lib
# ADD BASE LIB32 /nologo
# ADD LIB32 /nologo

!ENDIF 

# Begin Target

# Name "libpng - Win32 Release"
# Name "libpng - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=..\..\..\lpng\png.c
# End Source File
# Begin Source File

SOURCE=..\..\..\lpng\pngerror.c
# End Source File
# Begin Source File

SOURCE=..\..\..\lpng\pnggccrd.c
# End Source File
# Begin Source File

SOURCE=..\..\..\lpng\pngget.c
# End Source File
# Begin Source File

SOURCE=..\..\..\lpng\pngmem.c
# End Source File
# Begin Source File

SOURCE=..\..\..\lpng\pngpread.c
# End Source File
# Begin Source File

SOURCE=..\..\..\lpng\pngread.c
# End Source File
# Begin Source File

SOURCE=..\..\..\lpng\pngrio.c
# End Source File
# Begin Source File

SOURCE=..\..\..\lpng\pngrtran.c
# End Source File
# Begin Source File

SOURCE=..\..\..\lpng\pngrutil.c
# End Source File
# Begin Source File

SOURCE=..\..\..\lpng\pngset.c
# End Source File
# Begin Source File

SOURCE=..\..\..\lpng\pngtrans.c
# End Source File
# Begin Source File

SOURCE=..\..\..\lpng\pngvcrd.c
# End Source File
# Begin Source File

SOURCE=..\..\..\lpng\pngwio.c
# End Source File
# Begin Source File

SOURCE=..\..\..\lpng\pngwrite.c
# End Source File
# Begin Source File

SOURCE=..\..\..\lpng\pngwtran.c
# End Source File
# Begin Source File

SOURCE=..\..\..\lpng\pngwutil.c
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=..\..\..\lpng\png.h
# End Source File
# Begin Source File

SOURCE=..\..\..\lpng\pngasmrd.h
# End Source File
# Begin Source File

SOURCE=..\..\..\lpng\pngconf.h
# End Source File
# End Group
# End Target
# End Project
