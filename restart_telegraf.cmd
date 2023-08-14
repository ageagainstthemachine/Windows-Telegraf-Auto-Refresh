@echo off
rem Telegraf Restart Script by Julian McConnell
rem Rev 20230813a
rem https://julianmcconnell.com

rem This short script is used in conjuntion with the scheduled task hourly restarts of the Telegraf Windows service to trigger new dynamic config pulls from a central InfluxDB server

rem stop telegraf
net stop "telegraf"

rem start telegraf
net start "telegraf"