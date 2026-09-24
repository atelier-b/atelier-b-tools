@echo off
setlocal DisableDelayedExpansion

if not exist "%CD%\AtelierB" (
    echo Error: 'AtelierB' config file not found in "%CD%".
    exit /b 1
)
if exist "%~dp0startBB-2404.bat" (
    set "START_BB=%~dp0startBB-2404.bat"
) else (
    for %%I in (startBB-2404.bat) do set "START_BB=%%~$PATH:I"
)
if not defined START_BB (
    echo Error: startBB-2404.bat was not found beside this script or on PATH.
    exit /b 1
)

set "PROJECT_ROOT=%CD%"
set "WORK=%TEMP%\syncABWS-%RANDOM%-%RANDOM%"
mkdir "%WORK%" || exit /b 1
set "FAILED=0"

echo Starting Atelier B workspace synchronization...
call :project_list
if errorlevel 1 goto :failed

rem Register directories that are present on disk.
for /d %%D in (*) do call :register "%%~nxD" "%%~fD"

rem Remove database projects whose directories have disappeared.
for /f "usebackq delims=" %%P in ("%WORK%\projects.txt") do (
    if not exist "%PROJECT_ROOT%\%%P\NUL" (
        echo ^>^> Project folder '%%P' not found. Removing from database...
        > "%WORK%\input.txt" echo(rp %%P
        >> "%WORK%\input.txt" echo(quit
        call :run "%WORK%\input.txt" "%WORK%\output.txt"
        if errorlevel 1 set "FAILED=1"
    )
)

echo Refreshing project list for file synchronization...
call :project_list
if errorlevel 1 goto :failed
for /d %%D in (*) do call :sync_project "%%~nxD" "%%~fD"

echo -----------------------------------------------
if "%FAILED%"=="1" (
    echo Synchronization finished with errors.
    rmdir /s /q "%WORK%"
    exit /b 1
)
echo Synchronization complete.
rmdir /s /q "%WORK%"
exit /b 0

:failed
echo Error: Could not get the Atelier B project list. Synchronization stopped.
rmdir /s /q "%WORK%"
exit /b 1

:run
call "%START_BB%" < "%~1" > "%~2"
if errorlevel 1 (
    type "%~2"
    exit /b 1
)
exit /b 0

:project_list
> "%WORK%\input.txt" echo(spl
>> "%WORK%\input.txt" echo(quit
call :run "%WORK%\input.txt" "%WORK%\output.txt"
if errorlevel 1 exit /b 1
type nul > "%WORK%\projects.txt"
rem In bbatch's spl output, registered project names begin with two spaces.
for /f "tokens=1" %%P in ('findstr /R /C:"^  " "%WORK%\output.txt"') do >> "%WORK%\projects.txt" echo(%%P
exit /b 0

:register
set "NAME=%~1"
set "DIR=%~2"
if /I "%NAME%"=="bdb" exit /b 0
if /I "%NAME%"=="Archives" exit /b 0
if "%NAME:~0,1%"=="." exit /b 0
findstr /I /X /L /C:"%NAME%" "%WORK%\projects.txt" >nul 2>nul
if not errorlevel 1 (
    echo ^>^> Project '%NAME%' is already registered.
    exit /b 0
)

echo ^>^> New project detected: '%NAME%'. Preparing registration...
if exist "%DIR%\lang\NUL" (
    if exist "%DIR%\lang-tmp\NUL" (
        echo Error: '%DIR%\lang-tmp' already exists; cannot move lang safely.
        set "FAILED=1"
        exit /b 1
    )
    move "%DIR%\lang" "%DIR%\lang-tmp" >nul
    if errorlevel 1 (
        echo Error: Could not move '%DIR%\lang'.
        set "FAILED=1"
        exit /b 1
    )
)
if not exist "%DIR%\bdp\NUL" mkdir "%DIR%\bdp"
if not exist "%DIR%\lang\NUL" mkdir "%DIR%\lang"
if not exist "%DIR%\bdp\NUL" (
    echo Error: Could not create bdp and lang for '%NAME%'.
    set "FAILED=1"
    exit /b 1
)
if not exist "%DIR%\lang\NUL" (
    echo Error: Could not create bdp and lang for '%NAME%'.
    set "FAILED=1"
    exit /b 1
)
> "%WORK%\input.txt" echo(create_project %NAME% "%DIR%\bdp" "%DIR%\lang"
>> "%WORK%\input.txt" echo(quit
call :run "%WORK%\input.txt" "%WORK%\output.txt"
if errorlevel 1 set "FAILED=1"
if exist "%DIR%\lang-tmp\NUL" (
    robocopy "%DIR%\lang-tmp" "%DIR%\lang" /E /XC /XN /XO >nul
    if errorlevel 8 (
        echo Error: Could not restore lang files for '%NAME%'.
        set "FAILED=1"
    ) else (
        rmdir /s /q "%DIR%\lang-tmp"
    )
)
exit /b 0

:sync_project
set "NAME=%~1"
set "DIR=%~2"
if /I "%NAME%"=="bdb" exit /b 0
if /I "%NAME%"=="Archives" exit /b 0
if "%NAME:~0,1%"=="." exit /b 0
findstr /I /X /L /C:"%NAME%" "%WORK%\projects.txt" >nul 2>nul
if errorlevel 1 (
    echo Problem with the %NAME% project: not registered.
    set "FAILED=1"
    exit /b 1
)
echo Syncing components for: %NAME%
> "%WORK%\input.txt" echo(op %NAME%
>> "%WORK%\input.txt" echo(sml
>> "%WORK%\input.txt" echo(quit
call :run "%WORK%\input.txt" "%WORK%\output.txt"
if errorlevel 1 (
    set "FAILED=1"
    exit /b 1
)
type nul > "%WORK%\components.txt"
rem Indented sml lines contain the registered component names.
for /f "tokens=1" %%C in ('findstr /R /C:"^ " "%WORK%\output.txt"') do >> "%WORK%\components.txt" echo(%%C

if not exist "%DIR%\src\NUL" (
    echo    Warning: src directory not found. Skipping files.
    exit /b 0
)
> "%WORK%\input.txt" echo(op %NAME%
set "CHANGED=0"
for %%F in ("%DIR%\src\*.mch" "%DIR%\src\*.ref" "%DIR%\src\*.imp") do (
    if exist "%%~fF" call :add_component "%%~nF" "%%~fF" "%%~nxF"
)
for /f "usebackq delims=" %%C in ("%WORK%\components.txt") do call :remove_component "%%C" "%DIR%\src"
if "%CHANGED%"=="0" (
    echo    Components are up to date.
    exit /b 0
)
>> "%WORK%\input.txt" echo(quit
call :run "%WORK%\input.txt" "%WORK%\output.txt"
if errorlevel 1 set "FAILED=1"
exit /b 0

:add_component
findstr /I /X /L /C:"%~1" "%WORK%\components.txt" >nul 2>nul
if not errorlevel 1 exit /b 0
echo    [+] Adding new component: %~3
>> "%WORK%\input.txt" echo(af "%~2"
set "CHANGED=1"
exit /b 0

:remove_component
if exist "%~2\%~1.mch" exit /b 0
if exist "%~2\%~1.ref" exit /b 0
if exist "%~2\%~1.imp" exit /b 0
echo    [-] Removing missing component: %~1
>> "%WORK%\input.txt" echo(rc %~1
set "CHANGED=1"
exit /b 0
