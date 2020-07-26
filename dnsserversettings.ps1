Install-WindowsFeature DNS -IncludeManagementTools
Add-DnsServerPrimaryZone -Name "uk.ntc.com" -ZoneFile "uk.ntc.com.dns"
Add-DnsServerResourceRecordA -Name 'vm-spoke-01' -ZoneName 'uk.ntc.com' -IPv4Address 10.1.0.4
