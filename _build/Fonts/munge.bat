@REM WARNING: enabledelayedexpansion means ! is a special character,
@REM   which means it isn't available for use as the mungeapp recursive
@REM   wildcard character.  Use the alternate $ instead.
@setlocal enabledelayedexpansion

@set MUNGE_ROOT_DIR=..\..
@if not "%1"=="" set MUNGE_PLATFORM=%1
@if %MUNGE_PLATFORM%x==x set MUNGE_PLATFORM=PC
@if %MUNGE_LANGDIR%x==x set MUNGE_LANGDIR=ENG

@set MUNGE_BIN_DIR=%CD%\%MUNGE_ROOT_DIR%\..\ToolsFL\Bin
@set PATH=%CD%\..\..\..\ToolsFL\Bin;%PATH%


@set MUNGE_ARGS=-checkdate -continue -platform %MUNGE_PLATFORM%
@set MUNGE_DIR=MUNGED\%MUNGE_PLATFORM%
@set OUTPUT_DIR=%MUNGE_ROOT_DIR%\_LVL_%MUNGE_PLATFORM%\Fonts

@set LOCAL_MUNGE_LOG="%CD%\%MUNGE_PLATFORM%_MungeLog.txt"
@if "%MUNGE_LOG%"=="" (
	@set MUNGE_LOG=%LOCAL_MUNGE_LOG%
	@if exist %LOCAL_MUNGE_LOG% ( del %LOCAL_MUNGE_LOG% )
)

@if not exist MUNGED mkdir MUNGED
@if not exist %MUNGE_DIR% mkdir %MUNGE_DIR%
@if not exist %MUNGE_ROOT_DIR%\_LVL_%MUNGE_PLATFORM% mkdir %MUNGE_ROOT_DIR%\_LVL_%MUNGE_PLATFORM%
@if not exist %MUNGE_ROOT_DIR%\_LVL_%MUNGE_PLATFORM%\Fonts mkdir %MUNGE_ROOT_DIR%\_LVL_%MUNGE_PLATFORM%\Fonts
@if not exist %OUTPUT_DIR% mkdir %OUTPUT_DIR%

@REM ===== Handle files in CustomLVL\
@set SOURCE_SUBDIR=CustomLVL
@set SOURCE_DIR=
@set SOURCE_DIR=%SOURCE_DIR% %MUNGE_ROOT_DIR%\%SOURCE_SUBDIR%


@for /f %%A in ('dir %SOURCE_DIR%\Fonts /b /Ad') do if not exist %MUNGE_DIR%\%%A mkdir %MUNGE_DIR%\%%A

@for /f %%A in ('dir %SOURCE_DIR%\Fonts /b /Ad') do fontmunge -inputfile $*.fff %MUNGE_ARGS% -sourcedir %SOURCE_DIR%\Fonts\%%A -outputdir %MUNGE_DIR%\%%A 2>>%MUNGE_LOG%

@REM ===== Build LVL files

@for /f %%A in ('dir %SOURCE_DIR%\Fonts /b /Ad') do levelpack -inputfile %%A.req %MUNGE_ARGS% -sourcedir %SOURCE_DIR% -inputdir %MUNGE_DIR%\%%A -outputdir %OUTPUT_DIR% 2>>%MUNGE_LOG%
 
xcopy %OUTPUT_DIR% "C:\Program Files (x86)\LucasArts\Star Wars Battlefront II\GameData\addon\Remaster\Fonts" /Y

@REM If the munge log was created locally and has anything in it, view it
@if not %MUNGE_LOG%x==%LOCAL_MUNGE_LOG%x goto skip_mungelog
@set FILE_CONTENTS_TEST=
@if exist %MUNGE_LOG% for /f %%i in (%MUNGE_LOG:"=%) do @set FILE_CONTENTS_TEST=%%i
@if not "%FILE_CONTENTS_TEST%"=="" ( Notepad.exe %MUNGE_LOG% ) else ( if exist %MUNGE_LOG% (del %MUNGE_LOG%) )

:skip_mungelog
@endlocal