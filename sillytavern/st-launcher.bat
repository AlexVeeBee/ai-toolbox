@echo off
REM SillyTavern Launcher
REM Created by: Deffcolony
REM
REM Description:
REM This script can launch, backup and reinstall sillytavern + extras 
REM
REM This script is intended for use on Windows systems.
REM report any issues or bugs on the GitHub repository.
REM
REM GitHub: https://github.com/SillyTavern/SillyTavern-Launcher
REM Issues: https://github.com/SillyTavern/SillyTavern-Launcher/issues
title SillyTavern Launcher
setlocal

REM ANSI Escape Code for Colors
set "reset=[0m"

REM Strong Foreground Colors
set "white_fg_strong=[90m"
set "red_fg_strong=[91m"
set "green_fg_strong=[92m"
set "yellow_fg_strong=[93m"
set "blue_fg_strong=[94m"
set "magenta_fg_strong=[95m"
set "cyan_fg_strong=[96m"

REM Normal Background Colors
set "red_bg=[41m"
set "blue_bg=[44m"
set "yellow_bg=[43m"

REM Environment Variables (TOOLBOX 7-Zip)
set "zip7version=7z2301-x64"
set "zip7_install_path=%ProgramFiles%\7-Zip"
set "zip7_download_path=%TEMP%\%zip7version%.exe"

REM Environment Variables (TOOLBOX FFmpeg)
set "ffmpeg_url=https://www.gyan.dev/ffmpeg/builds/ffmpeg-git-full.7z"
set "ffdownload_path=%~dp0ffmpeg.7z"
set "ffextract_path=C:\ffmpeg"
set "bin_path=%ffextract_path%\bin"

REM Environment Variables (TOOLBOX Node.js)
set "node_installer_path=%temp%\NodejsInstaller.msi"

REM Environment Variables (winget)
set "winget_path=%userprofile%\AppData\Local\Microsoft\WindowsApps"

REM Environment Variables (TOOLBOX Install Extras)
set "miniconda_path=%userprofile%\miniconda3"

REM Define variables to track module status
set "modules_path=%~dp0modules.txt"
set "cuda_trigger=false"
set "rvc_trigger=false"
set "talkinghead_trigger=false"
set "caption_trigger=false"
set "summarize_trigger=false"
set "listen_trigger=false"
set "whisper_trigger=false"
set "edge_tts_trigger=false"

REM Define variables to track module status (XTTS)
set "modules_path=%~dp0modules-xtts.txt"
set "xtts_cuda_trigger=false"
set "xtts_hs_trigger=false"
set "xtts_deepspeed_trigger=false"
set "xtts_cache_trigger=false"
set "xtts_listen_trigger=false"
set "xtts_model_trigger=false"


REM Create modules.txt if it doesn't exist
if not exist modules.txt (
    type nul > modules.txt
)

REM Load module flags from modules.txt
for /f "tokens=*" %%a in (modules.txt) do set "%%a"


REM Create modules-xtts.txt if it doesn't exist
if not exist modules-xtts.txt (
    type nul > modules-xtts.txt
)

REM Load module flags from modules-xtts.txt
for /f "tokens=*" %%a in (modules-xtts.txt) do set "%%a"



REM Get the current PATH value from the registry
for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v PATH') do set "current_path=%%B"

REM Check if the paths are already in the current PATH
echo %current_path% | find /i "%winget_path%" > nul
set "ff_path_exists=%errorlevel%"

setlocal enabledelayedexpansion

REM Append the new paths to the current PATH only if they don't exist
if %ff_path_exists% neq 0 (
    set "new_path=%current_path%;%winget_path%"
    echo.
    echo [DEBUG] "current_path is:%cyan_fg_strong% %current_path%%reset%"
    echo.
    echo [DEBUG] "winget_path is:%cyan_fg_strong% %winget_path%%reset%"
    echo.
    echo [DEBUG] "new_path is:%cyan_fg_strong% !new_path!%reset%"

    REM Update the PATH value in the registry
    reg add "HKCU\Environment" /v PATH /t REG_EXPAND_SZ /d "!new_path!" /f

    REM Update the PATH value for the current session
    setx PATH "!new_path!" > nul
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%winget added to PATH.%reset%
) else (
    set "new_path=%current_path%"
    echo %blue_fg_strong%[INFO] winget already exists in PATH.%reset%
)

REM Check if Winget is installed; if not, then install it
winget --version > nul 2>&1
if %errorlevel% neq 0 (
    echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] Winget is not installed on this system.%reset%
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Winget...
    curl -L -o "%temp%\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" "https://github.com/microsoft/winget-cli/releases/download/v1.6.2771/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    start "" "%temp%\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Winget installed successfully. Please restart the Launcher.%reset%
    pause
    exit
) else (
    echo %blue_fg_strong%[INFO] Winget is already installed.%reset%
)

REM Check if Git is installed if not then install git
git --version > nul 2>&1
if %errorlevel% neq 0 (
    echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] Git is not installed on this system.%reset%
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Git using Winget...
    winget install -e --id Git.Git
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Git is installed. Please restart the Launcher.%reset%
    pause
    exit
) else (
    echo %blue_fg_strong%[INFO] Git is already installed.%reset%
)

REM Check if Miniconda3 is installed if not then install Miniconda3
call conda --version > nul 2>&1
if %errorlevel% neq 0 (
    echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] Miniconda3 is not installed on this system.%reset%
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Miniconda3 using Winget...
    winget install -e --id Anaconda.Miniconda3
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Miniconda3 installed successfully. Please restart the Installer.%reset%
    pause
    exit
) else (
    echo %blue_fg_strong%[INFO] Miniconda3 is already installed.%reset%
)

