#Requires -version 3.0
function Import-dsUsersFromCompass
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        [string]$csvfile = 'C:\Users\Artfulbodger\Downloads\County Member Directory (Updated).csv'
    )

    Begin
    {
      $contacts_list = Import-Csv -Path $csvfile
    }
    Process
    { 
      $o365cred = Get-Credential
      $aaduserlist = Get-dsAzureADUsersReport -credential $o365cred
      $compassuserlist = @()
      $summary = @()
      $createO365 = 0
      $deleteO365 = 0
        
      Foreach ($contact in $contacts_list){
            #New-dsO365User -firstname $contact.'Known As' -lastname $contact.Surname -role $contact.role -membershipnumber $contact.'Membership Number'
            
            If ($contact.Role -match "Occasional Helper"){
              Write-dsLogMessage -message "Skipping $($contact.preferred_forename) $($contact.surname) - Role is $($contact.Role)"
            } else {
            $compassuserlist += [pscustomobject]@{
            
                'Membership Number' = $contact.contact_number
                'Firstname'= $contact.preferred_forename
                'Surname'= $contact.surname
                'Role' = $contact.Role
                'Source' = 'Compass'
                }
              }
      }
      
      $compare = Compare-Object -ReferenceObject $compassuserlist -DifferenceObject $aaduserlist -Property 'Membership Number'
      
      Write-dsLogMessage -message "$($compare.count) differences detected between Compass and Office 365"
      
      Foreach($difference in $compare){
        If($difference.SideIndicator -eq '=>'){
          #Only in Office365
          Write-dsLogMessage -message "Member $($difference.'Membership Number') is not present in Compass Extract - Requires deleting from O365"
          $deleteO365 ++
        } elseif ($difference.SideIndicator -eq '<='){
          #Only in Compass
          Write-dsLogMessage -message "Member $($difference.'Membership Number') is not in O365 - new O365 user required"
          $createO365 ++
        }
      }
      Write-dsLogMessage -message "$deleteO365 Office365 accouts require deleting"
      Write-dsLogMessage -message "$createO365 Office365 accouts require creating"
      
      $summary += [pscustomobject]@{
        'Compass Records' = $compassuserlist.count
        'Office 365 Users' = $aaduserlist.count
        'Differences' = $compare.count
        'Office 365 Deleteions required' = $deleteO365
        'Office 365 Creations required' = $createO365
      }
    }
    End
    {
      #Send-MailMessage -SmtpServer 'devonscouts-org-uk.mail.protection.outlook.com' -To richard.carpenter@devonscouts.org.uk -Body "Test" -Subject 'Compass Sync results' -from 'communications@devonscouts.org.uk' -UseSsl
    }
}