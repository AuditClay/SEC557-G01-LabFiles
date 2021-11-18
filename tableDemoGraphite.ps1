#Create a predictable "random" number generator so all
#students get the same results
Get-Random -SetSeed 314159 | Out-Null


#Create data for 10 servers for 10 days
for( $day = (Get-Date).addDays(-10); $day -le (Get-date); $day = $day.AddDays(1)){
    for( $i=0; $i -lt 10; $i++){
        $todaySec = Get-Date -date $day -UFormat %s
        $hostname = "Server$i"
        $diskFree = Get-Random -Minimum 0 -Maximum 100
        $cpuAvg = Get-Random -Minimum 0 -Maximum 100
        $uptimeDays = Get-Random -Minimum 0 -Maximum 365

        "sec557.demo.table.$hostname.diskfree $diskFree $todaySec"
        "sec557.demo.table.$hostname.cpuavg $cpuAvg $todaySec"
        "sec557.demo.table.$hostname.uptimedays $uptimeDays $todaySec"
    }
}
