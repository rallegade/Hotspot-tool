@echo off

:: This script was made by: Rasmus Hedekær Krohn Gade https://github.com/rallegade/Hotspot-tool
set Scriptversion=1.4
mode con: cols=80 lines=31
color 0a
Title Hotspot Configurator

rem  --> code for colored text without using powershell
setLOCAL EnableDelayedExpansion
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set "DEL=%%a"
)

cls

:: BatchGotAdmin
:-------------------------------------
rem  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

rem --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto :UACPrompt
) else ( goto :gotAdmin )

:UACPrompt
    echo set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"=""
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------    

rem  --> This script was made by: Rasmus Hedekær Krohn Gade https://github.com/rallegade/Hotspot-tool

rem  --> GUI/menu of this tool
:start
cls
call :ColorText 4e "If this is the first time using this script on this computer"
echo.
call :ColorText 4e "configure hotspot (1), turn hotspot on (2) and configurate network adapter (4)"
echo.
echo.
call :ColorText 4e "REMEMBER TO TURN OFF THE FIREWALL"
echo.
echo --------------------------------------------------------------------------------
echo [1] Configure hotspot
echo --------------------------------------------------------------------------------
echo [2] Turn on hotspot
echo --------------------------------------------------------------------------------
echo [3] Turn off hotspot
echo --------------------------------------------------------------------------------
echo [4] Configure networkadapter
echo --------------------------------------------------------------------------------
echo [5] Hotspot info
echo --------------------------------------------------------------------------------
echo [6] Connected devices
echo --------------------------------------------------------------------------------
echo [7] Check for new versions of the script
echo --------------------------------------------------------------------------------
echo [8] Close this script
echo --------------------------------------------------------------------------------
set /p choice=

rem  --> Code for the different choices made through GUI/menu

if %choice%==1 goto :Hotspotconfig
if %choice%==2 goto :Starthotspot
if %choice%==3 goto :Stophotspot
if %choice%==4 goto :Netconfig
if %choice%==5 goto :Hotspotinfo
if %choice%==6 goto :Connecteddevices
if %choice%==7 goto :Autoupdate
if %choice%==8 goto :Closeprogram
echo Wrong input, please just enter a number between 1-8!.
pause
goto :start

rem  --> option 1: hotspot configuration code
:Hotspotconfig
netsh wlan stop hostednetwork
netsh wlan set hostednetwork mode=allow
cls
::This needs a way to restrict the user from using space in the name
echo What would you like to call the hotspot? (no spaces are allowed in the name!)
set /p name=
::This needs a way of not allowing userinputs under 8 characters
echo What would you like the password to be? (minimum of 8 characters!)
set /p key=
cls
netsh wlan set hostednetwork ssid=%name%
netsh wlan set hostednetwork key=%key%
netsh wlan show hostednetwork setting=security
goto :start

rem  --> option 2: The start hotspot code
:Starthotspot
cls
echo Starting hotspot
netsh wlan start hostednetwork
goto :start

rem  --> option 3: The stop hotspot code
:Stophotspot
cls
echo Stopping hotspot
netsh wlan stop hostednetwork
goto :start

rem  --> option 4: network adaptor settings
::Temporary fix for first time setting the windows hostednetwork up. This is only valid until i get something done in powershell
:Netconfig
cls
echo --------------------------------------------------------------------------------
echo The network adapter settings is opening up now, please follow the instructions.
pause
cls

::opens up network adapter settings
explorer.exe ::{7007ACC7-3202-11D1-AAD2-00805FC1270E}

