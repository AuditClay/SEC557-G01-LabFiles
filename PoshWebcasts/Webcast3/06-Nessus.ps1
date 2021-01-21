"Demo for SEC557 Classes"


#Let's go ask the admins for the results of all the scans for the last 90 days for 50 servers
.\GetVulnData.ps1

#Let's look at part of the output file:
Get-Content .\vulnData.csv | Select-Object -first 10

#Pull that into a variable
$results = Import-Csv .\vulnData.csv

$results.Count

#Convert the data for import into the dashboard database - view the first 10
#for a sanity check
$results | Select-Object ServerName,Risk,@{n='epoch';e={Get-Date -Date $_.DateRun -AsUTC -UFormat %s}},Count | foreach { "vuln." + $_.ServerName.ToString() + "." + $_.Risk.toString() + " " + $_.count + " " + $_.epoch.ToString()} | Select-Object -First 10

#Use netcat in WSL to do the import
$results | Select-Object ServerName,Risk,@{n='epoch';e={Get-Date -Date $_.DateRun -AsUTC -UFormat %s}},Count | foreach { "vuln." + $_.ServerName.ToString() + "." + $_.Risk.toString() + " " + $_.count + " " + $_.epoch.ToString()} | wsl nc -vv -N 10.50.7.50 2003