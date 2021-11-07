#Run on Win10
Set-Location C:\SEC557\Lab3.3
$cred = Get-Credential -UserName auditor

.\ADDemographics.ps1 -Credential $cred -Server 10.50.7.10 | 
  wsl nc -N -vv ubuntu 2003

