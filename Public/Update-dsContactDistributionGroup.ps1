#Requires -Version 3.0
function Update-dsContactDistributionGroup
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
      [string]$csvfile
    )

    Begin
    {
      New-dsEXOConnection
      #$allcontacts = Get-Contact -ResultSize unlimited
      $allcontacts = Import-Csv -Path $csvfile | Where-Object {$_.Email -ne ''}
    }
    Process
    {
    $unknownroles=@()  
    Foreach($contact in $allcontacts){
       # $group = $null
        Switch($contact.role.trim()){
          'District Assistant Commissioner (Section) - Beaver Scouts' {$group = 'EveryADCBeavers@devonscouts.org.uk'
          Write-Verbose "Adding $($contact.Email) to ADC Beavers Group"}
          'District Asst Commiss (Section) - Beaver Scouts' {$group = 'EveryADCBeavers@devonscouts.org.uk'
          Write-Verbose "Adding $($contact.Email) to ADC Beavers Group"}
          'ADC Beavers' {$group = 'EveryADCBeavers@devonscouts.org.uk'
          Write-Verbose "Adding $($contact.Email) to ADB Beavers Group"}
          'Assistant District Commissioner (Section) - Cub Scouts' {$group = 'everyadccubs@devonscouts.org.uk'
          Write-Verbose "Adding $($contact.Email) to ADC Cubs Group"}
          'District Assistant Commissioner (Section) - Cub Scouts' {$group = 'everyadccubs@devonscouts.org.uk'
          Write-Verbose "Adding $($contact.Email) to ADC Cubs Group"}
          'District Asst Commissioner (Section) - Cub Scouts' {$group = 'everyadccubs@devonscouts.org.uk'
          Write-Verbose "Adding $($contact.Email) to ADC Cubs Group"}
          'District Assistant Commissioner (Section) - Scouts' {$group = 'everyadcscouts@devonscouts.org.uk'
          Write-Verbose "Adding $($contact.Email) to ADC Scouts Group"}
          'District Section Leader - Beaver Scouts' {$group = 'everybsl@devonscouts.org.uk'
          Write-Verbose "Adding $($contact.Email) to Every BSL Group"}
          'Section Leader - Beaver Scouts' {$group = 'everybsl@devonscouts.org.uk'
          Write-Verbose "Adding $($contact.Email) to Every BSL Group"}
          'District Section Leader - Cub Scouts' {$group = 'everycsl@devonscouts.org.uk'
          Write-Verbose "Adding $($contact.Email) to Every CSL Group"}
          'Section Assistant - Cub Scouts'  {$group = 'everycsl@devonscouts.org.uk'
          Write-Verbose "Adding $($contact.Email) to Every CSL Group"}
          'District Section Leader - Scouts' {$group = 'everysl@devonscouts.org.uk'
          Write-Verbose "Adding $($contact.Email) to Every SL Group"}
          'Section Leader - Scouts' {$group = 'everysl@devonscouts.org.uk'
          Write-Verbose "Adding $($contact.Email) to Every SL Group"}
          'County Executive Committee Member' {$group = 'everyexecmember@devonscouts.org.uk'
          Write-Verbose "Adding $($contact.Email) to Every Exec Member Group"}
          'District Executive Committee Member'{$group = 'everyexecmember@devonscouts.org.uk'
          Write-Verbose "Adding $($contact.Email) to Every Exec Member Group"}
          'Group Executive Committee Member' {$group = 'everyexecmember@devonscouts.org.uk'
          Write-Verbose "Adding $($contact.Email) to Every Exec Member Group"}
          Default {$unknownroles += [pscustomobject]@{"Role" = $contact.role}
          Write-Host "Unknown match for role $($contact.Role)"}
        }
        If($group){
          Try {
            Add-DistributionGroupMember -Identity $group -Member $contact.Email -ErrorAction SilentlyContinue
          } Catch {
          }
          $group = $null
          
        }
      }
      $unknownroles | Group-Object -Property Role | Select-Object -Property Name, Count | sort-object -Property Count -Descending
    }
    End
    {
    }
}