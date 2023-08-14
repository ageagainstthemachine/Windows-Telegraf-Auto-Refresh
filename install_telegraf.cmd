@echo off
rem Telegraf Dynamic Config Windows Installer Command File by Julian McConnell
rem Rev 20230813a
rem https://julianmcconnell.com

rem This Telegraf installation command file uses the configuration stored in InfluxDB with API endpoint and Token

rem IMPORTANT: LATEST (OR DESIRED VERSION OF) TELEGRAF BINARY (TELEGRAF.EXE) IS REQUIRED! PLACE IT IN THE SAME DIRECTORY AS THE REST OF THESE FILES!

rem Please note this file must be run from a local drive, not a UNC path or network drive.

rem Credit for auto-elevation goes to: https://gist.github.com/Flayed/cafed37bbdc4fb82081d98d87721fd1b#file-launchasadmin-cmd
rem Credit for checking if the script is being run from a UNC path or network drive goes to: https://stackoverflow.com/questions/57703876/windows-10-how-can-i-determine-whether-a-batch-file-is-being-run-from-network-m

rem First, check if this is running from a UNC path (network share) or mapped network drive
if "%~d0" == "\\" (
    echo Batch file was started from a UNC path - "%~dp0". Please move to a local directory! This script will now exit.
    pause
    goto :EOF
)
%SystemRoot%\System32\net.exe use | %SystemRoot%\System32\findstr.exe /I /L /C:" %~d0 " >nul
if not errorlevel 1 (
    echo Batch file was started from network drive %~d0. Please move to a local directory! This script will now exit.
    pause
    goto :EOF
)
echo Running batch file from local drive %~d0. Continuing...

rem This section attempts to elevate if not elevated already
:-------------------------------------
REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:-------------------------------------- 
rem Continue after we have admin privileges...

rem Here we make sure Telegraf binary is present (note that this is just checking the file name, not hash or anything more definitive)
if exist "%~dp0telegraf.exe" (
    rem Telegraf binary is actually present, so we are continuing
    GOTO CONTINUE
) else (
    rem The file is not present, so let the user know that
    echo Telegraf binary is not present! Please add the latest telegraf.exe binary in the source folder.
    rem Here we pause for the user to take notice of the message and take action
    pause
    rem Now we quit the script
    GOTO QUITME
)

:CONTINUE
rem Now we create the directory C:\Program Files\Telegraf\
echo Creating Telegraf Program Files Directory...
md "C:\Program Files\Telegraf\"

rem Next we copy files to directory
echo Copying Files To Telegraf Program Files Directory...
copy "%~dp0telegraf.exe" "C:\Program Files\Telegraf\telegraf.exe"
copy "%~dp0restart_telegraf.cmd" "C:\Program Files\Telegraf\restart_telegraf.cmd"
copy "%~dp0uninstall_telegraf.cmd" "C:\Program Files\Telegraf\uninstall_telegraf.cmd"

rem Now comes the part where we setup the environment variable for token storage
echo Setting InfluxDB Token Environment Variable...
setx /M INFLUX_TOKEN "TOKEN_VALUE_HERE_BETWEEN_DOUBLE_QUOTES"

rem installs service with config set to InfluxDB config URL
echo Installing the Telegraf Windows service...
"C:\Program Files\Telegraf\telegraf.exe" --service install --config "http://endpoint-fqdn-or-ip-address-here:8086/api/v2/telegrafs/012345678abcdef"

rem start the telegraf service
echo Starting the Telegraf Windows service...
"C:\Program Files\Telegraf\telegraf.exe" --service start

rem setup hourly scheduled task for restarting the Telegraf service
echo Setting up hourly scheduled task for regular Telegraf Windows service restarts (configuration retrieval refreshes)
SCHTASKS /CREATE /SC HOURLY /TN "Misc\Restart_Telegraf" /TR "C:\Program Files\Telegraf\restart_telegraf.cmd" /RL HIGHEST /RU SYSTEM /ST 12:00

rem All finished (note: comment out the pause if the desire is for this script to be fully automated)
echo Complete!
pause

:QUITME
