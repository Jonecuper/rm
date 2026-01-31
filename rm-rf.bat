@echo off
setlocal disabledelayedexpansion

if "%~1"=="" (
    echo Использование: rm-rf "пути к файлам или папкам"
    exit /b 1
)

:next_arg
if "%~1"=="" goto :done

set "TARGET=%~1"

:: Проверка на wildcard
echo %TARGET% | findstr /r "[*?]" >nul && (
    call :delete_by_wildcard "%TARGET%"
    goto :shift_next
)

:: Проверяем существование
if not exist "%TARGET%" (
    echo Внимание: путь не найден - %TARGET%
    goto :shift_next
)

:: === ОПРЕДЕЛЕНИЕ ТИПА БЕЗ ИСПОЛЬЗОВАНИЯ СКОБОК В IF ===
set "IS_DIR="
for %%A in ("%TARGET%") do set "ATTR=%%~aA"
if defined ATTR if "%ATTR:~0,1%"=="d" set "IS_DIR=1"

if defined IS_DIR (
    (call ) >nul 2>&1
    rmdir /s /q "%TARGET%"
    if errorlevel 1 (
        echo Ошибка: не удалось удалить папку '%TARGET%'
        exit /b 1
    )
) else (
    (call ) >nul 2>&1
    del /f /q "%TARGET%"
    if errorlevel 1 (
        echo Ошибка: не удалось удалить файл '%TARGET%'
        exit /b 1
    )
)

:shift_next
shift
goto :next_arg

:done
exit /b 0


:delete_by_wildcard
setlocal enabledelayedexpansion
set "MASK=%~1"
set "FOUND=0"

for %%F in ("%MASK%") do (
    set "FOUND=1"
    set "IS_DIR="
    for %%A in ("%%F") do set "ATTR=%%~aA"
    if defined ATTR if "!ATTR:~0,1!"=="d" (
        (call ) >nul 2>&1
        rmdir /s /q "%%F"
        if errorlevel 1 (
            echo Ошибка удаления папки: %%F
            exit /b 1
        )
    ) else (
        (call ) >nul 2>&1
        del /f /q "%%F"
        if errorlevel 1 (
            echo Ошибкак удаления файла: %%F
            exit /b 1
        )
    )
)

for /d %%D in ("%MASK%") do (
    set "FOUND=1"
    (call ) >nul 2>&1
    rmdir /s /q "%%D"
    if errorlevel 1 (
        echo Ошибка удаления папки: %%D
        exit /b 1
    )
)

if "!FOUND!"=="0" (
    echo Внимание: по указанной маске не найдены файлы папки или для удаления - %MASK%
)
endlocal
exit /b 0