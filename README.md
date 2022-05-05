# PowerShellLogTools
This PowerShell module  provides several functions that can be used to add logging to a text-based file to your scripts, quickly and easily. It also includes functions to manage those files.

## Purpose
The PowerShell LogTools Module is designed to add text-based logging features to your PowerShell scripts in a seamless way. The idea is that you write scripts using standard PowerShell language, features, and functions. Then, with a small amount of starter code, you will be able to get text-based logging of things that you output to the screen using common cmdlets like Write-Verbose, Write-Warning, Write-Debug, and Write-Error. If the module is not installed on the machine, then the starter code is bypassed and your script runs just the way it did when you wrote it, just without logging. If the module is installed, then the start code activates logging. That's it!!!

The idea is that your script should have logging capabilities when the module is available, but not require code changes or produce errors if it is not available. And, you shouldn't have to make major modifications to add logging to a script that already has verbose, warning, debug, and error messages implemented throughout.  

## How Does it Work?
The LogTools module includes a number of functions that assist with logfile operations, from creating a directory for your logs, to generating logfile names that include the date and hostname, to adding and removing a file lock, to cleaning up old log files. However, tje core of the module is actually writing messages to log files. For that there are several key functions, the most central of which is the Write-LogMessage function. This function actually writes the log messages, but there are also some helper functions that simply call the Write-LogMessage function with different options. Each of these functions is designed to align with a default PowerShell cmdlet, as follows: 

LogTools Function|Aligns with PowerShell Function
|:---|:---|
Write-LogMessage (with no parameters)|Write-Verbose
Write-LogWarning|Write-Warning
Write-LogError|Write-Error  
Write-LogDebug|Write-Debug


## Included Functions
* New-LogDirectory
* New-LogFileName
* Write-LogMessage
* Write-LogWarning
* Write-LogError
* Write-LogDebug
* New-LogFileLock<br>
* Remove-LogFileLock<br>
* Enable-LogFileHooking<br>
* Initialize-LogFile<br>
* Disable-LogFileHooking<br>
* Clear-LogFileHistory<br>


