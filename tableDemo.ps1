#Get today's date with no time 
$today = (get-date).ToShortDateString()

#Now, convert it to an epoch time
$todaySec = Get-Date -date $today -AsUTC -UFormat %s

#Create a predictable "random" number generator so all
#students get the same results
Get-Random -SetSeed 314159 | Out-Null

#Create data for 10 servers
for( $i=0; $i -lt 10; $i++){
    $hostname = "Server$i"
    $diskFree = Get-Random -Minimum 0 -Maximum 100
    $cpuAvg = Get-Random -Minimum 0 -Maximum 100
    $uptimeDays = Get-Random -Minimum 0 -Maximum 365

    "sec557.demo.table.$hostname.diskfree $diskFree $todaySec"
    "sec557.demo.table.$hostname.cpuavg $cpuAvg $todaySec"
    "sec557.demo.table.$hostname.uptimedays $uptimeDays $todaySec"
}