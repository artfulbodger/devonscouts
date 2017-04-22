function New-dsO365User
{
  <#
      .SYNOPSIS
      Creates a new Office 365 user and licenses for base services.

      .DESCRIPTION
      Creates a new Office 365 user and grants a new E2 license with unrequire services disabled.

      .PARAMETER firstname
      Users Firstname as defined on Compass.

      .PARAMETER lastname
      Users Lastname as defined on Compass.

      .PARAMETER role
      Users primary role as defined on Compass.

      .EXAMPLE
      New-dsO365User -firstname 'John' -lastname 'Doe' -role 'County Commissioner'
      Creates a new User Called John Doe with an alias of john.doe@devonscouts.org.uk
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
    
    Try {
      Get-MsolUser -UserPrincipalName $upn -ErrorAction Stop
    } catch [Microsoft.Online.Administration.Automation.MicrosoftOnlineException] {
      New-MsolUser -UserPrincipalName $upn -FirstName $firstname -LastName $lastname -DisplayName $displayname -Password 'Scoutie1907' -ForceChangePassword $true -LicenseAssignment devonscouts:STANDARDWOFFPACK -LicenseOptions $licenseoptions -UsageLocation GB -Title $role
    }
  }
  End
  {
  }
}