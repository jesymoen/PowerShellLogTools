# PowerShellLogTools
This PowerShell module  provides several functions that can be used to add logging to a text-based file to your scripts, quickly and easily. It also includes functions to manage those files.

## Purpose
The PowerShell LogTools module is designed to add text-based logging features to your PowerShell scripts in a seamless way. The idea is that you write scripts using standard PowerShell language, features, and functions. Then, with a small amount of starter code, you will be able to get text-based logging of things that you output to the screen using common cmdlets like Write-Verbose, Write-Warning, Write-Debug, and Write-Error. If the module is not installed on the machine, then the starter code is bypassed and your script runs just the way it did when you wrote it, just without logging. If the module is installed, then the start code activates logging. That's it!!!

The idea is that your script should have logging capabilities when the module is available, but not require code changes or produce errors if it is not available. And, you shouldn't have to make major modifications to add logging to a script that already has verbose, warning, debug, and error messages implemented throughout.  

## Installation
The PowerShell LogTools module is published on [PowerShell Gallery](https://www.powershellgallery.com/packages/LogTools). To install, simply run:<br>
>Install-Module -Name LogTools

## How Does it Work?
The LogTools module includes a number of functions that assist with logfile operations, from creating a directory for your logs, to generating logfile names that include the date and hostname, to adding and removing a file lock, to cleaning up old log files. However, the core functionality of the module is actually writing messages to log files. For that there are several key functions, the most central of which is the Write-LogMessage function. This function actually writes the log messages, but there are also some helper functions that simply call the Write-LogMessage function with different options. Each of these functions is designed to align with a default PowerShell cmdlet, as follows: 

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
Test-LogToolsSampleScriptAdvanced.ps1 | Provides a more advanced example of creating a log file by capturing the script name, creating and removing a file lock on the log file, and enabling log file hooking with advanced options. This script also writes a header into the logfile, using the MyInvocation variable to parse the script name to include in the header. Includes examples of Write-Verbose, Write-Warning, Write-Debug, and Write-Error, as well as exception handling. Also includes an example of Clear-LogFileHistory function, which can be used to delete old log files.


## Included Functions
The table below provides a high-level description of each of the functions that are included in the module.

Function|Description
|:------------------------------------|:------------------|
New-LogDirectory | Checks to see if the target directory exists, if not the function creates it. The function returns the path of the directory, properly formatted.  
New-LogFileName | Generates a new logfile name formatted as "C:\LogDir\LogBaseName_YYYY-MM-DD_(HostName).log". The returned value can be used as a parameter to for any cmdlet that writes (or reads) to a log file. The  cmdlet allows for consistent logfile name creation that incorporates a user provided name (LogBaseName) and automatically stamps date, hostname and uniqueness strings in the logfile name.
Write-LogMessage | Writes a user-provided status message out to a designated logfile and optionally to the console screen.
Write-LogWarning | The Write-LogWarning function is a helper function, which maps to the functionality of the PowerShell Write-Error cmdlet. This function (along with Write-LogError and Write-LogDebug) is designed to be used with the Enable-LogFileHooking function, which creates an alias to redirect calls to the Write-Error cmdlet to this function. This allows the standard Write-Warning cmdlet to be used in scripts, while adding support to write the content to a targeted logfile.
Write-LogError | The Write-LogError function is a helper function, which maps to the functionality of the PowerShell Write-Error cmdlet. This function (along with Write-LogWarning and Write-LogDebug) is designed to be used with the Enable-LogFileHooking function, which creates an alias to redirect calls to the Write-Error cmdlet to this function. This allows the standard Write-Error cmdlet to be used in scripts, while adding support to write the content to a targeted logfile. 
Write-LogDebug | The Write-LogDebug function is a helper function, which maps to the functionality of the PowerShell Write-Debug cmdlet. This function (along with Write-LogWarning and Write-LogError) is designed to be used with the Enable-LogFileHooking function, which creates an alias to redirect calls to the Write-Debug cmdlet to this function. This allows the standard Write-Debug cmdlet to be used in scripts, while adding support to write the content to a targeted logfile.
New-LogFileLock |  Creates a new read-write file lock on the file provided as the input argument.
Remove-LogFileLock | Removes a file lock from a file system object provided as the input argument.
Enable-LogFileHooking | The Enable-LogFileHooking function runs a series of configuration tasks that "hook" logging into your script or PowerShell session. Once run, this function enables all Write-Verbose, Write-Warning, Write-Error, and Write-Debug messages to be logged to the designated logfile.    
Disable-LogFileHooking | The Disable-LogFileHooking function removes the configuration settings (the global variables and aliases) created by the Enable-LogFileHooking hooking function.
Initialize-LogFile | Initializes the logfile by writing a banner in the logfile. This function is optional, but can provide a nice way to differentiate between different runs of a script when appending to the same log file.
Clear-LogFileHistory | The Clear-LogFileHistory function can be used to delete files in a directory (or a single file) that are older than a given number of days. This function can be used to effectively prune, for example, a logfile directory that experiences continuous growth. Running the Clear-LogFileHistory cmdlet once per day with, for example, the RetentionDays argument set to 14 will delete all files that are older than 14 days. 

