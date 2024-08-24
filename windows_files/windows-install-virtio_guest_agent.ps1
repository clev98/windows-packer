$url="http:\\$Env:PACKER_HTTP_ADDR/qemu-ga-x86_64.msi"
$outfile="C:\qemu-ga-x86_64.msi"
Invoke-WebRequest -UseBasicParsing $url -OutFile $outfile

Start-Process -FilePath "C:\qemu-ga-x86_64.msi" -ArgumentList "/install /quiet /norestart" -Wait