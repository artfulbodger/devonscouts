#Requires -version 3.0
function Import-dsContactsFromCompass
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        [parameter(Mandatory,HelpMessage='Path to County Member Directory Compass report')][string]$csvfile
    )

    Begin
    {
      $contacts_list = Import-Csv -Path $csvfile
    }
    Process
    { 
      Foreach ($contact in $contacts_list){
        $location = $null
        If ($contact.EmailAddress1 -inotlike '*@devonscouts.org.uk'){
          If($contact.EmailAddress1) {
            Write-verbose -Message "Creating contact for $($contact.preferred_forename) $($contact.surname)"
            If($contact.Scout_Group){
              $location = $contact.Scout_Group
            } elseif ($contact.district) {
              $location = $contact.district
            } elseif ($contact.County) {
              $location = $contact.county
            }
            New-dsMailContact -firstname $contact.preferred_forename -lastname $contact.surname -ExternalEmailAddress $contact.EmailAddress1 -role $contact.Role -membership_number $contact.contact_number -location $location
            
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