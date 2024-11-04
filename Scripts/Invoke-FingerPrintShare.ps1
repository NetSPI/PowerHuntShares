<#
	GENERAL NOTES
	Testing of these functions was limited to the versions below:
	o PowerShell Version: 5.1
	o LLM Version: Azure LLM API; GPT 4o & GPT 4o mini 

	TODO
	o Add optional threading for LLM requests.
	o Add ability to generate images with text + image requests.
#>

# Function for generic LLM requests
# Author: Scott Sutherland (@_nullbind), NetSPI 2024
# v.01
function Invoke-LLMRequest {
	<#
            .SYNOPSIS
            This function sends text or an image to a specified Azure LLM API endpoint using the provided API key.
            It requires the 'apikey', 'endpoint', and 'text' parameters to be specified.
            This was tested on GPT 4o and 4o-mini.
            .PARAMETER apikey
            The API key required to access the endpoint.
            .PARAMETER endpoint
            The API service URL to which the request is sent.
            .PARAMETER text
            The text content that will be analyzed by the API service.
            .PARAMETER ImagePath
            Optional. The path to an image file that will be sent to the API.
            .PARAMETER SimpleOutput
            Optional. The will return the simple LLM response instead of the whole response object.
            .PARAMETER SimpleOutput
            Optional. The will return the simple LLM response instead of the whole response object.
            .PARAMETER Temperature
            Optional. This will set the temperature for the query.
            .PARAMETER TopP
            Optional. This will set the top_p for the query.
            .PARAMETER MaxTokens
            Optional. This will set the max tokens for the query.
            .EXAMPLE
	        PS C:\> Invoke-LLMRequest -apikey "your_api_key" -endpoint "https://api.example.com/analyze" -text "Sample text to analyze"
            .EXAMPLE
	        PS C:\> Invoke-LLMRequest -SimpleOutput -apikey "your_api_key" -endpoint "https://api.example.com/analyze" -text "Sample text to analyze"
            .EXAMPLE   
            Invoke-LLMRequest -SimpleOutput  -apikey "your_api_key" -endpoint "https://api.example.com/analyze" -text "What is this image?" -ImagePath "c:\temp\thing1.png"
            PS C:\temp\test> Import-Module Invoke-HuntSMBShares.ps1
	#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$apikey,

        [Parameter(Mandatory=$true)]
        [string]$endpoint,

        [Parameter(Mandatory=$true)]
        [string]$text, 

        [Parameter()]
        [string]$ImagePath,

        [Parameter()]
        [switch]$SimpleOutput,

        [Parameter()]
        [decimal]$Temperature = 0.7,

        [Parameter()]
        [decimal]$TopP = 0.95,

        [Parameter()]
        [int]$MaxTokens = 2000
    )

    # Initialize content based on input
    $content = @()
    if ($text) {
        $content += @{
            "type" = "text"
            "text" = $text
        }
    }
    
    if ($ImagePath) {
        try {
            $encoded_image = [Convert]::ToBase64String([IO.File]::ReadAllBytes($ImagePath))
            $content += @{
                "type" = "image"
                "image" = $encoded_image
            }
        } catch {
            Write-Host "Error: Unable to read or encode the image at $ImagePath"
            return
        }
    }

    # Set headers
    $headers = @{
        "Content-Type" = "application/json"
        "api-key" = $apikey
    }

    # Payload for the request
    $payload = @{
        "messages" = @(
            @{
                "role" = "user"
                "content" = $content
            }
        )
        "temperature" = $Temperature
        "top_p" = $TopP
        "max_tokens" = $MaxTokens
    } | ConvertTo-Json -Depth 10

    # Show configuration
    Write-Verbose "Settings:"
    Write-Verbose "- Temperature: $Temperature"
    Write-Verbose "- Top P: $TopP"
    Write-Verbose "- Max Tokens: $MaxTokens"

    # Send request
    try {
        $response = Invoke-RestMethod -Uri $endpoint -Headers $headers -Method Post -Body $payload

        # Display token details
        $UsagePromptTokens     = $response.usage.prompt_tokens
        $UsageCompletionTokens = $response.usage.completion_tokens
        $UsageTotalTokens      = $response.usage.total_tokens
        Write-Verbose "Prompt/Input Tokens: $UsagePromptTokens"
        Write-Verbose "Completion/Output tokens: $UsageCompletionTokens"
        Write-Verbose "Total Tokens: $UsageTotalTokens"

        # Return the message text
        if($SimpleOutput){
            return $response.choices[0].message.content
        }else{
            $response
        }
    } catch {
        Write-Host "Failed to make the request. Error: $_"
        return $null
    }
}


