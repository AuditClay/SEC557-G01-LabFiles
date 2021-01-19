function Convert-InspecResults{
    #This script loads an Inspec result file in JSON format and
    #processes it into the Graphite input text format. You can
    #run the output of this script through netcat to upload it
    #straight into Graphite

    #The MetricPath parameter is mandatory and should be in
    #whisper metric database format, i.e. benchmarks.windows.hostname

    #The script will add .fail, .pass, .total, .skip, .failpct metrics
    #to the base name, add the count for each and the epoch date
    #If no DateRun parameter is supplied, the current date and time will be used
    #If no FileName parameter is specified, the script will try to use
    #a file named "results.json"
    param ( 
        [string]$FileName = "results.json",
        [DateTime]$DateRun = (Get-Date),
        [string]$MetricPath
    )

    #stop execution with an error if the file doesn't exist
    if( -Not (Test-Path $FileName)) {
        Throw "FileName not found"
    }

    #stop execution with an error if no metric path was specified
    if( -Not ($MetricPath)){
        Throw "MetricPath not included"
    }

    #Convert the DateRun parameter to epoch time
    $epochDate = Get-Date -Date $DateRun -ASUtc -Uformat %s

    #Load the results and group them by status
    $inspecResult = Get-Content $FileName | ConvertFrom-Json
    $grouped = $inspecResult.profiles.controls.results.status | Group-Object

    #Calculate all the metrics from the groupd results
    $fail =  ($grouped | Where-Object { $_.name -eq 'failed'}).Count
    $pass = ($grouped | Where-Object { $_.name -eq 'passed'
    }).Count
    $skip = ($grouped | Where-Object { $_.name -eq 'skipped'
    }).Count
    $total = $pass + $fail
    $failpct = $fail / $total * 100.0

    #output the metrics in Graphite import format
    "$MetricPath.fail " + $fail + " $epochDate"
    "$MetricPath.pass " + $pass + " $epochDate"
    "$MetricPath.total " + $total + " $epochDate"
    "$MetricPath.skip " + $skip + " $epochDate"
    "$MetricPath.failpct " + $failpct + " $epochDate"
}

function Convert-PatchVelocity {
    [CmdletBinding()]
    Param(
        [string]$MetricPath,
        [Parameter(ValueFromPipelineByPropertyName)]$Name,
        [Parameter(ValueFromPipelineByPropertyName)]$Count
    )
    process{
        #stop execution with an error if no metric path was specified
        if( -Not ($MetricPath)){
            Throw "MetricPath not included"
        }
        $epochTime = Get-Date -date $Name -AsUTC -UFormat %s
        "$MetricPath $Count $epochTime"
    }
}

function Convert-PesterResults {
    [CmdletBinding()]
    Param(
        [DateTime]$DateRun = (Get-Date),
        [string]$MetricPath,
        [Parameter(ValueFromPipelineByPropertyName)]$FailedCount,
        [Parameter(ValueFromPipelineByPropertyName)]$PassedCount,
        [Parameter(ValueFromPipelineByPropertyName)]$SkippedCount
    )
    
    #stop execution with an error if no metric path was specified
    if( -Not ($MetricPath)){
        Throw "MetricPath not included"
    }
    $epochTime = Get-Date -date $DateRun -AsUTC -UFormat %s
    $totalCount = $PassedCount + $FailedCount
    $failPct = $FailedCount / $TotalCount * 100.0

    "$MetricPath.fail $FailedCount $epochTime"
    "$MetricPath.pass $PassedCount $epochTime"
    "$MetricPath.skip $SkippedCount $epochTime"
    "$MetricPath.total $totalCount $epochTime"
    "$MetricPath.failpct $failPct $epochTime"
}