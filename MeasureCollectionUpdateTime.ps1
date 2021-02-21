#Test the time it takes to create a collection und to add a machine by direct membership
#This script is provided as-is without any warrenty 

[CmdletBinding()]
Param
(
    # TestMachine: Any machine that can be added to a collection will do
    [Parameter(mandatory)]
    $TestMachine,
    # Provider: The provider is usually running on the primary
    [Parameter(mandatory)]
    $ProviderMachineName,
    # SiteCode: The 3-letter sitecode that identifies your environment
    [Parameter(mandatory)]
    $SiteCode
)

$TestCollectionName = 'TemporaryPerformanceTestCollection'
$stopwatch = [system.diagnostics.stopwatch]::startNew()

# Customizations
$initParams = @{}

# Import the ConfigurationManager.psd1 module 
if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}

# Connect to the site's drive if it is not already present
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}

# Set the current location to be the site code.
Set-Location "$($SiteCode):\" @initParams

$testcoll = New-CMDeviceCollection -LimitingCollectionId 'SMSDM003' -Name $TestCollectionName

$timeout = $false
$count1 = $count2 = 0

while($count1 -le 300)
{
    $coll = Get-CMDeviceCollection -Name $TestCollectionName   
    if($coll -ne $null)
    {
        Write-Host 'Collection creation succeeded' -BackgroundColor DarkGreen -ForegroundColor White
        Try{
            Add-CMDeviceCollectionDirectMembershipRule -CollectionId $coll.CollectionID -ResourceId (Get-CMDevice -Name $TestMachine).ResourceID  #-Resource $TestMachine #-ErrorAction Stop
        }
        Catch
        {
            Write-Host 'Failed to add $TestMachine to TemporaryPerformanceTestCollection. Please check that the machine exists and that the collection has been created.' -BackgroundColor DarkRed -ForegroundColor Yellow
            Exit
        }

        while($count2 -le 300)
        {
            Try{
            $machine = Get-CMCollectionMember -Name $TestMachine -CollectionName 'TemporaryPerformanceTestCollection'
            }
            Catch{
            Write-Host 'Machine not yet found in collection' -BackgroundColor Black -ForegroundColor Yellow
            }        
            if($machine.Name -ne $null){
                Write-Host '$TestMachine showed up in Collection' -BackgroundColor DarkGreen -ForegroundColor White
                break;
            }
            else
            {
                Write-Host 'Machine did not show up yet, sleeping 2 sec before next check' -BackgroundColor Black -ForegroundColor White
                Sleep -Seconds 2
            }
            $count2++;
        }
        break;
    }
    else
    {
        Write-Host 'Collection is not yet there, sleeping 2 sec before next check' -BackgroundColor Black -ForegroundColor White
        Sleep -Seconds 2
        count1++
    }
}

$stopwatch
Write-Host 'Script ran for' $stopwatch.Elapsed.TotalSeconds 'seconds' -BackgroundColor Black -ForegroundColor White

Remove-CMCollection -Name TemporaryPerformanceTestCollection -Force 

Set-Location "c:"
