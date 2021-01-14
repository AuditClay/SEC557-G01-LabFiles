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

#How many hosts were scanned?
$scanResults.Host | Sort-Object -Unique

#you can use the Group-Object command to develop a quick summary of results by risk rating:

$scanResults | Group-Object Risk

#To view only the results with a risk rating of critical, you can use 
#Where-Object to limit the output of your command:

$scanResults | Group-Object Risk | Where-Object Name -eq 'Critical'

#show all the servers which have at least five critical findings, sorted largest first
$scanResults |  Where-Object Risk -eq 'critical' |  Group-Object Host | Select-Object Count, Name | Where-Object Count -gt 5 | Sort-Object Count -Descending

#What if I did something like this every day and collectecd the records over time?
Set-Location ..

.\GetVulnData.ps1