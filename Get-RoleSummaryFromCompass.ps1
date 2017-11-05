#Requires -Version 3.0
function Get-RoleSummaryFromCompass
{
  <#
    .SYNOPSIS
    Generates a grouped summary of all roles from the Compass County Appointments Report.

    .DESCRIPTION
    Generates a grouped summary of all roles with totals for each role sorted alphabetically by role.  THe data is sourced from teh Comapss County APpointments Report.

    .PARAMETER csvfile
    Path to a local copy of the Compass Area/Region/County Appointments Report (usually named 'County Appointments Report %28Beta%29.csv')

    .EXAMPLE
    Get-RoleSummaryFromCompass -csvfile 'C:\County Appointments Report %28Beta%29.csv'

    .NOTES
    Place additional notes here.

    .LINK
    https://github.com/artfulbodger/devonscouts/wiki/Get-RoleSummaryFromCompass

    .INPUTS
    List of input types that are accepted by this function.

    .OUTPUTS
    List of output types produced by this function.
  #>


  [CmdletBinding()]
  [OutputType([int])]
  Param
  (
    [string]$csvfile
  )

  Begin
  {
    $appointments_list =  Import-Csv -Path $csvfile
  }
  Process
  {
    $appointments_list | group-object -Property Role | Select-Object -Property Name,Count | Sort-Object -Property Name
  }
  End
  {
  }
}