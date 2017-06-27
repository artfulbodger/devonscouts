#Requires -version 3.0
#Requires -modules MSOnline
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
      $user = Get-MsolUser -UserPrincipalName $upn -ErrorAction Stop
      If ($user.IsLicensed -eq $false) {       
        # Add license to existing O365 user
        Set-MSOLUser -UserPrincipalName $upn -UsageLocation GB
        Set-MsolUserLicense -UserPrincipalName $upn -LicenseOptions $licenseoptions
      } else {
        # Licensed - now check if license list contains E2 SKU
        $licensedE2 = $false
        Foreach ($license in $user.licenses) {
          If ($license.AccountSkuId -eq 'devonscouts:STANDARDWOFFPACK') {
            $licensedE2 = $true
          }    
        }
        If ($licensedE2 -eq $false) {
          # No E2 SKU license assigned
          Set-MsolUserLicense -UserPrincipalName $upn -LicenseOptions $licenseoptions
        }
      }
    } catch [Microsoft.Online.Administration.Automation.MicrosoftOnlineException] {
      # User not found - go ahead and create user with E2 SKU license
      New-MsolUser -UserPrincipalName $upn -FirstName $firstname -LastName $lastname -DisplayName $displayname -Password 'Scoutie1907' -ForceChangePassword $true -LicenseAssignment devonscouts:STANDARDWOFFPACK -LicenseOptions $licenseoptions -UsageLocation GB -Title $role
    }
  }
  End
  {
  }
}