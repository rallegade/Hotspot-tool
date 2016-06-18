@echo off
rem  --> This script was made by: Rasmus Hedekær Krohn Gade
rem  --> Script version 1.2
mode con: cols=80 lines=25
color 0a
Title Hotspot konfiguration
chcp 1252
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

rem  --> hotspot configuration code
:Hotspot
set /P c=Vil du konfigurere hotspottet før det startes [Y/N]?
if /I "%c%" EQU "Y" netsh wlan stop hostednetwork
if /I "%c%" EQU "Y" netsh wlan set hostednetwork mode=allow
rem  --> This needs a way to restrict the user from using space in the name
if /I "%c%" EQU "Y" set /p name= Hvad vil du kalde dit hotspot? (navnet må ikke indeholde mellemrum!)
rem  --> This needs a way of not allowing userinputs under 8 characters
if /I "%c%" EQU "Y" set /p key= Hvad skal koden være til dit hotspot? (skal minimum være på 8 tegn!)
if /I "%c%" EQU "Y" netsh wlan set hostednetwork ssid=%name%
if /I "%c%" EQU "Y" netsh wlan set hostednetwork key=%key%
if /I "%c%" EQU "N" pause

rem  --> GUI/menu of this tool
:start
cls
powershell -Command Write-Host "Hvis det er første gang du bruger programmet, på din PC, skal du tænde for hotspot ved at taste 1 og dernæst vælge 'konfigurer netværksindtilling' ved at taste 3" -background "red" -foreground "yellow"
ECHO.
powershell -Command Write-Host "HUSK AT SLÅ FIREWALL FRA!!!" -background "red" -foreground "yellow"
ECHO --------------------------------------------------------------------------------
ECHO 1.Tænd for hotspot
ECHO --------------------------------------------------------------------------------
ECHO 2.Sluk for hotspot
ECHO --------------------------------------------------------------------------------
ECHO 3.Konfigurer netværksindstilling
ECHO --------------------------------------------------------------------------------
ECHO 4.Konfigurer hotspotsindstillinger
ECHO --------------------------------------------------------------------------------
ECHO 5.Luk dette program
ECHO --------------------------------------------------------------------------------

rem  --> Code for the different choices made through GUI/menu
CHOICE /C 12345 /M "Læs først alle mulighederne og vælg derefter:"

:: Note - list ERRORLEVELS in decreasing order
IF ERRORLEVEL 5 GOTO Closeprogram
IF ERRORLEVEL 4 GOTO Hotspotconfig
IF ERRORLEVEL 3 GOTO Netconfig
IF ERRORLEVEL 2 GOTO Stophotspot
IF ERRORLEVEL 1 GOTO Starthotspot

rem  --> The start hotspot code
:Starthotspot
ECHO Starter hotspot
netsh wlan start hostednetwork
pause
GOTO start

rem  --> The stop hotspot code
:Stophotspot
ECHO Stopper hotspot
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
ECHO netværksindstillingerne åbnes nu, følg dernæst vejledningen der følger.
pause
cls

rem  --> opens up network adapter settings
explorer.exe ::{7007ACC7-3202-11D1-AAD2-00805FC1270E}

rem  --> Guide for sharing the connection with other users
ECHO --------------------------------------------------------------------------------
ECHO 1: Højreklik på dit trådede netværk (vist med et ikon af to tændte skærme og et stik) og vælg egenskaber.
pause
ECHO --------------------------------------------------------------------------------
ECHO 2: Vælg fanen "Deling"
pause
ECHO --------------------------------------------------------------------------------
ECHO 3: Ving kassen af med teksten "Tillad andre brugere på netværket at oprette forbindelse gennem denne computers internetforbindelse"
pause
ECHO --------------------------------------------------------------------------------
ECHO 4: Tryk på kassen med teksten "vælg en privat netværksforbindelse" og vælg den  af lan forbindelserne der har et * ikon i navnet og tryk "ok"
ECHO --------------------------------------------------------------------------------

pause
GOTO start

rem  --> closes the program
:Closeprogram
GOTO exit