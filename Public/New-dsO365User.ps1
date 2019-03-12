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
    [Parameter(Mandatory,HelpMessage='Primary Compass role')][string]$role,
    [Parameter(Mandatory,HelpMessage='Compass Membership Number')][string]$membershipnumber,
    [Parameter(Mandatory)][PSCredential]$credential,
    [Parameter()][switch]$noteamscard
  )

  Begin
  {
    #New-dsEXOConnection
    Try {
        Get-MsolDomain -ErrorAction Stop | Out-Null
    } Catch {
        Connect-MsolService -Credential $credential
    }
    $disabledplans = 'Deskless', 'FLOW_O365_P1', 'POWERAPPS_O365_P1', 'SWAY', 'YAMMER_ENTERPRISE', 'PROJECTWORKMANAGEMENT', 'FORMS_PLAN_E1', 'STREAM_O365_E1', 'SHAREPOINTWAC', 'MCOSTANDARD', 'SHAREPOINTSTANDARD'
    $licenseoptions = New-MsolLicenseOptions -AccountSkuId devonscouts:STANDARDWOFFPACK -DisabledPlans $disabledplans
    Connect-AzureAD -Credential $credential | Out-Null
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
        Start-Sleep -s 3
        Set-AzureADUserExtension -ObjectId $upn -ExtensionName "extension_f78b8b10d59f499ca99da2acdc29191b_membership_number" -ExtensionValue $membershipnumber
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
          Set-AzureADUserExtension -ObjectId $upn -ExtensionName "extension_f78b8b10d59f499ca99da2acdc29191b_membership_number" -ExtensionValue $membershipnumber
        }
      }
    } catch [Microsoft.Online.Administration.Automation.MicrosoftOnlineException] {
      # User not found - go ahead and create user with E2 SKU license
      Try {
        New-MsolUser -UserPrincipalName $upn -FirstName $firstname -LastName $lastname -DisplayName $displayname -Password 'Scoutie1907' -ForceChangePassword $true -LicenseAssignment devonscouts:STANDARDWOFFPACK -LicenseOptions $licenseoptions -UsageLocation GB -Title $role
        Start-Sleep -s 3
        Set-AzureADUserExtension -ObjectId $upn -ExtensionName "extension_f78b8b10d59f499ca99da2acdc29191b_membership_number" -ExtensionValue $membershipnumber
        If($noteamscard) {
        
        } else {
          New-dsUserTeamsCard -firstname $firstname -lastname $lastname -role $role -membershipnumber $membershipnumber
        }
      } Catch {
        $errormessage = $_.Exception.Message
        Write-Host "Failed to create user $upn. $errormessage"
      }
      
    }
  }
  End
  {
  }
}