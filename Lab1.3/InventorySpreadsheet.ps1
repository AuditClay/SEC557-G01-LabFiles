function generateData()
{
        #Mfr, model, Acq date (1-2000), Asset tag, serial, BU
        for( $i = 0; $i -lt 200; ++$i){
            $output = [PSCustomObject]@{
                Manufacturer = "Vendor" + (Get-Random -Minimum 1 -Maximum 4).ToString()
                Model = (Get-Random -Minimum 10 -Maximum 99) * 100
                AcqDate = 0-(Get-Random -Minimum 1 -Maximum 2000)
                AssetTag = Get-Random -Minimum 1000000 -Maximum 9999999
                SerialNumber = (Get-Random -Minimum 100 -Maximum 999).ToString() + "-" + (Get-Random -Minimum 100000 -Maximum 999999).ToString()
            }
            $output
        }
}

$outputFileName = ".\Inventory.xlsx"

if( Test-Path -Path $outputFileName)
{
    Remove-Item $outputFileName
}

foreach ($tab in "Servers","Workstations","Network") {
    $fileName = "$tab.csv"

    $data = Import-Csv -Path $fileName
    $data | 
      Select-Object Manufacturer, Model, `
      @{n='AcqDate';e={((Get-Date).AddDays($_.acqOffset)).ToShortDateString()}}, AssetTag, SerialNumber |
      Export-Excel $outputFileName -WorksheetName $tab -AutoSize -AutoFilter

}

