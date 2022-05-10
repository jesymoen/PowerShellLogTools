<#
.SYNOPSIS
This script module provides various functions for performing logging operations in 
PowerShell scripts.  

.DESCRIPTION
This script module provides various functions for performing logging operations in 
PowerShell scripts. 

Author: Jeff Symoens (jeff.symoens@microsoft.com), Microsoft Consulting Services
Created: 05/04/2022
Last Modified: 05/04/2022

Disclaimer: This script is provided "as-is". No support or warranty from Microsoft 
is expressed or implied.

#>


function New-LogDirectory ()
{
    <#
    .SYNOPSIS
        Checks to see if the target directory exists, if not the function creates it. The function returns the path of the directory, properly formatted.   
    .DESCRIPTION
        Checks to see if the target directory exists, if not the function creates it. The function returns the path of the directory, properly formatted. For example, if an unqualified directory name is passed to the function, such as 'Logs' then it will be formatted relative to the current working directory, like '.\Logs'. The script will also strip trailing backslashes if present in the input.
    
    .PARAMETER Name
        Indicates the name or location of the desired log directory. This parameter is mandatory. Examples include:
    
        Logs
        .\Logs
        C:\Logs
        \\servername\sharename\Logs

    .PARAMETER Path
        Indicates the parent directory location for the logfile name. This parameter is optional. Since you can include the directory location as part of the Directory parameter, this parameter is only used if you want to pass the logfile name and location as separate parameters.    
    
    .EXAMPLE
        PS C:\> New-LogDirectory Logs

        or 

        PS C:\> New-LogDirectory -Name Logs
        
        This example checks for the presence of the directory '.\Logs'. If it doesn't exist, the function creates the directory relative to the current console path. The function then returns '.\Logs'.  
    
    .EXAMPLE
        PS C:\> $Path = (Split-Path -Path ((Get-Variable -Name MyInvocation).Value).MyCommand.Path)
        PS C:\> New-LogDirectory -Name Logs -Path $Path
        
        This example sets a variable $Path to the path of the running script, based on the $MyInvocation variable. The $Path variable is then passed to the Path parameter.   

    
    .INPUTS
        System.String[]
    .OUTPUTS
        System.String[]
    .NOTES
        Version 1.0.2
        Author: Jeff Symoens
        Date: 05/10/2022
        Note: Initial release of function.

    #>
    [cmdletbinding()]
        Param( 
                [Parameter(Mandatory = $true, Position = 0)][ValidateNotNullOrEmpty()][string]$Name,
                [Parameter(Mandatory = $false, Position = 1)][ValidateNotNullOrEmpty()][string]$Path
              )

    Try 
    {
        [string]$VerboseFnPrefix="Function ($(($MyInvocation).MyCommand.Name)):"
        Write-Verbose "$VerboseFnPrefix Testing/Creating directory $Name..."


        if (($Name -like "*:\*") -or ($Name -like "\\*"))
        {
            if ([bool]$ParentPath)
            {
                Write-Verbose "$VerboseFnPrefix An explicit path format was provided for the 'Name' argument. The 'ParentPath' argument will be ignored."
            }

            $DirVar = $Name
        }

        Elseif ([bool]$ParentPath)
        {
            $ParenttPath = $ParenttPath.TrimEnd("\")
            $DirVar = "${ParentPath}\${Name}"
        }

        Else 
        {
            $DirVar = ".\$(${Directory}.TrimStart(".\"))"            
        }



        If (!(Test-Path -Path $DirVar))
        {
            Write-Verbose -Message "$VerboseFnPrefix Creating the folder : $DirVar"
            New-Item -Path $DirVar -ItemType Directory | Out-Null
        }
        Else 
        {
            Write-Verbose "'$VerboseFnPrefix $DirVar' already exists. No need to create it." 
        }

        return $DirVar
    }

    Catch { throw $_ }
}

function New-LogFileName 
{

    <#
    .Synopsis
    Generates a new logfile name formatted as "C:\LogDir\LogBaseName_YYYY-MM-DD_(HostName).log".

    .DESCRIPTION
    Generates a new logfile name formatted as "C:\LogDir\LogBaseName_YYYY-MM-DD_(HostName).log". The returned value can be used as a parameter to for any cmdlet that writes (or reads) to a log file. 

    The New-LogFileName cmdlet allows for consistent logfile name creation that incorporates a user provided name (LogBaseName) and automatically stamps date and hostname uniqueness strings in the logfile name.

    The Unique switch can be used to verify that the logfile name returned does not already exist. If it does, the resulting logfile name will be incremented to return a unique logfile name.

    .PARAMETER LogBaseName
    Provides the base for the logfile name. This is effectively the uniqueness parameter that differentiates the logfile from others in the same directory. 
    
    .Parameter LogDir
    Provides the directory location where the logfile will be stored. This parameter can include a trailing backslash, or not. Valid examples for the LogDir parameter include:

    C:\Logfiles\
    C:\Logfiles
    .\
    .
    \\hostname\sharename\directoryname
    \\hostname\sharename\directoryname\

    .PARAMETER Extension
    Provides the file extension for the logfile name. This parameter is optional. The logfile name extension is set to '.log' be default. Examples for the Extension parameter include: 
    
    csv
    txt
    log
    test
    123


    .PARAMETER Unique
    When the Unique parameter is supplied the resulting logfile name will be verified to make sure that a file with the specified name does not already exist at the target path. 
    
    If a file does exist with that name, then the resulting logfile name will be incremented with an enumerator until it has been verified as unique. 



    .EXAMPLE
    New-LogFileName -LogBaseName Testlog -LogDir C:\Test

    
    This command creates a new logfile name and returns it to the PowerShell console. 
            
    Returns: 

    C:\Test\TestLog_2022-02-07_(user-PC).log

    .EXAMPLE
    New-LogFileName -LogBaseName Testlog -LogDir C:\Test -Unique

    
    This command creates a new logfile name and returns it to the PowerShell console. 
            
    Returns: 

    C:\Test\TestLog_2022-02-07_(user-PC).log


    If a file already exists with that name at that path, then the following is returned:

    C:\Test\TestLog_2022-02-07_(user-PC)-1.log


    .EXAMPLE
    $Logfile=New-LogFileName -LogBaseName Testlog -LogDir C:\Test 

    
    This command creates a new logfile name and set the value of the variable $Logfile to the new logfile name. 


    $Logfile Returns: 
    
    C:\Test\TestLog_2022-02-07_(user-PC).log


    .EXAMPLE
    $Logfile=New-LogFileName -LogBaseName Testlog -LogDir C:\Test -Extension csv

    
    This command creates a new logfile name with a '.csv' extenstion and set the value of the variable $Logfile to the new logfile name. 


    $Logfile Returns: 
    
    C:\Test\TestLog_2022-02-07_(user-PC).csv

    .INPUTS
    System.String[]
    System.Management.Automation.SwitchParameter
    .OUTPUTS
    System.String[]  

    .NOTES
    Version 1.0.2
    Author: Jeff Symoens
    Date: 05/10/2022
    Note: Initial release of function.
    #>

    [cmdletbinding()]
    Param( 
            [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$LogBaseName , 
            [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$LogDir,
            [Parameter(Mandatory = $false)][ValidateNotNullOrEmpty()][string]$Extension="log",
            [Parameter(Mandatory = $false)][switch]$Unique
            )
    

    Try {
            [string]$VerboseFnPrefix="Function ($(($MyInvocation).MyCommand.Name)):"
        
            if (!(Test-Path -Path $LogDir)) {  throw "[ERROR]: The logpath is invalid or could not be found." }
            $LogDir=$LogDir.Replace("/","\")
            if ($LogDir.Substring($LogDir.Length-1) -ne "\" ) { $LogDir=$LogDir+"\"; Microsoft.PowerShell.Utility\write-Verbose "LogDir is: $LogDir"}
            Microsoft.PowerShell.Utility\Write-Verbose "The LogBaseName variable is: $LogBaseName"

            [regex]$ExcludedCharacters="[<>:|?*\/`"]"

            if ($ExcludedCharacters.IsMatch($LogBaseName)) {throw "[ERROR]: $VerboseFnPrefix The LogBaseName parameter contains one of the following invalid characters: $($ExcludedCharacters.ToString().Substring(1,$ExcludedCharacters.Tostring().Length-2)) "  }
    
            [int]$MaxLength=255
            [string]$ExecHost=hostname
            $LogNameDate=(get-date -Format s).split("T")
            $LogNameDate=$LogNameDate[0]

            [string]$Log="${LogDir}${LogBaseName}_${LogNameDate}_(${ExecHost}).${Extension}"

            # Unique Switch Generation
            if ($PSBoundParameters['Unique']) 
            {
                $LogEnum=$null
                [int]$i=1 
                while (test-path -Path $Log) 
                {	
                    Microsoft.PowerShell.Utility\Write-Verbose "$VerboseFnPrefix Logfile $log exists..."
                    $LogEnum="-" + ($i++)
                    $Log="${LogDir}${LogBaseName}_${LogNameDate}_(${ExecHost})${LogEnum}.${Extension}"
                }
            }

            
            if ($Log.Length -gt $MaxLength) 
            { 
                Write-Error -Message "[ERROR]: $VerboseFnPrefix The logfile name '$Log' exceeds $MaxLength characters."
                throw 
            }
            Else 
            {
                if (Test-Path $Log)
                {
                    Write-Verbose "$VerboseFnPrefix Logfile '$Log' exists and will not be created."
                }
                
                Else 
                {
                    Write-Verbose "$VerboseFnPrefix Creating logfile '$Log'..."
                    New-Item -Path $Log | Out-Null
                }
                return [string]$Log 
            }

            }

    Catch {  Write-Error $_ }

    Finally { } 
}


function Write-LogMessage
{

    <#
    .Synopsis
        Writes a user-provided status message out to a designated logfile and optionally to the console screen.
    
    .DESCRIPTION
        Writes a user-provided status message out to a designated logfile and optionally to the console screen. 

        If the Write-LogMessage function (or a cmdlet or script that calls that function) is run with the -Verbose option, the status message will also be ouput to the screen as verbose-mode output. This provides a benefit to scripts that may run as scheduled tasks or that may be called programatically that should produce no screen output under normal operation. Output can be logged to a logfile. However, using the -Verbose option when desired sends output to the screen as well, thus providing more information at the console. This option also honors the $VerbosePreference variable setting with respect to outputing Write-Verbose messages.
        
        If the Write-LogMessage function is run with the -Degbug option, the status message will also be ouput to the screen as debug-mode output. This provides a benefit to scripts that may run as scheduled tasks or that may be called programatically that should produce no screen output under normal operation. Output can be logged to a logfile. However, using the -Verbose option when desired sends output to the screen as well, thus providing more information at the console. This option also honors the $DebugPreference variable setting with respect to outputing Write-Deubg messages.

        The Write-LogMessage function automatically puts a Date/Time stamp and a status severity indicator in the logged message, allowing ease in differentiating different types logging output.        

        The Write-LogMessage function writes to the desginated logfile in Append mode. 

    .PARAMETER Message
    Indicates the status message that should be written. 
    
    .Parameter Logfile
    Provides that name of the logfile that output should be logged to. By default this parameter is set to $LogFile. You can create a global variable for $LogFile or use the Enable-LogFileHooking function to perform create the variable, which will provide a more seamless experience.    

    Examples include: 

    C:\Logfiles\TestLog_2022-02-07_(user-PC).log
    .\TestLog_2022-02-07_(user-PC).log
    \\hostname\sharename\directoryname\TestLog_2022-02-07_(user-PC).log


    .Parameter StatusCode
    The StatusCode Parameter determines status severity to assign to the message. This is used to stamp the logged message with a severity rating. 

    Possible values include: 

        1 - Stamps the message with a status of "[INFORMATION]" - Uses Write-Verbose to output to screen if Verbose option is selected.
        2 - Stamps the message with a status of "[WARNING]" - Uses Write-Warning to output to screen if Verbose option is selected.
        3 - Stamps the message with a status of "[ERROR]" - Uses Write-Error to output to screen if Verbose option is selected.
        4 - Stamps the message with a status of "[DEBUG]" - Uses Write-Debug to output to screen if Verbose option is selected.

    If no StatusCode parameter is indicated, the default status of 1 or "[INFORMATION]" is applied. 
 

    .EXAMPLE
        Write-LogMessage -Message "This is a test." -Logfile ".\test.log"

        This example writes the status "This is a test." to the logfile .\test.log.  


        Writes to logfile .\test.log: 

            2022-02-07T14:55:43.4490641-05:00 [INFORMATION]: This is a test.

       
    .EXAMPLE
        Write-LogMessage -Message "This is a test." -Logfile ".\test.log" -Verbose -IncludeRunspaceID

        The following example writes the status "This is a test." to the logfile .\test.log and returns the verbose-mode output to the screen.

        

        Output written to logfile .\test.log: 

            2022-02-07T14:55:43.4490641-05:00 [Runspace ID: bd5ac1be-03a2-4486-935a-a1ba189d27b6][INFORMATION]:: This is a test.

       

        Returns the following verbose-mode output to screen: 

            VERBOSE: This is a test.




    .EXAMPLE
        Write-LogMessage -Message "This is a test." -Logfile ".\test.log" -Verbose -StatusCode 3 -IncludeRunspaceID


        This example writes the status "This is a test." to the logfile .\test.log, with an [ERROR] status code.



        Writes to logfile .\test.log: 

            2022-02-07T14:55:43.4650566-05:00 [Runspace ID: bd5ac1be-03a2-4486-935a-a1ba189d27b6][Error]: This is a test.

       

        Returns the following verbose-mode output to screen: 

            Write-LogMessage : This is a test.
            At line:1 char:1
            + Write-LogMessage -Message "This is a test."  -Verbose -StatusCode 3 -IncludeRunspace ...
            + ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                + CategoryInfo          : NotSpecified: (:) [Write-Error], WriteErrorException
                + FullyQualifiedErrorId : Microsoft.PowerShell.Commands.WriteErrorException,Write-LogMessage
 


    .INPUTS
    System.String
    System.Int
    System.Object.Hashtable
    System.Management.Automation.SwitchParameter
    .OUTPUTS
    None

    .NOTES
    Version 1.0.2
    Author: Jeff Symoens
    Date: 05/10/2022
    Note: Initial release of function.
    #>


    [cmdletbinding()]
    Param(
            [Parameter(Mandatory = $true,Position=0,ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][ValidateNotNullOrEmpty()][string]$Message,
            [Parameter(Mandatory = $false)][Hashtable]$PassedParams,
            [Parameter(Mandatory = $false)][ValidateNotNullOrEmpty()][string]$Logfile=$LogfileGlobal,
            [Parameter(Mandatory = $false)][int]$StatusCode,
            [Parameter(Mandatory = $false)][switch]$IncludeRunspaceID=$false
            )

    BEGIN
    {
        $StatusCodes=@{ 
                        1=[string]"[INFORMATION]: ";
                        2=[string]"[WARNING]: ";
                        3=[string]"[ERROR]: " 
                        4=[string]"[DEBUG]: " 
                    }

    }

    PROCESS
    {

        Try 
        {
            if (!$Logfile) 
            {
                Microsoft.PowerShell.Utility\Write-Verbose "No value supplied for parameter Logfile. Activity will not be logged."
            }

            Else
            {
                if ($IncludeRunspaceID -or $Global:IncludeRunspaceIDGlobal) 
                {
                    $RunspaceID=[System.Management.Automation.Runspaces.Runspace]::DefaultRunspace.InstanceId.Guid
	                $RunspaceID = "[Runspace ID: $RunspaceID]"
                }
                Else { $RunspaceID = $null } 

                if (!$StatusCode) { $StatusCode=1 }
                $StatusMessage=[string]$RunspaceID + $StatusCodes.$StatusCode + $Message 

                (get-date -Format o) + " " + $StatusMessage |  Add-Content -Path $Logfile -Encoding Ascii  
            }

            #if ($BoundParameters['Verbose'])
            #if ($VerboseModeGlobal -or $PSBoundParameters['Verbose'] -or ($VerbosePreference -eq "Continue"))
            if (!$SupressConsoleOutputGlobal)
            {
                if ($StatusCode -eq 1) # Write-Verbose if -Verbose 
                {
                    Microsoft.PowerShell.Utility\Write-Verbose $Message
                }

                Elseif ($StatusCode -eq 2) # Write-Warning if -Verbose
                {
                    Microsoft.PowerShell.Utility\Write-Warning -Message $Message 
                }

                Elseif (($StatusCode -eq 3)) # Write-Error if -Verbose and not ThrowExceptionOnWriteError
                {
                    if (!$ThrowExceptionOnWriteErrorGlobal -or (!$PassedParams.ErrorRecord))
                    {
                        #Microsoft.PowerShell.Utility\Write-Error -Message $Message
                        Microsoft.PowerShell.Utility\Write-Error @PassedParams
                    }
                }

            }

            # If Status Code is "4", then Write-Debug
            if ($StatusCode -eq 4)
            {
                Microsoft.PowerShell.Utility\Write-Debug -Message $Message 
            }

        } 
    
        Catch { throw "[ERROR]: Exception thrown in logging module. Unable to log exception. `n `n$_ `n "   }

        Finally { }
    }

    END {}
}

function Write-LogWarning {

    <#
    .Synopsis
       The Write-LogWarning function writes the supplied warning message out to a designated logfile, and optionally to the console screen when the Verbose parameter is used. 
    
    .DESCRIPTION
       The Write-LogWarning function writes the supplied warning message out to a designated logfile, and optionally to the console screen when the Verbose parameter is used.

       Write-LogWarning calls the Write-LogMessage function to log the error message to a logfile. Therefore, if the function is called with the -Verbose option, the status message will also be ouput to the screen as verbose-mode output. This option also honors the $VerbosePreference variable setting with respect to outputing Write-Verbose messages. 
       
       Warnings logged with Write-LogWarning will be logged with status code '2' or '[WARINING]'. 

       The Write-LogWarning function is a helper function, which maps to the functionality of the PowerShell Write-Error cmdlet. This function (along with Write-LogError and Write-LogDebug) is designed to be used with the Enable-LogFileHooking function, which creates an alias to redirect calls to the Write-Error cmdlet to this function. This allows the standard Write-Warning cmdlet to be used in scripts, while adding support to write the content to a targeted logfile.

    .PARAMETER Message
    Indicates the status message to be logged, and displayed to the screen when using verbose-mode.     

    .EXAMPLE
        $LogFile=New-LogfileName -LogBaseName TestLog -LogDir .\ ; Write-LogWarning "This is a test."

        This example writes the error "This is a test." to the logfile specified in the $Logfile variable. Then throws an exception. 


       Writes to logfile .\TestLog_2022-02-07_(user-PC).log: 

            2022-02-07T14:55:43.4650566-05:00 [WARNING]: This is a test.

       
    .INPUTS
       System.String
    .OUTPUTS
       None
    .NOTES
        Version 1.0.2
        Author: Jeff Symoens
        Date: 05/10/2022
        Note: Initial release of function.
    #>

    [cmdletbinding()]
    Param([Parameter(Mandatory = $true,Position=0,ValuefromPipeline=$true)][string]$Message)
    
    BEGIN {}

	PROCESS {
	    Write-LogMessage -Message $Message -StatusCode 2 
    }

    END {}
}

function Write-LogDebug {
    <#
    .Synopsis
       Write-LogDebug is a helper function that writes the supplied debug message out to a designated logfile, and optionally to the console screen when the Verbose parameter is used. 
    
    .DESCRIPTION
       The Write-LogDebug is a helper function that writes the supplied warning message out to a designated logfile, and optionally to the console screen when the Verbose parameter is used.

       Write-LogDebug uses the Write-LogMessage function to log the error message to a logfile. Therefore, if the function is called with the -Debug option, the status message will also be ouput to the screen as debug-mode output. This option also honors the $DebugPreference variable setting with respect to outputing Write-Debug messages. 
       
       Debug messages logged with Write-LogDebug will be logged with status code '4' or '[DEBUG]'.

       The Write-LogDebug function is a helper function, which maps to the functionality of the PowerShell Write-Debug cmdlet. This function (along with Write-LogWarning and Write-LogError) is designed to be used with the Enable-LogFileHooking function, which creates an alias to redirect calls to the Write-Debug cmdlet to this function. This allows the standard Write-Debug cmdlet to be used in scripts, while adding support to write the content to a targeted logfile.


    .PARAMETER Message
    Indicates the status message to be logged, and displayed to the screen when using verbose-mode.     

    .EXAMPLE
        $Logfile = New-LogfileName -LogBaseName TestLog -LogDir .\ ; Write-LogDebug "This is a test."

        This example writes the message "This is a test." to the logfile specified in the $Logfile variable. Then throws an exception. 


       Writes to logfile .\TestLog_2022-02-07_(user-PC).log: 

            2022-02-07T14:55:43.4980610-05:00 [DEBUG]: This is a test.

       
    .INPUTS
       System.String
    .OUTPUTS
       None
    .NOTES
        Version 1.0.2
        Author: Jeff Symoens
        Date: 05/10/2022
        Note: Initial release of function.
    #>

    [cmdletbinding()]
    Param([Parameter(Mandatory = $true,Position=0,ValuefromPipeline=$true)][string[]]$Message)

    BEGIN {}

	PROCESS {
	    Write-LogMessage -Message "$Message" -StatusCode 4 
    }

    END {}
}

function Write-LogError {

    <#
    .Synopsis
    Write-LogError is a helper function that writes the supplied error message out to a designated logfile, and optionally to the console screen console screen when the Verbose parameter is used. 
    
    .DESCRIPTION
    Write-LogError is a helper function that writes the supplied error message out to a designated logfile, and optionally to the console screen. This function is a helper function which maps to the functionality of the PowerShell Write-Error function. When using the Enable-LogFileHooking function, this function intercepts the Write-Error funtion and writes content to the target logfile.     

    Write-LogError uses the Write-LogMessage function to log the error message to a logfile. Therefore, if the function is called with the -Verbose option, the status message will also be ouput to the screen as verbose-mode output. This option also honors the $VerbosePreference variable setting with respect to outputing the content of Write-Error messages. 
    
    Errors logged with Write-LogError will be logged with status code '3' or "[ERROR]".

    The Write-LogError function is a helper function, which maps to the functionality of the PowerShell Write-Error cmdlet. This function (along with Write-LogWarning and Write-LogDebug) is designed to be used with the Enable-LogFileHooking function, which creates an alias to redirect calls to the Write-Error cmdlet to this function. This allows the standard Write-Error cmdlet to be used in scripts, while adding support to write the content to a targeted logfile.
            
    When using in conjunction with the Enable-LogFileHooking function, the Enable-LogFileHooking funciton has an option (ThrowExceptionOnWriteError) that sets the behavior to throw an exception after logging an error using Write-LogError. This functionality allows the exception to be logged before throwing an exception. When used in this mode, an exception will only be thrown if the ErrorRecord parameter is used. When using this functionality use "Write-Error -ErrorRecord $_" in the catch statement, rather than the "throw" keyword. 

    The Write-LogError function includes parameter options for each parameter supported by the PowerShell Write-Error cmdlet. Any parameters/arguments used when calling the function are passed to the Write-LogMessage function, which will pass them through when calling Write-Error after logging the message. Values for these parameters are not evaluated by the Write-LogError function, there are merely passed on to the Write-Error cmdlet and processed there. Only the Message and ErrorRecord are processed by this function. 


    .PARAMETER Message
    Indicates the status message to be written in. This input will also be written to the log, and displayed to the screen when using verbose-mode. 

    .PARAMETER ErrorRecord
    Supports an ErrorRecord object to be used as an input, for example, when an exception is thrown the exception can be passed to the ErrorRecord parameter. In this case,  
    This input will also be written to the log, and displayed to the screen when using verbose-mode. 

    The ErrorRecord parameter can be used by itself or in conjunction with the Message parameter. If the Message parameter is not provided, then the ErrorRecord will be converted to a string and then used as the Message to be logged.   
  

    .EXAMPLE
        $logfile=New-LogfileName -LogBaseName TestLog -LogDir .\ 
        Write-LogError "This is a test."

        This example writes the error "This is a test." to the logfile specified in the $Logfile variable. Then throws an exception. 


       Writes to logfile .\TestLog_2022-02-07_(user-PC).log: 

            2022-02-07T14:55:43.5050583-05:00 [ERROR]: This is a test.


        If verbose output has been selected, then Write-Error will be called by the Write-LogMessage function of to display the output onscreen. Otherwise, it will just be logged.

       Error output: 

            This is a test.
            At C:\Users\jesymoen\OneDrive - Microsoft\Documents\Engagements\Scripts\Logging.psm1:306 char:34
            +     foreach ($e in $ErrorsToSend) { throw $e }
            +                                     ~~~~~~~~
                + CategoryInfo          : OperationStopped: (This is a test.:String) [], RuntimeException
                + FullyQualifiedErrorId : This is a test.

       
       
        If the $ThrowExceptionOnWriteErrorGlobal variable is true (set by the Enable-LogFileHooking function) and the ErrorRecord parameter was used, then an exception will be thrown. 

    .EXAMPLE
        $logfile=New-LogfileName -LogBaseName TestLog -LogDir .\ 
        $ThrowExceptionOnWriteErrorGlobal = $True
        try {
            # Test an exception
            get-fooboohoo
        }

        catch {
            Write-LogError -ErrorRecord $_
        }
         

        This example catches an exception and writes it the logfile specified in the $Logfile variable before throwing the exception.  


        Writes to logfile .\TestLog_2022-02-07_(user-PC).log: 

            2022-02-09T16:48:22.5520102-05:00 [ERROR]: get-fooboohoo : The term 'get-fooboohoo' is not recognized as the name of a cmdlet, function, script file, or operable program. Check the spelling of the name, 
            or if a path was included, verify that the path is correct and try again.
            At line:3 char:13
            +             get-fooboohoo
            +             ~~~~~~~~~~~~~
                + CategoryInfo          : ObjectNotFound: (get-fooboohoo:String) [], CommandNotFoundException
                + FullyQualifiedErrorId : CommandNotFoundException


    .EXAMPLE
        $logfile=New-LogfileName -LogBaseName TestLog -LogDir .\ 
        $ThrowExceptionOnWriteErrorGlobal = $True
        try {
            # Test an exception
            get-fooboohoo
        }

        catch {
            Write-LogError -Message $_
        }
         

        This example catches an exception and writes it the logfile specified in the $Logfile variable. It does not throw an exception after logging the error, even though the $ThrowExceptionOnWriteErrorGlobal variable is set to $true, because the -Message argument is used and not the -ErrorRecord argument.  


        Writes to logfile .\TestLog_2022-02-07_(user-PC).log: 

            2022-02-09T16:55:13.3978175-05:00 [ERROR]: The term 'get-fooboohoo' is not recognized as the name of a cmdlet, function, script file, or operable program. Check the spelling of the name, or if a path was included, verify that the path is correct and try again.

        Note: In this example, only the 'Exception' property of the exception is logged, because the exception is passed to the -Message argument.  


    .INPUTS
        System.String
        System.Object.ErrorRecord
    .OUTPUTS
        System.Object.ErrorRecord
        
    .NOTES
        Version 1.0.2
        Author: Jeff Symoens
        Date: 05/10/2022
        Note: Initial release of function.
    #>

    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $false,ValuefromPipeline=$false)]$Exception,
        [Parameter(Mandatory = $false,Position=0,ValuefromPipeline=$true)][string]$Message,
        [Parameter(Mandatory = $false,ValuefromPipeline=$false)]$Category,
        [Parameter(Mandatory = $false,ValuefromPipeline=$false)]$ErrorId,
        [Parameter(Mandatory = $false,ValuefromPipeline=$false)]$TargetObject,
        [Parameter(Mandatory = $false,ValuefromPipeline=$false)]$RecommendedAction,
        [Parameter(Mandatory = $false,ValuefromPipeline=$false)]$CategoryActivity,
        [Parameter(Mandatory = $false,ValuefromPipeline=$false)]$CategoryReason,
        [Parameter(Mandatory = $false,ValuefromPipeline=$false)]$CategoryTargetName,
        [Parameter(Mandatory = $false,ValuefromPipeline=$false)]$CategoryTargetType,
        [Parameter(Mandatory = $false,ValuefromPipeline=$false)]$ErrorRecord
        )

        BEGIN {

            $PassedParamsSplat = @{}
            foreach ($Key in $PSBoundParameters.Keys)
            {
                $PassedParamsSplat.Add($Key,$PSBoundParameters.$Key)
            }
        }

        process {
            try 
            {
                if ((!$Message) -and $ErrorRecord)
                {
                    $Message = $ErrorRecord | Out-String
                }

                Write-LogMessage -Message $Message -StatusCode 3 -PassedParams $PassedParamsSplat 

                if ($ThrowExceptionOnWriteErrorGlobal)
                {
                    if ($ErrorRecord)
                    {
                        throw $ErrorRecord
                    }
                }
            }

            catch { throw }       
            
            finally {}
        }

        END {}

    }


function Enable-LogFileHooking
{
    <#
    .SYNOPSIS
        The Enable-LogFileHooking function runs a series of configuration tasks that "hook" logging into your script or PowerShell session. Once run, this function enables all Write-Verbose, Write-Warning, Write-Error, and Write-Debug messages to be logged to the designate logfile.   
    .DESCRIPTION
        The Enable-LogFileHooking function runs a series of configuration tasks that "hook" logging into your script or PowerShell session. Once run, this function enables all Write-Verbose, Write-Warning, Write-Error, and Write-Debug messages to be logged to the designated logfile.   

        The Enable-LogFileHooking function creates a several global variables in the PowerShell session which are used to facilite logging. In addition, the function also creates alias that redirect some common PowerShell cmdlets to functions in the LogTools module, as follows:
            Alias: Write-Verbose --> Redirects to function: Write-LogMessage
            Alias: Write-Warning --> Redirects to function: Write-LogWarning
            Alias: Write-Debug --> Redirects to function: Write-LogDebug
            Alias: Write-Error --> Redirects to function: Write-LogError
        
        The creation of these alias allows you to simply use these common PowerShell cmdlets when writing your script. When LogFileHooking is not enabled, these cmdlets simply run as normal, providing the desired screen output notifications that they were designed for. 
        
        When LogFileHooking is enabled, then these aliases will call the corresponding helper functions in this module and enable logging of this messages. 

        When LogFileHooking is enable, the display of Verbose and Debug messages to the screen is governed by either the common parameter switches (the "-Verbose" and "-Debug" switches respectively) when running a script, cmdlet or function, or the respective environmental variables ("$VerbosePreference" and "$DebugPreference"). This is the same is if LogFileHooking was not enabled. Therefore, to manage whether Write-Verbose and Write-Debug messages are displayed on-screen simply use the command-line parameters or environment variables as normal.    

        To remove the varables and aliases created by this function, run the Disable-LogFileHooking function. 
    
    .PARAMETER LogFile
        Specifies the path\filename for the logfile that logging will be established to. This value will be used to create a global variable called $Global:LogFileGlobal, which is used by the Write-LogMessage function to determine the destination to writing log messages to. Creating this global variable elliminates the need to specify a value for the LogFile parameter each time the Write-LogMessage function is called. Typically, the New-LogFileName function is used to create a logfile name. However, a sting with path\filename is sufficient. 

    .PARAMETER IncludeRunspaceID
         The IncludeRunspaceID switch parameter that indicates whether or not to include the PowerShell RunspaceID in each message that is logged to the logfile. This value will be used to create a global variable called $Global:IncludeRunspaceIDGlobal, which is used by the Write-LogMessage function to determine whether to include the RunspaceID when write log messages. When this parameter is selected the global IncludeRunspaceIDGlobal variable is set to True. If $IncludeRunspaceIDGlobal evaluates to True, then the RunspaceID is included. Otherwise it is not, unless the IncludeRunspaceID switch parameter is used when calling the Write-LogMessage function. 
    
    .PARAMETER ThrowExceptionOnWriteError
         The ThrowExceptionOnWriteError switch parameter that indicates whether or not to throw an exception after writing a message to the logfile when calling the Write-LogError function (which the alias for Write-Error is redirected to when running the Enable-LogFile Hooking function). This value will be used to create a global variable called $Global:ThrowExceptionOnWriteErrorGlobal, which is used by the Write-LogMessage and Write-LogError functions to determine whether to throw an exception or write the error to the console screen when the verbose parameter is selected. When this parameter is selected the global ThrowExceptionOnWriteErrorGlobal variable is set to True. If $ThrowExceptionOnWriteErrorGlobal evaluates to True and the ErrorRecord parameter is used when calling Write-LogError, then an exception is thrown after logging the error. Otherwise no exception is thrown, and the Write-Error cmdlet is used to write the error to the console screen when the verbose parameter is selected. 

         Using the the ThrowExceptionOnWriteError option and calling the Write-LogError function, as opposed to using the throw keyword, allows you to log terminating errors before exiting the script. For more on this option, see also 'Get-Help Write-LogError -Full'.

    .PARAMETER SupressConsoleOutput
         The SupressConsoleOutput switch parameter indicates whether or not to supress all console output from the Write-Verbose, Write-Warning, and Write-Error cmdlets when they are called. This can helpful when running automation scripts in, for example, a programatic runspace. In this case, any output that would be rendered to the console from one of the previously mentioned functions would only be logged, and while output to the screen is supressed. This effectively limits screen output to items returned from the script and output from exceptions.

         The SupressConsoleOutput switch only supresses output for three of the four cmdlets that are redirected for logging. These are Write-Verbose, Write-Warning, and Write-Error. Output from other cmdlets, such as Write-Host for example, will still generate console output, since they are not redirected for logging they are considered interactive to the script. If output supression using this switch is desired, use one of the four cmdlets that are redirected for logging.
         
         When operating with the SupressConsoleOutput switch, output from and interaction with the Write-Debug cmdlet is not supressed. This is because when running with the debug mode, there is a general expection of console output and interaction interaction.  

    .EXAMPLE
        PS C:\> $Logfile = New-LogfileName -LogBaseName TestLog -LogDir .\ 
        Enable-LogFileHooking -Logfile $LogFile
        
        This example creates a logfile '.\TestLog_2022-02-09_(HOSTNAME).log' and the enables logging of messages to that logfile. In this example, the following configuration is produced:  
        
            Include RunspaceID in logged messages: True

            Write-Verbose:
                Logged to file: True
                Write ouput to Screen: False  

            Write-Warning:
                Logged to file: True
                Write ouput to Screen: False

            Write-Debug:
                Logged to file: True
                Write ouput to Screen: False

            Write-Error:
                Logged to file: True
                Write ouput to Screen: False - when using the -Message parameter and not using the -ErrorRecord parameter
                Throw Exception on error: False (not set)



    .EXAMPLE
        PS C:\> $Logfile = New-LogfileName -LogBaseName TestLog -LogDir .\ 
        Enable-LogFileHooking -Logfile $LogFile -Verbose -IncludeRunspaceID -ThrowExceptionOnWriteError
        
        This example creates a logfile '.\TestLog_2022-02-09_(HOSTNAME).log' and the enables logging of messages to that logfile. In this example, the following configuration is produced:  
        
            Include RunspaceID in logged messages: True

            Write-Verbose:
                Logged to file: True
                Write ouput to Screen: True  

            Write-Warning:
                Logged to file: True
                Write ouput to Screen: True

            Write-Debug:
                Logged to file: True
                Write ouput to Screen: False

            Write-Error:
                Logged to file: True
                Write ouput to Screen: True - when using the -Message parameter and not using the -ErrorRecord parameter
                Throw Exception on error: True - when using the -ErrorRecord parameter, with or without the -Message parameter
    
    .EXAMPLE
        PS C:\> $Logfile = New-LogfileName -LogBaseName TestLog -LogDir .\ 
        Enable-LogFileHooking -Logfile $LogFile -Verbose -Debug -IncludeRunspaceID -ThrowExceptionOnWriteError
        
        This example creates a logfile '.\TestLog_2022-02-09_(HOSTNAME).log' and the enables logging of messages to that logfile. In this example, the following configuration is produced:  
        
            Include RunspaceID in logged messages: True

            Write-Verbose:
                Logged to file: True
                Write ouput to Screen: True  

            Write-Warning:
                Logged to file: True
                Write ouput to Screen: True

            Write-Debug:
                Logged to file: True
                Write ouput to Screen: True

            Write-Error:
                Logged to file: True
                Write ouput to Screen: True - when using the -Message parameter and not using the -ErrorRecord parameter
                Throw Exception on error: True - when using the -ErrorRecord parameter, with or without the -Message parameter

    .EXAMPLE
        PS C:\> $Logfile = New-LogfileName -LogBaseName TestLog -LogDir .\ 
        Enable-LogFileHooking -Logfile $LogFile -Verbose -Debug -IncludeRunspaceID -SupressConsoleOutput
        
        This example creates a logfile '.\TestLog_2022-02-09_(HOSTNAME).log' and the enables logging of messages to that logfile. In this example, the following configuration is produced:  
        
            Include RunspaceID in logged messages: True

            Write-Verbose:
                Logged to file: True
                Write ouput to Screen: True  

            Write-Warning:
                Logged to file: True
                Write ouput to Screen: True

            Write-Debug:
                Logged to file: True
                Write ouput to Screen: True

            Write-Error:
                Logged to file: True
                Write ouput to Screen: True - when using the -Message parameter and not using the -ErrorRecord parameter
                Throw Exception on error: True - when using the -ErrorRecord parameter, with or without the -Message parameter


    
    .INPUTS
        System.String
        System.Management.Automation.SwitchParameter
    .OUTPUTS
        None
    .NOTES
        Version 1.0.2
        Author: Jeff Symoens
        Date: 05/10/2022
        Note: Initial release of function.

    #>
    
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $false,Position=0)][string]$LogFile,
        [Parameter(Mandatory = $false,Position=1)][switch]$IncludeRunspaceID,
        [Parameter(Mandatory = $false,Position=2)][switch]$ThrowExceptionOnWriteError,
        [Parameter(Mandatory = $false,Position=2)][switch]$SupressConsoleOutput
    )

    # Set LogFile variable
    if ($Logfile)
    {
        $Global:LogfileGlobal = $Logfile
    }

    # Set SupressConsoleOutputGlobal variable
    if ($SupressConsoleOutput)
    {
        $Global:SupressConsoleOutputGlobal = $true
    }

    # Set IncludeRunspaceIDGlobal variable
    if ($IncludeRunspaceID)
    {
        if (!$SupressConsoleOutputGlobal)
        {
            Write-Verbose "The IncludeRunspaceID option is selected. Logged entries will include the PowerShell Runspace ID."
        }
        $Global:IncludeRunspaceIDGlobal = $true
    }

    # Set ThrowExceptionOnWriteErrorGlobal variable
    if ($ThrowExceptionOnWriteError)
    {
        if (!$SupressConsoleOutputGlobal)
        {
            Write-Verbose "The ThrowExceptionOnWriteError option is selected. When Write-LogError is call with an ErrorRecord, then an exception will be thrown after logging the error."
        }
        
        $Global:ThrowExceptionOnWriteErrorGlobal = $true
    }


    # Create write-verbose alias to hook logfile output
    if (!(test-path Alias:\Write-Verbose))
    {
        New-Alias -Name Write-Verbose -Value Write-LogMessage -Scope Global
    }

    # Create Write-Warning alias to hook logfile output
    if (!(test-path Alias:\Write-Warning))
    {
        New-Alias -Name Write-Warning -Value Write-LogWarning -Scope Global
    }

    # Create Write-Error alias to hook logfile output
    if (!(test-path Alias:\Write-Error))
    {
        New-Alias -Name Write-Error -Value Write-LogError -Scope Global
    }

    # Create Write-Debug alias to hook logfile output
    if (!(test-path Alias:\Write-Debug))
    {
        New-Alias -Name Write-Debug -Value Write-LogDebug -Scope Global
    }
    
}

