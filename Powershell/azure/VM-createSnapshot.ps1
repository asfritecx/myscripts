<#
Explanation:    
This Script will enumerate the disks on an Azure VM automatically and take a snapshot of each disks and store in in the TempRG folder

Usage:  Fill in the below and replace the 3 fields
    - sourceSubscription = 'a1234b5678-ab12-1234-ab12-abcdef12345'
    - sourceRG           = 'The Resource Group Of The VM Here'
    - sourceVmName       = 'The VM Name Here'
#>

# Script Variables
$script:scriptParamsSplat = @{
    sourceSubscription = 'a1234b5678-ab12-1234-ab12-abcdef12345'
    sourceRG           = 'The Resource Group Of The VM Here'
    sourceVmName       = 'The VM Name Here'
    location           = 'southeastasia'
    TempRG             = 'TempRG'
}

# Sets the script parameters such that they are accessible within the function
function Set-ScriptParameters {
    [CmdletBinding(PositionalBinding=$false)]
    param (
        [Parameter(Mandatory=$true)]
        [string]$sourceSubscription, 

        [Parameter(Mandatory=$true)]
        [string]$sourceRG,

        [Parameter(Mandatory=$true)]
        [string]$sourceVmName,

        [Parameter(Mandatory=$true)]
        [string]$location,

        [Parameter(Mandatory=$false)]
        [string]$TempRG
    )

    [string]$script:sourceSubscription = $sourceSubscription
    [string]$script:sourceRG = $sourceRG
    [string]$script:sourceVmName = $sourceVmName
    [string]$script:location = $location
    [string]$script:TempRG = $TempRG

}

# Enumerates the disk available on a VM and Snapshot each of them
function Create-Snapshot {
    [CmdletBinding(PositionalBinding=$false)]
    param (
        [Parameter()]
        [string]$sourceRG,

        [Parameter()]
        [string]$sourceVmName,

        [Parameter()]
        [string]$location
    )

    # Grab The VM Object in the source subscription
    $vm = Get-AzVM -ResourceGroupName $sourceRG -Name $sourceVmName
    $osSSName = Get-AzResource -Id $vm.StorageProfile.OsDisk.ManagedDisk.Id
    
    # Snapshot OSDisk & store it in TempRG Resource Group
    $snapshot = New-AzSnapshotConfig -SourceUri $vm.StorageProfile.OsDisk.ManagedDisk.Id -Location $location -CreateOption copy
    New-AzSnapshot -Snapshot $snapshot -SnapshotName "$($osSSName.Name)-osdisk-snapshot" -ResourceGroupName $TempRG
    
    # Snapshot Data Disks & store it in TempRG Resource Group
    $getSourceVMDatadisksId = $vm.StorageProfile.DataDisks.ManagedDisk.Id
    $datadisklunnumber = 0
    foreach ($item in $getSourceVMDatadisksId) {
        $datadiskSnapshot = New-AzSnapshotConfig -SourceUri $item -Location $location -CreateOption copy
        New-AzSnapshot -Snapshot $datadiskSnapshot -SnapshotName "$($sourceVmName)-datadisk-lun$($datadisklunnumber)-snapshot" -ResourceGroupName $TempRG
        $datadisklunnumber++
    }
    
}

function Initiate-Script {

    $createSnapshotSplat = @{
        sourceRG           = "$sourceRG"
        sourceVmName       = "$sourceVmName"
        location           = "$location"
    }

        # Check TempRG Exists
        $rgCheck = Get-AzResourceGroup -Name $TempRG -ErrorAction SilentlyContinue
        if ($rgCheck) {
            Write-Host 'TempRG Exists Creating Snapshots'
            try {
                Create-Snapshot @createSnapshotSplat
            }
            catch {
                Write-Error "Error:`n $_"
            }
        }
        else {
            Write-Host "TempRG doesn't exists creating"
            try {
                New-AzResourceGroup -Name $TempRG -Location $location
                Create-Snapshot @createSnapshotSplat
            }
            catch {
                Write-Error "Error:`n $_"
            }
        } 
}

# Script Execution 
try {
    Set-ScriptParameters @scriptParamsSplat
    Select-AzSubscription -subscriptionid $sourceSubscription
    Initiate-Script
} catch {
    Write-Error "An Error Was Encountered See Below: `n $_"
}