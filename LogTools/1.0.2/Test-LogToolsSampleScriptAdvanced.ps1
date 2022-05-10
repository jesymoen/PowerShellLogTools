<#
.SYNOPSIS
This is an advanced sample test script that illustrates how to use the LogTools module functions most effectively.

This is an advanced version of the sample scripts provided with the module, which illustrates the more advanced functionality of easily hooking text file logging into your scripts.   

.DESCRIPTION
This is a simple sample test script that illustrates how to use the LogTools module functions most effectively.

This is a simple version of the sample scripts provided with the module, which illustrates the basic functionality of easily hooking text file logging into your scripts. This advanced sample script which demonstrates module functionality using the advanced function options and scripting techniques.  

There is also a simple version, called Test-LogToolsSampleScriptSimple.ps1, which demonstrates the basic functionality of the module and using simple techniques.

.EXAMPLE
    PS C:\Scripts> .\Test-LogToolsSampleScriptAdvanced.ps1
    
    This example simply runs the script. 
    
    Test logged output will be logged to C:\Scripts\Logs\MyScript_YYYY-MM-DD_(HOSTNAME).log

.EXAMPLE
    PS C:\Scripts> .\Test-LogToolsSampleScriptAdvanced.ps1 -LogDir C:\Scripts\Logs

    This example runs the script using the -LogDir paramater, which allows you to specify the target log directory when running the script. 
    
    Test logged output will be logged to C:\Scripts\Logs\MyScript_YYYY-MM-DD_(HOSTNAME).log

.EXAMPLE
    PS C:\Scripts> .\Test-LogToolsSampleScriptAdvanced.ps1 -Verbose

    This example runs the script in Verbose mode. When run in Verbose mode, all Write-Verbose statements will be written in to the console (as normal), as well as written to the logfile. 
    
    When Verbose mode is NOT enabled, all Write-Verbose statements will NOT be written to the console, but they will be written to the logfile.
    
    Test logged output will be logged to C:\Scripts\Logs\MyScript_YYYY-MM-DD_(HOSTNAME).log

.EXAMPLE
    PS C:\Scripts> .\Test-LogToolsSampleScriptAdvanced.ps1 -Debug
    
    This example runs the script in Debug mode. When run in Debug mode, all Write-Debug statements will be processed and will prompt for interaction (as normal) depending on debug preference. Write-Debug messages will also be written to the logfile in this mode. 
    
    When Debug mode is NOT enabled, all Write-Debug statements will NOT be processed, but they will be written to the logfile.
    
    Test logged output will be logged to C:\Scripts\Logs\MyScript_YYYY-MM-DD_(HOSTNAME).log

.NOTES
Version 1.0.2
Author: Jeff Symoens (jeff.symoens@microsoft.com), Microsoft Consulting Services
Created: 05/04/2022
Last Modified: 05/04/2022

Disclaimer: This script is provided "as-is". No support or warranty from Microsoft is expressed or implied.

#>


[CmdletBinding()]
param(
    [Parameter(Mandatory=$false,Position=1,ValuefromPipeline=$false)][ValidateNotNullOrEmpty()][string]$LogDir="C:\Scripts\Logs"
)


