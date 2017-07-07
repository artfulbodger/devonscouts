#Requires -Version 3.0
function Get-RoleSummaryFromCompass
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        [string]$csvfile= 'C:\Users\Artfulbodger\Downloads\County Appointments Report v1.1.csv'
    )

    Begin
    {
      $appointments_list =  Import-Csv -Path $csvfile
    }
    Process
    {
      $appointments_list | group-object -Property Role | Select-Object Name,Count | Sort-Object Name | Export-Csv -Path 'C:\Users\Artfulbodger\Downloads\County Appointments Summary.csv' -NoTypeInformation
    }
    End
    {
    }
}