function Disable-LogFileHooking
{
    <#
    .SYNOPSIS
        The Disable-LogFileHooking function removes the configuration settings (the global variables and aliases) created by the Enable-LogFileHooking hooking function.
    .DESCRIPTION
        The Disable-LogFileHooking function removes the configuration settings (the global variables and aliases) created by the Enable-LogFileHooking hooking function.   

        The Disable-LogFileHooking function removes the following global variables in the PowerShell session which are used to facilite logging. 
            $Global:LogfileGlobal --> Establishes the target logfile for logging. 
            $Global:IncludeRunspaceIDGlobal --> Establishes whether the RunspaceID will be included in each logged message entry.
            $Global:ThrowExceptionOnWriteErrorGlobal --> Enables exception throwing after logging Write-Error messages using the ErrorRecord Parameter 
            SupressConsoleOutputGlobal --> 
            $Global:VerboseModeGlobal --> Enables output to console of logged messages 

        In addition, the function also removes alias that redirect some common PowerShell cmdlets to functions in the LogTools module, as follows:
            Alias: Write-Verbose --> Redirects to function: Write-LogMessage
            Alias: Write-Warning --> Redirects to function: Write-LogWarning
            Alias: Write-Debug --> Redirects to function: Write-LogDebug
            Alias: Write-Error --> Redirects to function: Write-LogError
        
        The creation of these alias allows you simply use these common PowerShell cmdlets when writing your script. When LogFileHooking is not enabled, these cmdlets simply run as normal, providing the desired screen output notifications that they were designed for. 
        
        When LogFileHooking is enabled, then these aliases will call the corresponding helper functions in this module and enable logging of this messages. Also, when LogFileHooking status messages from the above cmdlets will only be displayed on screen of the -Verbose switch (or -Debug in the case of Write-Debug) is enabled when calling the Enable-LogFileHooking function.  

        For more information about enabling logfile hooking, see Get-Help Enable-LogFileHooking. 
    
    .EXAMPLE
        PS C:\> Disable-LogFileHooking 

        This example removes logfile hooking by removing the aliases and variables that have been created using the Enable-LogFileHooking function. 

    .INPUTS
        None
    .OUTPUTS
        None

    .NOTES
        Version 1.0.2
        Author: Jeff Symoens
        Date: 05/10/2022
        Note: Initial release of function.

    #>
    
    [cmdletbinding()]
    param()
   
    # Remove write-verbose alias 
    if (Test-Path Alias:\Write-Verbose)
    {
        Get-ChildItem Alias:\Write-Verbose | Remove-Item
    }

    # Remove Write-Warning alias 
    if (Test-Path Alias:\Write-Warning)
    {
        Get-ChildItem Alias:\Write-Warning | Remove-Item
    } 

    # Remove Write-Debug alias 
    if (Test-Path Alias:\Write-Debug)
    {
        Get-ChildItem Alias:\Write-Debug | Remove-Item
    } 

    # Remove Write-Error alias 
    if (Test-Path Alias:\Write-Error)
    {
        Get-ChildItem Alias:\Write-Error | Remove-Item
    }

    # Remove Verbose Mode Global Variable
    if (Test-Path Variable:\VerboseModeGlobal)
    {
        Remove-Variable VerboseModeGlobal -Scope Global
    }

    # Remove LogfileGlobal Variable
    if (Get-Variable LogfileGlobal -Scope Global -ErrorAction SilentlyContinue)
    {
        Remove-Variable LogfileGlobal -Scope Global
    }

    # Remove IncludeRunspaceIDGlobal Variable
    if (Get-Variable IncludeRunspaceIDGlobal -Scope Global -ErrorAction SilentlyContinue)
    {
        Remove-Variable IncludeRunspaceIDGlobal -Scope Global
    }

    # Remove ThrowExceptionOnWriteError Variable
    if (Get-Variable ThrowExceptionOnWriteErrorGlobal -Scope Global -ErrorAction SilentlyContinue)
    {
        Remove-Variable ThrowExceptionOnWriteErrorGlobal -Scope Global
    }

    if (Get-Variable SupressConsoleOutputGlobal -Scope Global -ErrorAction SilentlyContinue)
    {
        Remove-Variable SupressConsoleOutputGlobal -Scope Global
    }
    
}