# Function for application finger printing based on share and file names
# Author: Scott Sutherland (@_nullbind), NetSPI 2024
# v.01
function Invoke-FingerPrintShare {
	<#
            .SYNOPSIS
            This function sends a share name and file list to the Azure LLM API endpoint for fingerprinting.
            It requires the 'apikey', 'endpoint', and 'text'. This was tested on GPT 4o and GPT 4o-mini.
            .PARAMETER apikey
            The API key required to access the endpoint.
            .PARAMETER endpoint
            The API service URL to which the request is sent.
            .PARAMETER ShareName
            This is the name of the network share to fingerprint.
            .PARAMETER FileList
            Optional. This is a list of file names found in the share to help fingerprint the application or OS associated with the share name.
            .PARAMETER FilePath
            Optional. This is a csv file with the columns 'ShareName' and 'FileList' that includes the file names found in the share.
            .PARAMETER DataTable
            Optional. This is a DataTable with the columns 'ShareName' and 'FileList' that includes the file names found in the share.             
            .PARAMETER OutputFile
            Optional. This should be the full path to a file name that he results will be written to.
            .PARAMETER MakeLog
            Optional. This enabled error log file creation that can be used for debugging.
            .EXAMPLE
	        PS C:\> Invoke-LLMRequest -Verbose -FilePath "c:\temp\input.csv" -OutputFile 'c:\temp\output.csv' -apikey "your_api_key" -endpoint "https://api.example.com/analyze" 
            .EXAMPLE   
            PS C:\> Invoke-LLMRequest -Verbose -ShareName "sccm" -FileList "variables.dat" -apikey "your_api_key" -endpoint "https://api.example.com/analyze" 
            .EXAMPLE   
            PS C:\> Invoke-LLMRequest -Verbose -DataTable $exampleTable -apikey "your_api_key" -endpoint "https://api.example.com/analyze" 
            .EXAMPLE   
            PS C:\> Invoke-LLMRequest -Verbose -OutputFile 'c:\temp\output.csv' -DataTable $exampleTable -apikey "your_api_key" -endpoint "https://api.example.com/analyze" 
            .EXAMPLE   
            PS C:\> Invoke-LLMRequest -MakeLog -Verbose -DataTable $exampleTable -apikey "your_api_key" -endpoint "https://api.example.com/analyze"                        
	#>
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$ShareName,

        [Parameter(Mandatory = $true)]
        [string]$ApiKey,

        [Parameter(Mandatory = $true)]
        [string]$Endpoint,

        [Parameter()]
        [string]$FileList,

        [Parameter()]
        [string]$FilePath,

        [Parameter()]
        [System.Data.DataTable]$DataTable,

        [Parameter()]
        [string]$OutputFile,

        [Parameter()]
        [switch]$MakeLog
    )

    # Start Timer
    $StartTime    =  Get-Date -UFormat "%m/%d/%Y %R"
    $StopWatch    =  [system.diagnostics.stopwatch]::StartNew()
    $LogTimestamp = Get-Date -Format "MMddyyyyHHmmss"

    # Dependency Check for Invoke-LLMRequest PowerShell function
    $requiredFunction = "Invoke-LLMRequest"
    if (!(Get-Command -Name $requiredFunction -CommandType Function -ErrorAction SilentlyContinue)) {
        Write-Error "The required function '$requiredFunction' is not available. Please define it or import the module that provides it."
        return
    }

    # Verify that a data table, csv, or filenames have been passed into the function before moving on.
    if (-not $FileList -and -not $FilePath -and -not $DataTable) {
        Write-Output "No file names, file paths, or data tables have been provided."
        break
    }

    # Verify the file path exists
    If($FilePath){

        if(Test-Path $FilePath){ 
                # Write-Verbose "The csv file path exists."
        }else{
                Write-Output " [x] The $FilePath did not exist."
                Write-Output " [!] Aborting operation."
                break
        }
    }

    # Create table for master list
    $TargetList = New-Object System.Data.DataTable
    $null = $TargetList.Columns.Add("ShareName") 
    $null = $TargetList.Columns.Add("FileList") 

    # Parse file path if provided
    If($FilePath){
        $CsvFileData = Import-Csv $FilePath | select ShareName, FileList
        $CsvFileDataCount = $CsvFileData | measure | select count -ExpandProperty count
        if($CsvFileDataCount -eq 0){
            Write-Verbose "Importing 0 records from the provided file."
        }else{
            Write-Verbose "Importing $CsvFileDataCount records from the provided file."
            Write-Verbose " - $FilePath"
            $CsvFileData | 
            foreach{ 
                 
                # Create a new row for the TargetList DataTable
                $newRow = $TargetList.NewRow()
                $newRow["ShareName"] = $_.ShareName
                $newRow["FileList"]  = $_.FileList

                # Add the new row to the TargetList DataTable
                $TargetList.Rows.Add($newRow)
            }
        }
    }

    # Parse data table if provided
    if($DataTable){
        $DtFileDataCount = $DataTable.Rows.Count
        if ($DtFileDataCount -eq 0) {
            Write-Verbose "Importing 0 records from the provided data table."
        } else {
            Write-Verbose "Importing $DtFileDataCount records from the provided data table."

            foreach ($row in $DataTable.Rows) {
                # Create a new row for the TargetList DataTable
                $newRow = $TargetList.NewRow()
                $newRow["ShareName"] = $row["ShareName"]
                $newRow["FileList"] = $row["FileList"]

                # Add the new row to the TargetList DataTable
                $TargetList.Rows.Add($newRow)
            }
        }
    }

    # Generate file list object
    if (($FileList) -and ($ShareName)) {
        Write-Verbose "Importing 1 record from command line."
        # Create a new row in the DataTable
        $newRow = $TargetList.NewRow()

        # Set values for each column
        $newRow["ShareName"] = $ShareName
        $newRow["FileList"] = $FileList

        # Add the new row to the DataTable
        $null = $TargetList.Rows.Add($newRow)
    }        

    # Verify records exist
    $TargetListCount      = $TargetList | measure | select count -ExpandProperty count
    $TargetListCountTrack = 0
    if($TargetListCount -gt 0){        
        Write-Verbose "$TargetListCount records will be processed."
    }else{
        Write-Output "No records were found for processing, aborting."
        break
    }
    Write-Verbose "Endpoint: $Endpoint"
    Write-Verbose "-----------------------------------------------"

    # Process records
    $Results = $TargetList |
    foreach {
        $ShareNamesFormatted = $_.ShareName
        $FileListFormatted   = $_.FileList   
        
        # Define the prompt
        $MyPrompt = @"
You will be provided with a share name and a list of file names. Your task is to:

1. Analyze the provided share name to determine it is related to a known application.  Please ensure your only return a application guess if you know of an existing application or operating system by name. Do not make things up or refer generic product categories.
2. Analyze all provided file names to determine if one or more are related to a known application or operating system. Make sure to take into analyze file names, file name prefixes, and file extensions. Run this analysis 5 time on the backend and select the one that is most accurate.
3. Define a confidence score ranging from 1 to 5, where 5 represents very high confidence.
4. If any identified applications have a confidence score above 3, return the top one application and it's confidence score. 
5. If no application has a confidence score above 3, then don't return anything."
6. For each identified application where the confidence score is above 3, return the following information in XML format:
- Share Name
- Application Name
- Confidence Score
- A list of the top 10 most relevant files that have been comma seperated on one line.
- A two-sentence justification of the match. Include the justification based on the share name in the first sentance, the justification based on the top 5 file names in the second, and link to the application page at the end (if available).
Ensure the output is formatted as XML. Please only return the XML formatted response with nothing else. Please DO NOT wrap the XML response with any comments or labeling. For example, do not include "```xml". Please do not wrap responses in nested "{}".

Please ensure the xml follows the structure below:
Applications.Application.ShareName
Applications.Application.ApplicationName
Applications.Application.ConfidenceScore
Applications.Application.RelevantFiles
Applications.Application.Justification

Input:

Share Name: 
$ShareNamesFormatted

File Names: 
$FileListFormatted
"@

        # Send request
        Try{    
            $TargetListCountTrack = $TargetListCountTrack +1       
            Write-Verbose "($TargetListCountTrack/$TargetListCount) Sending request for $ShareNamesFormatted share name. "            
            $LLMResponse           = Invoke-LLMRequest -Verbose:$false -Text $MyPrompt -APIKEY $ApiKey -Endpoint $Endpoint
            [xml]$Fingerprint      = $LLMResponse.choices[0].message.content
        }catch{
            $FailMsg = "($TargetListCountTrack/$TargetListCount) $ShareNamesFormatted sharename and file process failed for some reason."
            Write-Verbose "$FailMsg"
            if($MakeLog){
                try{
                    Add-Content -Path ./LlmRequest$LogTimestamp.log -Value $FailMsg
                }catch{
                    write-Verbose "Could not write LlmRequest$LogTimestamp.log."
                }
            }
        }

        # Build PowerShell Object and return
        if ($Fingerprint) {

            # Return formatted response in powershell object
            $FingerprintObj = New-Object PSObject
            $FingerprintObj | Add-Member -MemberType NoteProperty -Name "ShareName"         -Value $Fingerprint.Applications.Application.ShareName
            $FingerprintObj | Add-Member -MemberType NoteProperty -Name "ApplicationName"   -Value $Fingerprint.Applications.Application.ApplicationName
            $FingerprintObj | Add-Member -MemberType NoteProperty -Name "ConfidenceScore"   -Value $Fingerprint.Applications.Application.ConfidenceScore
            $FingerprintObj | Add-Member -MemberType NoteProperty -Name "RelevantFiles"     -Value $Fingerprint.Applications.Application.RelevantFiles
            $FingerprintObj | Add-Member -MemberType NoteProperty -Name "Justification"     -Value $Fingerprint.Applications.Application.Justification
            $FingerprintObj | Add-Member -MemberType NoteProperty -Name "PromptTokens"      -Value $LLMResponse.usage.prompt_tokens
            $FingerprintObj | Add-Member -MemberType NoteProperty -Name "CompletionTokens"  -Value $LLMResponse.usage.completion_tokens
            $FingerprintObj | Add-Member -MemberType NoteProperty -Name "TotalTokens"       -Value $LLMResponse.usage.total_tokens
        
            return $FingerprintObj
        } else {
            Write-Verbose "No valid fingerprint data returned."
        }
    } | where ShareName -NotLike ""

    # Return results
    $Results 

    # Write results to file
    if($OutputFile){
        try{
            $Results | Export-Csv -NoTypeInformation $OutputFile
            Write-Verbose "Results written to $OutputFile."
        }catch{
            Write-Verbose "Could not write $OutputFile."
        }
    }

    # Calculate total tokens used 
    $TokensTotalPrompt     = 0
    $TokensTotalCompletion = 0
    $TokensTotalTotal      = 0
    $Results | 
    foreach {
        $TokensTotalPrompt     += $_.PromptTokens
        $TokensTotalCompletion += $_.CompletionTokens
        $TokensTotalTotal      += $_.TotalTokens
    }

    # Get tokens stats
    Write-Verbose "Token Usage Summary"
    Write-Verbose " - Prompt Tokens Total: $TokensTotalPrompt"
    Write-Verbose " - Completion Tokens Total: $TokensTotalCompletion"
    Write-Verbose " - Grand Total: $TokensTotalTotal"
    Write-Verbose ""

    # Get run time stats
    $EndTime =  Get-Date -UFormat "%m/%d/%Y %R"
    $StopWatch.Stop()
    $RunTime = $StopWatch | Select-Object Elapsed -ExpandProperty Elapsed
    Write-Verbose "Runtime Summary"
    Write-Verbose " - Start   : $StartTime"
    Write-Verbose " - End     : $EndTime"
    Write-Verbose " - Duration: $RunTime"

    # Add to log
    if($MakeLog){
        try{
            Add-Content -Path ./LlmRequest$LogTimestamp.log -Value "Token Usage Summary"
            Add-Content -Path ./LlmRequest$LogTimestamp.log -Value " - Prompt Tokens Total: $TokensTotalPrompt"
            Add-Content -Path ./LlmRequest$LogTimestamp.log -Value " - Completion Tokens Total: $TokensTotalCompletion"
            Add-Content -Path ./LlmRequest$LogTimestamp.log -Value " - Grand Total: $TokensTotalTotal"
            Add-Content -Path ./LlmRequest$LogTimestamp.log -Value "Runtime Summary"
            Add-Content -Path ./LlmRequest$LogTimestamp.log -Value " - Start   : $StartTime"
            Add-Content -Path ./LlmRequest$LogTimestamp.log -Value " - End     : $EndTime"
            Add-Content -Path ./LlmRequest$LogTimestamp.log -Value " - Duration: $RunTime"
            Write-Verbose ""
            Write-Verbose "LLM request log written to LlmRequest.log."
        }catch{
            Write-Verbose "Could not write LlmRequest.log."
        }
    }
    
    # Status user 
    Write-Verbose "All done."
}

