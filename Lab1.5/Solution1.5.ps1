Set-Location C:\SEC557\Lab1.5\
$issueResponse = (Invoke-WebRequest -Uri https://api.github.com/repos/PowerShell/PowerShell/issues?per_page=100`&state=closed)
$issueContent = $issueResponse.Content
$issues=($issueContent | ConvertFrom-Json)

$issues | 
  Select-Object @{n='ClosedDate'; e={Get-Date -Date $_.closed_at -Hour 0 `
    -Min 0 -Second 0 -Millisecond 0 -AsUTC -UFormat %s}} | 
  Group-Object ClosedDate | 
  Foreach {"issues.closed " + $_.count.ToString() + " " +$_.Name.ToString()} | 
  wsl nc -vv -N 10.50.7.50 2003
