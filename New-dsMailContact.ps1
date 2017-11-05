#Requires -version 3.0

function New-dsMailContact
{
  <#
      .SYNOPSIS
      Creates an External Mail contact.

      .DESCRIPTION
      Creates an External Mail contact, and assigns ROle and Location if supplied.

      .PARAMETER ExternalEmailAddress
      Personal EMail address to send Email to.

      .PARAMETER firstname
      Contacts first name.

      .PARAMETER lastname
      Contacts last name.

      .PARAMETER location
      Location where primary role is active.

      .PARAMETER role
      Primary Role stored on Compass.

      .EXAMPLE
      New-dsMailContact -ExternalEmailAddress john.doe@example.com -firstname John -lastname Doe -location Devon -role 'County Commissioner'
      Creates a new contact for John Doe, setting the External Emai laddress to john.doe@example.com. Also sets the Location to Devon and the Title to County Commissioner.
  #>

    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        [Parameter(Mandatory,HelpMessage='Personal EMail address to send Email to')][string]$ExternalEmailAddress,
        [Parameter(Mandatory,HelpMessage='Contacts first name')][string]$firstname,
        [Parameter(Mandatory,HelpMessage='Contacts last name')][string]$lastname,
        [Parameter(Mandatory)][string]$membership_number,
        [string]$location,
        [string]$role
    )

    Begin
    {
      New-dsEXOConnection
    }
    Process
    {
    $newcontact = $null  
    Try {
        If((Get-MailContact -Identity "$ExternalEmailAddress" -ErrorAction 'SilentlyContinue').IsValid){
          Write-verbose -message "Contact $($firstname) $($lastname) Already Exists"
          Write-verbose -Message "Updating Contact $($firstname) $($lastname) - $role ($location)"
          $null = Set-Contact -Identity $ExternalEmailAddress -Title $role.trim() -Company $location
          $null = Set-MailContact -Identity $ExternalEmailAddress -CustomAttribute1 $membership_number
        } else {
          $newcontact = New-MailContact -DisplayName "$firstname $lastname" -ExternalEmailAddress $ExternalEmailAddress -FirstName $firstname -LastName $lastname -Name "$firstname $lastname" 
          If(($role -ne $null)){
            Write-Verbose -Message 'We have details of Role and location'
            If($newcontact){
              $null = Set-Contact -Identity $ExternalEmailAddress -Title $role.trim() -Company $location
              $null = Set-MailContact -Identity $ExternalEmailAddress -CustomAttribute1 $membership_number
            }
          }
        }
        
      } Catch {
        
        Write-Verbose -Message $_.Exception.Message
      }  
    }
    End
    {
    }
}