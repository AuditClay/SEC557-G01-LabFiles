#Get a list of hosts (usually by querying AD or the inventory database)
$hostList = 'badhost','localhost','winDC', 'win10'

#Parallel-process the hosts for better performance - note that results may not come back in predictable order
$hostList | Foreach -parallel { 
    #Don't clutter the output with errors for non-responsive hosts. Just set their patch age to -1
    #to signal that they were unreachable
    $ErrorActionPreference = "SilentlyContinue"
    
    #Gather patch velocity for the current host
    $patchDates = $null
    $patchDates = (Get-HotFix -ComputerName $_ | Group-Object InstalledOn)
    $source = $_

    #If the host was reachable and returned a result output it to the pipeline
    if( $patchDates) {
        $patchDates | 
          Select-Object @{n='Source';e={$source}}, `
          @{n='Date';e={(Get-Date -Date $_.Name).ToShortDateString()}}, `
          @{n='PatchCount';e={$_.Count}}
    }
   
    $ErrorActionPreference = "Continue"
}