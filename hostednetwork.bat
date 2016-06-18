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

set /P c=Vil du konfigurere hotspottet f�r det startes [Y/N]?
if /I "%c%" EQU "Y" netsh wlan stop hostednetwork
if /I "%c%" EQU "Y" netsh wlan set hostednetwork mode=allow
if /I "%c%" EQU "Y" set /p name= Hvad vil du kalde dit hotspot?
if /I "%c%" EQU "Y" set /p key= Hvad skal koden v�re til dit hotspot (skal minimum v�re p� 8 tegn)?
if /I "%c%" EQU "Y" netsh wlan set hostednetwork ssid=%name%
if /I "%c%" EQU "Y" netsh wlan set hostednetwork key=%key%
if /I "%c%" EQU "N" pause

:start
cls
ECHO Hvis det er f�rste gang, du bruger dette program, skal du t�nde for hotspottet (tryk 1) og dern�st v�lge "konfigurer netv�rksindtilling" (tryk 3)
ECHO -----------------------------------------------------------------------------------------------------------------------------------------------------------
ECHO 1.T�nd for hotspot
ECHO -----------------------------------------------------------------------------------------------------------------------------------------------------------
ECHO 2.Sluk for hotspot
ECHO -----------------------------------------------------------------------------------------------------------------------------------------------------------
ECHO 3.Konfigurer netv�rksindstilling
ECHO -----------------------------------------------------------------------------------------------------------------------------------------------------------
ECHO 4.Luk dette program
ECHO -----------------------------------------------------------------------------------------------------------------------------------------------------------

CHOICE /C 1234 /M "L�s f�rst alle mulighederne og v�lg derefter!:"

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
ECHO netv�rksindstillingerne �bnes nu, f�lg dern�st vejledningen der f�lger.
pause
explorer.exe ::{7007ACC7-3202-11D1-AAD2-00805FC1270E}
ECHO -----------------------------------------------------------------------------------------------------------------------------------------------------------
ECHO 1: H�jreklik p� dit tr�dede netv�rk (vist med et ikon af to sk�rme og et stik) og v�lg egenskaber.
pause
ECHO -----------------------------------------------------------------------------------------------------------------------------------------------------------  
ECHO 2: V�lg fanen "Deling"
pause
ECHO -----------------------------------------------------------------------------------------------------------------------------------------------------------  
ECHO 3: Ving kassen af med teksten "Tillad andre brugere p� netv�rket at oprette forbindelse gennem denne computers internetforbindelse"
pause
ECHO -----------------------------------------------------------------------------------------------------------------------------------------------------------
ECHO 4: Tryk p� kassen med teksten "v�lg en privat netv�rksforbindelse" og v�lg den af lan forbindelserne der har et * ikon til sidst og tryk "ok"
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