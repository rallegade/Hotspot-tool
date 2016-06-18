@echo off
chcp 1252
cls
color 0a
mode con: cols=160 lines=50
Title Hotspot konfiguration

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

set /P c=Vil du konfigurere hotspottet før det startes [Y/N]?
if /I "%c%" EQU "Y" netsh wlan stop hostednetwork
if /I "%c%" EQU "Y" netsh wlan set hostednetwork mode=allow
if /I "%c%" EQU "Y" set /p name= Hvad vil du kalde dit hotspot?
if /I "%c%" EQU "Y" set /p key= Hvad skal koden være til dit hotspot (skal minimum være på 8 tegn)?
if /I "%c%" EQU "Y" netsh wlan set hostednetwork ssid=%name%
if /I "%c%" EQU "Y" netsh wlan set hostednetwork key=%key%
if /I "%c%" EQU "N" pause

:start
cls
ECHO Hvis det er første gang, du bruger dette program, skal du tænde for hotspottet (tryk 1) og dernæst vælge "konfigurer netværksindtilling" (tryk 3)
ECHO -----------------------------------------------------------------------------------------------------------------------------------------------------------
ECHO 1.Tænd for hotspot
ECHO -----------------------------------------------------------------------------------------------------------------------------------------------------------
ECHO 2.Sluk for hotspot
ECHO -----------------------------------------------------------------------------------------------------------------------------------------------------------
ECHO 3.Konfigurer netværksindstilling
ECHO -----------------------------------------------------------------------------------------------------------------------------------------------------------
ECHO 4.Luk dette program
ECHO -----------------------------------------------------------------------------------------------------------------------------------------------------------

CHOICE /C 1234 /M "Læs først alle mulighederne og vælg derefter!:"

:: Note - list ERRORLEVELS in decreasing order
IF ERRORLEVEL 4 GOTO Closeprogram
IF ERRORLEVEL 3 GOTO Netconfig
IF ERRORLEVEL 2 GOTO Stophotspot
IF ERRORLEVEL 1 GOTO Starthotspot

:Starthotspot
ECHO Starter hotspot
netsh wlan start hostednetwork
pause
GOTO start

:Stophotspot
ECHO Stopper hotspot
netsh wlan stop hostednetwork
pause
GOTO start

:Netconfig
ECHO -----------------------------------------------------------------------------------------------------------------------------------------------------------
ECHO netværksindstillingerne åbnes nu, følg dernæst vejledningen der følger.
pause
explorer.exe ::{7007ACC7-3202-11D1-AAD2-00805FC1270E}
ECHO -----------------------------------------------------------------------------------------------------------------------------------------------------------
ECHO 1: Højreklik på dit trådede netværk (vist med et ikon af to skærme og et stik) og vælg egenskaber.
pause
ECHO -----------------------------------------------------------------------------------------------------------------------------------------------------------  
ECHO 2: Vælg fanen "Deling"
pause
ECHO -----------------------------------------------------------------------------------------------------------------------------------------------------------  
ECHO 3: Ving kassen af med teksten "Tillad andre brugere på netværket at oprette forbindelse gennem denne computers internetforbindelse"
pause
ECHO -----------------------------------------------------------------------------------------------------------------------------------------------------------
ECHO 4: Tryk på kassen med teksten "vælg en privat netværksforbindelse" og vælg den af lan forbindelserne der har et * ikon til sidst og tryk "ok"
pause
GOTO start

:Closeprogram
GOTO exit

:ColorText
echo off
echo %DEL% > "%~2"
findstr /v /a:%1 /R "^$" "%~2" nul
del "%~2" > nul 2>&1
goto :eof