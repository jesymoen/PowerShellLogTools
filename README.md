# PowerShellLogTools
This PowerShell module  provides several functions that can be used to add logging to a text-based file to your scripts, quickly and easily. It also includes functions to manage those files.

## Purpose
The PowerShell LogTools Module is designed to add text-based logging features to your PowerShell scripts in a seamless way. The idea is that you write scripts using standard PowerShell language, features, and functions. Then, with a small amount of starter code, you will be able to get text-based logging of things that you output to the screen using common cmdlets like Write-Verbose, Write-Warning, Write-Debug, and Write-Error. If the module is not installed on the machine, then the starter code is bypassed and your script runs just the way it did when you wrote it, just without logging. If the module is installed, then the start code activates logging. That's it!!!

The idea is that your script should have logging capabilities when the module is available, but not require code changes or produce errors if it is not available. And, you shouldn't have to make major modifications to add logging to a script that already has verbose, warning, debug, and error messages implemented throughout.  

## How Does it Work?
The LogTools module includes a number of functions that assist with logfile operations, from creating a directory for your logs, to generating logfile names that include the date and hostname, to adding and removing a file lock, to cleaning up old log files. However, tje core of the module is actually writing messages to log files. For that there are several key functions, the most central of which is the Write-LogMessage function. This function actually writes the log messages, but there are also some helper functions that simply call the Write-LogMessage function with different options. Each of these functions is designed to align with a default PowerShell cmdlet, as follows: 

LogTools Function|Aligns with PowerShell Function
|:---|:---|
Write-LogMessage (with default parameters)|Write-Verbose
Write-LogWarning|Write-Warning
Write-LogError|Write-Error  
Write-LogDebug|Write-Debug

While each of the above functions can be called directly, the module is best used by using the Enable-LogFileHooking function. The Enable-LogFileHooking function runs a series of configuration tasks that "hook" logging into your script or PowerShell session. Once run, this function enables all Write-Verbose, Write-Warning, Write-Error, and Write-Debug messages to be logged to the designated logfile.   

The Enable-LogFileHooking function creates a several global variables in the PowerShell session which are used to facilite logging. In addition, the function also creates alias that redirect common PowerShell cmdlets to functions in the LogTools module, as follows:

Alias created for:| Redirects to LogTools function:
|:---|:---|
Write-Verbose | Write-LogMessage
Write-Warning | Write-LogWarning
Write-Debug | Write-LogDebug
Write-Error | Write-LogError
        
The creation of these alias allows you to simply use these common PowerShell cmdlets when writing your script. When LogFileHooking is not enabled, these cmdlets simply run as normal, providing the desired screen output notifications that they were designed for. 
        
When LogFileHooking is enabled, then these aliases will call the corresponding helper functions in this module and enable logging of this messages. 

When LogFileHooking is enable, the display of Verbose and Debug messages to the screen is governed by either the common parameter switches (the "-Verbose" and "-Debug" switches respectively) when running a script, cmdlet or function, or the respective environmental variables ("$VerbosePreference" and "$DebugPreference"). This is the same is if LogFileHooking was not enabled. Therefore, to manage whether Write-Verbose and Write-Debug messages are displayed on-screen simply use the command-line parameters or environment variables as normal.    

To remove the varables and aliases created by this function, run the Disable-LogFileHooking function. 

## Test/Sample Scripts
There are two sample scripts in the module directory that provide examples of how to utilize the module effectively. These scripts are designed to help demonstrate the core functionality of the module. However, you can also use them as starter scripts or templates from which to start creating scripts that are enabled for logging from the start. The table below provides a breif description of each of the sample scripts.    

Sample Script Name| Description
|:------------------------------------|:------------------|
Test-LogToolsSampleScriptSimple.ps1 | Provides a basic example of creating a log file and enabling log file hooking and writing a header into the logfile. Includes examples of Write-Verbose, Write-Warning, Write-Debug, and Write-Error, as well as exception handling.  
Test-LogToolsSampleScriptAdvanced.ps1 | Provides a more advanced example of creating a log file by capturing the script name, creating and removove a file lock on the log file, and enabling log file hooking with advanced options. This script also writes a header into the logfile, using the MyInvocation variable to parse the script name to include in the header. Includes examples of Write-Verbose, Write-Warning, Write-Debug, and Write-Error, as well as exception handling. Also includes an example of Clear-LogFileHistory function, which can be used to delete old log files.


## Included Functions
* New-LogDirectory
* New-LogFileName
* Write-LogMessage
* Write-LogWarning
* Write-LogError
* Write-LogDebug
* New-LogFileLock
* Remove-LogFileLock
* Enable-LogFileHooking
* Initialize-LogFile
* Disable-LogFileHooking
* Clear-LogFileHistory
