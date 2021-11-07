#Run on Win10
Set-Location C:\SEC557\Lab3.1\

.\GetPatchData.ps1

$patchAgeData = Import-Csv .\patchAge.csv

$patchAgeData | 
  select ServerName,PatchAge, @{n='epoch';e={Get-Date -Date $_.Date -AsUTC -UFormat %s}} | 
  ForEach-Object { "patchage." + $_.ServerName + " " + $_.PatchAge + " " + $_.epoch} | 
  wsl nc -vv -N 10.50.7.50 2003

  $patchdata = Import-Csv .\patches.csv
  
  $servers = $patchdata | Select-Object Source -Unique

  $servers | 
  ForEach-Object { 
      $server=$_.source; 
      $patchdata | 
        Where-Object Source -eq $server | 
        Group-Object InstalledOn | 
        Select-Object @{n='server';e={"patchvelocity." + $server}}, Count, @{n='EpochTime';e={Get-Date -Date $_.Name -UFormat %s}} | 
        Foreach-Object { 
          $_.server + " " + $_.Count + " " + $_.EpochTime 
        }
  } | wsl nc -vv -N 10.50.7.50 2003

  