REM Change the current directory to 'sillytavern' folder
cd /d "%~dp0SillyTavern"

REM Check for updates
git fetch origin

for /f %%i in ('git rev-list HEAD...origin/%current_branch%') do (
    set "update_status=%yellow_fg_strong%Update Available%reset%"
    goto :found_update
)

set "update_status=%green_fg_strong%Up to Date%reset%"
:found_update


REM Home - frontend
:home
title SillyTavern [HOME]
cls
echo %blue_fg_strong%/ Home%reset%
echo -------------------------------------
echo What would you like to do?
echo 1. Start SillyTavern
echo 2. Start Extras
echo 3. Start XTTS
echo 4. Update
echo 5. Backup
echo 6. Switch branch
echo 7. Toolbox
echo 8. Support
echo 0. Exit

REM Get the current Git branch
for /f %%i in ('git branch --show-current') do set current_branch=%%i
echo ======== VERSION STATUS =========
echo SillyTavern branch: %cyan_fg_strong%%current_branch%%reset%
echo SillyTavern: %update_status%
echo Launcher: V1.0.6
echo =================================

set "choice="
set /p "choice=Choose Your Destiny (default is 1): "

REM Default to choice 1 if no input is provided
if not defined choice set "choice=1"

REM Home - backend
if "%choice%"=="1" (
    call :start_st
) else if "%choice%"=="2" (
    call :start_extras
) else if "%choice%"=="3" (
    call :start_xtts
) else if "%choice%"=="4" (
    call :update
) else if "%choice%"=="5" (
    call :backup_menu
) else if "%choice%"=="6" (
    call :switchbrance_menu
) else if "%choice%"=="7" (
    call :toolbox
) else if "%choice%"=="8" (
    call :support
) else if "%choice%"=="0" (
    exit
) else (
    color 6
    echo WARNING: Invalid number. Please insert a valid number.
    pause
    goto :home
)


:start_st
REM Check if Node.js is installed
node --version > nul 2>&1
if %errorlevel% neq 0 (
    echo %red_fg_strong%[ERROR] node command not found in PATH%reset%
    echo %red_bg%Please make sure Node.js is installed and added to your PATH.%reset%
    echo %blue_bg%To install Node.js go to Toolbox%reset%
    pause
    goto :home
)
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% SillyTavern launched in a new window.
start cmd /k "title SillyTavern && cd /d %~dp0SillyTavern && call npm install --no-audit && node server.js && pause && popd"
goto :home


:start_extras
REM Run conda activate from the Miniconda installation
call "%miniconda_path%\Scripts\activate.bat"

REM Activate the extras environment
call conda activate extras

REM Start SillyTavern Extras with desired configurations
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Extras launched in a new window.

REM Set the path to modules.txt (in the same directory as the script)
set "modules_path=%~dp0modules.txt"

REM Read modules.txt and find the start_command line
set "start_command="

for /F "tokens=*" %%a in ('findstr /I "start_command=" "%modules_path%"') do (
    set "%%a"
)

if not defined start_command (
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] No modules enabled!%reset%
    echo %red_bg%Please make sure you enabled at least one of the modules from Edit Extras Modules.%reset%
    echo.
    echo %blue_bg%We will redirect you to the Edit Extras Modules menu.%reset%
    pause
    goto :edit_extras_modules
)

set "start_command=%start_command:start_command=%"
start cmd /k "title SillyTavern Extras && cd /d %~dp0SillyTavern-extras && %start_command%"
goto :home

:start_xtts
REM Activate the xtts environment
call conda activate xtts

REM Start XTTS
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% XTTS launched in a new window.

REM Set the path to modules.txt (in the same directory as the script)
set "xtts_modules_path=%~dp0modules-xtts.txt"

REM Read modules.txt and find the xtts_start_command line
set "xtts_start_command="

for /F "tokens=*" %%a in ('findstr /I "xtts_start_command=" "%xtts_modules_path%"') do (
    set "%%a"
)

if not defined xtts_start_command (
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] No modules enabled!%reset%
    echo %red_bg%Please make sure you enabled at least one of the modules from Edit XTTS Modules.%reset%
    echo.
    echo %blue_bg%We will redirect you to the Edit XTTS Modules menu.%reset%
    pause
    goto :edit_xtts_modules
)

set "xtts_start_command=%xtts_start_command:xtts_start_command=%"
start cmd /k "title XTTSv2 API Server && cd /d %~dp0xtts && %xtts_start_command%"
goto :home

REM Check if Node.js is installed
node --version > nul 2>&1
if %errorlevel% neq 0 (
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] node command not found in PATH%reset%
    echo %red_bg%Please make sure Node.js is installed and added to your PATH.%reset%
    echo %red_bg%To install Node.js go to Toolbox%reset%
    pause
    goto :home
)
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% SillyTavern launched in a new window.
start cmd /k "title SillyTavern && cd /d %~dp0SillyTavern && call npm install --no-audit && node server.js && pause && popd"


REM Run conda activate from the Miniconda installation
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Activating Miniconda environment...
call "%miniconda_path%\Scripts\activate.bat"

REM Activate the extras environment
call conda activate extras

REM Start SillyTavern Extras with desired configurations
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Extras launched in a new window.

REM Set the path to modules.txt (in the same directory as the script)
set "modules_path=%~dp0modules.txt"

REM Read modules.txt and find the start_command line
set "start_command="

