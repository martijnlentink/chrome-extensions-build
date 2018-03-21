@echo off
setlocal enabledelayedexpansion
echo === Removing old files ===
@del /F /Q %CD%\bin\release.zip
set /p appversion=App version: 
echo === Copy build files ===
echo D | xcopy /s/e/y "..\src" "in"
echo === Minifying sources ===
for /R ./in %%f in (*.*) do (
  set B=%%f
  set "p=bin\build\!B:%CD%\in\=!"
  set "e=%%~xf"
  echo !p! 
  if not exist "!p!\.." @mkdir "!p!/.."
  set "s=0"
  if "!e!"==".css" (set "s=2")
  if "!e!"==".js" (set "s=1")
  if "!s!"=="1" ( @java -jar "res\closure-compiler-v20180204.jar" --compilation_level SIMPLE --js "%%f" --js_output_file "!p!" --define='CIRC_DEBUG=false' --jscomp_off=unknownDefines)
  if "!s!"=="2" ( @java -jar res\yuicompressor-2.4.8.jar %%f -o "!p!" )
  if "!s!"=="0" ( copy /Y %%f "!p!" > NUL)
  if "!e!"==".json" (cscript "res\replace.vbs" //B "!p!" 0.0.0 %appversion%)
)
::for /f "usebackq" %%a in (`"dir bin/build/ .git"`) do rmdir "%%a"
del /s /q /f bin\build\*.git
del /s /q /f bin\build\*.gitignore
echo === Creating ZIP ===
cscript res\zip.vbs %CD%\bin\release.zip new > NUL
for /f "delims=" %%D in ('dir bin\build /b') do (
	cscript res\zip.vbs %CD%\bin\release.zip add %CD%\bin\build\%%D > NUL
	echo Added %%D to zip
)
@rmdir /S /Q %CD%\in\
echo === We're done! ===
pause