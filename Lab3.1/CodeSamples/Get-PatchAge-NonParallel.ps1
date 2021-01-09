#Get a list of hosts (usually by querying AD or the inventory database)
$hostList = 'badhost','localhost','winDC', 'win10'

#Parallel-process the hosts for better performance - note that results may not come back in predictable order
$hostList | ForEach-Object  { 
    #Don't clutter the output with errors for non-responsive hosts. Just set their patch age to -1
    #to signal that they were unreachable
    $ErrorActionPreference = "SilentlyContinue"
    
    #Calculate the last patch date for the current host
    $lastPatchDate = (Get-HotFix -ComputerName $_ | Sort-Object InstalledOn -Descending | Select-Object -First 1).InstalledOn

    #If the host was reachable and returned a result store it. Otherwise indicate the error with a value of -1
    if( $lastPatchDate) {
        $patchAge = [int](New-TimeSpan -Start $lastPatchDate -End (Get-Date)).TotalDays
    }
    else {
        $patchAge = -1
    }

    #build the output object
    $patchAgeRecord = [PSCustomObject]@{
        'Source' = $_
        'PatchAge' = $patchAge
        'DateRun' = (Get-Date).ToShortDateString()
    }
    #Send the output object to the pipeline
    $patchAgeRecord
    $ErrorActionPreference = "Continue"
}