#Requires -version 3.0
function Import-dsContactsFromCompass
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        [string]$csvfile= 'C:\Users\Artfulbodger\Downloads\County Member Directory.csv'
    )

    Begin
    {
      $contacts_list = Import-Csv -Path $csvfile
    }
    Process
    {
      Foreach ($contact in $contacts_list){
        If ($contact.EmailAddress1 -inotlike '*@devonscouts.org.uk'){
          If($contact.EmailAddress1) {
            Write-verbose -Message "Creating contact for $($contact.preferred_forename) $($contact.surname)"
            New-dsMailContact -firstname $contact.preferred_forename -lastname $contact.surname -ExternalEmailAddress $contact.EmailAddress1 -role $contact.Role
            
          } ELSE {
            Write-debug -Message "$($contact.preferred_forename) $($contact.surname) does not have an email address stored in Compass"
          }
          
        } else {
          Write-debug -Message "$($contact.EmailAddress1) is one of ours - no contact required"
        }
      }
    }
    End
    {
    }
}