#Requires -version 3
#Requires -module MSOnline
function Set-dsO365UserPassword
{
  <#
      .SYNOPSIS
      Resets O365 User Password and Emails new password to user.

      .DESCRIPTION
      Resets O365 User Password and generates a random password. The user is required to reset the password on next sign in.
      The new password is Emailed to the user via an external email adddress.

      .EXAMPLE
      Set-dsO365UserPassword -Param1 Value -Param2 Value
      Describe what this call does

      .NOTES
      Author:  Richard Carpenter
      GitHub: https://github.com/artfulbodger

      This function uses the SMTP Client Submission Method to send the User Email via the office365 SMTP Relay.
      Sender must have a licensed mailbox in O365.
      Sender msut have SendAs permission on sending mailbox.
      Device or application server must support TLS.
      30 messages sent per minute throttle.

      .LINK
      URLs to related sites
      The first link is opened by Get-Help -Online Verb-Noun

  #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    [OutputType([int])]
    Param
    (
      [parameter(mandatory)][string]$upn,
      [parameter(mandatory)][string]$useremail,
      [parameter(mandatory)][string]$fromemail
    )

    Begin
    {
      [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
      $c = Get-Credential -Message "O365 admin account used to reset passwords.  Must have SendAs permissions on mailbox $fromemail"
    }
    Process
    {
      Try {
        if ($pscmdlet.shouldprocess($upn)) {
          Connect-MsolService -Credential $c -ErrorAction Stop
          $resetresponse = Set-MsolUserPassword -UserPrincipalName $upn -ForceChangePassword $true
          Write-Debug $resetresponse
          $content = Get-content -Path C:\development\devonscouts\templates\passwordrset.html
          $content = $content.replace('%username%',$upn)
          $content = $content.replace('%password%',$resetresponse)
          Send-MailMessage -Credential $c -Body "$content" -Subject 'Devon Scouts Password Reset' -SmtpServer smtp.office365.com -to $useremail -from 'communications@devonscouts.org.uk' -UseSsl -BodyAsHtml
        }
      } Catch {
        Write-Host "Bad Username or Password"
      }
    }
    End
    {
    }
}