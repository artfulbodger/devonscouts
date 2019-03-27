function New-dsMailChimpUpdateCard
{
    [CmdletBinding()]
    Param
    (
      [Parameter(Mandatory,HelpMessage='Previous Mailchimp list members Count')][string]$mcprevcount,
      [Parameter(Mandatory,HelpMessage='Removed members count')][string]$removecount,
      [Parameter(Mandatory,HelpMessage='Added members count')][string]$addcount,
      [Parameter(Mandatory,HelpMessage='New Mailchimp list members Count')][string]$mcnewcount
    )

    Begin
    {
    }
    Process
    {
      $Body = @{
        text = 'List - Compass Adults'
        title ='MailChimp Update'
        themeColor='800080'
        sections = @(
          @{
            activityTitle = 'Members added and removed'
            activityText = "$(Get-Date -format 'dd/MM/yyyy HH:mm')"
          }
          @{
            title = 'Update Summary'
            facts = @(
              @{
                name = 'Members removed'
                value = $removecount
              }
              @{
                name = 'Members added'
                value = $addcount
              }
              @{
                name = 'Previous count'
                value = $mcprevcount
              }
              @{
                name = 'New count'
                value = $mcnewcount
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
