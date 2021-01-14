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