for /F "tokens=*" %%a in ('findstr /I "start_command=" "%modules_path%"') do (
    set "%%a"
)

if not defined start_command (
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] No modules enabled!%reset%
    echo %red_bg%Please make sure you enabled at least one of the modules from Edit Extras Modules.%reset%
    echo.
    echo %blue_bg%We will redirect you to the Edit Extras Modules menu.%reset%
    pause
    goto :edit_extras_modules
)

set start_command=%start_command:start_command=%
start cmd /k "title SillyTavern Extras && cd /d %~dp0SillyTavern-extras && %start_command%"
goto :home


:update
title SillyTavern [UPDATE]
REM Update SillyTavern-Launcher
set max_retries=3
set retry_count=0

:retry_update_st_launcher
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Updating SillyTavern-Launcher...
cd /d "%~dp0"
call git pull
if %errorlevel% neq 0 (
    set /A retry_count+=1
    echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] Retry %retry_count% of %max_retries%%reset%
    if %retry_count% lss %max_retries% goto :retry_update_st_launcher
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] Failed to update SillyTavern-Launcher repository after %max_retries% retries.%reset%
    pause
    goto :home
)

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%SillyTavern-Launcher updated successfully.%reset%

REM Update SillyTavern
set max_retries=3
set retry_count=0

:retry_update_st
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Updating SillyTavern...
cd /d "%~dp0SillyTavern"
call git pull
if %errorlevel% neq 0 (
    set /A retry_count+=1
    echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] Retry %retry_count% of %max_retries%%reset%
    if %retry_count% lss %max_retries% goto :retry_update_st
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] Failed to update SillyTavern repository after %max_retries% retries.%reset%
    pause
    goto :home
)

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%SillyTavern updated successfully.%reset%


REM Check if SillyTavern-extras directory exists
if not exist "%~dp0SillyTavern-extras" (
    echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] SillyTavern-extras directory not found. Skipping extras update.%reset%
    goto :update_xtts
)

REM Update SillyTavern-extras
set max_retries=3
set retry_count=0

:retry_update_extras
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Updating SillyTavern-extras...
cd /d "%~dp0SillyTavern-extras"
call git pull
if %errorlevel% neq 0 (
    set /A retry_count+=1
    echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] Retry %retry_count% of %max_retries%%reset%
    if %retry_count% lss %max_retries% goto :retry_update_extras
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] Failed to update SillyTavern-extras repository after %max_retries% retries.%reset%
    pause
    goto :home
)

:update_xtts
REM Check if XTTS directory exists
if not exist "%~dp0xtts" (
    echo %yellow_bg%[%time%]%reset% %yellow_fg_strong%[WARN] xtts directory not found. Skipping XTTS update.%reset%
    pause
    goto :home
)
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Updating XTTS...
call conda activate xtts
pip install --upgrade xtts-api-server
call conda deactivate
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%XTTS updated successfully.%reset%
pause
goto :home

REM Switch Brance - frontend
:switchbrance_menu
title SillyTavern [SWITCH-BRANCE]
cls
echo %blue_fg_strong%/ Home / Switch Branch%reset%
echo -------------------------------------
echo What would you like to do?
echo 1. Switch to Release - SillyTavern
echo 2. Switch to Staging - SillyTavern
echo 0. Back to Home

REM Get the current Git branch
for /f %%i in ('git branch --show-current') do set current_branch=%%i
echo ======== VERSION STATUS =========
echo SillyTavern branch: %cyan_fg_strong%%current_branch%%reset%
echo =================================
set /p brance_choice=Choose Your Destiny: 

REM Switch Brance - backend
if "%brance_choice%"=="1" (
    call :switch_release_st
) else if "%brance_choice%"=="2" (
    call :switch_staging_st
) else if "%brance_choice%"=="0" (
    goto :home
) else (
    color 6
    echo WARNING: Invalid number. Please insert a valid number.
    pause
    goto :switchbrance_menu
)


:switch_release_st
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Switching to release branch...
cd /d "%~dp0SillyTavern"
git switch release
pause
goto :switchbrance_menu


:switch_staging_st
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Switching to staging branch...
cd /d "%~dp0SillyTavern"
git switch staging
pause
goto :switchbrance_menu



REM Backup - Frontend
:backup_menu
title SillyTavern [BACKUP]
REM Check if 7-Zip is installed
7z > nul 2>&1
if %errorlevel% neq 0 (
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] 7z command not found in PATH%reset%
    echo %red_bg%Please make sure 7-Zip is installed and added to your PATH.%reset%
    echo %red_bg%To install 7-Zip go to Toolbox%reset%
    pause
    goto :home
)
cls
echo %blue_fg_strong%/ Home / Backup%reset%
echo -------------------------------------
echo What would you like to do?
REM color 7
echo 1. Create Backup
echo 2. Restore Backup
echo 0. Back to Home

set /p backup_choice=Choose Your Destiny: 

REM Backup - Backend
if "%backup_choice%"=="1" (
    call :create_backup
) else if "%backup_choice%"=="2" (
    call :restore_backup
) else if "%backup_choice%"=="0" (
    goto :home
) else (
    color 6
    echo WARNING: Invalid number. Please insert a valid number.
    pause
    goto :backup_menu
)