function Initialize-LogFile
{
    <#
    .SYNOPSIS
        Initializes the logfile by writing a banner in the logfile. This function is optional, but can provide a nice way to differentiate between different runs of a script when appending to the same log file. 

    .DESCRIPTION
        Initializes the logfile by writing a banner in the logfile. This function is optional, but can provide a nice way to differentiate between different runs of a script when appending to the same log file. 
        
        This function accepts either an InvocationInfo (Invocation parameter) object or a string message (Message parameter) to determine the header information that is included in the log file.  
 

    .PARAMETER Invocation
        The Invocation parameter allows from providing an InvocationInfo object (for example, Get-Variable -Name MyInvocation | Initialize-LogFile), which the function will parse to get the name and/or path of the script to include in the log header. 
    
    .PARAMETER IncludeScriptPath
        When using Invocation parameter, the IncludeScriptPath switch indicates whether to include the full path to the script (rather than just the script name) when in the log header when initializing the log file.  

    .PARAMETER Message 
        Specifies the message to use as the header message. 

    .EXAMPLE
        PS C:\> Initialize-LogFile -Message "This is a test." -Logfile C:\Scripts\Logs\Logfile1.txt

        Writes the following header into the logfile 'C:\Scripts\Logs\Logfile1.txt':
        
            2022-03-02T22:17:34.6672625-05:00 [INFORMATION]: ======================================================================================
            2022-03-02T22:17:34.6752640-05:00 [INFORMATION]:    This is a test.
            2022-03-02T22:17:34.6852956-05:00 [INFORMATION]: ======================================================================================
    
    .EXAMPLE
        Script excerpt example from a sample script 'C:\Scripts\Test-LogToolsSampleScript.ps1': 
            $LogDir = New-LogDirectory -Name C:\Scripts\Logs
            $LogFile = New-LogfileName -LogBaseName Logfile -LogDir $LogDir 
            Enable-LogFileHooking -Logfile $LogFile -ThrowExceptionOnWriteError -SupressConsoleOutput
            Get-Variable -Name MyInvocation | Initialize-LogFile -IncludeScriptPath
        

        - Checks for a log directory named "C:\Scripts\Logs" and creates it if it does not exist.
        - Creates a new logfile named 'C:\Scripts\Logs\Logfile_2022-02-24_(HOSTNAME).log'
        - Creates aliases and variables to enable logfile hooking (see, Get-Help Enable-LogFileHooking -Full)
        - Gets and pipes the $MyInvocation variable to the Initialize-LogFile functions, which writes the following header into the logfile 'C:\Scripts\Logs\Logfile_2022-02-24_(HOSTNAME).log':
        
            2022-03-02T22:17:34.6672625-05:00 [INFORMATION]: ======================================================================================
            2022-03-02T22:17:34.6752640-05:00 [INFORMATION]:    Running Script C:\Scripts\Test-LogToolsSampleScript.ps1...
            2022-03-02T22:17:34.6852956-05:00 [INFORMATION]: ======================================================================================
    
        Note: If the 'IncludeScriptPath' switch is not used, then the header message would read 'Running Script Test-LogToolsSampleScript.ps1...' instead 'Running Script C:\Scripts\Test-LogToolsSampleScript.ps1...'.

    .INPUTS
    System.String
    System.Management.Automation.InvocationInfo
    System.Management.Automation.SwitchParameter

    .OUTPUTS
    None

    .NOTES
        Version 1.0.2
        Author: Jeff Symoens
        Date: 05/10/2022
        Note: Initial release of function.

    #>

    [CmdletBinding()]

    param (
        [Parameter(ParameterSetName="Invocation",Mandatory = $true, Position = 0,ValueFromPipeline = $true)][ValidateNotNullOrEmpty()][object]$Invocation,
        [Parameter(ParameterSetName="Message",Mandatory = $true, Position = 1,ValueFromPipeline = $false)][string]$Message,
        [Parameter(ParameterSetName="Invocation",Mandatory = $false, Position = 2,ValueFromPipeline = $false)][switch]$IncludeScriptPath,
        [Parameter(Mandatory = $false,Position = 3)][string]$Logfile=$LogfileGlobal
    )

    try 
    {
        if (!$Logfile) 
        {
            Microsoft.PowerShell.Utility\Write-Verbose "No value supplied for parameter Logfile. Activity will not be logged."
        }

        else 
        {

            switch ($pscmdlet.ParameterSetName)
            {
                "Invocation"
                {
                    if ($Invocation.Value.GetType().Name -eq "InvocationInfo")
                    {

                        # Getting Script name and setting ScriptName variable...
                        if ($IncludeScriptPath)
                        {
                            $HeaderMessage = "Running Script $(($Invocation.Value).MyCommand.Path)..."
                        }

                        else
                        {
                            $HeaderMessage = "Running Script $(($Invocation.Value).MyCommand.Name)..."
                        }
                    }
                }

                "Message"
                {
                    $HeaderMessage = $Message
                }

            }

            # Initialize logfile
            Write-LogMessage '======================================================================================' -Logfile $Logfile
            
            Write-LogMessage "   ${HeaderMessage}" -Logfile $Logfile

            Write-LogMessage '======================================================================================' -Logfile $Logfile
        }
    }

    Catch { }

    Finally { }

}


