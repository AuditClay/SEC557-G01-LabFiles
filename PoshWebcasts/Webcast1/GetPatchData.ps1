"Admins are gathering 1 year of patch data for 100 servers"
"This may take a minute..."

Get-Content .\patchInput.csv |
  ConvertFrom-Csv |
  Select-Object Source, ` 
    @{N='InstalledOn';E={(Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0).AddDays($_.DateOffset)}}, `
    HotFixID, Description, InstalledBy |Where-Object InstalledOn -lt (Get-Date) |
  Export-Csv -Force -NoTypeInformation -Path patches.csv

"Annual patch data written to: patches.csv"  

  Get-Content .\patchAgeInput.csv |
  ConvertFrom-Csv |
  Select-Object ServerName, ` 
    @{N='Date';E={(Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0).AddDays($_.DateOffset)}}, `
    PatchAge |Where-Object Date -lt (Get-Date) |
  Export-Csv -Force -NoTypeInformation -Path patchAge.csv
  
"Annual patch age data written to: patchAge.csv" 