@echo off
setlocal enabledelayedexpansion

:: ====================================================
:: DETECCIÓN AUTOMÁTICA DE LA RUTA DE STEAM
:: ====================================================

:: Método 1: Buscar en el registro de Windows
for /f "tokens=2*" %%A in ('reg query "HKLM\SOFTWARE\Valve\Steam" /v InstallPath 2^>nul') do (
    set "STEAM_PATH=%%B"
)

:: Método 2: Buscar en el registro para sistemas de 64 bits
if not defined STEAM_PATH (
    for /f "tokens=2*" %%A in ('reg query "HKLM\SOFTWARE\WOW6432Node\Valve\Steam" /v InstallPath 2^>nul') do (
        set "STEAM_PATH=%%B"
    )
)

:: Método 3: Buscar en ubicaciones comunes si no se encontró en el registro
if not defined STEAM_PATH (
    if exist "C:\Program Files\Steam" set "STEAM_PATH=C:\Program Files\Steam"
)
if not defined STEAM_PATH (
    if exist "C:\Program Files (x86)\Steam" set "STEAM_PATH=C:\Program Files (x86)\Steam"
)
if not defined STEAM_PATH (
    if exist "D:\Steam" set "STEAM_PATH=D:\Steam"
)
if not defined STEAM_PATH (
    if exist "E:\Steam" set "STEAM_PATH=E:\Steam"
)
if not defined STEAM_PATH (
    if exist "F:\Steam" set "STEAM_PATH=F:\Steam"
)

:: Verificar si se encontró Steam
if not defined STEAM_PATH (
    echo [ERROR] No se pudo detectar la instalación de Steam.
    echo Por favor, verifica que Steam esté instalado.
    pause
    exit /b
)

:: Construir la ruta a los mods de Project Zomboid
set "ORIGEN=%STEAM_PATH%\steamapps\workshop\content\108600"
set "DESTINO=%USERPROFILE%\Zomboid\mods"

echo ====================================================
echo   Extractor Automatico de Mods - Project Zomboid
echo ====================================================
echo Steam detectado en: %STEAM_PATH%
echo Origen: %ORIGEN%
echo Destino: %DESTINO%
echo ----------------------------------------------------

if not exist "%ORIGEN%" (
    echo [ERROR] No se encuentra la ruta: %ORIGEN%
    echo Por favor, verifica que Project Zomboid esté instalado y que tengas mods del Workshop.
    pause
    exit /b
)

if not exist "%DESTINO%" mkdir "%DESTINO%"

:: Recorrer las carpetas numéricas de los mods
for /d %%G in ("%ORIGEN%\*") do (
    set "MOD_ID_DIR=%%G"
    set "MODS_SUBDIR=!MOD_ID_DIR!\mods"
    
    :: Verificar si existe la carpeta interna "mods"
    if exist "!MODS_SUBDIR!" (
        echo Procesando Mod ID: %%~nG...
        
        :: Copiar las carpetas internas de los mods a la carpeta local de Zomboid
        for /d %%M in ("!MODS_SUBDIR!\*") do (
            echo   Copiando: %%~nM
            xcopy "%%M" "%DESTINO%\%%~nM" /E /I /H /Y /Q >nul
        )
    )
)

echo ----------------------------------------------------
echo [PROCESO TERMINADO] Los mods ya estan en tu carpeta local.
echo ====================================================
pause