function Clear-LogFileHistory
{
    <#
    .Synopsis
       The Clear-LogFileHistory function can be used to delete/prune files in a directory (or a single file) that are older than a given number of days. 
    
    .DESCRIPTION
       The Clear-LogFileHistory function can be used to delete files in a directory (or a single file) that are older than a given number of days. 

       This function can be used to effectively prune, for example, a logfile directory that experiences continuous growth. Running the Clear-LogFileHistory cmdlet once per day with, for example, the RetentionDays argument set to 14 will delete all falls that are older than 14 days. 

       In determining files to prune, Clear-LogFileHistory compares both the file creation date and the last write time to determine if the file exceeds the max retention date.
       

    .PARAMETER Path
    Indicates the path of the file or directory to be checked for pruning. 

    .PARAMETER RetentionDays
    Provides the number of days to be used as the retention time. For example, if the RetentionDays is set to 14, files older than 14 days will be pruned from the target directory. If a value of 0 is provided, that all files will be deleted from the target path.
     

    .EXAMPLE
        Clear-LogFileHistory -Path C:\Test -RetentionDays 7

        This example deletes all files older than 7 days in the C:\Test directory. It does not delete files in any subdirectories.

    .EXAMPLE
        Clear-LogFileHistory -Path C:\Test\test.txt -RetentionDays 7

        This example deletes the file C:\Test\test.txt if it is older than 7 days. 

    .EXAMPLE
        Clear-LogFileHistory -Path "C:\Test\*.log" -RetentionDays 7 

        This example deletes files that match the wild-card pattern '*.log' in the 'C:\Test' directory if the file(s) is older than 7 days. 
    
    
        .EXAMPLE
        dir C:\Test | Clear-LogFileHistory -RetentionDays 7

        This example gets the contents of the directory C:\Test and passes that list of files and immediate child directories to the Clear-LogFileHistory command, which deletes the contents of each argument if it is older than 7 days. 

        For example, if the result of the comman "dir C:\Test" returns 10 files and 3 child directories, then each of the 10 files and any files in each of the three subdirectories will be evaluated for deletion. This command does not recurse the subdirectories (see the next example).  

    .EXAMPLE
        dir C:\Test -recurse | Clear-LogFileHistory -RetentionDays 7

        This example gets the contents of the directory C:\Test recursively (including nested subdirectories) and passes that resulting list of files and directories to the Clear-LogFileHistory command, which deletes each file in the result set that is older than 7 days. 
       
    .INPUTS
       String,Object
    .OUTPUTS
        N/A
 
        
    .NOTES
        Version 1.0.2
        Author: Jeff Symoens
        Date: 05/10/2022
        Note: Initial release of function.
    #>

    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true,Position=0,ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]$Path,
        [Parameter(Mandatory = $true)][int]$RetentionDays
        )

    
    BEGIN 
    {
        if ([System.Math]::Sign($RetentionDays) -eq -1) { $RetentionDays = $RetentionDays* -1 }
        $CompDate = [datetime]::now.AddDays(-$RetentionDays)
        [string]$VerboseFnPrefix="Function ($(($MyInvocation).MyCommand.Name)):"
    }       

    PROCESS
    {
        try 
        {
            Write-Verbose -Message "$VerboseFnPrefix Running Clear-LogFileHistory on path $path..."  

            if (![string]::IsNullOrEmpty($Path.Fullname)) { $Path=$Path.Fullname }
            #write-host $Path

            if (Test-Path -Path  $Path) {


                if (Test-Path -Path $Path -PathType Container) 
                {
                    Write-Verbose -Message "$VerboseFnPrefix Pruning files in $Path directory older than $CompDate ($RetentionDays days)... "
                    $PruneFiles = Get-ChildItem $Path\*.* | Where-Object { ($_.LastWriteTime -lt $CompDate) -and ($_.CreationTime -lt $CompDate) }
                }

                Else { Write-Verbose -Message "$VerboseFnPrefix Pruning the file ${PrunePath}, if older than $CompDate ($RetentionDays days)... "
                    $PruneFiles = Get-ChildItem $Path | Where-Object { ($_.LastWriteTime -lt $CompDate) -and ($_.CreationTime -lt $CompDate) }
                }

                if ($PruneFiles) 
                {
                    foreach ($file in $PruneFiles) 
                    {
                        Write-Verbose "$VerboseFnPrefix File $file will be deleted."
                    }

                    $PruneFiles | Remove-Item -Force
            
                } # if Prunefiles
                Else {  Write-Verbose "$VerboseFnPrefix No file(s) found that meet the age criteria at path $path."}
            }

            Else { throw "$VerboseFnPrefix The path `'$Path`' could not be found."}
            
        } # Try

        catch { Write-LogError $_ } 
        
        Finally {}
    } # PROCESS

    END {}

}


