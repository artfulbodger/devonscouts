function Remove-dsMailchimpMember
{
  
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
      [Parameter(Mandatory,HelpMessage='Email address to be deleted from Mailchimp List')][string]$emailaddress,
      [string]$listID = 'a512378808',
      [string]$mailchimpAPIKey = 'e8197bfcdd50c5ba7ea60786daabcc88-us13',
      [string]$dc='us13'
    )

    Begin
    {
      $user = 'anystring'
      $pair = "${user}:${mailchimpAPIKey}"
      $bytes = [Text.Encoding]::ASCII.GetBytes($pair)
      $base64 = [Convert]::ToBase64String($bytes)
      $basicAuthValue = ('Basic {0}' -f $base64)
      $headers = @{ Authorization = $basicAuthValue }
      
      # Email MD5 hash
      $md5 = new-object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
      $utf8 = new-object -TypeName System.Text.UTF8Encoding
      $emailMD5 = [BitConverter]::ToString($md5.ComputeHash($utf8.GetBytes($emailaddress)))
      $emailMD5 = $emailMD5.ToLower() -replace '-',''
    }
    Process
    {
      Try {
        $response = Invoke-WebRequest -Uri "https://$($dc).api.mailchimp.com/3.0/lists/$listID/members/$emailMD5" -Headers $headers -Method Delete
      } Catch {
        $response = $_.ErrorDetails.Message | ConvertFrom-Json
        Write-Verbose -Message "$emailaddress - $($response.detail)"
      }
    }
    End
    {
    }
}