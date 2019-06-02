function New-MailChimpDataSet
{
  <#
      .SYNOPSIS
      Creates a merged data set from the Compass Appointments report and the Membership Directory.

      .DESCRIPTION
      Add the Email address data to each role in the Appointments report for matching membership numbers.

      .PARAMETER membershipdireectory
      Full path to a downloaded copy of the Compass 'Membership Directory Report'.

      .PARAMETER appointmentreport
      Full path to a downloaded copy of the Compass 'Appointment Report'.

      .EXAMPLE
      New-MailChimpDataSet -membershipdireectory 'C:\Downloads\County Member Directory (Updated).csv' -appointmentreport 'C:\Downloads\County Appointments Report (Beta).csv'
      Creates a merged data set from the downloaded reports in the declared file locations.

      .NOTES
      You will need to download the compass reports required before running this code.

      .LINK
      https://artfulbodger.github.io/devonscouts/New-MailChimpDataSet

  #>

  [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
  Param
  (
    [Parameter(Mandatory,HelpMessage='Compass Membership Directory Report')]
      [ValidateScript({
            if(-Not ($_ | Test-Path) ){
              throw 'File or folder does not exist'
            }
            if(-Not ($_ | Test-Path -PathType Leaf) ){
              throw 'The Path argument must be a file. Folder paths are not allowed.'
            }
            if($_ -notmatch '(\.csv)'){
              throw 'The file specified in the path argument must be as csv file'
            }
            return $true 
      })][IO.FileInfo]$membershipdireectory,
    [Parameter(Mandatory,HelpMessage='Compass Appointments Report')]
      [ValidateScript({
            if(-Not ($_ | Test-Path) ){
              throw 'File or folder does not exist'
            }
            if(-Not ($_ | Test-Path -PathType Leaf) ){
              throw 'The Path argument must be a file. Folder paths are not allowed.'
            }
            if($_ -notmatch '(\.csv)'){
              throw 'The file specified in the path argument must be as csv file'
            }
            return $true 
      })][IO.FileInfo]$appointmentreport
  )

  Begin
  {
    $dataset = @()
    $count = 1
  }
  Process
  {
    
    Write-Verbose -Message 'Starting Membership Import'
    $members = Import-csv -Path $membershipdireectory
    Write-Verbose -Message 'Starting Appointments Import'
    $appointments = Import-csv -Path $appointmentreport | where-object {($_.role -notlike "*Occasional Helper")}
    Write-Verbose -Message 'Starting data merge'
    Foreach ($appointment in $appointments){
      Write-Verbose -Message "Processing appointment $count of $($appointments.count)"
      If(($appointment.Member_Number -ne 'Member_Number2') -and ($appointment.Member_Number -ne $null)){
        $member = $members | where-Object {$_.contact_number -eq $appointment.Member_Number}
        $dataset += [pscustomobject]@{
          'preferred_forename' = $appointment.Known_As
          'surname' = $appointment.surname
          'membership_number' = $member.contact_number
          'Role' = $appointment.role
          'District' = $appointment.District
          'Section' = switch -Wildcard (($appointment.role).trim()){'*- Beaver Scouts*'{'Beavers'}'*- Cub Scouts*'{'Cubs'}'*- Scouts*'{'Scouts'}'*- Explorer Scouts*'{'Explorers'}'*Scout Network*'{'Network'}}
          'EmailAddress1' = $member.EmailAddress1     
        }
      }
      $count ++
    }
  }
  End
  {
      $dataset
  }
}