:create_backup
title SillyTavern [CREATE-BACKUP]
REM Create a backup using 7zip
7z a "%~dp0SillyTavern-backups\backup_.7z" ^
    "public\assets\*" ^
    "public\Backgrounds\*" ^
    "public\Characters\*" ^
    "public\Chats\*" ^
    "public\context\*" ^
    "public\Group chats\*" ^
    "public\Groups\*" ^
    "public\instruct\*" ^
    "public\KoboldAI Settings\*" ^
    "public\movingUI\*" ^
    "public\NovelAI Settings\*" ^
    "public\OpenAI Settings\*" ^
    "public\QuickReplies\*" ^
    "public\TextGen Settings\*" ^
    "public\themes\*" ^
    "public\User Avatars\*" ^
    "public\user\*" ^
    "public\worlds\*" ^
    "public\settings.json" ^
    "secrets.json"

REM Get current date and time components
for /f "tokens=1-3 delims=/- " %%d in ("%date%") do (
    set "day=%%d"
    set "month=%%e"
    set "year=%%f"
)

for /f "tokens=1-2 delims=:." %%h in ("%time%") do (
    set "hour=%%h"
    set "minute=%%i"
)

REM Pad single digits with leading zeros
setlocal enabledelayedexpansion
set "day=0!day!"
set "month=0!month!"
set "hour=0!hour!"
set "minute=0!minute!"

set "formatted_date=%month:~-2%-%day:~-2%-%year%_%hour:~-2%%minute:~-2%"

REM Rename the backup file with the formatted date and time
rename "%~dp0SillyTavern-backups\backup_.7z" "backup_%formatted_date%.7z"

endlocal


echo %green_fg_strong%Backup created at %~dp0SillyTavern-backups%reset%
pause
endlocal
goto :backup_menu


:restore_backup
title SillyTavern [RESTORE-BACKUP]

echo List of available backups:
echo =========================

setlocal enabledelayedexpansion
set "backup_count=0"

for %%F in ("%~dp0SillyTavern-backups\backup_*.7z") do (
    set /a "backup_count+=1"
    set "backup_files[!backup_count!]=%%~nF"
    echo !backup_count!. %cyan_fg_strong%%%~nF%reset%
)

echo =========================
set /p "restore_choice=Enter number of backup to restore: "

if "%restore_choice%" geq "1" (
    if "%restore_choice%" leq "%backup_count%" (
        set "selected_backup=!backup_files[%restore_choice%]!"
        echo Restoring backup !selected_backup!...
        REM Extract the contents of the "public" folder directly into the existing "public" folder
        7z x "%~dp0SillyTavern-backups\!selected_backup!.7z" -o"temp" -aoa
        xcopy /y /e "temp\public\*" "public\"
        rmdir /s /q "temp"
        echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%!selected_backup! restored successfully.%reset%
    ) else (
        color 6
        echo WARNING: Invalid backup number. Please insert a valid number.
    )
) else (
    color 6
    echo WARNING: Invalid number. Please insert a valid number.
)
pause
goto :backup_menu


REM Toolbox - Frontend
:toolbox
title SillyTavern [TOOLBOX]
cls
echo %blue_fg_strong%/ Home / Toolbox%reset%
echo -------------------------------------
echo What would you like to do?
REM color 7
echo 1. App Installer
echo 2. App Uninstaller
echo 3. Edit Extras Modules
echo 4. Edit XTTS Modules
echo 5. Edit Environment Variables
echo 6. Remove node_modules folder
echo 0. Back to Home

set /p toolbox_choice=Choose Your Destiny: 

REM Toolbox - Backend
if "%toolbox_choice%"=="1" (
    call :app_installer
) else if "%toolbox_choice%"=="2" (
    call :app_uninstaller
) else if "%toolbox_choice%"=="3" (
    call :edit_extras_modules
) else if "%toolbox_choice%"=="4" (
    call :edit_xtts_modules
) else if "%toolbox_choice%"=="5" (
    call :edit_environment_var
) else if "%toolbox_choice%"=="6" (
    call :remove_node_modules
) else if "%toolbox_choice%"=="0" (
    goto :home
) else (
    color 6
    echo WARNING: Invalid number. Please insert a valid number.
    pause
    goto :toolbox
)

REM App Installer - Frontend
:app_installer
title SillyTavern [APP INSTALLER]
cls
echo %blue_fg_strong%/ Home / Toolbox / App Installer%reset%
echo ------------------------------------------------
echo What would you like to do?
REM color 7
echo 1. Install 7-Zip
echo 2. Install FFmpeg
echo 3. Install Node.js
echo 0. Back to Toolbox

set /p app_installer_choice=Choose Your Destiny: 

REM App Installer - Backend
if "%app_installer_choice%"=="1" (
    call :install_7zip
) else if "%app_installer_choice%"=="2" (
    call :install_ffmpeg
) else if "%app_installer_choice%"=="3" (
    call :install_nodejs
) else if "%app_installer_choice%"=="0" (
    goto :toolbox
) else (
    color 6
    echo WARNING: Invalid number. Please insert a valid number.
    pause
    goto :app_installer
)


:install_7zip
title SillyTavern [INSTALL-7Z]
echo %blue_fg_strong%[INFO]%reset% Installing 7-Zip...
winget install -e --id 7zip.7zip

rem Get the current PATH value from the registry
for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v PATH') do set "current_path=%%B"

rem Check if the paths are already in the current PATH
echo %current_path% | find /i "%zip7_install_path%" > nul
set "zip7_path_exists=%errorlevel%"

setlocal enabledelayedexpansion

