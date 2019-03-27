function Write-dsLogMessage
{
    [CmdletBinding()]
    Param
    (
        [parameter(mandatory)][string]$message,
        [parameter()][string]$level='Info'
    )

    Begin
    {
      $suffix = get-date -Format 'yyyyMMdd'
      $timestamp = Get-date -Format 'HH:mm:ss'
      $file = "$env:ProgramData\DevonScouts\Logs\eventlog-$suffix.txt"
    }
    Process
    {
      If(!(Test-Path -Path $file)){
        $null = New-item -Name eventlog-$suffix.txt -Path $env:ProgramData\DevonScouts\Logs -force
        Add-content -Path $file -Value "$timestamp `t $level `t Log file created."
      }
      Try {
        Add-content -Path $file -Value "$timestamp `t $level `t $message"
      } Catch {
        Write-Debug -Message $_.Exception.Message
      }
    }
    End
    {
    }
}