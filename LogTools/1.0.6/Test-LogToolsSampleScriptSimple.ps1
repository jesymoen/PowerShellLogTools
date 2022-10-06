<#
.SYNOPSIS
This is a simple sample test script that illustrates how to use the LogTools module functions most effectively.

This is a simple version of the sample scripts provided with the module, which illustrates the basic functionality of easily hooking text file logging into your scripts.   

.DESCRIPTION
This is a simple sample test script that illustrates how to use the LogTools module functions most effectively.

This is a simple version of the sample scripts provided with the module, which illustrates the basic functionality of easily hooking text file logging into your scripts.   

There is also an advanced version, called Test-LogToolsSampleScriptAdvanced.ps1, which demonstrates more functionality and a few more advanced scripting techniques.

.EXAMPLE
    PS C:\Scripts> .\Test-LogToolsSampleScriptSimple.ps1
    
    This example simply runs the script. 
    
    Test logged output will be logged to C:\Scripts\Logs\MyScript_YYYY-MM-DD_(HOSTNAME).log

.EXAMPLE
    PS C:\Scripts> .\Test-LogToolsSampleScriptSimple.ps1 -LogDir C:\Scripts\Logs

    This example runs the script using the -LogDir paramater, which allows you to specify the target log directory when running the script. 
    
    Test logged output will be logged to C:\Scripts\Logs\MyScript_YYYY-MM-DD_(HOSTNAME).log

.EXAMPLE
    PS C:\Scripts> .\Test-LogToolsSampleScriptSimple.ps1 -Verbose

    This example runs the script in Verbose mode. When run in Verbose mode, all Write-Verbose statements will be written in to the console (as normal), as well as written to the logfile. 
    
    When Verbose mode is NOT enabled, all Write-Verbose statements will NOT be written to the console, but they will be written to the logfile.
    
    Test logged output will be logged to C:\Scripts\Logs\MyScript_YYYY-MM-DD_(HOSTNAME).log

.EXAMPLE
    PS C:\Scripts> .\Test-LogToolsSampleScriptSimple.ps1 -Debug
    
    This example runs the script in Debug mode. When run in Debug mode, all Write-Debug statements will be processed and will prompt for interaction (as normal) depending on debug preference. Write-Debug messages will also be written to the logfile in this mode. 
    
    When Debug mode is NOT enabled, all Write-Debug statements will NOT be processed, but they will be written to the logfile.
    
    Test logged output will be logged to C:\Scripts\Logs\MyScript_YYYY-MM-DD_(HOSTNAME).log

.NOTES
Version 1.0.5
Author: Jeff Symoens (jeff.symoens@microsoft.com), Microsoft Consulting Services
Created: 05/04/2022
Last Modified: 05/10/2022

Disclaimer: This script is provided "as-is". No support or warranty from Microsoft is expressed or implied.

#>


[CmdletBinding()]
param(
    [Parameter(Mandatory=$false,Position=1,ValuefromPipeline=$false)][ValidateNotNullOrEmpty()][string]$LogDir
)


Try
{
    if (Get-Module LogTools -ListAvailable)
    {   
        
        # To enable logging of Write-Verbose, Write-Warning and Write-Error use the following: 
        # - Create a logfile
        # - Add-LogFileHooking
        # - Run Initialize-LogOutput to initialize the logfile.

        # Check to see if the log directory exists, and if not creates it and returns it as a variable.
        if ($LogDir)
        {
            # If the $LogDir parameter was specified, then use that for the log directory
            $LogDir = New-LogDirectory -Name $LogDir
        }

        else {
            # Otherwise we use a manually specied directory
            $LogDir = New-LogDirectory -Name C:\Scripts\Logs
        }

        # Create the logfile name
        $LogFile = New-LogfileName -LogBaseName MyScript -LogDir $LogDir
        
        # Enable logfile hooking which will redirect the Write-Verbose, Write-Warning, Write-Error, and Write-Debug cmdlets
        Enable-LogFileHooking -Logfile $LogFile
        
        # Initialize the Logfile - (optional, but recommended - writes a header entry in the logfile)
        Initialize-LogFile -Message "This is a test of the emergency broadcast system."

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
    }
    
}
