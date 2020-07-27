param ($rgName, $dnsZone, $vmAdminUserName, $vmAdminPwd, $deployCustomScriptExtension)

if($deployCustomScriptExtension -eq "no")
{
 return 'Custom Script Extension has already been installed. Set $deployCustomScriptExtension to "yes" if you want to deploy again. '
}

$Vms = Get-AzureRmVM -ResourceGroupName $rgName
[string]$templateUri = "https://raw.githubusercontent.com/devsheoran/scripts/master/azuredeploy.customextension.json"
$vmAdminPassword=(ConvertTo-SecureString $vmAdminPwd -AsPlainText -Force)
$subscriptionID = (Get-AzureRMContext).Subscription.id
$zonefile = $dnsZone + ".dns"
$extensionScriptHub ="powershell.exe Add-DnsServerPrimaryZone -Name" + " " + $dnsZone  + " " +"-ZoneFile"+ " " + $zonefile + ";"
$extensionScriptHubForwardLookup=''

#Enable DNS Feature and Create DNS Zone
DeployCustomScript $rgName $templateUri $extensionScriptHub

foreach($vm in $Vms)
{
$nic = Get-AzureRmNetworkInterface -ResourceGroupName $rgName -Name  ($vm.Name + "-nic") 
$extensionScriptHubForwardLookup =""
   if ($vm.Name -like '*-ad-*')
  {
    $vmSubnetIdHub=$nic.IpConfigurations[0].Subnet.Id
    $vmStaticIPHub=$nic.IpConfigurations[0].PrivateIpAddress
    $vmNameHub=$vm.Name 
    $vmSizeHub=$vm.HardwareProfile.VmSize
   
    $extensionScriptHubForwardLookup = [string]::Concat("powershell.exe Add-DnsServerResourceRecordA -Name" + " " + $vm.Name  + " " + "-ZoneName" + " " + $dnsZone+ " " +"-IPv4Address" + " " + $nic.IpConfigurations[0].PrivateIpAddress + "; ")
 
    #DNS Forward lookup for Hub VM
    DeployCustomScript $rgName $templateUri $extensionScriptHubForwardLookup
    
  }
  if ($vm.Name -like '*-spoke-*')
  {   
    $extensionScriptHubForwardLookup = [string]::Concat("powershell.exe Add-DnsServerResourceRecordA -Name" + " " + $vm.Name  + " " + "-ZoneName" + " " + $dnsZone+ " " +"-IPv4Address" + " " + $nic.IpConfigurations[0].PrivateIpAddress + "; ")
    
    #DNS Forward lookup for spoke VMs
    DeployCustomScript $rgName $templateUri $extensionScriptHubForwardLookup
  
  }
}

function DeployCustomScript($rgName,$templateUri,$customScript)
{

$parameters = @{}
$parameters.Add(“vmAdminUsername”, $vmAdminUserName)
$parameters.Add(“vmAdminPassword”, $vmAdminPassword)
$parameters.Add(“vmSubnetId”, $vmSubnetIdHub )
$parameters.Add(“vmStaticIP”, $vmStaticIPHub )
$parameters.Add("vmName", $vmNameHub)
$parameters.Add("vmSize", $vmSizeHub)
$parameters.Add("extensionScript",$customScript)  
New-AzureRmResourceGroupDeployment -ResourceGroupName $rgName  -TemplateFile $templateUri -TemplateParameterObject $parameters -Verbose
}




