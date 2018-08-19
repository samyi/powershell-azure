cd C:\repos\powershell-azure\
$configFile = Import-LocalizedData -FileName config.psd1


Function myAzureFunction
{
    Param( 
        [String] $tenantId          = $configFile.TenantId,
        [String] $subscriptionId    = $configFile.SubscriptionId,
        [ValidateSet("login","startup","teardown")][String] $action 
        )

    Process {

        # Log in to Azure account
        if ($action -eq "login" -or $action -eq "startup" ) {Login-AzureRmAccount -TenantId $tenantId -Subscription $subscriptionId}


        if ($action -eq "startup") {

            # --- Resource Group
            $resGrpName = "PrototypeADF-RG"
            $resGrps = Get-AzureRmResourceGroup
            Foreach($resGrp in $resGrps)
            {
                if ($resGrp.ResourceGroupName -eq $resGrpName) {break}
                else { $resGrp = $null }
            }

            if ($resGrp -eq $null)
            {
                $resGrp = New-AzureRmResourceGroup $resGrpName -Location 'East US'
            }

            # No reason to remove resource group
            # Remove-AzureRmResourceGroup "PrototypeADF-RG"

            # $resGrp




            # --- Data Factory
            $datafactoryName = "PrototypeADF-DF"
            $datafactory = Set-AzureRmDataFactoryV2 -ResourceGroupName $resGrp.ResourceGroupName -Location $resGrp.Location -Name $datafactoryName


            



            # # Storage Account
            # $StorageAccountName = Get-AzureRmStorageAccount
            # echo $StorageAccountName.StorageAccountName
            # 
            # Remove-AzureRmStorageAccount -Name cs2c6c5d5ae39d6x4712xacf -ResourceGroupName $resGrp.ResourceGroupName
            # $storageName = New-AzureRmStorageAccount -Name cs2c6c5d5ae39d6x4712xacf -ResourceGroupName cloud-shell-storage-eastus -SkuName Standard_LRS -Location 'East US'
            # 
            # 
            # 
            # Get-AzureRmResourceGroup
            # Remove-AzureRmResourceGroup $resGrpName
        }



        # Teardown
        if ($action -eq "teardown") {
            "Teardown in progress..."
            $result = Remove-AzureRmDataFactoryV2 -Name $datafactory.DataFactoryName -ResourceGroupName $resGrp.ResourceGroupName
            $result = Remove-AzureRmResourceGroup "PrototypeADF-RG"
            "Teardown complete."
        }

    }
}




myAzureFunction -action "startup"
myAzureFunction -action "teardown"











