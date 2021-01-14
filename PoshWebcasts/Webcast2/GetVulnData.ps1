Get-Content .\vulnDataInput.csv |
  ConvertFrom-Csv |
  Select-Object ServerName, 
    @{n='DateRun';E={(Get-Date).AddDays($_.DateOffset).ToShortDateString()}},
    Risk, Count |
  Export-Csv -Force -NoTypeInformation -Path vulnData.csv

"Vulnerability information for last 90 days written to .\vulnData.csv"

