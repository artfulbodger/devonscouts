
function New-dsUserTeamsCard
{
  <#
    .SYNOPSIS
    Describe purpose of "Verb-Noun" in 1-2 sentences.

    .DESCRIPTION
    Add a more complete description of what the function does.

    .PARAMETER firstname
    Describe parameter -firstname.

    .PARAMETER lastname
    Describe parameter -lastname.

    .PARAMETER role
    Describe parameter -role.

    .PARAMETER membershipnumber
    Describe parameter -membershipnumber.

    .EXAMPLE
    Verb-Noun -firstname Value -lastname Value -role Value -membershipnumber Value
    Describe what this call does

    .NOTES
    Place additional notes here.

    .LINK
    URLs to related sites
    The first link is opened by Get-Help -Online Verb-Noun

    .INPUTS
    List of input types that are accepted by this function.

    .OUTPUTS
    List of output types produced by this function.
  #>


    [CmdletBinding()]
    Param
    (
      [Parameter(Mandatory,HelpMessage='User first name')][string]$firstname,
      [Parameter(Mandatory,HelpMessage='User surname')][string]$lastname,
      [Parameter(Mandatory,HelpMessage='Primary Compass role')][string]$role,
      [Parameter(Mandatory,HelpMessage='Compass Membership Number')][string]$membershipnumber
    )

    Begin
    {
    }
    Process
    {
      $Body = @{
        text = 'Automated tennat activity'
        title ='User Activity'
        themeColor='800080'
        sections = @(
          @{
            activityTitle = 'New O365 User Created'
            activityText = 'A new user has been created using the PowerShell Automation'
          }
          @{
            title = 'Details'
            facts = @(
              @{
                name = 'First Name'
                value = $firstname
              }
              @{
                name = 'Surname'
                value = $lastname
              }
              @{
                name = 'Role'
                value = $role
              }
              @{
                name = 'Membership Number'
                value = $membershipnumber
              }
            )
          }
        )
      } | ConvertTo-Json -Depth 5

      $uri = 'https://outlook.office.com/webhook/4ad2c863-4658-4dc1-ae97-cdc211e1547d@1351267d-8d51-4e96-9069-b13305364b74/IncomingWebhook/7e8f1795df5641cab32beaf1697fb5fc/d853adbe-381e-4400-a375-a75f731c0423'
      $contenttype = 'application/json'
      Try {
        Invoke-RestMethod -Method Post -uri $uri -body $body -ContentType $contenttype
      } Catch {
      }
    }
    End
    {
    }
}
