"Demo for SEC557 Classes"

"Clay/Carol: Do the VMWare poll"

Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false

#Get a credential to interact with the ESXi server
#Normally you would talk to your VCSA but the commands
#would be about the same
$cred = Get-Credential -UserName root -Message "Enter password"

#sever is using a self-signed certificate so turn off errors
# "Do as i say not as I do"
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

#Connect to the ESXi server
Connect-VIServer -Server esxi1 -Credential $cred

#We'll demonstrate just a few commands to show you the awesome sauce that is PowerCLI
#Start by getting a list of VMs on the host
Get-VM

#Let's see what information is returned by the Get-VM cmdlet
Get-VM | Get-Member 

#Another way to see this information would be to pipe the first returned object 
#through the Format-List cmdlet.
Get-VM | Select-Object -First 1 | Format-List *

#Get only the properties we care about
Get-VM | Select-Object Name, VMHost, NumCpu, CoresPerSocket

#Get-VMHost returns information about the VMWare host machine/config
Get-VMHost -Server esxi1

#Some measurements we can do on a VMWare host
#Validate the DNS settings for a host
Get-VMHost -Server esxi1 | Format-List *

#One of the properties returned is ExtensionData which contains the system settings 
#for the host. If you needed to validate common OS settings like the DNS servers 
#used by the host, the information would be stored in this object.
#Let's see what is available in ExtensionData

(Get-VMHost).ExtensionData

#Config has the interesting configuration information in it. 
#It has a number of sub-objects with the detailed settings.
(Get-VMHost).Extensiondata.Config.Network.DNSConfig

#What porperties does the DNS config have?
(Get-VMHost).Extensiondata.Config.Network.DNSConfig | Get-Member -Type Property

#See if we can retreive the DNS servers
$dnsservers = (Get-VMHost).Extensiondata.Config.Network.DNSConfig | Select-Object -ExpandProperty address

$dnsservers

#Your script could check to see that the correct servers are set:
$dnsservers -contains '8.8.8.8'
$dnsservers -contains '8.8.4.4'

#Validate the NTP server(s) configured for use by the host
Get-VMHost -Server esxi1 | Get-VMHostNtpServer

#Check the service status
Get-VMHost | Get-VMHostService | Where-Object {$_.key -eq "ntpd"} | Select-Object VMHost, Label, Key, Policy, Running, Required

#To consolidate all this into a single query
Get-VMHost | Sort Name | Select Name,   @{N="NTPServer";E={$_ | Get-VMHostNtpServer}}, @{N="ServiceRunning";E={(Get-VmHostService -VMHost $_ | Where-Object {$_.key-eq "ntpd"} ).Running}}, @{N="ServiceRequired";E={(Get-VmHostService -VMHost $_ | Where-Object {$_.key-eq "ntpd"} ).Required}}

#Patch data can be retrieved with the ESXCLI cmdlets
(Get-ESXCli -Server esxi1).software.vib.list()

#Get a count of patches by install date (patch velocity)
(Get-ESXCli -Server esxi1).software.vib.list() | Group-Object InstallDate

#Check the build number of the ESXi installation
(Get-VMHost).Build


"Check it here: https://kb.vmware.com/s/article/2143832"
