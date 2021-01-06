#This script simulates the work of server admins or infosec staff over the course of a year
#We retrieve two CSVs from the admin staff. It uses random data, precomputed to amke the demo go faster
#While this is simulated data, it is similar to what we have seen in real audits and consulting engagements

"Admins are gathering 1 year of patch data for 100 servers"
"This may take a minute..."

#Patches.csv has every patch installed on every server for the last year
#It could be obtained by running this code against all servers:
# Get-HotFix | Where-Object InstalledOn -gt (Get-Date).AddYears(-1)
Get-Content .\patchInput.csv |
  ConvertFrom-Csv |
  Select-Object Source, `
    @{N='InstalledOn';E={(Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0).AddDays($_.DateOffset)}}, `
    HotFixID, Description, InstalledBy |Where-Object InstalledOn -lt (Get-Date) |
  Export-Csv -Force -NoTypeInformation -Path patches.csv

"Annual patch data written to: patches.csv"  

#PatchAge.csv has the "patch age" (number of days since the server was last patched) for
#every server over the last year. This could be obtained by running this code daily against
#each server:
#$lastPatchDate = (Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 1).InstalledOn
#$patchAge = (New-TimeSpan -Start $lastPatchDate -End (Get-Date)).Days
  Get-Content .\patchAgeInput.csv |
  ConvertFrom-Csv |
  Select-Object ServerName, ` 
    @{N='Date';E={(Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0).AddDays($_.DateOffset)}}, `
    PatchAge |Where-Object Date -lt (Get-Date) |
  Export-Csv -Force -NoTypeInformation -Path patchAge.csv
  
"Annual patch age data written to: patchAge.csv" 