::Guide for sharing the connection with other users
echo --------------------------------------------------------------------------------
echo 1: Right click the active ethernet (shown as two screens and an ethernet plug)  and then go to properties.
pause
echo --------------------------------------------------------------------------------
echo 2: Switch to the tab called sharing
pause
echo --------------------------------------------------------------------------------
echo 3: Tick to share connection with other users
pause
echo --------------------------------------------------------------------------------
echo 4: Click the box underneath the share connection option and choose the hosted   network option just created (can be identified by the * icon in it's name) and  press "ok"
echo --------------------------------------------------------------------------------

pause
goto :start

rem  --> option 5: Shows information about the hotspot
:Hotspotinfo
cls
netsh wlan show hostednetwork
netsh wlan show hostednetwork setting=security
pause
goto :start

rem  --> option 6: Shows a list of connected devices
:: This was made by JamesCullum check out his hotspot tool here https://github.com/JamesCullum/Windows-Hotspot
:Connecteddevices
@echo off 
cls
set hasClients=0
arp -a | findstr /r "192\.168\.[0-9]*\.[2-9][^0-9] 192\.168\.[0-9]*\.[0-9][0-9][^0-9] 192\.168\.[0-9]*\.[0-1][0-9][0-9]" >test.tmp
arp -a | findstr /r "192\.168\.[0-9]*\.2[0-46-9][0-9] 192\.168\.[0-9]*\.25[0-4]" >>test.tmp
for /F "tokens=1,2,3" %%i in (test.tmp) do call :process %%i %%j %%k
del test.tmp
echo Connected Clients
echo ------------------
if %hasClients%==0 echo No device is currently connected to your hotspot
if %hasClients%==1 (
	type result.tmp
	del result.tmp
)
echo ------------------
pause
goto :start

:process
set VAR1=%1
ping -a %VAR1% -n 1 | findstr Pinging > loop1.tmp
for /F "tokens=1,2,3" %%i in (loop1.tmp) do call :process2 %%i %%j %%k
del loop1.tmp
goto :EOF

:process2 
set VAR2=%2
set VAR3=%3
set hasClients=1
echo %VAR2% %VAR3% >>result.tmp
goto :EOF 

:EOF

rem  --> option 7: This is the autoupdate script, which checks this version of the script against the ones on github
:: and downloads the new version if present.
:Autoupdate
::this part checks for internet connection
cls
echo checking internet connection
ping 8.8.8.8 -n 1 -w 1000
cls
if errorlevel 1 (goto :Nointernet) else (goto :Updatecheck)

:Updatecheck
cls
echo Checking the version of this script... Please whait.
powershell -command "& { (New-Object Net.WebClient).DownloadFile('https://github.com/rallegade/Hotspot-tool/releases/download/V0.1/version.cmd', '%cd%\version.cmd') }"
call version.cmd
if %Build% LEQ %Scriptversion% goto :Uptodate
if %Build% GTR %Scriptversion% goto :Updater
goto :start

:Updater
call :ColorText 4e "The current version of this script is not up to date!"
echo.
set /P c=Do you wish to download the newest version? [Y/N]
if /I "%c%" EQU "N" goto :Notupdating
if /I "%c%" EQU "Y" goto :UpdateDownload

:UpdateDownload
cls
echo Downloading %Name%
powershell -command "& { (New-Object Net.WebClient).DownloadFile('%Download%', '%cd%\%Name%') }"
echo deleting temporary files
Del version.cmd
echo.
echo The newest version was downloaded to the same
echo directory as this script is running from
pause
goto :Closeprogram

:Notupdating
DEL version.cmd
cls
call :ColorText 4e "The script was not updated!"
echo.
call :ColorText 4e "You should consider updating the script though!"
echo.
echo.
pause
goto :start

:Uptodate
echo The script is up to date!
DEL version.cmd
pause
goto :start

:Nointernet
call :ColorText 4e "You are not connected to the internet"
echo.
call :ColorText 4e "Connect to the internet and try again"
echo.
echo.
pause
goto :start

rem  --> option 8: closes the program
:Closeprogram
goto :exit

rem  --> code for colored text without using powershell
:ColorText
echo off
<nul set /p ".=%DEL%" > "%~2"
findstr /v /a:%1 /R "^$" "%~2" nul
del "%~2" > nul 2>&1
goto :eof
