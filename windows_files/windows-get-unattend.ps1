#get-unattend.ps1 - used to get the unattended file for this machine type,
#	template this file, then save it so sysprep.bat can run it
#author - connor shade

# Download the file
$url="http:\\$Env:PACKER_HTTP_ADDR/unattend.xml"
$outfile="C:\unattend.xml"
Invoke-WebRequest -UseBasicParsing $url -OutFile $outfile

# Template the file
((Get-Content -path $outfile -Raw) -replace "{{MACHINE_NAME}}","$Env:MACHINE_NAME") | Set-Content -Path $outfile