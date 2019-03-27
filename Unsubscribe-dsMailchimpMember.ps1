function Unsubscribe-dsMailchimpMember
{
  <#
      .SYNOPSIS
      Unsubscribes the supplied email address fro the List ID provided.

      .DESCRIPTION
      Coonects to MailChimp using the APIKey provided and unsubscribes the Emai laddress from the List ID provided.

      .PARAMETER emailaddress
      Email address to unsubscribe.

      .PARAMETER listID
      Mailchimp list ID to unsubscribe email address from.

      .PARAMETER mailchimpAPIKey
      API Key required to connect to MailChimp account.

      .EXAMPLE
      Unsubscribe-dsMailchimpMember -emailaddress john.dow@example.com -listID 9e67587f52 -mailchimpAPIKey <yourapikey>
      DConnects to MailChimp LIstID 9e67587f52 using the API Key supplied and unsubscribes john.dow@example.com

      .NOTES
      Place additional notes here.

      .LINK
      URLs to related sites
      The first link is opened by Get-Help -Online Unsubscribe-dsMailchimpMember

      .INPUTS
      List of input types that are accepted by this function.

      .OUTPUTS
      List of output types produced by this function.
  #>


    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
      [Parameter(Mandatory,HelpMessage='Email address to be unsubscribed from Mailchimp List')][string]$emailaddress,
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
      If((Get-dsMailchimpMemberStatus -emailaddress $emailaddress) -eq 'subscribed'){
        $Body = @{status = 'unsubscribed'} | ConvertTo-Json -Depth 1
        $contenttype = 'application/json'
        Invoke-RestMethod -Uri "https://$($dc).api.mailchimp.com/3.0/lists/$listID/members/$emailMD5" -Headers $headers -Method Patch -ContentType $contenttype -body $body
      }  
    }
    End
    {
    }
}