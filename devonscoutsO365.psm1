function New-dsO365User
{
  <#
      .SYNOPSIS
      Creates a new Office 365 user and licenses for base services.

      .DESCRIPTION
      Creates a new Office 365 user and grants a new E2 license with unrequire services disabled.

      .NOTES
      Place additional notes here.

      .LINK
      URLs to related sites
      The first link is opened by Get-Help -Online New-dsO365User

      .INPUTS
      List of input types that are accepted by this function.

      .OUTPUTS
      List of output types produced by this function.
  #>

  [CmdletBinding()]
  [OutputType([int])]
  Param
  (
    # Param1 help description
    [Parameter(Mandatory,HelpMessage='User first name')][string]$firstname,
    [Parameter(Mandatory,HelpMessage='User surname')][string]$lastname,
    [Parameter(Mandatory,HelpMessage='Primary Compass role')][string]$role
  )

  Begin
  {
    Connect-MsolService    
    $disabledplans = 'Deskless', 'FLOW_O365_P1', 'POWERAPPS_O365_P1', 'SWAY', 'YAMMER_ENTERPRISE'
    $licenseoptions = New-MsolLicenseOptions -AccountSkuId devonscouts:STANDARDWOFFPACK -DisabledPlans $disabledplans
  }
  Process
  {
    $displayname = "$($firstname) $($lastname)"
    $upn = "$($firstname).$($lastname)@devonscouts.org.uk"
    
    New-MsolUser -UserPrincipalName $upn -FirstName $firstname -LastName $lastname -DisplayName $displayname -Password 'Scoutie1907' -ForceChangePassword $true -LicenseAssignment devonscouts:STANDARDWOFFPACK -LicenseOptions $licenseoptions -UsageLocation GB -Title $role
  }
  End
  {
  }
}