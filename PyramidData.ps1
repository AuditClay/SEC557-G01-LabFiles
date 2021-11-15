$cloudbenchmarks = @(
    'aws.s3',
    'aws.iam', 
    'aws.lambda', 
    'aws.rds', 
    'aws.eks', 
    'aws.waf', 
    'aws.cloudfront' )
$onpremtypes =  @(
    'windows',
    'linux',
    'vmhost',
    'docker',
    'kubernetes'
)
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

$cloudbenchmarks | ForEach-Object {
    $measurementType = $_
    $numTests = Get-Random -Minimum 15 -Maximum 40
    $maxResults = $numTests
    $failresults = RandomWalk -numResults 52 -maxResult $maxResults
    
    $dateOffset = -365
    foreach( $result in $failresults){
        $epochTime = get-date -date ((get-date).AddDays($dateOffset)) -AsUTC -UFormat %s
        $base = "benchdemo.cloud.$measurementType"
        "$base.fail $result $epochTime"
        $numSuccess = $numTests - $result
        "$base.success $numSuccess $epochTime"
        $failPct = [float]$result/[float]$numTests*100.0
        "$base.total $numTests $epochTime"
        "$base.failPct $failPct $epochTime"
        
        $dateOffset += 7
    }
}

#Number of servers to build per category
$numServers=20
#Build up server-level data for on-prem technologies

$onpremtypes | ForEach-Object {
    $measurementType = $_
    $numTests = Get-Random -Minimum 15 -Maximum 40
    $maxResults = $numTests

    for( $i=1; $i-le $numServers; $i++){
        $hostname = "Host$i"
        $failresults = RandomWalk -numResults 52 -maxResult $maxResults
    
        $dateOffset = -365
        foreach( $result in $failresults){
            $epochTime = get-date -date ((get-date).AddDays($dateOffset)) -AsUTC -UFormat %s
            $base = "benchdemo.onprem.$measurementType.$hostname"
            "$base.fail $result $epochTime"
            $numSuccess = $numTests - $result
            "$base.success $numSuccess $epochTime"
            $failPct = [float]$result/[float]$numTests*100.0
            "$base.total $numTests $epochTime"
            "$base.failPct $failPct $epochTime"
            
            $dateOffset += 7
        }
    }

}