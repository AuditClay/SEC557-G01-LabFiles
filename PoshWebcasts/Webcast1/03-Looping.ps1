
#standard FOR loop - similar to other languages
for($x=20;$x -lt 30;$x++) {
  Invoke-Expression "ping -n 1 127.0.1.$x"
}

#For-each loop allows looping through items in a collection
#Foreach is a language contruct (loop type) and also an alias for ForEach-Object
#Here it is as a loop...BTW the Write-Host is usually optional, too...
Foreach( $svc in (Get-Service) ) {
  Write-Host ($svc.Name).ToUpper()
}

#Here it is as an alias for ForEach-Object
Get-Service | ForEach {
  $_.Name.ToUpper()
}

#Equivalent of this
Get-Service | Foreach-Object {
  $_.Name.ToUpper()
}

#If statements allow for conditional execution of commands
ForEach( $svc in (Get-Service) ) {
  if( $svc.Status -eq 'Running') {
    Write-Host -BackgroundColor white -ForegroundColor DarkGreen ($svc.Name).ToUpper()
  }
  else {
    Write-Host -BackgroundColor white -ForegroundColor Red ($svc.Name).ToLower()
  }
}

clear-host