#Requires -Version 3.0
function Update-dsOffice365fromCompass
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
    )

    Begin
    {
      $O365Contacts = Get-MailContact -ResultSize unlimited
      $compassContacts = Import-Csv -Path 'C:\Users\Artfulbodger\Downloads\2018 08 16 County Appointments Report.csv'
    }
    Process
    {
     Write-Verbose -Message "Found $($compassContacts.count) appointments in Compass Report"
     Write-Verbose -Message "Found $($O365Contacts.count) Mail COntacts in Office365"
    
    Foreach($contact in $compassContacts){
        If(($contact.Email -ne $null) -and ($contact.Email -inotlike '*@devonscouts.org.uk')) {
          If($O365contacts.ExternalEmailAddress -contains "SMTP:$($contact.Email)"){
            Write-Debug -Message "$($contact.Email) is in O365"
            $null = Set-Contact -Identity $contact.Email -Title $contact.role.trim() -Company $contact.location
            If (!($o365contacts | Where-Object { $_.CustomAttribute1 -eq $($contact.membership_number)}).isvalid){
              #Membership number is not stored against a contact - Lets update the contact
              Write-verbose -Message "Updating contact $($contact.Email) - Adding membership number $($contact.membership_number)"
              $null = Set-MailContact -Identity $contact.Email -CustomAttribute1 $contact.membership_number
            } else {
              Write-verbose -Message "Contact $($contact.Email) does not need Membership number updating"
            }
            
          } else {
            Write-Verbose -Message "$($contact.Email) needs importing to O365"
          }
        }
      }
    }
    End
    {
      $O365Contacts = $null
      $compassContacts = $null
    }
}