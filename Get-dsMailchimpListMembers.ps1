#requires -version 4.0

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
function Get-dsMailchimpListMembers
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
      [string]$listID = 'a512378808',
      [string]$mailchimpAPIKey = 'e8197bfcdd50c5ba7ea60786daabcc88-us13',
      [string]$dc='us13',
      [parameter()][int]$batchsize = 100
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
    }
    Process
    {
      # Get the list member count to enable pagination
      $membercount = ($(Invoke-WebRequest -Uri "https://$($dc).api.mailchimp.com/3.0/lists/$($listID)" -Headers $headers).content | ConvertFrom-Json).stats.member_count
      $offset = 0
      $mcmemberlist = @()
      Do {
        $wr = Invoke-WebRequest -Uri "https://$($dc).api.mailchimp.com/3.0/lists/$($listID)/members?status=subscribed&offset=$offset&count=$batchsize" -Headers $headers
        Foreach($member in $(($wr.Content | ConvertFrom-Json).members)){
          $mcmemberlist += [pscustomobject]@{
            'email_address' = $member.email_address
          }
        }
        $offset = $offset + $batchsize
      }
      While ($offset -le $membercount)
    }
    End
    {
      $mcmemberlist
    }
}





