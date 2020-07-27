$rgName = (New-AzureRmResourceGroup -Name 'task-rg-01' -Location 'uksouth' ).ResourceGroupName
$dnsZone ='uk.mycompany.com'
$vmAdminUserName ='adminuser'
$vmAdminPassword ="mypasswordhere
$subscriptionID = (Get-AzureRMContext).Subscription.id
$deployVnet =  "yes"  # FirstDeployment? 'yes' : 'no'

$Script = Invoke-WebRequest 'https://raw.githubusercontent.com/devsheoran/scripts/master/deploy.ps1'
$ScriptBlock = [Scriptblock]::Create($Script.Content)
Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList ($args + @($rgName, $dnsZone, $vmAdminUserName, $vmAdminPassword, $deployVnet ))
