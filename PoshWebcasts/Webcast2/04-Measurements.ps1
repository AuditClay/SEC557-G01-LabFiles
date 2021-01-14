"Demo for SEC557 Classes"

##### NOTE TO CLAY - run this in an elevated terminal. You'll thank me later
#####

"Noted"
#### REGISTRY ######
# Get a list of all the PSDrives on the system
Get-PSDrive

#On Windows PowerShell, this will include registry hives, the certificate store,
#PowerShell aliases and functions, the "Temp" filesystem, maybe Active Directory,
#and even disk drives :)

#Required security settings are often in the registry
#Get a set of values from the registry
Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"

#test a few individual values
(Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa").LimitBlankPasswordUse
(Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa").NoLMHash
(Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa").RestrictAnonymous

#assign results to a variable for further testing
$res = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa")
$res.LimitBlankPasswordUse

#build the check into an audit script as pass/fail
#for extra credit, check these in a Pester script. 
#See my blog post about Pester from 12 January 2021 sans.org/blog
if( $res.LimitBlankPasswordUse -eq 1 -and $res.NoLMHash -eq 1) { Write-Host "Pass"}

#certificates are also in a drive
#set the location to the trusted root CAs for this machine
Set-Location Cert:\LocalMachine\AuthRoot

#Get a list of the subject names and thumbprints of all the CAs
Get-ChildItem | Select-Object Subject, Thumbprint | Format-List

#Get out of the certificate drive
set-location c:

#There are a host of native commandlet and WMI objects for measuring other
#settings/attributes of Windows systems. A few examples follow:


#### PATCHES (HOTFIXES) ######
#Get a list of all hotfixes installed on the system
Get-HotFix

#Get a feel for "patching velocity" - how often has this machine been patched
Get-HotFix | Group-Object InstalledOn 

#Patch age measurements can help in a pinch
#How many days has it been since the last patch was installed?
$lastPatchDate = (Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 1).InstalledOn

#Calculate the age of the newest patch
(New-TimeSpan -Start $lastPatchDate -End (Get-Date)).TotalDays

#Queries can be run against a remote system
#Start by getting a set of credentials since I'm not a member of the domain
$cred = Get-Credential -UserName auditor -Message "Enter your password"

#Query the remote machine using the credentials
Get-HotFix -ComputerName 10.50.7.10 -Credential $cred 

#### LOCAL SECURITY POLICY ######
#It's not all saved in the registry. Some is "inside" LSASS
#The ancient SecEdit tool (Security Configuration and Analysis)
#Let's us query local security policy settings and export to a file
SecEdit.exe /export /cfg .\localSecPol.txt

#Contents are a text file which you can easily search
Get-Content .\localSecPol.txt

#To look for an individual setting, use Select-String (think grep)
#Let's find the minimum password age for local accounts:

Get-Content .\localSecPol.txt | Select-String '^MinimumPassword'


#### INSTALLED SOFTWARE ######
#grab a list of all installed software on a system (might take a few seconds)
Get-CimInstance Win32_Product

#What properties are available for us to query?
Get-CimInstance Win32_Product | Get-Member

#Get just the name, version and install date for each
Get-CimInstance Win32_Product | Format-List Name, Version, InstallDate 

#This only shows software installed with the MSI subsystem. This machine has Firefox, 
#but it was installed with a package manager and it won't show up
Get-CimInstance Win32_Product | Where-Object Name -like "*firefox*"  

#A better trick is to iterate the registry looking for uninstall keys left behind
#by installation packages. 
#Check the 32-bit and 64-bit installation pats
Get-Content .\InstalledSoftware.ps1

#Results look like this:
.\InstalledSoftware.ps1
