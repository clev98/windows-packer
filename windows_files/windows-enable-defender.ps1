#   Description:
# This script disables Windows Defender. Run it once (will throw errors), then
# reboot, run it again (this time no errors should occur) followed by another
# reboot.

### Taken from https://raw.githubusercontent.com/W4RH4WK/Debloat-Windows-10/master/lib/force-mkdir.psm1
# Included in-script because Packer doesn't execute all scripts in same context, so I couldn't easily import this
# Thanks to raydric, this function should be used instead of `mkdir -force`.
#
# While `mkdir -force` works fine when dealing with regular folders, it behaves
# strange when using it at registry level. If the target registry key is
# already present, all values within that key are purged.
function force-mkdir($path) {
    if (!(Test-Path $path)) {
        #Write-Host "-- Creating full path to: " $path -ForegroundColor White -BackgroundColor DarkGreen
        New-Item -ItemType Directory -Force -Path $path
    }
}
### End force-mkdir.psm1

### Taken from https://raw.githubusercontent.com/W4RH4WK/Debloat-Windows-10/master/lib/take-own.psm1
# Included in-script because Packer doesn't execute all scripts in same context, so I couldn't easily import this
function Takeown-Registry($key) {
    # TODO does not work for all root keys yet
    switch ($key.split('\')[0]) {
        "HKEY_CLASSES_ROOT" {
            $reg = [Microsoft.Win32.Registry]::ClassesRoot
            $key = $key.substring(18)
        }
        "HKEY_CURRENT_USER" {
            $reg = [Microsoft.Win32.Registry]::CurrentUser
            $key = $key.substring(18)
        }
        "HKEY_LOCAL_MACHINE" {
            $reg = [Microsoft.Win32.Registry]::LocalMachine
            $key = $key.substring(19)
        }
    }

    # get administraor group
    $admins = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-544")
    $admins = $admins.Translate([System.Security.Principal.NTAccount])

    # set owner
    $key = $reg.OpenSubKey($key, "ReadWriteSubTree", "TakeOwnership")
    $acl = $key.GetAccessControl()
    $acl.SetOwner($admins)
    $key.SetAccessControl($acl)

    # set FullControl
    $acl = $key.GetAccessControl()
    $rule = New-Object System.Security.AccessControl.RegistryAccessRule($admins, "FullControl", "Allow")
    $acl.SetAccessRule($rule)
    $key.SetAccessControl($acl)
}

function Takeown-File($path) {
    takeown.exe /A /F $path
    $acl = Get-Acl $path

    # get administraor group
    $admins = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-544")
    $admins = $admins.Translate([System.Security.Principal.NTAccount])

    # add NT Authority\SYSTEM
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($admins, "FullControl", "None", "None", "Allow")
    $acl.AddAccessRule($rule)

    Set-Acl -Path $path -AclObject $acl
}

function Takeown-Folder($path) {
    Takeown-File $path
    foreach ($item in Get-ChildItem $path) {
        if (Test-Path $item -PathType Container) {
            Takeown-Folder $item.FullName
        } else {
            Takeown-File $item.FullName
        }
    }
}

function Elevate-Privileges {
    param($Privilege)
    $Definition = @"
    using System;
    using System.Runtime.InteropServices;

    public class AdjPriv {
        [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
            internal static extern bool AdjustTokenPrivileges(IntPtr htok, bool disall, ref TokPriv1Luid newst, int len, IntPtr prev, IntPtr rele);

        [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
            internal static extern bool OpenProcessToken(IntPtr h, int acc, ref IntPtr phtok);

        [DllImport("advapi32.dll", SetLastError = true)]
            internal static extern bool LookupPrivilegeValue(string host, string name, ref long pluid);

        [StructLayout(LayoutKind.Sequential, Pack = 1)]
            internal struct TokPriv1Luid {
                public int Count;
                public long Luid;
                public int Attr;
            }

        internal const int SE_PRIVILEGE_ENABLED = 0x00000002;
        internal const int TOKEN_QUERY = 0x00000008;
        internal const int TOKEN_ADJUST_PRIVILEGES = 0x00000020;

        public static bool EnablePrivilege(long processHandle, string privilege) {
            bool retVal;
            TokPriv1Luid tp;
            IntPtr hproc = new IntPtr(processHandle);
            IntPtr htok = IntPtr.Zero;
            retVal = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok);
            tp.Count = 1;
            tp.Luid = 0;
            tp.Attr = SE_PRIVILEGE_ENABLED;
            retVal = LookupPrivilegeValue(null, privilege, ref tp.Luid);
            retVal = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);
            return retVal;
        }
    }
"@
    $ProcessHandle = (Get-Process -id $pid).Handle
    $type = Add-Type $definition -PassThru
    $type[0]::EnablePrivilege($processHandle, $Privilege)
}
### End take-own.psm1

Write-Output "Elevating priviledges for this process"
do {} until (Elevate-Privileges SeTakeOwnershipPrivilege)

### Adding this command to try to enable it after disabling it "the right way"
Set-MpPreference -DisableIntrusionPreventionSystem $false -DisableIOAVProtection $false -DisableRealtimeMonitoring $false -DisableScriptScanning $false 

$tasks = @(
    "\Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance"
    "\Microsoft\Windows\Windows Defender\Windows Defender Cleanup"
    "\Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan"
    "\Microsoft\Windows\Windows Defender\Windows Defender Verification"
)

foreach ($task in $tasks) {
    $parts = $task.split('\')
    $name = $parts[-1]
    $path = $parts[0..($parts.length-2)] -join '\'

    Write-Output "Trying to enable scheduled task $name"
    Enable-ScheduledTask -TaskName "$name" -TaskPath "$path"
}

Write-Output "Enabling Windows Defender via Group Policies"
force-mkdir "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows Defender"
Set-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows Defender" "DisableAntiSpyware" 0
Set-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows Defender" "DisableRoutinelyTakingAction" 0
force-mkdir "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows Defender\Real-Time Protection"
Set-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows Defender\Real-Time Protection" "DisableRealtimeMonitoring" 0

Write-Output "Enabling Windows Defender Services"
Takeown-Registry("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WinDefend")
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\WinDefend" "Start" 2
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\WdNisSvc" "Start" 2
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Sense" "Start" 2
Takeown-Registry("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Features")
Set-ItemProperty "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender\Features" "TamperProtection" "5"