function New-LogFileLock
{
    <#
    .SYNOPSIS
        Creates a new read-write file lock on the file provided as the input argument.

    .DESCRIPTION
        Creates a new read-write file lock on the file provided as the input argument.

        When creating a file lock, it is best to store the returned file system object as a variable so that the variable can be used to remove the file lock when finished. Otherwise, there will be no object to operate on to close the file lock.    
    
    .PARAMETER FileName
        Indicates the name of the file that the file lock will be created for. This parameter is mandatory.
    
    .EXAMPLE
        PS C:\> $LogFileLock = New-LogFileLock -FileName C:\Scripts\Logs\Logfile1.txt

        Creates a new read-write file lock on the file 'C:\Scripts\Logs\Logfile1.txt'.  
    

    .EXAMPLE
        PS C:\> $LogDir = New-LogDirectory -Name C:\Scripts\Logs
        PS C:\> $LogFile = New-LogfileName -LogBaseName Logfile -LogDir $LogDir 
        PS C:\> $LogFileLock = New-LogFileLock -FileName $LogFile
        PS C:\> "This is a test." | Add-Content -Path $Logfile -Encoding Ascii
        PS C:\> Remove-LogFileLock -FileSystemObject $LogFileLock

        Checks for a log directory named "C:\Scripts\Logs" and creates it if it does not exist.
        Creates a new logfile named 'C:\Scripts\Logs\Logfile_2022-02-24_(HOSTNAME).log'
        Creates a new read-write file lock on the file 'C:\Scripts\Logs\Logfile_2022-02-24_(HOSTNAME).log'.
        Writes the line 'This is a test.' to the logfile 'C:\Scripts\Logs\Logfile_2022-02-24_(HOSTNAME).log'.
        Removes the file lock from the file 'C:\Scripts\Logs\Logfile_2022-02-24_(HOSTNAME).log' 
    
    .INPUTS
        System.String

    .OUTPUTS
        System.IO.Stream[]

    .NOTES
        Version 1.0.2
        Author: Jeff Symoens
        Date: 05/10/2022
        Note: Initial release of function.

    #>

    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true,Position=0,ValueFromPipeline = $true)][string]$FileName
        )

        try 
        {
            [string]$VerboseFnPrefix ="Function ($(($MyInvocation).MyCommand.Name)):"

            Microsoft.PowerShell.Utility\Write-Verbose "$VerboseFnPrefix Placing a lock on file `'$FileName`'." 

            if (!(Test-Path -Path $fileName)) 
            {
                Microsoft.PowerShell.Utility\Write-Verbose "$VerboseFnPrefix Can't find file `'$FileName`'."
                New-Item $filename -ItemType file | Out-Null 

            }

                $FileSystemObject=[System.io.File]::Open($fileName, 'Append', 'Write','ReadWrite') 
                return $FileSystemObject
        }

        Catch { throw $_}

        Finally { }

}


