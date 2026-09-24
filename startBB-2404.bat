@echo off
setlocal DisableDelayedExpansion

rem Set ATELIERB_PATH to the Atelier B 24.04.2 installation directory.
if not defined ATELIERB_PATH (
    echo Error: Set ATELIERB_PATH to the Atelier B installation directory.
    exit /b 1
)
if not exist "%CD%\AtelierB" (
    echo Error: Configuration file 'AtelierB' not found in "%CD%".
    exit /b 1
)
if not exist "%ATELIERB_PATH%\bin\bbatch.exe" (
    echo Error: bbatch.exe not found in "%ATELIERB_PATH%\bin".
    exit /b 1
)

"%ATELIERB_PATH%\bin\bbatch.exe" "-r=%CD%\AtelierB" %*
exit /b %ERRORLEVEL%