REM Append the new paths to the current PATH only if they don't exist
if %zip7_path_exists% neq 0 (
    set "new_path=%current_path%;%zip7_install_path%"
    echo.
    echo [DEBUG] "current_path is:%cyan_fg_strong% %current_path%%reset%"
    echo.
    echo [DEBUG] "zip7_install_path is:%cyan_fg_strong% %zip7_install_path%%reset%"
    echo.
    echo [DEBUG] "new_path is:%cyan_fg_strong% !new_path!%reset%"

    REM Update the PATH value in the registry
    reg add "HKCU\Environment" /v PATH /t REG_EXPAND_SZ /d "!new_path!" /f

    REM Update the PATH value for the current session
    setx PATH "!new_path!" > nul
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%7-zip added to PATH.%reset%
) else (
    set "new_path=%current_path%"
    echo %blue_fg_strong%[INFO] 7-Zip already exists in PATH.%reset%
)

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%7-Zip installed successfully. Please restart the Launcher.%reset%
pause
exit


:install_ffmpeg
title SillyTavern [INSTALL-FFMPEG]
REM Check if 7-Zip is installed
7z > nul 2>&1
if %errorlevel% neq 0 (
    echo %red_bg%[%time%]%reset% %red_fg_strong%[ERROR] 7z command not found in PATH%reset%
    echo %red_bg%Please make sure 7-Zip is installed and added to your PATH.%reset%
    echo %red_bg%To install 7-Zip go to Toolbox%reset%
    pause
    goto :toolbox
)

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Downloading FFmpeg archive...
curl -L -o "%ffdownload_path%" "%ffmpeg_url%"

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Creating ffmpeg directory if it doesn't exist...
if not exist "%ffextract_path%" (
    mkdir "%ffextract_path%"
)

echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Extracting FFmpeg archive...
7z x "%ffdownload_path%" -o"%ffextract_path%"


echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Moving FFmpeg contents to C:\ffmpeg...
for /d %%i in ("%ffextract_path%\ffmpeg-*-full_build") do (
    xcopy "%%i\bin" "%ffextract_path%\bin" /E /I /Y
    xcopy "%%i\doc" "%ffextract_path%\doc" /E /I /Y
    xcopy "%%i\presets" "%ffextract_path%\presets" /E /I /Y
    rd "%%i" /S /Q
)

rem Get the current PATH value from the registry
for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v PATH') do set "current_path=%%B"

rem Check if the paths are already in the current PATH
echo %current_path% | find /i "%bin_path%" > nul
set "ff_path_exists=%errorlevel%"

setlocal enabledelayedexpansion

REM Append the new paths to the current PATH only if they don't exist
if %ff_path_exists% neq 0 (
    set "new_path=%current_path%;%bin_path%"
    echo.
    echo [DEBUG] "current_path is:%cyan_fg_strong% %current_path%%reset%"
    echo.
    echo [DEBUG] "bin_path is:%cyan_fg_strong% %bin_path%%reset%"
    echo.
    echo [DEBUG] "new_path is:%cyan_fg_strong% !new_path!%reset%"

    REM Update the PATH value in the registry
    reg add "HKCU\Environment" /v PATH /t REG_EXPAND_SZ /d "!new_path!" /f

    REM Update the PATH value for the current session
    setx PATH "!new_path!" > nul
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%ffmpeg added to PATH.%reset%
) else (
    set "new_path=%current_path%"
    echo %blue_fg_strong%[INFO] ffmpeg already exists in PATH.%reset%
)
del "%ffdownload_path%"
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%ffmpeg installed successfully. Please restart the Launcher.%reset%
pause
exit


:install_nodejs
title SillyTavern [INSTALL-NODEJS]
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Installing Node.js...
winget install -e --id OpenJS.NodeJS
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Node.js is installed. Please restart the Launcher.%reset%
pause
exit


:edit_environment_var
rundll32.exe sysdm.cpl,EditEnvironmentVariables
goto :toolbox

:reinstall_sillytavern
title SillyTavern [REINSTALL-ST]
setlocal enabledelayedexpansion
chcp 65001 > nul
REM Define the names of items to be excluded
set "script_name=%~nx0"
set "excluded_folders=backups"
set "excluded_files=!script_name!"

REM Confirm with the user before proceeding
echo.
echo %red_bg%╔════ DANGER ZONE ══════════════════════════════════════════════════════════════════════════════╗%reset%
echo %red_bg%║ WARNING: This will delete all data in the current branch except the Backups.                  ║%reset%
echo %red_bg%║ If you want to keep any data, make sure to create a backup before proceeding.                 ║%reset%
echo %red_bg%╚═══════════════════════════════════════════════════════════════════════════════════════════════╝%reset%
echo.
echo Are you sure you want to proceed? [Y/N] 
set /p "confirmation="
if /i "!confirmation!"=="Y" (
    cd /d "%~dp0SillyTavern"
    REM Remove non-excluded folders
    for /d %%D in (*) do (
        set "exclude_folder="
        for %%E in (!excluded_folders!) do (
            if "%%D"=="%%E" set "exclude_folder=true"
        )
        if not defined exclude_folder (
            rmdir /s /q "%%D" 2>nul
        )
    )

    REM Remove non-excluded files
    for %%F in (*) do (
        set "exclude_file="
        for %%E in (!excluded_files!) do (
            if "%%F"=="%%E" set "exclude_file=true"
        )
        if not defined exclude_file (
            del /f /q "%%F" 2>nul
        )
    )

    REM Clone repo into %temp% folder
    git clone https://github.com/SillyTavern/SillyTavern.git "%temp%\SillyTavern-TEMP"

    REM Move the contents of the temporary folder to the current directory
    xcopy /e /y "%temp%\SillyTavern-TEMP\*" .

    REM Clean up the temporary folder
    rmdir /s /q "%temp%\SillyTavern-TEMP"

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%SillyTavern reinstalled successfully.%reset%
) else (
    echo Reinstall canceled.
)
endlocal
pause
goto :toolbox