function Remove-LogFileLock
{
    <#
    .SYNOPSIS
        Removes a file lock from a file system object provided as the input argument.

    .DESCRIPTION
        Removes a file lock from a file system object provided as the input argument.
    
    .PARAMETER FileSystemObject
        Indicates the file system object that will have the file lock removed. This parameter is mandatory. The object type for this parameter must be System.IO.Stream. 
    
    .EXAMPLE
        PS C:\> Remove-LogFileLock $LogFileLock

        or 

        PS C:\> Remove-LogFileLock -FileSystemObject $LogFileLock

        or 

        $LogFileLock | Remove-LogFileLock
        
        Removes the file lock from the file system object stored in the variable $LogFileLock.  
    
    
    .INPUTS
        System.IO.Stream[]
    .OUTPUTS
        
    .NOTES
        Version 1.0.2
        Author: Jeff Symoens
        Date: 05/10/2022
        Note: Initial release of function.

    #>

    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true,Position=0,ValueFromPipeline = $true)][System.IO.Stream[]]$FileSystemObject
        )

    BEGIN {}

    PROCESS
    {
        try {

            $FileSystemObject.close()
            $FileSystemObject.dispose()
        }
          
        Catch { throw }

    }

    END {}
}

Export-ModuleMember -Function * -Alias *