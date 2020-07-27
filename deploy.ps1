param ($rgName, $location, $dnsZone, $vmAdminUserName, $vmAdminPwd, $deployVnet)

Write-Output $rgName
Write-Output $location
Write-Host $dnsZone
Write-Host $vmAdminUserName
Write-Host $vmAdminPwd
Write-Host $deployVnet

New-AzureRmResourceGroup -Name $rgName -Location $location

$templateUri = "https://raw.githubusercontent.com/devsheoran/scripts/master/azuredeploy.simplehubspoketopology.json"
$dnsIdentifier = $dnsZone
$vmAdminUserName =$vmAdminUserName
$vmAdminPassword =(ConvertTo-SecureString $vmAdminPwd -AsPlainText -Force)
$subscriptionID = (Get-AzureRMContext).Subscription.id

$parameters = @{}
$parameters.Add(“vmAdminUsername”, $vmAdminUserName)
$parameters.Add(“vmAdminPassword”, $vmAdminPassword)
$parameters.Add("subscriptionId","$subscriptionID")
$parameters.Add("dnsIdentifier",$dnsIdentifier)
$parameters.Add("deployVnet",$deployVnet)

New-AzureRmResourceGroupDeployment -ResourceGroupName $rgName -TemplateFile $templateUri -TemplateParameterObject $parameters -Verbose

#Set DNS Server - Forward lookup
$Script = Invoke-WebRequest 'https://raw.githubusercontent.com/devsheoran/scripts/master/dnsserversettings.ps1'
$ScriptBlock = [Scriptblock]::Create($Script.Content)
Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList ($args + @($rgName ,$dnsIdentifier,$vmAdminUserName,$vmAdminPassword, $deployVnet))