Try
{
    if (Get-Module LogTools -ListAvailable)
    {   
        
        # To enable logging of Write-Verbose, Write-Warning and Write-Error use the following: 
        # - Create a logfile
        # - Set a file lock on the log file (optional, but recommended - creates a file lock on the logfile)
        # - Add-LogFileHooking
        # - Run Initialize-LogOutput to initialize the logfile.

        # If nothing has been set for the LogDir parameter, then set the LogDir variable to the script directory + Logs.
        if (!$LogDir)
        {
            $LogDir = ($MyInvocation).MyCommand.Path.TrimEnd(($MyInvocation).MyCommand.Name) + "Logs" 
        }


        # Check to see if the log directory exists, and if not creates it and returns it as a variable.
        $LogDir = New-LogDirectory -Name $LogDir
        
        # Get the name of the script, to be used as the logfile base name. 
        $ScriptName = ($MyInvocation).MyCommand.Name
        
        # Parse script name base and strip "-" from the name and set to vaviable to be used for the logfile base name.
        $LogFileBaseName = $ScriptName.Split(".")[0].Replace("-","")
        
        # Generate logfile name and create the logfile. The -Unique option checks for the presence of the logfile. 
        # If it exists, then function adds an enumerator (i.e., 1, 2, 3, etc.) until the file name is unique. 
        $LogFile = New-LogfileName -LogBaseName $LogFileBaseName -LogDir $LogDir -Unique
        
        # Place a file lock on the logfile and store in variable to remove the lock when done. 
        $fsObjLogfile = New-LogFileLock -FileName $LogFile
        
        # Enable logfile hooking which will redirect the Write-Verbose, Write-Warning, Write-Error, and Write-Debug cmdlets.

        # Advanced options  
        #   -IncludeRunspaceID adds the RunspaceID to each logged message.
        #   -ThrowExceptionOnWriteError allows you to use Write-Error instead of 'throw' for exceptions. 
        #       In this case use Write-Error in the catch statement instead of throw. This will allow you to log the exception, using Write-Error, and then the module will throw the exception. 
        #   -SupressConsoleOutput supresses console output from  the Write-Verbose, Write-Warning, and Write-Error cmdlets. 
        #       This provides a silent-mode, which prevent status messages from being introduced into the pipeline. 
        Enable-LogFileHooking -Logfile $LogFile -IncludeRunspaceID -ThrowExceptionOnWriteError -SupressConsoleOutput 
        
        # Alternatively, you can use the line below for the simple version
        # Enable-LogFileHooking -Logfile $LogFile


        # Initialize the Logfile - (optional, but recommended - writes a header entry in the logfile).
        # In this case, we send the MyInvocation variable and the Initialize-LogFile function parses the script name and writes that in log header.
        # The -IncludeScriptPath parameter includes the full path of the script when writing the header.
        Get-Variable -Name MyInvocation | Initialize-LogFile -IncludeScriptPath

        # Alternatively, you can use the line below for the simple version to write a generic message header.
        # Initialize-LogFile -Message "This is a test of the emergency broadcast system."

        # Set a variable to indicate that logging is enabled
        $LoggingEnabled = $true
    }

    else 
    {
        # Set a variable to indicate that logging is not enabled
        $LoggingEnabled = $false
    }

    Write-Verbose "Logging Enabled: $LoggingEnabled"

    ### Start - Logging tests ###

    # Test output lines, created as an array
    $test = @("test1", "test2", "test3")
    # Tests send a string array to Write-Verbose using the pipeline.
    $test | Write-Verbose
    # Tests using Write-Verbose with a standard message.
    Write-Verbose "This is a 'Write-Verbose' test."

    # Tests send a string array to Write-Warning using the pipeline.
    $test | Write-Warning
    # Tests using Write-Warning with a standard message.
    Write-Warning "This is a 'Write-Warning' test."

    # Tests using Write-Debug with a standard message.
    # The 'Write-Debug' line will only run if either the $DebugPreference is set to "Continue" or the -Debug parameter is added when running the script. 
    # However, the line will be logged either way. 
    Write-Debug "This is a 'Write-Debug' test."  

    # Tests using Write-Error with a standard message.
    Write-Error "This is a 'Write-Error' test." 
    # Test an exception. This non-existent cmdlet will generate a terminating error.
    get-fooboohoo 

    ### End - Logging tests ###

}

Catch 
{ 
    # Option 1: Using Write-Error will write the exception to the logfile before throwing the exception
    if ($ThrowExceptionOnWriteErrorGlobal) # This is a Global variable created by the Add-LogFileHooking function if the -ThrowExceptionOnWriteError switch is used when running it.
    { 
        Write-Error -ErrorRecord $_ # Writes the Exception to the logfile, and then throws exception
    } 

    # Option 2: Uses the standard throw keyword. The exception will not be written to the logfile before it is thrown. 
    else 
    {
        throw $_
    }
      
}

Finally 
{
    if ($LoggingEnabled)
    {
        # Removes the LogFileHooking feature, including associated aliases that hook Write-Verbose, Write-Warning, Write-Debug and Write-Error, and global variables.
        Disable-LogfileHooking

        # Remove file lock on log file if one exists
        if ($fsObjLogfile)
        {
            Write-Verbose "Removing File Lock from $($fsObjLogfile.name)."
            Remove-LogFileLock -FileSystemObject  $fsObjLogfile
        }

        # Deletes old logfiles more than the value of 'RetentionDays' days old. In this example, logs more than 1 day old in the $LogDir directory will be deleted.
        Clear-LogFileHistory -Path $LogDir -RetentionDays 1
    }
    
}
