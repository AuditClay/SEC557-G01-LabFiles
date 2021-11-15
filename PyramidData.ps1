function RandomWalk{
    param(
        $numResults = 52,
        $minResult = 0,
        $maxResult = 6,
        $minOffset = -2,
        $maxOffset = 2
    )
    $returnValue = @()
    $startValue = Get-Random -Minimum $minResult -Maximum $maxResult

    for($i=0; $i -lt $numresults; $i++){
        #"start: $startValue"
        $offset = Get-Random -Minimum $minOffset -Maximum $maxOffset
        #"Offset: $offset"
        $newValue = $startValue + $offset
        if( $newValue -le $minResult ) { $newValue = $minResult }
        if( $newValue -ge $maxResult ) { $newValue = $maxResult}
        $startValue = $newValue
        $returnValue += $newValue
        #"new: $newValue"
    }
    $returnValue
}

#Dump data for on-prem systems first
Get-Random -SetSeed 314159 | out-null
RandomWalk -numResults 52
@('onprem.windows','onprem.linux','onprem.vmware','onprem.docker','onprem.k8s'
  'aws.s3', 'aws.iam', 'aws.lambda', 'aws.rds', 'aws.eks', 'aws.waf', 'aws.cloudfront' ) | 
  ForEach-Object {
    $measurementType = $_
    $numTests = Get-Random -Minimum 15 -Maximum 40
    $maxResults = $numTests
    $failresults = RandomWalk -numResults 52 -maxResult $maxResults
    
    $dateOffset = -365
    foreach( $result in $failresults){
        $epochTime = get-date -date ((get-date).AddDays($dateOffset)) -AsUTC -UFormat %s
        $base = "benchdemo.$measurementType"
        "$base.fail $result $epochTime"
        $numSuccess = $numTests - $result
        "$base.success $numSuccess $epochTime"
        $failPct = [float]$result/[float]$numTests*100.0
        "$base.total $numTests $epochTime"
        "$base.failPct $failPct $epochTime"
        
        $dateOffset += 7
    }
}


