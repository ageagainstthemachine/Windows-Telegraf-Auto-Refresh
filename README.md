# Windows-Telegraf-Auto-Refresh
Routine automatic InfluxDB 2 configuration refreshes with the Telegraf service on Windows

### Prerequisites
- Windows client machine to be monitored
- Latest Telegraf binary for Windows (available via <a href="https://github.com/influxdata/telegraf" target="_blank">GitHub</a>)
- InfluxDB 2 server to send metrics back to (accessible by the Windows client machine)
- InfluxDB 2 Telegraf configuration ready for deployment, including API endpoint URL and Token generated


### Process Overview
The way I've developed this process over the past few years is to deploy the latest Telegraf binary with an installation batch/command file which goes through a number of operations to achieve a desired result.

The process in a nutshell is as follows:
- The target installation directory is created on the system
- The Telegraf binary is copied to the installation directory (along wth supporting restart command stub file and uninstallation command file)
- The Telegraf Windows service is setup/installed via (parameter-based) binary interaction
- The Telegraf Windows service is started
- A scheduled task is created that restarts the Windows service every hour, effectively refreshing the configuration pull


### Security
One thing to note is that in this configuration, the InfluxDB token is being stored in the Windows OS as an environment variable. This has obvious security implications due to the token being present in plain text and accessible globally on the system. Unfortunately, there isn't a great solution here if this is a concern on the systems you're deploying to. The only other option I am aware of is to embed the Token in the configuration file. In that regard, choose your own adventure and monitor accordingly from a security standpoint.


### More Information
For more information, see <a href="https://julianmcconnell.com/posts/Automatic_Telegraf_Config_Refreshes/" target="_blank">here</a>.


### Development
There is a development branch available if you're feeling adventurous.

If you see something I have missed, something I should do differently, something I could do better, or maybe there is something you think could be added, please let me know.


### Disclaimer
These scripts are probably unstable and full of bugs. Like everything else on the internet, run at your own risk.