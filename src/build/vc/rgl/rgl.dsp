# Microsoft Developer Studio Project File - Name="rgl" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=rgl - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "rgl.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "rgl.mak" CFG="rgl - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "rgl - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "rgl - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "rgl - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "RGL_EXPORTS" /YX /FD /c
# ADD CPP /nologo /MT /W3 /O2 /D "NDEBUG" /D "WIN32" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "RGL_EXPORTS" /D "HAVE_PNG_H" /FD /c
# SUBTRACT CPP /YX
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386
# ADD LINK32 FP10.OBJ kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib opengl32.lib glu32.lib /nologo /dll /machine:I386
# Begin Special Build Tool
SOURCE="$(InputPath)"
PostBuild_Cmds=copy Release\rgl.dll ..\..\..\rgl.dll
# End Special Build Tool

!ELSEIF  "$(CFG)" == "rgl - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "RGL_EXPORTS" /YX /FD /GZ /c
# ADD CPP /nologo /MTd /W3 /Gm /ZI /Od /D "_DEBUG" /D "WIN32" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "RGL_EXPORTS" /D "HAVE_PNG_H" /FD /GZ /c
# SUBTRACT CPP /YX
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 FP10.OBJ kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib opengl32.lib glu32.lib /nologo /dll /debug /machine:I386 /pdbtype:sept
# Begin Special Build Tool
SOURCE="$(InputPath)"
PostBuild_Cmds=copy Debug\rgl.dll ..\..\..\rgl.dll
# End Special Build Tool

!ENDIF 

# Begin Target

# Name "rgl - Win32 Release"
# Name "rgl - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=..\..\..\api.cpp
# End Source File
# Begin Source File

SOURCE=..\..\..\device.cpp
# End Source File
# Begin Source File

SOURCE=..\..\..\devicemanager.cpp
# End Source File
# Begin Source File

SOURCE=..\..\..\fps.cpp
# End Source File
# Begin Source File

SOURCE=..\..\..\glgui.cpp
# End Source File
# Begin Source File

SOURCE=..\..\..\gui.cpp
# End Source File
# Begin Source File

SOURCE=..\..\..\math.cpp
# End Source File
# Begin Source File

SOURCE=..\..\..\pixmap.cpp
# ADD CPP /I "../../../lpng" /I "../../../zlib"
# End Source File
# Begin Source File

SOURCE=..\..\..\rglview.cpp
# End Source File
# Begin Source File

SOURCE=..\..\..\scene.cpp
# End Source File
# Begin Source File

SOURCE=..\..\..\types.cpp
# End Source File
# Begin Source File

SOURCE=..\..\..\win32gui.cpp
# End Source File
# Begin Source File

SOURCE=..\..\..\win32lib.cpp
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=..\..\..\device.h
# End Source File
# Begin Source File

SOURCE=..\..\..\devicemanager.h
# End Source File
# Begin Source File

SOURCE=..\..\..\fps.h
# End Source File
# Begin Source File

SOURCE=..\..\..\gui.h
# End Source File
# Begin Source File

SOURCE=..\..\..\lib.h
# End Source File
# Begin Source File

SOURCE=..\..\..\math.h
# End Source File
# Begin Source File

SOURCE=..\..\..\opengl.h
# End Source File
# Begin Source File

SOURCE=..\..\..\pixmap.h
# End Source File
# Begin Source File

SOURCE=..\..\..\rglview.h
# End Source File
# Begin Source File

SOURCE=..\..\..\scene.h
# End Source File
# Begin Source File

SOURCE=..\..\..\types.h
# End Source File
# Begin Source File

SOURCE=..\..\..\win32gui.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# Begin Source File

SOURCE=..\..\..\rgl_res.rc
# End Source File
# End Group
# Begin Source File

SOURCE=..\..\..\ChangeLog
# End Source File
# Begin Source File

SOURCE=..\..\..\TODO.txt
# End Source File
# End Target
# End Project
