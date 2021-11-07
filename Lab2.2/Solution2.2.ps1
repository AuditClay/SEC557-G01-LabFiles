#Run in PowerShell Core on Ubuntu
Set-Location /home/auditor/docker-bench-security

sudo sh docker-bench-security.sh

#Get today's date in epoch time for Graphite
$epochTime = Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0 -AsUTC -UFormat %s

#Create a hostname for the Graphite metric
$hostName = "docker." + (hostname)

#Process the results, renaming fields with calculated properties
$results = (Get-Content ./log/docker-bench-security.log.json | 
    ConvertFrom-Json).tests.results | 
    Where-Object {($_.result -eq 'PASS') -or ($_.result -eq 'WARN')} | 
    Select-Object @{n='result';e={$_.result -replace "PASS", "pass" -replace "WARN", "fail"}}


#Create variables for the failed, passed total 
$failedCount = ($results | Where-Object result -eq 'fail' | Measure-Object).Count
$passedCount = ($results | Where-Object result -eq 'pass' | Measure-Object).Count
$totalCount = ($results | Measure-Object).Count
$failedPct = $failedCount / $totalCount * 100.0

#Save the Graphite import format to a file
"benchmark.$hostName.pass " + $passedCount + " $epochTime" | Out-File -Path dockerTests.txt -Encoding ascii 
"benchmark.$hostName.fail " + $failedCount + " $epochTime" | Out-File -Path dockerTests.txt -Encoding ascii -Append
"benchmark.$hostName.total " + $totalCount + " $epochTime" | Out-File -Path dockerTests.txt -Encoding ascii -Append
"benchmark.$hostName.failpct " + $failedPct + " $epochTime" | Out-File -Path dockerTests.txt -Encoding ascii -Append

#Check the results of the file
Get-Content -Path dockerTests.txt

Get-Content -Path dockerTests.txt | nc -vv -N 10.50.7.50 2003

