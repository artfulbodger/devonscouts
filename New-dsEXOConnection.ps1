#Requires -Version 3.0
function New-dsEXOConnection
{
  <#
      .SYNOPSIS
      Creates a new session for Exchange Online.

      .DESCRIPTION
      Checks is a session with a matching name exists, and if not creates a new session.

      .PARAMETER sessionname
      Override the internal session name used to identify the EXO session during creation.
  #>

    [CmdletBinding()]
    Param
    (
      [string]$sessionname = 'dsEXOConnection'
    )

    Begin
    {
    }
    Process
    {
      Try{
        Get-PSSession -Name $sessionname -ErrorAction stop
      } Catch {
        $UserCredential = Get-Credential
        $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -Name $sessionname -AllowRedirection
        Import-PSSession -Session $Session -AllowClobber
      }
    }
    End
    {
    }
}