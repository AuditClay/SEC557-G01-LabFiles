#From Win10
Set-Location C:\SEC557\Lab3.4\

#Set the location of the files
$keyFile = ".\keyFile"
$credFile = ".\esxiCreds"

#Create a new key byte array and fill it
$Key = New-Object Byte[] 16
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)

#Send to the key file
$Key | Out-File $keyFile

#Use the encryption key to encrypt the password and dump the encrypted password to a file
#Remember that the password has a bang at the end: "Password1!""
$Password = Read-Host -AsSecureString "Enter VMWare password"
$Password | ConvertFrom-SecureString -Key $Key | Out-File $credFile


scp C:\SEC557\Lab3.4\esxiCreds auditor@ubuntu:/home/auditor/inspec
scp C:\SEC557\Lab3.4\keyFile auditor@ubuntu:/home/auditor/inspec

#In PowerShell Core on Ubuntu
function Convert-InspecResults{
  #This script loads an Inspec result file in JSON format and
  #processes it into the Graphite input text format. You can
  #run the output of this script through netcat to upload it
  #straight into Graphite

  #The MetricPath parameter is mandatory and should be in
  #whisper metric database format, i.e. benchmarks.windows.hostname

  #The script will add .fail, .pass, .total, .skip, .failpct metrics
  #to the base name, add the count for each and the epoch date
  #If no DateRun parameter is supplied, the current date and time will be used
  #If no FileName parameter is specified, the script will try to use
  #a file named "results.json"
  param ( 
      [string]$FileName = "results.json",
      [DateTime]$DateRun = (Get-Date),
      [string]$MetricPath
  )

  #stop execution with an error if the file doesn't exist
  if( -Not (Test-Path $FileName)) {
      Throw "FileName not found"
  }

  #stop execution with an error if no metric path was specified
  if( -Not ($MetricPath)){
      Throw "MetricPath not included"
  }

  #Convert the DateRun parameter to epoch time
  $epochDate = Get-Date -Date $DateRun -ASUtc -Uformat %s

  #Load the results and group them by status
  $inspecResult = Get-Content $FileName | ConvertFrom-Json
  $grouped = $inspecResult.profiles.controls.results.status | Group-Object

  #Calculate all the metrics from the groupd results
  $fail =  ($grouped | Where-Object { $_.name -eq 'failed'}).Count
  $pass = ($grouped | Where-Object { $_.name -eq 'passed'
  }).Count
  $skip = ($grouped | Where-Object { $_.name -eq 'skipped'
  }).Count
  $total = $pass + $fail
  $failpct = $fail / $total * 100.0

  #output the metrics in Graphite import format
  "$MetricPath.fail " + $fail + " $epochDate"
  "$MetricPath.pass " + $pass + " $epochDate"
  "$MetricPath.total " + $total + " $epochDate"
  "$MetricPath.skip " + $skip + " $epochDate"
  "$MetricPath.failpct " + $failpct + " $epochDate"
}

Set-Location /home/auditor/inspec/

Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

#Setup the needed files
$keyFile = ".\keyFile"
$credFile = ".\esxiCreds"

#Grab the key/token, decrypt the password and store it in a credentials object
$key = Get-Content $keyFile
$username = 'root'
$securePwd = Get-Content $credFile
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $username, ($securePwd | 
  ConvertTo-SecureString -Key $key)
#Get-NetworkCredential() allows you to retrieve the plain-text password from the encrypted credential. 
#Be careful what you do with it!
$esxiPassword = $cred.GetNetworkCredential().Password

$inspecCmd = "inspec exec vmware-esxi-6.5-stig-baseline -t `"vmware://root:$esxiPassword@10.50.7.31`" --reporter=cli json:esxi.json"

bash -c $inspecCmd

. /home/auditor/Functions.ps1

Convert-InspecResults -FileName ./esxi.json -MetricPath benchmark.vmware.esxi1 -DateRun (Get-Date).ToShortDateString() | nc -N -vv ubuntu 2003

#No need to build a dashboard. Just refresh the compliance dashboard
