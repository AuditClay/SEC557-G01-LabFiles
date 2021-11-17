#Get today's date with no time 
$today = (get-date).ToShortDateString()

#Create a predictable "random" number generator so all
#students get the same results
Get-Random -SetSeed 314159 | Out-Null

"--this script creates a table in MySql to emonstrate using tabular data in Grafana"
"create database tabledemo;"
"use tabledemo;"
"create table if not exists serverstats( dateRun date, servername varchar(100), diskfree int, cpuavg int, uptime int);"
"delete from serverstats;"

#Create data for 10 servers
for( $i=0; $i -lt 10; $i++){
    $hostname = "Server$i"
    $diskFree = Get-Random -Minimum 0 -Maximum 100
    $cpuAvg = Get-Random -Minimum 0 -Maximum 100
    $uptimeDays = Get-Random -Minimum 0 -Maximum 365

    "$hostname,$diskFree,$cpuavg,$uptimeDays"
    "insert into serverstats (dateRun, servername, diskfree, cpuavg, uptime values "
    "('$today', $hostname, $diskfree, $cpuAvg, $uptimeDays);"
    # "sec557.demo.table.$hostname.diskfree $diskFree $todaySec"
    # "sec557.demo.table.$hostname.cpuavg $cpuAvg $todaySec"
    # "sec557.demo.table.$hostname.uptimedays $uptimeDays $todaySec"
}


