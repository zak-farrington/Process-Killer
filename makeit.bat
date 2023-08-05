@ECHO OFF
ECHO "[:: > hAxProcessKiller Build File by fritz < ::]"
echo.
echo You must have all of the project files in C:\hAxProcessKiller\ and MASM32 installed for this to build file to work!
echo Or edit the makeit.bat file so it will be compatible with your assembly compiler
ECHO.
CD C:\MASM32\BIN
ML /c /coff /Cp C:\hAxProcessKiller\hAxProcessKiller.ASM
ECHO.
LINK /SUBSYSTEM:WINDOWS /LIBPATH:C:\MASM32\LIB hAxProcessKiller.OBJ C:\hAxProcessKiller\hAxProcessKiller.RES
ECHO.
del *.obj
del *.res
MOVE hAxProcessKiller.EXE C:\hAxProcessKiller\hAxProcessKiller.EXE
cd C:\hAxProcessKiller\
hAxProcessKiller.EXE
EXIT