REM Function to print module options with color based on their status
:printModule
if "%2"=="true" (
    echo %green_fg_strong%%1 [Enabled]%reset%
) else (
    echo %red_fg_strong%%1 [Disabled]%reset%
)
exit /b

:edit_extras_modules
title SillyTavern [EXTRAS-MODULES]
REM Edit Extras Modules - Frontend
cls
echo %blue_fg_strong%/ Home / Toolbox / Edit Extras Modules%reset%
echo -------------------------------------
echo Choose extras modules to enable or disable (e.g., "1 2 4" to enable Cuda, RVC, and Caption)
REM color 7

REM Display module options with colors based on their status
call :printModule "1. Cuda (--cuda)" %cuda_trigger%
call :printModule "2. RVC (--enable-modules=rvc --rvc-save-file --max-content-length=1000)" %rvc_trigger%
call :printModule "3. talkinghead (--enable-modules=talkinghead --talkinghead-gpu)" %talkinghead_trigger%
call :printModule "4. caption (--enable-modules=caption)" %caption_trigger%
call :printModule "5. summarize (--enable-modules=summarize)" %summarize_trigger%
call :printModule "6. listen (--listen)" %listen_trigger%
call :printModule "7. whisper (--enable-modules=whisper-stt)" %whisper_trigger%
call :printModule "8. Edge-tts (--enable-modules=edge-tts)" %edge_tts_trigger%
echo 0. Back to Toolbox

set "python_command="

set /p module_choices=Choose modules to enable/disable (1-6): 

REM Handle the user's module choices and construct the Python command
for %%i in (%module_choices%) do (
    if "%%i"=="1" (
        if "%cuda_trigger%"=="true" (
            set "cuda_trigger=false"
        ) else (
            set "cuda_trigger=true"
        )
        REM set "python_command= --gpu 0 --cuda-device=0"
    ) else if "%%i"=="2" (
        if "%rvc_trigger%"=="true" (
            set "rvc_trigger=false"
        ) else (
            set "rvc_trigger=true"
        )
        REM set "python_command= --enable-modules=rvc --rvc-save-file --max-content-length=1000"
    ) else if "%%i"=="3" (
        if "%talkinghead_trigger%"=="true" (
            set "talkinghead_trigger=false"
        ) else (
            set "talkinghead_trigger=true"
        )
        REM set "python_command= --enable-modules=talkinghead"
    ) else if "%%i"=="4" (
        if "%caption_trigger%"=="true" (
            set "caption_trigger=false"
        ) else (
            set "caption_trigger=true"
        )
        REM set "python_command= --enable-modules=caption"
    ) else if "%%i"=="5" (
        if "%summarize_trigger%"=="true" (
            set "summarize_trigger=false"
        ) else (
            set "summarize_trigger=true"
        )
    ) else if "%%i"=="6" (
        if "%listen_trigger%"=="true" (
            set "listen_trigger=false"
        ) else (
            set "listen_trigger=true"
        )
        REM set "python_command= --listen"
    ) else if "%%i"=="7" (
        if "%whisper_trigger%"=="true" (
            set "whisper_trigger=false"
        ) else (
            set "whisper_trigger=true"
        )
        REM set "python_command= --enable-modules=whisper-stt"
    ) else if "%%i"=="8" (
        if "%edge_tts_trigger%"=="true" (
            set "edge_tts_trigger=false"
        ) else (
            set "edge_tts_trigger=true"
        )
        REM set "python_command= --enable-modules=edge-tts"
    ) else if "%%i"=="0" (
        goto :toolbox
    )
)


REM Save the module flags to modules.txt
echo cuda_trigger=%cuda_trigger%>"%~dp0modules.txt"
echo rvc_trigger=%rvc_trigger%>>"%~dp0modules.txt"
echo talkinghead_trigger=%talkinghead_trigger%>>"%~dp0modules.txt"
echo caption_trigger=%caption_trigger%>>"%~dp0modules.txt"
echo summarize_trigger=%summarize_trigger%>>"%~dp0modules.txt"
echo listen_trigger=%listen_trigger%>>"%~dp0modules.txt"
echo whisper_trigger=%whisper_trigger%>>"%~dp0modules.txt"
echo edge_tts_trigger=%edge_tts_trigger%>>"%~dp0modules.txt"

REM remove modules_enable
set "modules_enable="

REM Compile the Python command
set "python_command=python server.py"
if "%listen_trigger%"=="true" (
    set "python_command=%python_command% --listen"
)
if "%cuda_trigger%"=="true" (
    set "python_command=%python_command% --cuda"
)
if "%rvc_trigger%"=="true" (
    set "python_command=%python_command% --rvc-save-file --max-content-length=1000"
    set "modules_enable=%modules_enable%rvc,"
)
if "%talkinghead_trigger%"=="true" (
    set "python_command=%python_command% --talkinghead-gpu"
    set "modules_enable=%modules_enable%talkinghead,"
)
if "%caption_trigger%"=="true" (
    set "modules_enable=%modules_enable%caption,"
)
if "%summarize_trigger%"=="true" (
    set "modules_enable=%modules_enable%summarize,"
)
if "%whisper_trigger%"=="true" (
    set "modules_enable=%modules_enable%whisper-stt,"
)
if "%edge_tts_trigger%"=="true" (
    set "modules_enable=%modules_enable%edge-tts,"
)

