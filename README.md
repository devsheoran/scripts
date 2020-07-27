# Simple Hub & Spoke topology deployment

This is an example of Hub & Spoke topology deployment using Azure ARM templates & powershell scripts. To use it just execute snippet from starter.ps1 file with proper parameters value.

Successful deployment will provision :
* A resource group. All resources will be provisiong under this resource group
* A Hub vNet and a subnet with one VM (vm-ad-01) in the subnet. This Vm will have static private ip (10.0.0.7)
* Two Spoke vNets with one subnet each. Each Spoke subnet will have two VMs each with dynamic private ip. (vm-spoke-01,vm-spoke-02 & vm-spoke-03, vm-spoke-03)
* Hub vNet will be peered with both spoke subnets
* There will be no peering between two spoke vNets
* Hub VM is our DNS server with static IP 10.0.0.7
* All vNets will be using custom DNS server i.e. 10.0.0.7
* To validate vNet peering and Custom DNS server setup correct, you can try to access (nslookup) VMs using VM Name (e.g. vm-spoke-01.uk.mycompany.com, vm-ad-01.uk.mycompany.com) from other VMs
* As all these VMs have private ip, these VMs will not be accessible publicly. Therefore a jump server is also provisioned which is publicly accessible
* You will need to RDP jump server and from jump server you can RDP all Hub & Spoke VMs
* If you wish to use different names for resources, IP range for vNet/subnet etc. you can update parameters/variables on template azuredeploy.simplehubspoketopology.json

