# Script to detach a list of non-datastore iSCSI LUNs from all the hosts in vSphere using their naa numbers
#
# This script is for detaching unused LUNs, i.e. those which show up in the "add storage" list.

# Load the stuff we need
.'C:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1'

# Connect to the vSphere server
$viServer = Read-Host -Prompt 'Enter hostname of vSphere server'
Connect-VIServer -Server $viServer

# Get list of datastores to detach from file
$datastoreNaas = Get-Content -Path "C:\Temp\DatastoresNaasToDetach.txt"

# Get all hosts attached to vSphere server
$vmHosts = Get-VMHost

# Iterate through the hosts...
Foreach($vmHost in $vmHosts)
{
    # Iterate through the datastores to be removed...
    Foreach($datastoreNaa in $datastoreNaas)
    {
        # Use the ID from above to get the UUID of the iSCSI LUN
        $lunUuid = (Get-ScsiLun -VmHost $vmHost -CanonicalName $datastoreNaa).ExtensionData.Uuid

        # What's going on?
        Write-Host "Detaching $lunUuid from $vmHost."

        # Open a connection to the VMware Storage System and detach the LUN from the host using the UUID
        $vmStorage = Get-View $vmHost.Extensiondata.ConfigManager.StorageSystem
        $vmStorage.DetachScsiLun($lunUuid)
    }
}