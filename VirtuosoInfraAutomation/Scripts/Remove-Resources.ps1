#parameters
param(
[Parameter(Mandatory=$true)]
[String]$resourceGroup,
[Parameter(Mandatory=$true)]
[String]$resourcesToRemove,
[Parameter(Mandatory=$true)]
[String]$resourceType,
[String]$serviceBusNamespace
)

$resourceArray = $resourcesToRemove -split ","

switch($resourceType){
    "Microsoft.ServiceBus/Queues"{
        foreach ($resource in $resourceArray)  {
	        $existing= Get-AzServiceBusQueue -ResourceGroup $resourceGroup -NamespaceName $serviceBusNamespace -QueueName $resource -ErrorAction SilentlyContinue
    
            if($existing){
                Remove-AzServiceBusQueue -ResourceGroup $resourceGroup -NamespaceName $serviceBusNamespace -QueueName $resource
                Write-Output "Queue : $resource Deleted Successfully"
            }else{
             Write-Output "Queue: $resource doesn't exist or might have already been deleted."
         }
        }
    }
    default {
        foreach ($resource in $resourceArray)  {
	        $existing = Get-AzResource -Name $resource -ResourceType $resourceType -ResourceGroupName $resourceGroup -ErrorAction SilentlyContinue
    
            if($existing){
                Remove-AzResource -ResourceName $resource -ResourceType $resourceType -ResourceGroupName $resourceGroup -Force
                Write-Output "Resource : $resource Deleted Successfully"
            } else {
             Write-Output "Resource: $resource doesn't exist or might have already been deleted."
         }
        }    
    }
}
