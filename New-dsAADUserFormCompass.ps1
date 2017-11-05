#Requires -version 3.0
function New-dsAADUserFormCompass
{
  <#
      .SYNOPSIS
      Describe purpose of "New-dsAADUserFormCompass" in 1-2 sentences.

      .DESCRIPTION
      Add a more complete description of what the function does.

      .PARAMETER compassreport
      Describe parameter -compassreport.

      .EXAMPLE
      New-dsAADUserFormCompass -compassreport Value
      Describe what this call does

      .NOTES
      Place additional notes here.

      .LINK
      URLs to related sites

      The first link is opened by Get-Help -Online New-dsAADUserFormCompass
      .INPUTS
      List of input types that are accepted by this function.

      .OUTPUTS
      List of output types produced by this function.
  #>


    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([int])]
    Param
    (
      [Parameter(Mandatory,HelpMessage='Path to csv copy of County/Area/Region Member Directory Report from Compass')]
      [ValidateScript({Test-Path -Path $_ -PathType 'Leaf'})]
      [ValidatePattern( '\.csv$' )]
      [string]$compassreport 
    )

    Begin
    {
    }
    Process
    {
      $credential = Get-Credential
      $aad = Get-dsAzureADUsersReport -credential $credential
      $compass = Import-CSV -Path $compassreport | Where-Object {(($_.Role -ne 'Group Occasional Helper') -and ($_.Role -ne 'District Occasional Helper') -and ($_.Role -ne 'County Occasional Helper'))}
      $compass | Add-member -MemberType AliasProperty -Name 'Membership Number' -Value 'contact_number'
      $missingaad = Compare-object -ReferenceObject $compass -DifferenceObject $aad -Property 'Membership Number' -PassThru | Where-Object {$_.SideIndicator -eq '<='}
      Write-Verbose -Message "$($missingaad.count) accounts require creating"
      $i = 1
      Foreach($missinguser in $missingaad){
          Write-Verbose -Message "Creating user $i of $($missingaad.count)"
          $firstname = $missinguser.preferred_forename -replace " ",""
          $firstname = $firstname -replace "'",""
          $firstname = $firstname -replace ",",""
          $surname = $missinguser.surname -replace " ",""
          $surname = $surname -replace "'",""
          $surname = $surname -replace ",",""
          New-dsO365User -firstname $firstname.tolower() -lastname $surname -role $missinguser.Role -membershipnumber $missinguser.contact_number -credential $credential -noteamscard      
          $i ++
      }
    }
    End
    {
    }
}