REM is modules_enable empty?
if defined modules_enable (
    REM remove last comma
    set "modules_enable=%modules_enable:~0,-1%"
)

REM command completed
if defined modules_enable (
    set "python_command=%python_command% --enable-modules=%modules_enable%"
)

REM Save the constructed Python command to modules.txt for testing
echo start_command=%python_command%>>"%~dp0modules.txt"
goto :edit_extras_modules

REM ==================================================================================================================================================

REM Function to print module options with color based on their status
:printModule
if "%2"=="true" (
    echo %green_fg_strong%%1 [Enabled]%reset%
) else (
    echo %red_fg_strong%%1 [Disabled]%reset%
)
exit /b

:edit_xtts_modules
title SillyTavern [XTTS-MODULES]
REM Edit XTTS Modules - Frontend
cls
echo %blue_fg_strong%/ Home / Toolbox / Edit XTTS Modules%reset%
echo -------------------------------------
echo Choose XTTS modules to enable or disable (e.g., "1 2 4" to enable Cuda, hs, and cache)
REM color 7

REM Display module options with colors based on their status
call :printModule "1. cuda (--device cuda)" %xtts_cuda_trigger%
call :printModule "2. hs (-hs 0.0.0.0)" %xtts_hs_trigger%
call :printModule "3. deepspeed (--deepspeed)" %xtts_deepspeed_trigger%
call :printModule "4. cache (--use-cache)" %xtts_cache_trigger%
call :printModule "5. listen (--listen)" %xtts_listen_trigger%
call :printModule "6. model (--model-source local)" %xtts_model_trigger%
echo 0. Back to Toolbox

set "python_command="

set /p xtts_module_choices=Choose modules to enable/disable (1-6): 

REM Handle the user's module choices and construct the Python command
for %%i in (%xtts_module_choices%) do (
    if "%%i"=="1" (
        if "%xtts_cuda_trigger%"=="true" (
            set "xtts_cuda_trigger=false"
        ) else (
            set "xtts_cuda_trigger=true"
        )
        REM set "python_command= --device cuda"
    ) else if "%%i"=="2" (
        if "%xtts_hs_trigger%"=="true" (
            set "xtts_hs_trigger=false"
        ) else (
            set "xtts_hs_trigger=true"
        )
        REM set "python_command= -hs 0.0.0.0"
    ) else if "%%i"=="3" (
        if "%xtts_deepspeed_trigger%"=="true" (
            set "xtts_deepspeed_trigger=false"
        ) else (
            set "xtts_deepspeed_trigger=true"
        )
        REM set "python_command= --deepspeed"
    ) else if "%%i"=="4" (
        if "%xtts_cache_trigger%"=="true" (
            set "xtts_cache_trigger=false"
        ) else (
            set "xtts_cache_trigger=true"
        )
        REM set "python_command= --use-cache"
    ) else if "%%i"=="5" (
        if "%xtts_listen_trigger%"=="true" (
            set "xtts_listen_trigger=false"
        ) else (
            set "xtts_listen_trigger=true"
        )
    ) else if "%%i"=="6" (
        if "%xtts_model_trigger%"=="true" (
            set "xtts_model_trigger=false"
        ) else (
            set "xtts_model_trigger=true"
        )
        REM set "python_command= --model-source local"
    ) else if "%%i"=="0" (
        goto :toolbox
    )
)

REM Save the module flags to modules-xtts.txt
echo xtts_cuda_trigger=%xtts_cuda_trigger%>"%~dp0modules-xtts.txt"
echo xtts_hs_trigger=%xtts_hs_trigger%>>"%~dp0modules-xtts.txt"
echo xtts_deepspeed_trigger=%xtts_deepspeed_trigger%>>"%~dp0modules-xtts.txt"
echo xtts_cache_trigger=%xtts_cache_trigger%>>"%~dp0modules-xtts.txt"
echo xtts_listen_trigger=%xtts_listen_trigger%>>"%~dp0modules-xtts.txt"
echo xtts_model_trigger=%xtts_model_trigger%>>"%~dp0modules-xtts.txt"

REM remove modules_enable
set "modules_enable="

REM Compile the Python command
set "python_command=python -m xtts_api_server"
if "%xtts_cuda_trigger%"=="true" (
    set "python_command=%python_command% --device cuda"
)
if "%xtts_hs_trigger%"=="true" (
    set "python_command=%python_command% -hs 0.0.0.0"
)
if "%xtts_deepspeed_trigger%"=="true" (
    set "python_command=%python_command% --deepspeed"
)
if "%xtts_cache_trigger%"=="true" (
    set "python_command=%python_command% --use-cache"
)
if "%xtts_listen_trigger%"=="true" (
    set "python_command=%python_command% --listen"
)
if "%xtts_model_trigger%"=="true" (
    set "python_command=%python_command% --model-source local"
)

REM is modules_enable empty?
if defined modules_enable (
    REM remove last comma
    set "modules_enable=%modules_enable:~0,-1%"
)

REM command completed
if defined modules_enable (
    set "python_command=%python_command% --enable-modules=%modules_enable%"
)

REM Save the constructed Python command to modules-xtts.txt for testing
echo xtts_start_command=%python_command%>>"%~dp0modules-xtts.txt"
goto :edit_xtts_modules


:remove_node_modules
echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing node_modules folder...
cd /d "%~dp0SillyTavern"
rmdir /s /q "node_modules"
goto :toolbox



