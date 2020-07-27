param ($rgName, $dnsZone)

$Vms = Get-AzureRmVM -ResourceGroupName $rgName

$templateUri = "C:\repo\ntc\ntc.infra\ntc.infra\ARM-Templates\azuredeploy.customextension.json"


$vmAdminUserName ='adminuser'
$vmAdminPassword=(ConvertTo-SecureString "P1sswor4@2020" -AsPlainText -Force)
$subscriptionID = (Get-AzureRMContext).Subscription.id
$extensionScriptHub ="powershell.exe"

foreach($vm in $Vms)
{
$nic = Get-AzureRmNetworkInterface -ResourceGroupName $rgName -Name  ($vm.Name + "-nic") 
  if($vm.Name -eq 'vm-ad-01')
  {
    $vmSubnetIdHub=$nic.IpConfigurations[0].Subnet.Id
    $vmStaticIPHub=$nic.IpConfigurations[0].PrivateIpAddress
    $vmNameHub=$vm.Name 
    $vmSizeHub=$vm.HardwareProfile.VmSize
    
  }
  if ($vm.Name -like '*-spoke-*')
  {
    $vm.Name 
    $extensionScriptHub +=" Add-DnsServerResourceRecordA -Name " + $vm.Name  +" -ZoneName " + $dnsZone +" -IPv4Address " + $nic.IpConfigurations[0].PrivateIpAddress + "; " 
  }
}


$parameters = @{}
$parameters.Add(“vmAdminUsername”, $vmAdminUserName)
$parameters.Add(“vmAdminPassword”, $vmAdminPassword)
$parameters.Add(“vmSubnetId”, $vmSubnetIdHub )
$parameters.Add(“vmStaticIP”, $vmStaticIPHub )
$parameters.Add("vmName", $vmNameHub)
$parameters.Add("vmSize", $vmSizeHub)
$parameters.Add("extensionScript",$extensionScriptHub)


New-AzureRmResourceGroupDeployment -ResourceGroupName $rgName  -TemplateFile $templateUri -TemplateParameterObject $parameters -Debug  -Verbose
