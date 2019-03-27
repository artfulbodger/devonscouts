#requires -version 3.0
function Update-DistrictGroups
{
  [CmdletBinding()]
  [OutputType([int])]
  Param
  (
    # Param1 help description
    [Parameter(Mandatory)][string]$compassfile
  )

  Begin
  {
    New-dsEXOConnection
    $adultlist = Import-csv -Path $compassfile
    $sl = 'District Section Leader','District Section Leader - Beaver Scouts','District Section Leader - Cub Scouts','District Section Leader - Explorer Scouts','District Section Leader - Explorer Scouts (Yng Leader)','District Section Leader - Scouts','Section Leader','Section Leader - Beaver Scouts','Section Leader - Cub Scouts','Section Leader - Explorer Scouts','Section Leader - Explorer Scouts (Yng Leader)','Section Leader - Scouts'
    $gsl = 'Group Scout Leader','Group Scout Leader (Acting)'
    $i=1
  }
  Process
  {
    Foreach($adult in $adultlist)
    {
      Write-Verbose "Processing appointment $i of $($adultlist.count)"
      $groups = @()
      If($adult.Email)
      {
        Switch($adult.District)
        {
          'North Devon' {
            $groups += 'northdevoneveryone@devonscouts.org.uk'
          }
          'Exmouth And Budleigh Salterton' {
            $groups += 'exbudeveryone@devonscouts.org.uk'
          }
          'Tiverton' {
            $groups += 'tivertoneveryone@devonscouts.org.uk'
          }
          'Torridge' {
            $groups += 'torridgeeveryone@devonscouts.org.uk'
          }
          'East Devon' {
            $groups += 'eastdevoneveryone@devonscouts.org.uk'
          }
          'Mid Devon' {
            $groups += 'middevoneveryone@devonscouts.org.uk'
          }
          'South Hams' {
            $groups += 'southhamseveryone@devonscouts.org.uk'
          }
          'Plympton And Ivybridge' {
            #$groups += ''
          }
          'Plymouth' {
            $groups += 'plymoutheveryone@devonscouts.org.uk'
          }
          'Plymstock' {
            $groups += 'plymstockeveryone@devonscouts.org.uk'
          }
          'West Devon' {
            $groups += 'everywestdevonadult@devonscouts.org.uk'
              
          }
          'Teignbridge' {
            $groups += 'teignbridgeeveryone@devonscouts.org.uk'
            Switch($adult.role)
            {
              {$sl -contains $_} {$groups += 'teignbridgesls@devonscouts.org.uk'}
              {$gsl -contains $_} {$groups += 'teignbridgegsls@devonscouts.org.uk'}
            }
          }
          'Exeter' {
            $groups += 'exetereveryone@devonscouts.org.uk'
            Switch($adult.role)
            {
              {$sl -contains $_} {$groups += 'exetersls@devonscouts.org.uk'}
              {$gsl -contains $_} {$groups += 'exetergsls@devonscouts.org.uk'}
            }
          }
          'Torbay Borough' {
            $groups += 'torbayeveryone@devonscouts.org.uk'
            Switch($adult.role)
            {
              {$sl -contains $_} {$groups += 'torbaysls@devonscouts.org.uk'}
              {$gsl -contains $_} {$groups += 'torbaygsls@devonscouts.org.uk'}
            }
          }
            
        }
        If($groups)
        {
          Foreach($group in $groups){
            Try {
              Write-Debug $group
              Write-Debug $adult.Email
              Add-DistributionGroupMember -Identity $group -Member $adult.Email -ErrorAction Stop
            } Catch {
              Write-verbose -Message "Failed to add $($adult.email) to $($group) - $($_.Exception.Message)"
            }
          }
        }
      }
      $i ++
    }
  }
  End
  {
  }
}