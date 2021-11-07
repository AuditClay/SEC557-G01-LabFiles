Set-Location C:\SEC557\Lab2.1

#Set the location of the files
$keyFile = ".\keyFile"
$tokenFile = ".\githubToken"

#Create a new key byte array and fill it
$Key = New-Object Byte[] 16
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)

#Send to the key file
$Key | Out-File $keyFile

#Use the encryption key to encrypt the password and dump the encrypted password to a file
$Password = Read-Host -AsSecureString "Paste in GitHub Token"

$Password | ConvertFrom-SecureString -Key $Key | Out-File $tokenFile

#Retrieving data from the files
$keyFile = ".\keyFile"
$tokenFile = ".\githubToken"
#Grab the key/token, decrypt the password and store it in a credentials object
$key = Get-Content $keyFile
$token = Get-Content $tokenFile

$githubUsername = Read-Host "Enter your github username"

$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $githubUsername, ($token | ConvertTo-SecureString -Key $key)

#last 3 months in UTC time
$since = (Get-Date -Date (Get-Date).addDays(-90) -Format "yyyyMMddTHHmmssZ" -Hour 0 -Minute 0 -Second 0 -Millisecond 0)

$issues = $null
#Counter variables
$page = -1
$count = 100

#Loop until you receive < 100 results on the page
while ( $count -eq 100)
{  
    $page++
    "Processing page: $page"

    #Set the URL for the request, plugging in $page as the page number
    $uri = "https://api.github.com/repos/PowerShell/PowerShell/issues?page=$page&per_page=100&state=closed&since=$since"

    #Get the next page and add the contents to the $issues variable
    $nextPage = Invoke-RestMethod -Credential $cred -Uri $uri
    $count = $nextPage.count
    $issues += $nextPage
}

"Importing:"
$issues | 
  Select-Object @{n='ClosedDate'; e={Get-Date -Date $_.closed_at -Hour 0 -Min 0 -Second 0 -Millisecond 0 -AsUTC -UFormat %s}} | 
  Group-Object ClosedDate | 
  Foreach {"issues.closed " + $_.count.ToString() + " " +$_.Name.ToString()}


$issues | 
  Select-Object @{n='ClosedDate'; e={Get-Date -Date $_.closed_at -Hour 0 -Min 0 -Second 0 -Millisecond 0 -AsUTC -UFormat %s}} | 
  Group-Object ClosedDate | 
  Foreach {"issues.closed " + $_.count.ToString() + " " +$_.Name.ToString()} | 
  wsl nc -vv -N 10.50.7.50 2003

  $MTTR = ($issues | 
  Select-Object @{n='TimeToResolve'; e={(New-TimeSpan -Start (Get-Date -date $_.created_at) -End ($_.closed_at)).TotalDays} } | 
  Measure-Object -Property TimeToResolve -Average).Average


"Importing: issues.mttr $MTTR " + (Get-Date -Hour 0 -Min 0 -Second 0 -Millisecond 0 -AsUTC -UFormat %s)
"issues.mttr $MTTR " + (Get-Date -Hour 0 -Min 0 -Second 0 -Millisecond 0 -AsUTC -UFormat %s) | 
  wsl nc -vv -N 10.50.7.50 2003
