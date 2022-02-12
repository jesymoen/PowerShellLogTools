[CmdletBinding()]
param(
    [Parameter(Mandatory=$false,Position=10,ValuefromPipeline=$false)][ValidateNotNullOrEmpty()][string]$LogDir="C:\Users\jesymoen\Documents\Repos\PowerShellGeneral\Logs\Test"
)


Try
{
    if (Get-Module LogTools -ListAvailable)
    {   
        # This line sets the $PSBoundParameters['Verbose'] value to a hard false (instead of null) if Verbose is not a bound parameter
        if (!($PSBoundParameters['Verbose']))
        {
            $PSBoundParameters['Verbose'] = $false
        }

        # This line sets the $PSBoundParameters['Debug'] value to a hard false (instead of null) if Verbose is not a bound parameter
        if (!($PSBoundParameters['Debug']))
        {
            $PSBoundParameters['Debug'] = $false
        }
        
        $VerbosePreference = "Continue"
        $WarningPreference = "Continue"
        $ErrorActionPreference = "Continue"
        $DebugPreference = "Continue"

        #$VerbosePreference = "SilentlyContinue"
        #$WarningPreference = "SilentlyContinue"
        #$ErrorActionPreference = "SilentlyContinue"
        #$DebugPreference = "SilentlyContinue"
        
        # To enable logging of Write-Verbose, Write-Warning and Write-Error use the following: 
        # - Create a logfile
        # - Set a file lock on the log file (optional, but recommended - creates a file lock on the logfile)
        # - Add-LogFileHooking
        # - Run Initialize-LogOutput to initialize the logfile.

        # If nothing has been set for the LogDir parameter, then set the LogDir variable to the script directory + Logs 
        if (!$LogDir)
        {
            $LogDir = ($MyInvocation).MyCommand.Path.TrimEnd(($MyInvocation).MyCommand.Name) + "Logs" 
        }


        # Check to see if the log directory exists, and if not creates
        $LogDir = New-LogDirectory -Name $LogDir
        # Get the name of the script, to be used as the logfile base name. 
        $ScriptName = ($MyInvocation).MyCommand.Name
        # Parse script name base and strip "-" from the name and set to vaviable to be used for the logfile base name
        $LogFileBaseName = $ScriptName.Split(".")[0].Replace("-","")
        $LogFile = New-LogfileName -LogBaseName $LogFileBaseName -LogDir $LogDir -Unique
        # Place a file lock on the logfile and store in variable to remove the lock when done  
        $fsObjLogfile = New-LogFileLock -FileName $LogFile
        # Enable logfile hooking which will redirect the Write-Verbose, Write-Warning, Write-Error, and Write-Debug cmdlets
        Enable-LogFileHooking -Logfile $LogFile -ThrowExceptionOnWriteError
        # Enable-LogFileHooking -Logfile $LogFile -Verbose:$PSBoundParameters['Verbose'] -Debug:$PSBoundParameters['Debug'] -IncludeRunspaceID -ThrowExceptionOnWriteError
        
        # Initialize the Logfile - (optional, but recommended - writes a header entry in the logfile)
        Get-Variable -Name MyInvocation | Initialize-LogOutput

        $LoggingEnabled = $true
    }

    else 
    {
        $LoggingEnabled = $false
    }

    Write-Verbose "Logging Enabled: $LoggingEnabled"

    # Test output lines
    Write-Verbose "This is a 'Write-Verbose' test."
    Write-Warning "This is a 'Write-Warning' test."
    # Tests send a string array to Write-Warning using the pipeline.
    $test = @("test1", "test2", "test3")
    $test | Write-Warning

    Write-Debug "This is a 'Write-Debug' test."  # This line will only run if either the $DebugPreference is set to "Continue" or the -Debug parameter is added when running the script.  
    Write-Error "This is a 'Write-Error' test." 
    # Test an exception
    get-fooboohoo # This non-existent cmdlet will generate a terminating error


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
            Remove-LogFileLock -fsObj $fsObjLogfile
        }

        # Deletes old logfiles more than the value of 'RetentionDays' days old. In this example, more than 1 day.
        Clear-LogFileHistory -Path $LogDir -RetentionDays 1
    }
    
}
