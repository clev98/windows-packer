#install-cloudbase.ps1 - used to install the cloudbaseinit setup file.
#	Notice the $env:PACKER_HTTP_ADDR - this file is designed to be run
#	as a script in packer, with this variable set, to pull from a packer
#	http server
#author - connor shade

$url="http:\\$Env:PACKER_HTTP_ADDR/cloudbaseInitSetup.msi"
$outfile="C:\Users\$Env:USERNAME\Desktop\cloudbaseInitSetup.msi"
try {
	Invoke-WebRequest -UseBasicParsing $url -OutFile $outfile
} catch {
	(new-object System.Net.WebClient).DownloadFile($url, $output)
}
# This function was taken from stackoverflow
function Get-InstalledApps
{
    if ([IntPtr]::Size -eq 4) {
        $regpath = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
    }
    else {
        $regpath = @(
            'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
            'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
        )
    }
    Get-ItemProperty $regpath | .{process{if($_.DisplayName -and $_.UninstallString) { $_ } }} | Select DisplayName, Publisher, InstallDate, DisplayVersion, UninstallString |Sort DisplayName
}

$result = Get-InstalledApps | where {$_.DisplayName -like "*Cloudbase-Init*"}
msiexec /i $outfile /qn /l*v log.txt

# wait until the install finished
while ($result -eq $null) {
    sleep 5
	$result = Get-InstalledApps | where {$_.DisplayName -like "*Cloudbase-Init*"}
}

# Set service startup type
$cloud = Get-service "*Cloudbase-init*"
$cloud | set-service -startuptype automatic
#$cloud | start-service
Remove-item $outfile