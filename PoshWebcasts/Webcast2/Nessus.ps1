"Demo for SEC557 Classes"

"Clay/Carol: Do the Vuln scanner poll"

#You've been given a pile of CSV exports from 80+ nessus scans.
#Management asks you to review them to see "how bad it is"
# - How many of the vulnerabilities reported are marked as "critical?"
# - What percentage of reported vulnerabilities are "critical?"
# - Which hosts have the largest numbers of critical vulnerabilities?

Set-Location .\Nessus

#Take a look at the files
Get-ChildItem

#Let's import ALL the scan results into a variable to make analysis go faster
$scanResults = Import-Csv -path (Get-ChildItem *.csv | Select-Object -ExpandProperty FullName)

#How many individual findings is this?
$scanResults | Measure-Object

#Import-Csv returns a PowerShell object with NoteProperties for each of the columns in the source CSV. 
#You can view the properties using the Get-Member cmdlet
$scanResults | Select-Object -first 1 | Get-Member -MemberType NoteProperty

#Which hosts were included in these scans?
$scanResults.Host | Sort-Object -Unique

#How many hosts were scanned?
$scanResults.Host | Sort-Object -Unique | Measure-Object

#you can use the Group-Object command to develop a quick summary of results by risk rating:

$scanResults | Group-Object Risk

#show all the servers which have at least five critical findings, sorted largest first
$scanResults |  Where-Object Risk -eq 'critical' |  Group-Object Host | Select-Object Count, Name | Where-Object Count -gt 5 | Sort-Object Count -Descending

#To count all the results with a risk rating of critical, you can use 
#Where-Object to limit the output of your command:

$scanResults | Group-Object Risk | Where-Object Name -eq 'Critical'

#gather the two values required to calculate the percentage of findings which are scored 'critical'
$criticalCount = ($scanResults | Group-Object Risk | Where-Object Name -eq 'Critical').Count

$totalCount = ($scanResults |  Where-Object Risk -ne 'None').Count

#view the values in the variables by invoking them in the PowerShell conso#le:
"Critical Count:`t " + $criticalCount + "`nTotal Count:`t " + $totalCount

#calculate the percentage of reported findings which are labeled critical by 
#simply performing the division required
$criticalCount/$totalCount

#Gather the count of findings per host, per risk level:
$scanResults | Group-Object Host, Risk

#What if I did something like that PER DAY and saved the results???
Set-Location ..

#Let's go ask the admins for the results of all the scans for the last 90 days for 50 servers
.\GetVulnData.ps1

#Let's look at part of the output file:
Get-Content .\vulnData.csv | Select-Object -first 10

#Pull that into a variable
$results = Import-Csv .\vulnData.csv

$results.Count

#Convert the data for inport into the dashboard database - view the first 10
#for a sanity check
$results | Select-Object ServerName,Risk,@{n='epoch';e={Get-Date -Date $_.DateRun -AsUTC -UFormat %s}},Count | foreach { "vuln." + $_.ServerName.ToString() + "." + $_.Risk.toString() + " " + $_.count + " " + $_.epoch.ToString()} | Select-Object -First 10

#Use netcat in WSL to do the import
$results | Select-Object ServerName,Risk,@{n='epoch';e={Get-Date -Date $_.DateRun -AsUTC -UFormat %s}},Count | foreach { "vuln." + $_.ServerName.ToString() + "." + $_.Risk.toString() + " " + $_.count + " " + $_.epoch.ToString()} | wsl nc -vv -N 10.50.7.50 2003