<#

# -----------------------
# Invoke-LLMRequest
# -----------------------
# Example Commands

# Simple output from text query
Invoke-LLMRequest -SimpleOutput -apikey "your_api_key" -endpoint "https://[yourapiname].openai.azure.com/openai/deployments/[yourapiname]/chat/completions?api-version=[configuredversion]" -text "What is 2+2?"

# Simple output from text query with image upload
# Note: Image response did not appear to be supported
Invoke-LLMRequest -SimpleOutput -apikey "your_api_key" -endpoint "https://[yourapiname].openai.azure.com/openai/deployments/[yourapiname]/chat/completions?api-version=[configuredversion]" -text "What is this an image of?" -ImagePath "c:\temp\apple.png"

# Full output with all response meta data
Invoke-LLMRequest -apikey "your_api_key" -endpoint "https://[yourapiname].openai.azure.com/openai/deployments/[yourapiname]/chat/completions?api-version=[configuredversion]" -text "What is 2+2?"

# -----------------------
# Invoke-FingerPrintShare
# -----------------------
# Example commands

# Name from Command Line
Invoke-FingerprintShare -verbose  -ShareName "sccm" -FileList "variables.dat" -APIKEY "your_api_key" -Endpoint "https://[yourapiname].openai.azure.com/openai/deployments/[yourapiname]/chat/completions?api-version=[configuredversion]"

# CSV Import
Invoke-FingerprintShare -MakeLog -verbose  -OutputFile 'c:\temp\testouput.csv' -FilePath "c:\temp\testinput.csv" -APIKEY "your_api_key" -Endpoint "https://[yourapiname].openai.azure.com/openai/deployments/[yourapiname]/chat/completions?api-version=[configuredversion]"

# Data Table Import
Invoke-FingerprintShare -verbose -DataTable $exampleTable -APIKEY "your_api_key" -Endpoint "https://[yourapiname].openai.azure.com/openai/deployments/[yourapiname]/chat/completions?api-version=[configuredversion]"

# Name from Command Line, CSV Import, and Data Table Import
Invoke-FingerprintShare -Verbose  -OutputFile 'c:\temp\testouput.csv' -FilePath "c:\temp\testinput.csv" -ShareName "sccm" -FileList "variables.dat" -DataTable $exampleTable -APIKEY "your_api_key" -Endpoint "https://[yourapiname].openai.azure.com/openai/deployments/[yourapiname]/chat/completions?api-version=[configuredversion]"

#>

