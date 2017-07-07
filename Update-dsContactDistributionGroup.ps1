#Requires -Version 3.0
function Update-dsContactDistributionGroup
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
    )

    Begin
    {
      New-dsEXOConnection
      $allcontacts = Get-Contact -ResultSize unlimited
    }
    Process
    {
      Foreach($contact in $allcontacts){
        $group = $null
        Switch($contact.title){
          "District Assistant Commissioner (Section) - Beaver Scouts" {$group = 'EveryADCBeavers@devonscouts.org.uk'
            Write-host "Adding $($contact.Identity) to ADC Beavers Group"}
          "District Asst Commiss (Section) - Beaver Scouts" {$group = 'EveryADCBeavers@devonscouts.org.uk'
            Write-host "Adding $($contact.Identity) to ADC Beavers Group"}
            'ADC Beavers' {$group = 'EveryADCBeavers@devonscouts.org.uk'
            Write-host "Adding $($contact.Identity) to ADB Beavers Group"}
            'Assistant District Commissioner (Section) - Cub Scouts' {$group = 'everyadccubs@devonscouts.org.uk'
            Write-host "Adding $($contact.Identity) to ADC Cubs Group"}
            'District Assistant Commissioner (Section) - Cub Scouts' {$group = 'everyadccubs@devonscouts.org.uk'
            Write-host "Adding $($contact.Identity) to ADC Cubs Group"}
            'District Asst Commissioner (Section) - Cub Scouts' {$group = 'everyadccubs@devonscouts.org.uk'
            Write-host "Adding $($contact.Identity) to ADC Cubs Group"}
            'District Assistant Commissioner (Section) - Scouts' {$group = 'everyadcscouts@devonscouts.org.uk'
            Write-host "Adding $($contact.Identity) to ADC Scouts Group"}
          Default {Write-Verbose "Unknown match for role $($contact.title)"}
        }
        If($group){
          Try {
            Add-DistributionGroupMember -Identity $group -Member $contact.DistinguishedName
          } Catch {
          }
          
        }
      }
    }
    End
    {
    }
}
#get-contact -ResultSize unlimited | group-object -Property Title | Select-Object Name,Count | Sort-Object Name | ft