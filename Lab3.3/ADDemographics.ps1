#Parameters for non-domain test machines
#If the machine running the script is not-joined, specifying these parameters
#will allow the script to authenticate to an LDAP server to run its queries.
#No special administrative privileges are required for the credentials used to connect.

param( $Server, $Credential)

$dateString = (Get-Date).ToShortDateString()
$epochDate = Get-Date -Date $dateString -AsUTC -Uformat %s

#For obvious reasons, the ActiveDirectory module is required by this script
if ( -not (Get-Module -ListAvailable -Name ActiveDirectory))
{
    Write-Host "Active Directory module not found. Exiting."
    return
}
Import-Module ActiveDirectory


#Only use the alternative connection parameters if they were supplied
if( $Server -and $Credential )
{
  $ServerPort = $Server.ToString() + ":389"
  New-PSDrive -name "ADAudit" -PSProvider ActiveDirectory -Root "" -Server $ServerPort -Credential $Credential | Out-Null
  Push-Location ADAudit: | Out-Null
}

#Number of days after which a user is considered "inactive" - used when analyzing last logon date and date of last password change.
$InactiveDays = 120

#AD User Information: Counts of enabled and disabled user accounts
$EnabledUsers = (Get-ADUser -Filter 'enabled -eq $true' | Measure-Object).Count
$DisabledUsers = (Get-ADUser -Filter 'enabled -eq $false' | Measure-Object).Count
$TotalUsers = (Get-ADUser -filter * | Measure-Object).Count

#Users created more than 120 days ago with no password change in 120 days
$StalePasswordUsers = (Get-ADUser -Filter 'enabled -eq $true' -Properties SAMAccountName,PasswordLastSet,WhenCreated | 
        Where-Object { ($_.WhenCreated -lt (Get-Date).AddDays( -$InactiveDays )) -and `
        ($_.passwordLastSet -lt (Get-Date).AddDays( -$InactiveDays )) } | Measure-Object).Count

#Users who haven't authenticated in 120 days
$InactiveUsers = (Get-ADUser -Filter 'enabled -eq $true' -Properties SAMAccountName,LastLogonDate,WhenCreated,PasswordLastSet |
        Where-Object { ($_.LastLogonDate -lt (Get-Date).AddDays( -$InactiveDays )) } | Measure-Object).Count

#Users who have authenticated or changed their password within the last 120 days
$ActiveUsers = (Get-ADUser -Filter 'enabled -eq $true' -Properties SAMAccountName,LastLogonDate,WhenCreated,PasswordLastSet |
        Where-Object { ($_.LastLogonDate -gt (Get-Date).AddDays( -$InactiveDays )) `
        -or ($_.passwordLastSet -gt (Get-Date).AddDays( -$InactiveDays )) } | Measure-Object).Count

#Members of sensitive groups
$DomainAdmins = (Get-ADGroupMember -Recursive -Identity "Domain Admins" | Measure-Object).Count
$SchemaAdmins = (Get-ADGroupMember -Recursive -Identity "Schema Admins" | Measure-Object).Count
$EnterpriseAdmins = (Get-ADGroupMember -Recursive -Identity "Enterprise Admins" | Measure-Object).Count

#Enabled users with password which never expires
$svcAccts = Get-ADUser -filter {PasswordNeverExpires -eq $true -and Enabled -eq $true} -SearchBase 'OU=Service Accounts,OU=Information Systems,DC=CNHSA,DC=COM'
$mboxAccts = Get-ADUser -filter {PasswordNeverExpires -eq $true -and Enabled -eq $true} -SearchBase 'CN=Monitoring Mailboxes,CN=Microsoft Exchange System Objects,DC=CNHSA,DC=COM'

$PasswordNeverExpires = (Get-ADUser -filter {PasswordNeverExpires -eq $true -and Enabled -eq $true} | 
    Where-Object {$_.distinguishedName -notin ($svcAccts).distinguishedName -and $_.distinguishedName -notin ($mboxAccts).distinguishedName} | Measure-Object).Count
 
#Enabled users with password which was never set
$PasswordNeverSet = (Get-ADUser -Filter 'enabled -eq $true' -Properties PasswordLastSet, Created |
        Where-Object { ($_.PasswordLastSet -eq $null) -and ($_.Created -lt (Get-Date).AddDays( -14 ))} | Measure-Object).Count


#Enabled users with no password required
$PasswordNotRequired = (Get-ADUser -Filter 'enabled -eq $true -and PasswordNotRequired -eq $true' | Measure-Object).Count

$outputLine = "ad.enabledUsers " 
$outputLine += $EnabledUsers.ToString()
$outputLine += " " + $dateString
$outputLine

$outputLine = "ad.disabledUsers " 
$outputLine += $DisabledUsers.ToString()
$outputLine += " " + $dateString
$outputLine

$outputLine = "ad.totalUsers " 
$outputLine += $TotalUsers.ToString()
$outputLine += " " + $dateString
$outputLine

$outputLine = "ad.stalePasswordUsers " 
$outputLine += $StalePasswordUsers.ToString()
$outputLine += " " + $dateString
$outputLine

$outputLine = "ad.inactiveUsers " 
$outputLine += $InactiveUsers.ToString()
$outputLine += " " + $dateString
$outputLine

$outputLine = "ad.activeUsers " 
$outputLine += $ActiveUsers.ToString()
$outputLine += " " + $dateString
$outputLine

$outputLine = "ad.domainAdmins " 
$outputLine += $DomainAdmins.ToString()
$outputLine += " " + $dateString
$outputLine

$outputLine = "ad.schemaAdmins " 
$outputLine += $SchemaAdmins.ToString()
$outputLine += " " + $dateString
$outputLine

$outputLine = "ad.enterpriseAdmins " 
$outputLine += $EnterpriseAdmins.ToString()
$outputLine += " " + $dateString
$outputLine

$outputLine = "ad.passwordNeverExpires " 
$outputLine += $PasswordNeverExpires.ToString()
$outputLine += " " + $dateString
$outputLine

$outputLine = "ad.passwordNeverSet " 
$outputLine += $PasswordNeverSet.ToString()
$outputLine += " " + $dateString
$outputLine

$outputLine = "ad.passwordNotRequired " 
$outputLine += $PasswordNotRequired.ToString()
$outputLine += " " + $dateString
$outputLine

#If the alternate connection was used, then get back to the original location and remove the PS drive
#before exiting
if( $Server -and $Credential )
{
  Pop-Location
  Remove-PSDrive -name "ADAudit"
}
