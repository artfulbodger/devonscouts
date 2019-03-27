<#
    .Synopsis
    Short description
    .DESCRIPTION
    Long description
    .EXAMPLE
    Example of how to use this cmdlet
    .EXAMPLE
    Another example of how to use this cmdlet
#>
function Update-dsMailchimpList
{
  [CmdletBinding()]
  [OutputType([int])]
  Param
  (
    [Parameter(Mandatory,HelpMessage='Member Directory Report from Compass')]
      [ValidateScript({
            if(-Not ($_ | Test-Path) ){
              throw "File or folder does not exist"
            }
            if(-Not ($_ | Test-Path -PathType Leaf) ){
              throw "The Path argument must be a file. Folder paths are not allowed."
            }
            if($_ -notmatch "(\.csv)"){
              throw "The file specified in the path argument must be as csv file"
            }
            return $true 
      })][System.IO.FileInfo]$memberdirectory,
      [parameter(ParameterSetName='skipdelete')][switch]$skipdelete,
    [string]$listID = 'a512378808',
    [string]$mailchimpAPIKey = 'e8197bfcdd50c5ba7ea60786daabcc88-us13',
    [string]$dc='us13'
  )

  Begin
  {
    # Authentication
    $user = 'anystring'
    $pair = "${user}:${mailchimpAPIKey}"
    $bytes = [Text.Encoding]::ASCII.GetBytes($pair)
    $base64 = [Convert]::ToBase64String($bytes)
    $basicAuthValue = ('Basic {0}' -f $base64)
    $headers = @{ Authorization = $basicAuthValue }
    # Import Compass report
     $compassmemberlist = Import-csv -path $memberdirectory
     $compassemails = ($compassmemberlist | where-object {$_.Role -notlike '*Occasional Helper'} | where-object {$_.EmailAddress1 -ne ''} | Measure-Object)
     Write-Host "Compass contains $($compassemails.count) email addresses"
  }
  Process
  {
    $wr = $null
    $mailchimppurge = 0
    $mailchimpadd = 0
    #$wr = Invoke-WebRequest -Uri "https://$($dc).api.mailchimp.com/3.0/lists/$listID/members?fields=members.id,members.email_address,members.status&count=4000" -Headers $headers
    #$listmembers = $wr | convertfrom-json
    Write-Host "Getting MailChimp list subscribers"
    $listmembers = Get-dsMailchimpListMembers
    Write-Host "MailChimp list currently has $($listmembers.count) subscribers"
    #region Check mailchimp against compass
    If (-not($skipdelete)){
      #Check that each email address on the mailchimp list exists in the compass reprt, if not delete them from mailchimp list
      Write-Host "Removing email addresses from MailChimp missing from Compass"
      foreach($member in $listmembers){
        If(-not($compassmemberlist.EmailAddress1 -contains $member.email_address)){
          #If(-not($member.status -eq 'cleaned')) {
            #member needs to be delete from the list
            Write-Verbose "Mailchimp list member $($member.email_address) is not in compass - Delete"
            $mailchimppurge ++
            Try {
              # Email MD5 hash
              $md5 = new-object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
              $utf8 = new-object -TypeName System.Text.UTF8Encoding
              $emailMD5 = [BitConverter]::ToString($md5.ComputeHash($utf8.GetBytes($member.email_address)))
              $emailMD5 = $emailMD5.ToLower() -replace '-',''
              $response = Invoke-WebRequest -Uri "https://$($dc).api.mailchimp.com/3.0/lists/$listID/members/$emailMD5" -Headers $headers -Method Delete
              Write-Verbose "$($member.email_address) has been removed from Mailchimp"
            } Catch {
              $response = $_.ErrorDetails.Message | ConvertFrom-Json
              Write-Debug -Message "$($member.email_address) - $($response.detail)"
            }
          #}
        }
      }
      }
      Write-Host "$mailchimppurge email addresses have been removed from Mailchimp"
      
    Write-Host "Adding missing Email addresses to MailChimp"
      Foreach($scouter in $compassmemberlist){
        
        If (-not([string]::IsNullOrEmpty($scouter.EmailAddress1))) {
          Switch -wildcard ($scouter.role) {
            $null
            {Write-Debug -Message "Ignoring - No Email address in Compass"}
            ''
            {Write-Debug -Message "Ignoring - No Email address in Compass"}
            '*Occasional Helper'
            {Write-Debug -Message "Ignoring OH Role"}
            default
            {
              Write-Debug -Message "Checking Non OH Role"
              If(-not($listmembers.email_address -contains $scouter.EmailAddress1)){
                #Compass email is not in mailchimp
                Write-Verbose "$($scouter.EmailAddress1) ($($scouter.role)) is missing from Mailchimp"
                Try {
                  $data = @{
                    email_address = $($scouter.EmailAddress1)
                    status = 'subscribed'
                    merge_fields = @{
                      FNAME = $($scouter.surname)
                      LNAME = $($scouter.preferred_forename)
                    }
                  } | ConvertTo-Json
                  $newmemberresponse = Invoke-WebRequest -Uri "https://$($dc).api.mailchimp.com/3.0/lists/$listID/members" -Method Post -Headers $headers -Body $data
                  $mailchimpadd ++
                } Catch {
                  $newmemberresponse = $_.ErrorDetails.Message | ConvertFrom-Json
                  Write-Debug -Message "Failed to add new Compass member $($scouter.contact_number) - $($newmemberresponse.detail)"
                }
              }
            }
          }
        }        
      }
      Write-Host "$mailchimpadd email addresses have been added to MailChimp"
      New-dsMailChimpUpdateCard -mcprevcount $($listmembers.count) -removecount $mailchimppurge -addcount $mailchimpadd -mcnewcount $($($listmembers.count)+$mailchimpadd-$mailchimppurge) 
      Write-Host "Removed $mailchimppurge enteries from MailChimp"
      Write-Host "Added $mailchimpadd members to MailChimp list"
      Write-Host "MailChimp should now have $($($listmembers.count)+$mailchimpadd-$mailchimppurge) subscribers"
    #endregion
  }
  End
  {
  }
}
