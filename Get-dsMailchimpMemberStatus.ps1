#Requires -version 3.0
function Get-dsMailchimpMemberStatus
{
  [CmdletBinding()]
  [OutputType([string])]
  Param
  (
    [Parameter(Mandatory,HelpMessage='Email address to be queried')][string]$emailaddress,
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
  }
  Process
    {
      # Email MD5 hash
      $md5 = new-object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
      $utf8 = new-object -TypeName System.Text.UTF8Encoding
      $emailMD5 = [BitConverter]::ToString($md5.ComputeHash($utf8.GetBytes($emailaddress)))
      $emailMD5 = $emailMD5.ToLower() -replace '-',''
      $wr = Invoke-WebRequest -Uri "https://$($dc).api.mailchimp.com/3.0/lists/$($listID)/members/$($emailMD5)" -Headers $headers -Method GET
      If($wr.StatusCode -eq 200){
        Return ($wr.Content | convertfrom-json).status
      }
  }
    End
    {
    }
}