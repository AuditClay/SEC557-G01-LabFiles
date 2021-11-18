#Create a predictable "random" number generator so all
#students get the same results
Get-Random -SetSeed 314159 | Out-Null

"#this script creates a table in MySql to demonstrate using tabular data in Grafana"
"create database if not exists grafana;"
"use grafana;"
"create table if not exists serverstats( dateRun date, servername varchar(100), diskfree int, cpuavg int, uptime int);"
"delete from serverstats;"

#Create data for 10 servers for 10 days
for( $day = (Get-Date).addDays(-10); $day -le (Get-date); $day = $day.AddDays(1)){
    for( $i=0; $i -lt 10; $i++){
        #Get today's date with no time 
        $today = Get-Date -Date $day -Format "yyyy-MM-dd"  
        $hostname = "Server$i"
        $diskFree = Get-Random -Minimum 0 -Maximum 100
        $cpuAvg = Get-Random -Minimum 0 -Maximum 100
        $uptimeDays = Get-Random -Minimum 0 -Maximum 365
    
        "insert into serverstats (dateRun, servername, diskfree, cpuavg, uptime) values "
        "('$today', '$hostname', $diskfree, $cpuAvg, $uptimeDays);"
        # "sec557.demo.table.$hostname.diskfree $diskFree $todaySec"
        # "sec557.demo.table.$hostname.cpuavg $cpuAvg $todaySec"
        # "sec557.demo.table.$hostname.uptimedays $uptimeDays $todaySec"
    }
}

"#data in table is:"
"select * from serverstats;"
<#
SELECT
  daterun AS "time",
  servername, diskfree,cpuavg,uptime
FROM serverstats
ORDER BY time
#>