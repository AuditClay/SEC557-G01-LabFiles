#From Win10

scp C:\SEC557\Lab3.2\win10input.yml auditor@ubuntu:/home/auditor

scp C:\SEC557\Functions.ps1 auditor@ubuntu:/home/auditor

#From PowerShell Core on Ubuntu
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

Set-Location /home/auditor/inspec/
inspec exec ./microsoft-windows-10-stig-baseline -t winrm://auditor@10.50.7.101 --port 5985 --password Password1 --input-file /home/auditor/win10input.yml --reporter cli json:win10Results.json

$res= Get-Content ./win10Results.json | ConvertFrom-Json
#"Dot-source" the functions script to include it in the current environment
. /home/auditor/Functions.ps1
Convert-InspecResults -FileName ./win10Results.json -MetricPath benchmark.windows.win10 -DateRun (Get-Date).ToShortDateString()

Convert-InspecResults -FileName ./win10Results.json -MetricPath benchmark.windows.win10 `
 -DateRun (Get-Date).ToShortDateString() | nc -vv -N ubuntu 2003

inspec exec ./microsoft-windows-server-2016-stig-baseline -t winrm://auditor@10.50.7.10:5985 --password Password1 --reporter cli json:winDC.json

Convert-InspecResults -FileName ./winDC.json -MetricPath 'benchmark.windows.windc' 
Convert-InspecResults -FileName ./winDC.json -MetricPath 'benchmark.windows.windc' | nc -vv -N ubuntu 2003

#No need to import the dashboard. it alerady exists
