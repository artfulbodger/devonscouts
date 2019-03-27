#requires -module AzureAD
function Get-dsAzureADUsersReport
{
  <#
      .SYNOPSIS
      Describe purpose of "Get-dsAzureADUsersReport" in 1-2 sentences.

      .DESCRIPTION
      Add a more complete description of what the function does.

      .EXAMPLE
      Get-dsAzureADUsersReport
      Describe what this call does

      .NOTES
      Place additional notes here.

      .LINK
      URLs to related sites
      The first link is opened by Get-Help -Online Get-dsAzureADUsersReport

      .INPUTS
      List of input types that are accepted by this function.

      .OUTPUTS
      List of output types produced by this function.
  #>


    [CmdletBinding()]
    Param
    (
      [Parameter(Mandatory)]$credential,
      [Parameter(ParameterSetName = 'csvexport')][switch]$csv,
      [Parameter(ParameterSetName = 'csvexport')][string]$csvoutfile,
      [switch]$testdata
    )

    Begin
    {
      Write-dsLogMessage -message "Starting Get-dsAzureADUsersReport" -level 'Debug'  
      Try {
                Get-AzureADTenantDetail -ErrorAction Stop | Out-null
            } Catch {
                Connect-AzureAD -Credential $credential
            }
        $aduserlist = @()
    }
    Process
    {
        If($testdata){
          $adusers = Get-AzureADUser -Top 10 | Where-Object {$_.AssignedLicenses.Count -gt 0} | select-object GivenName, Surname, JobTitle, UserPrincipalName
        } Else {
          $adusers = Get-AzureADUser -All $true | Where-Object {$_.AssignedLicenses.Count -gt 0} | select-object GivenName, Surname, JobTitle, UserPrincipalName
        }
        Write-verbose -Message "Found $($adusers.count) Azure AD Users."
        Write-dsLogMessage -message "Found $($adusers.count) Azure AD Users."
        $i = 1
        $indexcounter = 0
        Foreach ($user in $adusers) {
          Write-verbose -Message "Processing user $i of $($adusers.count)"  
          $member_no = $null
            Try {
              $member_no = (Get-AzureADUserExtension -ObjectId $user.UserPrincipalName).get_item('extension_f78b8b10d59f499ca99da2acdc29191b_membership_number')
              $aduserlist += [pscustomobject]@{
                'Index' = $indexcounter
                'Membership Number' = $member_no
                'Firstname'=$user.GivenName
                'Surname'=$user.Surname
                'Role' = $user.JobTitle
                'UPN' = $user.UserPrincipalName
                'Source' = 'AAD'
                }
              $indexcounter ++
            } Catch {
              Write-dsLogMessage -message "$($user.UserPrincipalName) does not have a membership number set"
                }
          $i ++
        }
        Write-dsLogMessage -message "Found $($aduserlist.count) Users with Membership numbers."
    }
    End
    {
        If($csv){
            $aduserlist | Export-Csv -Path $csvoutfile -NoTypeInformation
        } else {
            $aduserlist
        }
    }
}