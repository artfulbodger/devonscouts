#Requires -Version 3
function Test-dsMailContactExists
{
  <#
      .SYNOPSIS
      Describe purpose  "Test-dsMailCOntactExists" in 1-2 sentences.

      .DESCRIPTION
      Add a more complete description of what the function does.

      .PARAMETER emailaddress
      Describe parameter -emailaddress.

      .EXAMPLE
      Test-dsMailCOntactExists -emailaddress Value
      Describe what this call does

      .NOTES
      Place additional notes here.

      .LINK
      URLs to related sites
      The first link is opened by Get-Help -Online Test-dsMailCOntactExists

      .INPUTS
      List of input types that are accepted by this function.

      .OUTPUTS
      List of output types produced by this function.
  #>


    [CmdletBinding()]
    [OutputType([boolean])]
    Param
    (
        [Parameter(Mandatory)][string]$emailaddress
    )

    Begin
    {
      New-dsEXOConnection
    }
    Process
    {
      Write-Debug -Message "Testing contact $emailaddress"
      $contact = Get-MailContact -Identity $emailaddress -ErrorAction SilentlyContinue
        If ($contact -ne $Null) { 
          Write-Debug -Message "Contact $($contact.Name) exists in Office365"
          Return $true
        } Else {
          Write-Debug -Message "No contact found with emailaddress $emailaddress in Office365"
          Return $false
        }
    }
    End
    {
    }
}