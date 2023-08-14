@echo off
rem Telegraf Dynamic Config Windows Uninstaller
rem Rev 20230813a
rem https://julianmcconnell.com

rem This uninstallation command file is used to remove the Windows Telegraf installation located in C:\Program Files\Telegraf\

rem Credit for auto-elevation goes to: https://gist.github.com/Flayed/cafed37bbdc4fb82081d98d87721fd1b#file-launchasadmin-cmd

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

rem First stop the Telegraf service
echo Stopping the Telegraf service...
"%~dp0telegraf.exe" --service stop

rem Next delete the scheduled task
echo Deleting the scheduled task...
SCHTASKS /DELETE /TN "Misc\Restart_Telegraf"

rem Next uninstall the Telegraf service
echo Uninstalling Telegraf Windows service...
"%~dp0telegraf.exe" --service uninstall

rem Now remove the token environment variable
echo Removing the Token environment variable...
REG delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /F /V "INFLUX_TOKEN"

rem Finally remove directory and attempt to remove self
start /b "" cmd /c rd /s /q "%~dp0" && echo Complete! && pause