:app_uninstaller
REM App Uninstaller - Frontend
:app_uninstaller
title SillyTavern [APP UNINSTALLER]
cls
echo %blue_fg_strong%/ Home / Toolbox / App Uninstaller%reset%
echo ------------------------------------------------
echo What would you like to do?
echo 1. UNINSTALL Extras
echo 2. UNINSTALL XTTS
echo 3. UNINSTALL SillyTavern
echo 0. Back to Toolbox

set /p app_uninstaller_choice=Choose Your Destiny: 

REM App Uninstaller - Backend
if "%app_uninstaller_choice%"=="1" (
    call :uninstall_extras
) else if "%app_uninstaller_choice%"=="2" (
    call :uninstall_xtts
) else if "%app_uninstaller_choice%"=="3" (
    call :uninstall_st
) else if "%app_uninstaller_choice%"=="0" (
    goto :toolbox
) else (
    color 6
    echo WARNING: Invalid number. Please insert a valid number.
    pause
    goto :app_uninstaller
)

:uninstall_extras
title SillyTavern [UNINSTALL EXTRAS]
setlocal enabledelayedexpansion
chcp 65001 > nul

REM Confirm with the user before proceeding
echo.
echo %red_bg%╔════ DANGER ZONE ══════════════════════════════════════════════════════════════════════════════╗%reset%
echo %red_bg%║ WARNING: This will delete all data of Extras                                                  ║%reset%
echo %red_bg%║ If you want to keep any data, make sure to create a backup before proceeding.                 ║%reset%
echo %red_bg%╚═══════════════════════════════════════════════════════════════════════════════════════════════╝%reset%
echo.
set /p "confirmation=Are you sure you want to proceed? [Y/N]: "
if /i "%confirmation%"=="Y" (

    REM Remove the Conda environment
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing the Conda environment 'extras'...
    call conda remove --name extras --all -y

    REM Remove the folder SillyTavern-extras
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing the SillyTavern-extras directory...
    cd /d "%~dp0"
    rmdir /s /q "%~dp0SillyTavern-extras"

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%Extras has been uninstalled successfully.%reset%
    pause
    goto :app_uninstaller
) else (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Uninstall canceled.
    pause
    goto :app_uninstaller
)


:uninstall_xtts
title SillyTavern [UNINSTALL XTTS]
setlocal enabledelayedexpansion
chcp 65001 > nul

REM Confirm with the user before proceeding
echo.
echo %red_bg%╔════ DANGER ZONE ══════════════════════════════════════════════════════════════════════════════╗%reset%
echo %red_bg%║ WARNING: This will delete all data of XTTS                                                    ║%reset%
echo %red_bg%║ If you want to keep any data, make sure to create a backup before proceeding.                 ║%reset%
echo %red_bg%╚═══════════════════════════════════════════════════════════════════════════════════════════════╝%reset%
echo.
set /p "confirmation=Are you sure you want to proceed? [Y/N]: "
if /i "%confirmation%"=="Y" (

    REM Remove the Conda environment
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing the Conda environment 'xtts'...
    call conda remove --name xtts --all -y

    REM Remove the folder SillyTavern
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing the xtts directory...
    cd /d "%~dp0"
    rmdir /s /q "%~dp0xtts"

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%XTTS has been uninstalled successfully.%reset%
    pause
    goto :app_uninstaller
) else (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Uninstall canceled.
    pause
    goto :app_uninstaller
)


:uninstall_st
title SillyTavern [UNINSTALL ST]
setlocal enabledelayedexpansion
chcp 65001 > nul

REM Confirm with the user before proceeding
echo.
echo %red_bg%╔════ DANGER ZONE ══════════════════════════════════════════════════════════════════════════════╗%reset%
echo %red_bg%║ WARNING: This will delete all data of SillyTavern                                             ║%reset%
echo %red_bg%║ If you want to keep any data, make sure to create a backup before proceeding.                 ║%reset%
echo %red_bg%╚═══════════════════════════════════════════════════════════════════════════════════════════════╝%reset%
echo.
set /p "confirmation=Are you sure you want to proceed? [Y/N]: "
if /i "%confirmation%"=="Y" (

    REM Remove the folder SillyTavern
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Removing the SillyTavern directory...
    cd /d "%~dp0"
    rmdir /s /q "%~dp0SillyTavern"

    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% %green_fg_strong%SillyTavern has been uninstalled successfully.%reset%
    pause
    goto :app_uninstaller
) else (
    echo %blue_bg%[%time%]%reset% %blue_fg_strong%[INFO]%reset% Uninstall canceled.
    pause
    goto :app_uninstaller
)

REM Support menu - Frontend
:support
title SillyTavern [SUPPORT]
cls
echo %blue_fg_strong%/ Home / Support%reset%
echo -------------------------------------
echo What would you like to do?
echo 1. I want to report a issue
echo 2. Documentation
echo 3. Discord
echo 0. Back to Home

set /p support_choice=Choose Your Destiny: 

REM Support menu - Backend
if "%support_choice%"=="1" (
    call :issue_report
) else if "%support_choice%"=="2" (
    call :documentation
) else if "%support_choice%"=="3" (
    call :discord
) else if "%support_choice%"=="0" (
    goto :home
) else (
    color 6
    echo WARNING: Invalid number. Please insert a valid number.
    pause
    goto :support
)

:issue_report
start "" "https://github.com/SillyTavern/SillyTavern-Launcher/issues/new/choose"
goto :support

:documentation
start "" "https://docs.sillytavern.app/"
goto :support

:discord
start "" "https://discord.gg/sillytavern"
goto :support