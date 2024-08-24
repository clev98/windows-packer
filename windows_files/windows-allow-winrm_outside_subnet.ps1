New-NetFirewallRule -DisplayName "Winrm Outside Subnet TCP" -Direction Inbound -Action Allow -LocalPort 5985, 5986 -Profile Any -Protocol tcp
New-NetFirewallRule -DisplayName "Winrm Outside Subnet TCP" -Direction Outbound -Action Allow -LocalPort 5985, 5986 -Profile Any -Protocol tcp
New-NetFirewallRule -DisplayName "Winrm Outside Subnet UDP" -Direction Inbound -Action Allow -LocalPort 5985, 5986 -Profile Any -Protocol udp
New-NetFirewallRule -DisplayName "Winrm Outside Subnet UDP" -Direction Outbound -Action Allow -LocalPort 5985, 5986 -Profile Any -Protocol udp