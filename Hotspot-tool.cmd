@echo off

rem  --> This script was made by: Rasmus Hedekær Krohn Gade
rem  --> Script version 1.2
rem  --> test version for now
mode con: cols=80 lines=25
color 0a
Title Hotspot Configurator
cls

:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------    

rem  --> This script was made by: Rasmus Hedekær Krohn Gade

rem  --> GUI/menu of this tool
:start
cls
powershell -Command Write-Host "If this is the first time using this script on this computer" -background "red" -foreground "yellow"
powershell -Command Write-Host "configure hotspot (1), turn hotspot on (2) and configurate network adapter (4)" -background "red" -foreground "yellow"
ECHO.
powershell -Command Write-Host "REMEMBER TO TURN OFF THE FIREWALL!!" -background "red" -foreground "yellow"
ECHO --------------------------------------------------------------------------------
ECHO [1] Configure hotspot
ECHO --------------------------------------------------------------------------------
ECHO [2] Turn on hotspot
ECHO --------------------------------------------------------------------------------
ECHO [3] Turn off hotspot
ECHO --------------------------------------------------------------------------------
ECHO [4] Configure networkadapter
ECHO --------------------------------------------------------------------------------
ECHO [5] Close this script
ECHO --------------------------------------------------------------------------------
set /p choice=

rem  --> Code for the different choices made through GUI/menu

if %choice%==1 GOTO Hotspotconfig
if %choice%==2 GOTO Starthotspot
if %choice%==3 GOTO Stophotspot
if %choice%==4 GOTO Netconfig
if %choice%==5 GOTO Closeprogram
ECHO Wrong input, please just enter a number between 1-5!.
pause
GOTO start

rem  --> hotspot configuration code
:Hotspotconfig
netsh wlan stop hostednetwork
netsh wlan set hostednetwork mode=allow
cls
rem  --> This needs a way to restrict the user from using space in the name
ECHO What would you like to call the hotspot? (no spaces are allowed in the name!)
set /p name=
rem  --> This needs a way of not allowing userinputs under 8 characters
ECHO What would you like the password to be? (minimum of 8 characters!)
set /p key=
netsh wlan set hostednetwork ssid=%name%
netsh wlan set hostednetwork key=%key%
netsh wlan start hostednetwork
pause
GOTO start

rem  --> The start hotspot code
:Starthotspot
ECHO Starting hotspot
netsh wlan start hostednetwork
pause
GOTO start

rem  --> The stop hotspot code
:Stophotspot
ECHO Stopping hotspot
netsh wlan stop hostednetwork
pause
GOTO start

rem  --> Takes user back to the config hotspot code in the beginning of the script
:Hotspotconfig
cls
GOTO Hotspot

rem  --> Temporary fix for first time setting the windows hostednetwork up. This is only valid until i get something done in powershell
:Netconfig
cls
ECHO --------------------------------------------------------------------------------
ECHO The network adapter settings is opening up now, please follow the instructions.
pause
cls

rem  --> opens up network adapter settings
explorer.exe ::{7007ACC7-3202-11D1-AAD2-00805FC1270E}

rem  --> Guide for sharing the connection with other users
ECHO --------------------------------------------------------------------------------
ECHO 1: Right click the active ethernet (shown as two screens and an ethernet plug)  and then go to properties.
pause
ECHO --------------------------------------------------------------------------------
ECHO 2: Switch to the tab called sharing
pause
ECHO --------------------------------------------------------------------------------
ECHO 3: Tick to share connection with other users
pause
ECHO --------------------------------------------------------------------------------
ECHO 4: Click the box underneath the share connection option and choose the hosted   network option just created (can be identified by the * icon in it's name) and  press "ok"
ECHO --------------------------------------------------------------------------------

pause
GOTO start

rem  --> closes the program
:Closeprogram
GOTO exit
